"""赛事统计服务。

原始事实：
- Match：比赛时间、主客队、状态。
- MatchEvent：进球、点球、乌龙球、牌、换人。
- MatchAppearance：球员出场记录。

派生结果：
- MatchScoreView：由事件实时计算比分。
- Standing、PlayerStat：物化统计表，通过本模块全量重算。
"""

from __future__ import annotations

from typing import Any


def get_match_scope(conn: Any, match_id: int) -> tuple[int, int]:
    with conn.cursor() as cursor:
        cursor.execute(
            """
            SELECT season_id, tournament_id
            FROM `Match`
            WHERE match_id = %s
            """,
            (match_id,),
        )
        row = cursor.fetchone()

    if row is None:
        raise ValueError(f"比赛 {match_id} 不存在")

    return int(row["season_id"]), int(row["tournament_id"])


def get_match_score(conn: Any, match_id: int) -> dict[str, int]:
    with conn.cursor() as cursor:
        cursor.execute(
            """
            SELECT match_id, home_score, away_score
            FROM MatchScoreView
            WHERE match_id = %s
            """,
            (match_id,),
        )
        row = cursor.fetchone()

    if row is None:
        raise ValueError(f"比赛 {match_id} 不存在")

    return {
        "match_id": int(row["match_id"]),
        "home_score": int(row["home_score"]),
        "away_score": int(row["away_score"]),
    }


def _participant_team_ids(
    conn: Any,
    season_id: int,
    tournament_id: int,
) -> list[int]:
    """
    当前项目限定为单赛季、单赛事，因此 Team 表中的球队均视为参赛球队。
    这样尚未安排比赛的球队也会以0场0分出现在积分榜中。
    """
    del season_id, tournament_id
    with conn.cursor() as cursor:
        cursor.execute("SELECT team_id FROM Team ORDER BY team_id")
        rows = cursor.fetchall()

    return [int(row["team_id"]) for row in rows]


def recalculate_standings(
    conn: Any,
    season_id: int,
    tournament_id: int,
) -> int:
    """根据已结束比赛及 MatchScoreView 全量重算积分榜。"""
    team_ids = _participant_team_ids(conn, season_id, tournament_id)
    table: dict[int, dict[str, int]] = {
        team_id: {
            "played": 0,
            "win": 0,
            "draw": 0,
            "loss": 0,
            "goals_for": 0,
            "goals_against": 0,
            "points": 0,
        }
        for team_id in team_ids
    }

    with conn.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                m.home_team_id,
                m.away_team_id,
                s.home_score,
                s.away_score
            FROM `Match` AS m
            INNER JOIN MatchScoreView AS s ON s.match_id = m.match_id
            WHERE m.season_id = %s
              AND m.tournament_id = %s
              AND m.`status` = 'finished'
            ORDER BY m.match_id
            """,
            (season_id, tournament_id),
        )
        matches = cursor.fetchall()

    for match in matches:
        home_id = int(match["home_team_id"])
        away_id = int(match["away_team_id"])
        home_score = int(match["home_score"])
        away_score = int(match["away_score"])

        home = table[home_id]
        away = table[away_id]

        home["played"] += 1
        away["played"] += 1
        home["goals_for"] += home_score
        home["goals_against"] += away_score
        away["goals_for"] += away_score
        away["goals_against"] += home_score

        if home_score > away_score:
            home["win"] += 1
            home["points"] += 3
            away["loss"] += 1
        elif home_score < away_score:
            away["win"] += 1
            away["points"] += 3
            home["loss"] += 1
        else:
            home["draw"] += 1
            away["draw"] += 1
            home["points"] += 1
            away["points"] += 1

    rows = [
        (
            season_id,
            tournament_id,
            team_id,
            stats["played"],
            stats["win"],
            stats["draw"],
            stats["loss"],
            stats["goals_for"],
            stats["goals_against"],
            stats["points"],
        )
        for team_id, stats in table.items()
    ]

    with conn.cursor() as cursor:
        cursor.execute(
            """
            DELETE FROM Standing
            WHERE season_id = %s AND tournament_id = %s
            """,
            (season_id, tournament_id),
        )
        if rows:
            cursor.executemany(
                """
                INSERT INTO Standing (
                    season_id, tournament_id, team_id,
                    played, win, draw, loss,
                    goals_for, goals_against, points
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                rows,
            )

    return len(rows)


def recalculate_player_stats(
    conn: Any,
    season_id: int,
    tournament_id: int,
) -> int:
    """根据出场记录和比赛事件全量重算球员统计。"""
    team_ids = _participant_team_ids(conn, season_id, tournament_id)
    if not team_ids:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                DELETE FROM PlayerStat
                WHERE season_id = %s AND tournament_id = %s
                """,
                (season_id, tournament_id),
            )
        return 0

    placeholders = ", ".join(["%s"] * len(team_ids))

    with conn.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT player_id
            FROM Player
            WHERE team_id IN ({placeholders})
            ORDER BY player_id
            """,
            tuple(team_ids),
        )
        player_ids = [int(row["player_id"]) for row in cursor.fetchall()]

        cursor.execute(
            """
            SELECT
                ma.player_id,
                COUNT(*) AS appearances
            FROM MatchAppearance AS ma
            INNER JOIN `Match` AS m ON m.match_id = ma.match_id
            WHERE m.season_id = %s
              AND m.tournament_id = %s
              AND m.`status` = 'finished'
            GROUP BY ma.player_id
            """,
            (season_id, tournament_id),
        )
        appearance_map = {
            int(row["player_id"]): int(row["appearances"])
            for row in cursor.fetchall()
        }

        cursor.execute(
            """
            SELECT
                me.player_id,
                SUM(
                    CASE
                        WHEN me.event_type IN ('goal', 'penalty_goal') THEN 1
                        ELSE 0
                    END
                ) AS goals,
                SUM(
                    CASE
                        WHEN me.event_type = 'yellow_card' THEN 1
                        ELSE 0
                    END
                ) AS yellow_cards,
                SUM(
                    CASE
                        WHEN me.event_type = 'red_card' THEN 1
                        ELSE 0
                    END
                ) AS red_cards
            FROM MatchEvent AS me
            INNER JOIN `Match` AS m ON m.match_id = me.match_id
            WHERE m.season_id = %s
              AND m.tournament_id = %s
              AND m.`status` = 'finished'
            GROUP BY me.player_id
            """,
            (season_id, tournament_id),
        )
        actor_map = {
            int(row["player_id"]): {
                "goals": int(row["goals"] or 0),
                "yellow_cards": int(row["yellow_cards"] or 0),
                "red_cards": int(row["red_cards"] or 0),
            }
            for row in cursor.fetchall()
        }

        cursor.execute(
            """
            SELECT
                me.related_player_id AS player_id,
                COUNT(*) AS assists
            FROM MatchEvent AS me
            INNER JOIN `Match` AS m ON m.match_id = me.match_id
            WHERE m.season_id = %s
              AND m.tournament_id = %s
              AND m.`status` = 'finished'
              AND me.event_type IN ('goal', 'penalty_goal')
              AND me.related_player_id IS NOT NULL
            GROUP BY me.related_player_id
            """,
            (season_id, tournament_id),
        )
        assist_map = {
            int(row["player_id"]): int(row["assists"])
            for row in cursor.fetchall()
        }

    rows = []
    for player_id in player_ids:
        actor = actor_map.get(
            player_id,
            {"goals": 0, "yellow_cards": 0, "red_cards": 0},
        )
        rows.append(
            (
                season_id,
                tournament_id,
                player_id,
                appearance_map.get(player_id, 0),
                actor["goals"],
                assist_map.get(player_id, 0),
                actor["yellow_cards"],
                actor["red_cards"],
            )
        )

    with conn.cursor() as cursor:
        cursor.execute(
            """
            DELETE FROM PlayerStat
            WHERE season_id = %s AND tournament_id = %s
            """,
            (season_id, tournament_id),
        )
        if rows:
            cursor.executemany(
                """
                INSERT INTO PlayerStat (
                    season_id, tournament_id, player_id,
                    appearances, goals, assists,
                    yellow_cards, red_cards
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """,
                rows,
            )

    return len(rows)


def recalculate_all(
    conn: Any,
    season_id: int,
    tournament_id: int,
) -> dict[str, int]:
    standing_rows = recalculate_standings(conn, season_id, tournament_id)
    player_stat_rows = recalculate_player_stats(
        conn,
        season_id,
        tournament_id,
    )
    return {
        "standing_rows": standing_rows,
        "player_stat_rows": player_stat_rows,
    }
