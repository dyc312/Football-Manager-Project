from __future__ import annotations

import hmac
import os
from datetime import datetime
from functools import wraps
from pathlib import Path
from typing import Any, Callable, TypeVar

import pymysql
from flask import Flask, jsonify, request, session, redirect

from stat_service import get_match_scope, recalculate_all

BASE_DIR = Path(__file__).resolve().parent

app = Flask(
    __name__,
    static_folder=str(BASE_DIR / "frontend"),
    static_url_path="",
)

app.secret_key = os.environ.get("SECRET_KEY", "football-manager-dev-secret")

ALLOWED_MATCH_STATUS = {
    "scheduled",
    "live",
    "finished",
    "postponed",
    "cancelled",
}
ALLOWED_POSITIONS = {"Goalkeeper", "Defender", "Midfielder", "Forward"}
ALLOWED_EVENT_TYPES = {
    "goal",
    "penalty_goal",
    "own_goal",
    "yellow_card",
    "red_card",
    "substitution",
}
ADMIN_KEY = os.getenv("ADMIN_KEY", "")

F = TypeVar("F", bound=Callable[..., Any])


def get_db_connection(database: str | None = None):
    return pymysql.connect(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "football_app"),
        password=os.getenv("DB_PASSWORD", ""),
        database=database or os.getenv("DB_NAME", "football_manager"),
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False,
    )


def require_admin(func: F) -> F:
    @wraps(func)
    def wrapper(*args: Any, **kwargs: Any):
        supplied = request.headers.get("X-Admin-Key", "")
        session_ok = session.get("is_admin") is True
        key_ok = bool(ADMIN_KEY) and hmac.compare_digest(supplied, ADMIN_KEY)

        if not (session_ok or key_ok):
            return jsonify({"error": "未登录或管理员密钥无效"}), 401

        return func(*args, **kwargs)

    return wrapper  # type: ignore[return-value]


def json_body() -> dict[str, Any]:
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        raise ValueError("请求体必须是 JSON 对象")
    return data


def positive_int(value: Any, field: str) -> int:
    try:
        result = int(value)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"{field}必须是整数") from exc
    if result <= 0:
        raise ValueError(f"{field}必须大于0")
    return result


def nonnegative_int(value: Any, field: str) -> int:
    try:
        result = int(value)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"{field}必须是整数") from exc
    if result < 0:
        raise ValueError(f"{field}不能为负数")
    return result


def parse_datetime(value: Any) -> datetime:
    if not isinstance(value, str) or not value.strip():
        raise ValueError("match_date不能为空")
    normalized = value.strip().replace("T", " ")
    try:
        return datetime.fromisoformat(normalized)
    except ValueError as exc:
        raise ValueError("match_date格式应为 YYYY-MM-DD HH:MM") from exc


def handle_db_error(exc: Exception):
    if isinstance(exc, pymysql.err.IntegrityError):
        return jsonify({"error": f"数据库约束失败：{exc.args[1]}"}), 409
    return jsonify({"error": str(exc)}), 500


def row_exists(conn: Any, table: str, id_column: str, value: int) -> bool:
    allowed = {
        ("Season", "season_id"),
        ("Tournament", "tournament_id"),
        ("Team", "team_id"),
        ("Player", "player_id"),
    }
    if (table, id_column) not in allowed:
        raise ValueError("不允许的表或主键")
    with conn.cursor() as cursor:
        cursor.execute(
            f"SELECT 1 FROM `{table}` WHERE `{id_column}` = %s",
            (value,),
        )
        return cursor.fetchone() is not None


def fetch_match(conn: Any, match_id: int) -> dict[str, Any]:
    with conn.cursor() as cursor:
        cursor.execute(
            """
            SELECT *
            FROM MatchDetailView
            WHERE match_id = %s
            """,
            (match_id,),
        )
        row = cursor.fetchone()
    if row is None:
        raise ValueError(f"比赛 {match_id} 不存在")
    return row


def validate_match_teams(
    conn: Any,
    home_team_id: int,
    away_team_id: int,
) -> None:
    if home_team_id == away_team_id:
        raise ValueError("主队和客队不能相同")
    with conn.cursor() as cursor:
        cursor.execute(
            "SELECT COUNT(*) AS n FROM Team WHERE team_id IN (%s, %s)",
            (home_team_id, away_team_id),
        )
        if int(cursor.fetchone()["n"]) != 2:
            raise ValueError("主队或客队不存在")


def player_team(conn: Any, player_id: int) -> int:
    with conn.cursor() as cursor:
        cursor.execute(
            "SELECT team_id FROM Player WHERE player_id = %s",
            (player_id,),
        )
        row = cursor.fetchone()
    if row is None:
        raise ValueError(f"球员 {player_id} 不存在")
    return int(row["team_id"])


def validate_event(
    conn: Any,
    match_id: int,
    player_id: int,
    related_player_id: int | None,
    event_type: str,
) -> dict[str, Any]:
    match = fetch_match(conn, match_id)
    participants = {
        int(match["home_team_id"]),
        int(match["away_team_id"]),
    }
    actor_team = player_team(conn, player_id)
    if actor_team not in participants:
        raise ValueError("事件球员不属于本场比赛的参赛球队")

    related_team = None
    if related_player_id is not None:
        if related_player_id == player_id:
            raise ValueError("相关球员不能与主要球员相同")
        related_team = player_team(conn, related_player_id)
        if related_team not in participants:
            raise ValueError("相关球员不属于本场比赛的参赛球队")

    if event_type == "substitution":
        if related_player_id is None:
            raise ValueError("换人事件必须填写换上球员")
        if actor_team != related_team:
            raise ValueError("换下与换上球员必须属于同一支球队")
    elif event_type in {"goal", "penalty_goal"}:
        if related_player_id is not None and actor_team != related_team:
            raise ValueError("助攻球员必须与进球球员属于同一支球队")
    elif related_player_id is not None:
        raise ValueError("该事件类型不能填写相关球员")

    return match


def ensure_event_match_live(match: dict[str, Any]) -> None:
    """
    比赛事件只能在比赛状态为 live（进行中）时增删改。
    scheduled / finished / postponed / cancelled 状态下只能查看事件，不能修改事件。
    """
    if str(match.get("status", "")).strip() != "live":
        raise ValueError("只有比赛处于进行中状态时，才能新增、修改或删除比赛事件")


def recalc_scope(conn: Any, season_id: int, tournament_id: int):
    return recalculate_all(conn, season_id, tournament_id)



@app.get("/admin-login.html")
def admin_login_page():
    return app.send_static_file("admin-login.html")


@app.post("/api/admin/login")
def admin_login():
    data = request.get_json(silent=True) or {}
    admin_key = str(data.get("admin_key", "")).strip()

    if not ADMIN_KEY or not hmac.compare_digest(admin_key, ADMIN_KEY):
        return jsonify({"error": "管理员密钥错误"}), 401

    session["is_admin"] = True
    return jsonify({"message": "登录成功"})


@app.post("/api/admin/logout")
def admin_logout():
    session.clear()
    return jsonify({"message": "已退出后台"})


@app.get("/admin.html")
def admin_page():
    if session.get("is_admin") is not True:
        return redirect("/admin-login.html")

    return app.send_static_file("admin.html")


@app.route("/")
def index_page():
    return app.send_static_file("index.html")


@app.route("/team/<int:team_id>")
def team_page(team_id: int):
    return app.send_static_file("team_detail.html")


@app.route("/api/health")
def health():
    return jsonify(
        {
            "message": "Football Manager API is running",
            "database": os.getenv("DB_NAME", "football_manager"),
        }
    )


# -------------------- Season / Tournament --------------------

@app.get("/api/seasons")
def list_seasons():
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    season_id,
                    season_name,
                    DATE_FORMAT(start_date, '%Y-%m-%d') AS start_date,
                    DATE_FORMAT(end_date, '%Y-%m-%d') AS end_date
                FROM Season
                ORDER BY start_date DESC
                """
            )
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


@app.post("/api/seasons")
@require_admin
def create_season():
    conn = get_db_connection()
    try:
        data = json_body()
        season_name = str(data.get("season_name", "")).strip()
        start_date = data.get("start_date")
        end_date = data.get("end_date")
        if not season_name or not start_date or not end_date:
            raise ValueError("赛季名称、开始日期和结束日期不能为空")
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO Season (season_name, start_date, end_date)
                VALUES (%s, %s, %s)
                """,
                (season_name, start_date, end_date),
            )
            season_id = cursor.lastrowid
        conn.commit()
        return jsonify({"season_id": season_id}), 201
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.put("/api/seasons/<int:season_id>")
@require_admin
def update_season(season_id: int):
    conn = get_db_connection()
    try:
        data = json_body()
        with conn.cursor() as cursor:
            cursor.execute(
                """
                UPDATE Season
                SET season_name = %s, start_date = %s, end_date = %s
                WHERE season_id = %s
                """,
                (
                    str(data.get("season_name", "")).strip(),
                    data.get("start_date"),
                    data.get("end_date"),
                    season_id,
                ),
            )
            if cursor.rowcount == 0 and not row_exists(
                conn, "Season", "season_id", season_id
            ):
                raise ValueError("赛季不存在")
        conn.commit()
        return jsonify({"message": "赛季已更新"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 404
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.delete("/api/seasons/<int:season_id>")
@require_admin
def delete_season(season_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "DELETE FROM Season WHERE season_id = %s",
                (season_id,),
            )
            if cursor.rowcount == 0 and not row_exists(
                conn, "Season", "season_id", season_id
            ):
                raise ValueError("赛季不存在")
        conn.commit()
        return jsonify({"message": "赛季已删除"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 404
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.get("/api/tournaments")
def list_tournaments():
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM Tournament ORDER BY tournament_name")
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


@app.post("/api/tournaments")
@require_admin
def create_tournament():
    conn = get_db_connection()
    try:
        data = json_body()
        tournament_name = str(data.get("tournament_name", "")).strip()
        organizer = str(data.get("organizer", "")).strip()
        if not tournament_name or not organizer:
            raise ValueError("赛事名称和组织方不能为空")
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO Tournament (tournament_name, organizer)
                VALUES (%s, %s)
                """,
                (tournament_name, organizer),
            )
            tournament_id = cursor.lastrowid
        conn.commit()
        return jsonify({"tournament_id": tournament_id}), 201
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.put("/api/tournaments/<int:tournament_id>")
@require_admin
def update_tournament(tournament_id: int):
    conn = get_db_connection()
    try:
        data = json_body()
        with conn.cursor() as cursor:
            cursor.execute(
                """
                UPDATE Tournament
                SET tournament_name = %s, organizer = %s
                WHERE tournament_id = %s
                """,
                (
                    str(data.get("tournament_name", "")).strip(),
                    str(data.get("organizer", "")).strip(),
                    tournament_id,
                ),
            )
            if cursor.rowcount == 0 and not row_exists(
                conn, "Tournament", "tournament_id", tournament_id
            ):
                raise ValueError("赛事不存在")
        conn.commit()
        return jsonify({"message": "赛事已更新"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 404
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.delete("/api/tournaments/<int:tournament_id>")
@require_admin
def delete_tournament(tournament_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "DELETE FROM Tournament WHERE tournament_id = %s",
                (tournament_id,),
            )
            if cursor.rowcount == 0 and not row_exists(
                conn, "Tournament", "tournament_id", tournament_id
            ):
                raise ValueError("赛事不存在")
        conn.commit()
        return jsonify({"message": "赛事已删除"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 404
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


# -------------------- Teams --------------------

@app.get("/api/teams")
def list_teams():
    q = request.args.get("q", "").strip()
    conn = get_db_connection()
    try:
        sql = """
            SELECT team_id, team_name, city, coach_name
            FROM Team
            WHERE (%s = '' OR team_name LIKE %s OR city LIKE %s)
            ORDER BY team_name
        """
        like = f"%{q}%"
        with conn.cursor() as cursor:
            cursor.execute(sql, (q, like, like))
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


@app.get("/api/teams/<int:team_id>")
def get_team(team_id: int):
    season_id = request.args.get(
        "season_id",
        default=1,
        type=int,
    )
    tournament_id = request.args.get(
        "tournament_id",
        default=1,
        type=int,
    )

    conn = get_db_connection()

    try:
        with conn.cursor() as cursor:
            # 查询球队基本信息
            cursor.execute(
                """
                SELECT
                    team_id,
                    team_name,
                    city,
                    coach_name
                FROM Team
                WHERE team_id = %s
                """,
                (team_id,),
            )
            team = cursor.fetchone()

            if team is None:
                return jsonify({"error": "球队不存在"}), 404

            # 查询该球队的积分数据
            cursor.execute(
                """
                SELECT
                    s.team_id,
                    s.played,
                    s.win,
                    s.draw,
                    s.loss,
                    s.goals_for,
                    s.goals_against,
                    CAST(s.goals_for AS SIGNED) - CAST(s.goals_against AS SIGNED) AS goal_diff,
                    s.points
                FROM Standing AS s
                WHERE s.season_id = %s
                  AND s.tournament_id = %s
                  AND s.team_id = %s
                """,
                (
                    season_id,
                    tournament_id,
                    team_id,
                ),
            )
            standing = cursor.fetchone()

            # 按积分榜规则获取完整排序
            cursor.execute(
                """
                SELECT s.team_id
                FROM Standing AS s
                INNER JOIN Team AS t
                    ON t.team_id = s.team_id
                WHERE s.season_id = %s
                  AND s.tournament_id = %s
                ORDER BY
                    s.points DESC,
                    (CAST(s.goals_for AS SIGNED) - CAST(s.goals_against AS SIGNED)) DESC,
                    s.goals_for DESC,
                    t.team_name ASC
                """,
                (
                    season_id,
                    tournament_id,
                ),
            )
            ranked_teams = cursor.fetchall()

        if standing is not None:
            rank_map = {
                int(row["team_id"]): rank
                for rank, row in enumerate(
                    ranked_teams,
                    start=1,
                )
            }
            standing["rank_no"] = rank_map.get(team_id)

        return jsonify(
            {
                "team": team,
                "standing": standing,
            }
        )

    except Exception as exc:
        return handle_db_error(exc)

    finally:
        conn.close()


@app.post("/api/teams")
@require_admin
def create_team():
    conn = get_db_connection()
    try:
        data = json_body()
        values = (
            str(data.get("team_name", "")).strip(),
            str(data.get("city", "")).strip(),
            str(data.get("coach_name", "")).strip(),
        )
        if not all(values):
            raise ValueError("球队名称、城市和教练不能为空")
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO Team (team_name, city, coach_name)
                VALUES (%s, %s, %s)
                """,
                values,
            )
            team_id = cursor.lastrowid
        recalc_scope(conn, 1, 1)
        conn.commit()
        return jsonify({"team_id": team_id}), 201
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.put("/api/teams/<int:team_id>")
@require_admin
def update_team(team_id: int):
    conn = get_db_connection()
    try:
        data = json_body()
        values = (
            str(data.get("team_name", "")).strip(),
            str(data.get("city", "")).strip(),
            str(data.get("coach_name", "")).strip(),
        )
        if not all(values):
            raise ValueError("球队名称、城市和教练不能为空")
        with conn.cursor() as cursor:
            cursor.execute(
                """
                UPDATE Team
                SET team_name = %s, city = %s, coach_name = %s
                WHERE team_id = %s
                """,
                (*values, team_id),
            )
            if cursor.rowcount == 0 and not row_exists(
                conn, "Team", "team_id", team_id
            ):
                raise ValueError("球队不存在")
        conn.commit()
        return jsonify({"message": "球队已更新"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.delete("/api/teams/<int:team_id>")
@require_admin
def delete_team(team_id):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # 1. 先确认球队存在
            cursor.execute(
                """
                SELECT team_id, team_name
                FROM Team
                WHERE team_id = %s
                """,
                (team_id,),
            )
            team = cursor.fetchone()

            if team is None:
                return jsonify({"error": "球队不存在"}), 404

            # 2. 如果球队已经出现在比赛里，不允许直接删除
            cursor.execute(
                """
                SELECT COUNT(*) AS cnt
                FROM `Match`
                WHERE home_team_id = %s OR away_team_id = %s
                """,
                (team_id, team_id),
            )
            match_count = int(cursor.fetchone()["cnt"])

            if match_count > 0:
                return jsonify({
                    "error": "该球队已有比赛记录，不能直接删除。请先删除相关比赛，或保留该球队。"
                }), 400

            # 3. 找到该球队下的球员
            cursor.execute(
                """
                SELECT player_id
                FROM Player
                WHERE team_id = %s
                """,
                (team_id,),
            )
            player_ids = [int(row["player_id"]) for row in cursor.fetchall()]

            # 4. 如果这些球员已经有事件或出场记录，不允许直接删除
            if player_ids:
                placeholders = ", ".join(["%s"] * len(player_ids))

                cursor.execute(
                    f"""
                    SELECT COUNT(*) AS cnt
                    FROM MatchEvent
                    WHERE player_id IN ({placeholders})
                       OR related_player_id IN ({placeholders})
                    """,
                    tuple(player_ids) + tuple(player_ids),
                )
                event_count = int(cursor.fetchone()["cnt"])

                cursor.execute(
                    f"""
                    SELECT COUNT(*) AS cnt
                    FROM MatchAppearance
                    WHERE player_id IN ({placeholders})
                    """,
                    tuple(player_ids),
                )
                appearance_count = int(cursor.fetchone()["cnt"])

                if event_count > 0 or appearance_count > 0:
                    return jsonify({
                        "error": "该球队的球员已有比赛事件或出场记录，不能直接删除。"
                    }), 400

                # 删除球员统计
                cursor.execute(
                    f"""
                    DELETE FROM PlayerStat
                    WHERE player_id IN ({placeholders})
                    """,
                    tuple(player_ids),
                )

                # 删除球员
                cursor.execute(
                    """
                    DELETE FROM Player
                    WHERE team_id = %s
                    """,
                    (team_id,),
                )

            # 删除积分榜记录
            cursor.execute(
                """
                DELETE FROM Standing
                WHERE team_id = %s
                """,
                (team_id,),
            )

            # 最后删除球队
            cursor.execute(
                """
                DELETE FROM Team
                WHERE team_id = %s
                """,
                (team_id,),
            )

        conn.commit()
        return jsonify({
            "message": f"球队 {team['team_name']} 已删除"
        })

    except Exception as exc:
        conn.rollback()
        return jsonify({"error": f"删除球队失败：{exc}"}), 400

    finally:
        conn.close()

@app.get("/api/teams/<int:team_id>/players")
def team_players(team_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT player_id, team_id, player_name, number, `position`
                FROM Player
                WHERE team_id = %s
                ORDER BY
                    FIELD(`position`, 'Goalkeeper', 'Defender', 'Midfielder', 'Forward'),
                    number
                """,
                (team_id,),
            )
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


@app.get("/api/teams/<int:team_id>/matches")
def team_matches(team_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT *
                FROM MatchDetailView
                WHERE home_team_id = %s OR away_team_id = %s
                ORDER BY match_date
                """,
                (team_id, team_id),
            )
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


# -------------------- Players --------------------

@app.get("/api/players")
def list_players():
    team_id = request.args.get("team_id", type=int)
    q = request.args.get("q", "").strip()
    number = request.args.get("number", type=int)
    position = request.args.get("position", "").strip()

    clauses = ["1=1"]
    params: list[Any] = []
    if team_id is not None:
        clauses.append("p.team_id = %s")
        params.append(team_id)
    if q:
        clauses.append("p.player_name LIKE %s")
        params.append(f"%{q}%")
    if number is not None:
        clauses.append("p.number = %s")
        params.append(number)
    if position:
        clauses.append("p.`position` = %s")
        params.append(position)

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                f"""
                SELECT
                    p.player_id,
                    p.team_id,
                    t.team_name,
                    p.player_name,
                    p.number,
                    p.`position`
                FROM Player AS p
                INNER JOIN Team AS t ON t.team_id = p.team_id
                WHERE {' AND '.join(clauses)}
                ORDER BY t.team_name, p.number
                """,
                tuple(params),
            )
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


@app.post("/api/players")
@require_admin
def create_player():
    conn = get_db_connection()
    try:
        data = json_body()
        team_id = positive_int(data.get("team_id"), "team_id")
        number = positive_int(data.get("number"), "number")
        name = str(data.get("player_name", "")).strip()
        position = str(data.get("position", "")).strip()
        if not name:
            raise ValueError("球员姓名不能为空")
        if position not in ALLOWED_POSITIONS:
            raise ValueError("球员位置不合法")
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO Player (team_id, player_name, number, `position`)
                VALUES (%s, %s, %s, %s)
                """,
                (team_id, name, number, position),
            )
            player_id = cursor.lastrowid
        recalc_scope(conn, 1, 1)
        conn.commit()
        return jsonify({"player_id": player_id}), 201
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.put("/api/players/<int:player_id>")
@require_admin
def update_player(player_id: int):
    conn = get_db_connection()
    try:
        data = json_body()
        team_id = positive_int(data.get("team_id"), "team_id")
        number = positive_int(data.get("number"), "number")
        name = str(data.get("player_name", "")).strip()
        position = str(data.get("position", "")).strip()
        if not name or position not in ALLOWED_POSITIONS:
            raise ValueError("球员信息不完整或位置不合法")

        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT team_id FROM Player WHERE player_id = %s",
                (player_id,),
            )
            current = cursor.fetchone()
            if current is None:
                raise ValueError("球员不存在")
            if int(current["team_id"]) != team_id:
                cursor.execute(
                    """
                    SELECT
                        (SELECT COUNT(*) FROM MatchEvent
                         WHERE player_id = %s OR related_player_id = %s)
                        +
                        (SELECT COUNT(*) FROM MatchAppearance
                         WHERE player_id = %s) AS n
                    """,
                    (player_id, player_id, player_id),
                )
                if int(cursor.fetchone()["n"]) > 0:
                    raise ValueError(
                        "球员已有比赛历史，不能直接更换球队"
                    )

        with conn.cursor() as cursor:
            cursor.execute(
                """
                UPDATE Player
                SET team_id = %s, player_name = %s,
                    number = %s, `position` = %s
                WHERE player_id = %s
                """,
                (team_id, name, number, position, player_id),
            )
            if cursor.rowcount == 0 and not row_exists(
                conn, "Player", "player_id", player_id
            ):
                raise ValueError("球员不存在")
        recalc_scope(conn, 1, 1)
        conn.commit()
        return jsonify({"message": "球员已更新"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.delete("/api/players/<int:player_id>")
@require_admin
def delete_player(player_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "DELETE FROM Player WHERE player_id = %s",
                (player_id,),
            )
            if cursor.rowcount == 0 and not row_exists(
                conn, "Player", "player_id", player_id
            ):
                raise ValueError("球员不存在")
        recalc_scope(conn, 1, 1)
        conn.commit()
        return jsonify({"message": "球员已删除"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 404
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


# -------------------- Matches --------------------

@app.get("/api/matches")
def list_matches():
    round_no = request.args.get("round_no", type=int)
    team_id = request.args.get("team_id", type=int)
    status = request.args.get("status", "").strip()

    clauses = ["1=1"]
    params: list[Any] = []
    if round_no is not None:
        clauses.append("round_no = %s")
        params.append(round_no)
    if team_id is not None:
        clauses.append("(home_team_id = %s OR away_team_id = %s)")
        params.extend([team_id, team_id])
    if status:
        clauses.append("`status` = %s")
        params.append(status)

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                f"""
                SELECT *
                FROM MatchDetailView
                WHERE {' AND '.join(clauses)}
                ORDER BY round_no, match_date, match_id
                """,
                tuple(params),
            )
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


@app.get("/api/matches/<int:match_id>")
def get_match(match_id: int):
    conn = get_db_connection()
    try:
        try:
            return jsonify(fetch_match(conn, match_id))
        except ValueError as exc:
            return jsonify({"error": str(exc)}), 404
    finally:
        conn.close()


@app.post("/api/matches")
@require_admin
def create_match():
    conn = get_db_connection()
    try:
        data = json_body()
        season_id = positive_int(data.get("season_id", 1), "season_id")
        tournament_id = positive_int(
            data.get("tournament_id", 1),
            "tournament_id",
        )
        home_team_id = positive_int(data.get("home_team_id"), "home_team_id")
        away_team_id = positive_int(data.get("away_team_id"), "away_team_id")
        round_no = positive_int(data.get("round_no"), "round_no")
        match_date = parse_datetime(data.get("match_date"))
        status = str(data.get("status", "scheduled")).strip()
        if status not in ALLOWED_MATCH_STATUS:
            raise ValueError("比赛状态不合法")
        validate_match_teams(conn, home_team_id, away_team_id)

        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO `Match` (
                    season_id, tournament_id,
                    home_team_id, away_team_id,
                    round_no, match_date, `status`
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    season_id,
                    tournament_id,
                    home_team_id,
                    away_team_id,
                    round_no,
                    match_date,
                    status,
                ),
            )
            match_id = cursor.lastrowid
        recalc_scope(conn, season_id, tournament_id)
        conn.commit()
        return jsonify({"match_id": match_id}), 201
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.put("/api/matches/<int:match_id>")
@require_admin
def update_match(match_id: int):
    conn = get_db_connection()
    try:
        data = json_body()
        current = fetch_match(conn, match_id)
        season_id = positive_int(
            data.get("season_id", current["season_id"]),
            "season_id",
        )
        tournament_id = positive_int(
            data.get("tournament_id", current["tournament_id"]),
            "tournament_id",
        )
        home_team_id = positive_int(
            data.get("home_team_id", current["home_team_id"]),
            "home_team_id",
        )
        away_team_id = positive_int(
            data.get("away_team_id", current["away_team_id"]),
            "away_team_id",
        )
        round_no = positive_int(
            data.get("round_no", current["round_no"]),
            "round_no",
        )
        match_date = parse_datetime(
            data.get("match_date", current["match_date"].isoformat(sep=" ")),
        )
        status = str(data.get("status", current["status"])).strip()
        if status not in ALLOWED_MATCH_STATUS:
            raise ValueError("比赛状态不合法")
        validate_match_teams(conn, home_team_id, away_team_id)

        if (
            home_team_id != int(current["home_team_id"])
            or away_team_id != int(current["away_team_id"])
        ):
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT
                        (SELECT COUNT(*) FROM MatchEvent WHERE match_id = %s)
                        +
                        (SELECT COUNT(*) FROM MatchAppearance WHERE match_id = %s)
                        AS n
                    """,
                    (match_id, match_id),
                )
                if int(cursor.fetchone()["n"]) > 0:
                    raise ValueError("已有事件或出场记录时不能更换主客队")

        old_scope = (
            int(current["season_id"]),
            int(current["tournament_id"]),
        )
        with conn.cursor() as cursor:
            cursor.execute(
                """
                UPDATE `Match`
                SET season_id = %s,
                    tournament_id = %s,
                    home_team_id = %s,
                    away_team_id = %s,
                    round_no = %s,
                    match_date = %s,
                    `status` = %s
                WHERE match_id = %s
                """,
                (
                    season_id,
                    tournament_id,
                    home_team_id,
                    away_team_id,
                    round_no,
                    match_date,
                    status,
                    match_id,
                ),
            )

        recalc_scope(conn, season_id, tournament_id)
        if old_scope != (season_id, tournament_id):
            recalc_scope(conn, *old_scope)
        conn.commit()
        return jsonify({"message": "比赛已更新，统计已刷新"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.delete("/api/matches/<int:match_id>")
@require_admin
def delete_match(match_id: int):
    conn = get_db_connection()
    try:
        season_id, tournament_id = get_match_scope(conn, match_id)
        with conn.cursor() as cursor:
            cursor.execute(
                "DELETE FROM `Match` WHERE match_id = %s",
                (match_id,),
            )
        recalc_scope(conn, season_id, tournament_id)
        conn.commit()
        return jsonify({"message": "比赛及其事件、出场记录已删除"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 404
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


# -------------------- Events --------------------

@app.get("/api/matches/<int:match_id>/events")
def list_match_events(match_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    me.event_id,
                    me.match_id,
                    me.player_id,
                    p.player_name,
                    p.team_id,
                    t.team_name,
                    me.related_player_id,
                    rp.player_name AS related_player_name,
                    me.minute,
                    me.stoppage_minute,
                    me.event_type
                FROM MatchEvent AS me
                INNER JOIN Player AS p ON p.player_id = me.player_id
                INNER JOIN Team AS t ON t.team_id = p.team_id
                LEFT JOIN Player AS rp
                    ON rp.player_id = me.related_player_id
                WHERE me.match_id = %s
                ORDER BY me.minute, me.stoppage_minute, me.event_id
                """,
                (match_id,),
            )
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


@app.post("/api/matches/<int:match_id>/events")
@require_admin
def create_event(match_id: int):
    conn = get_db_connection()
    try:
        data = json_body()
        player_id = positive_int(data.get("player_id"), "player_id")
        raw_related = data.get("related_player_id")
        related_player_id = (
            None
            if raw_related in (None, "", 0, "0")
            else positive_int(raw_related, "related_player_id")
        )
        minute = nonnegative_int(data.get("minute"), "minute")
        stoppage = nonnegative_int(
            data.get("stoppage_minute", 0),
            "stoppage_minute",
        )
        event_type = str(data.get("event_type", "")).strip()
        if event_type not in ALLOWED_EVENT_TYPES:
            raise ValueError("事件类型不合法")
        if minute > 130 or stoppage > 20:
            raise ValueError("事件时间超出合理范围")

        match = validate_event(
            conn,
            match_id,
            player_id,
            related_player_id,
            event_type,
        )
        ensure_event_match_live(match)

        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO MatchEvent (
                    match_id, player_id, related_player_id,
                    minute, stoppage_minute, event_type
                )
                VALUES (%s, %s, %s, %s, %s, %s)
                """,
                (
                    match_id,
                    player_id,
                    related_player_id,
                    minute,
                    stoppage,
                    event_type,
                ),
            )
            event_id = cursor.lastrowid
        result = recalc_scope(
            conn,
            int(match["season_id"]),
            int(match["tournament_id"]),
        )
        conn.commit()
        return jsonify(
            {
                "event_id": event_id,
                "message": "事件已录入，比分和统计已自动刷新",
                **result,
            }
        ), 201
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.put("/api/events/<int:event_id>")
@require_admin
def update_event(event_id: int):
    conn = get_db_connection()
    try:
        data = json_body()
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT * FROM MatchEvent WHERE event_id = %s",
                (event_id,),
            )
            old = cursor.fetchone()
        if old is None:
            return jsonify({"error": "事件不存在"}), 404

        match_id = int(old["match_id"])
        player_id = positive_int(
            data.get("player_id", old["player_id"]),
            "player_id",
        )
        raw_related = data.get(
            "related_player_id",
            old["related_player_id"],
        )
        related_player_id = (
            None
            if raw_related in (None, "", 0, "0")
            else positive_int(raw_related, "related_player_id")
        )
        minute = nonnegative_int(data.get("minute", old["minute"]), "minute")
        stoppage = nonnegative_int(
            data.get("stoppage_minute", old["stoppage_minute"]),
            "stoppage_minute",
        )
        event_type = str(data.get("event_type", old["event_type"])).strip()
        if event_type not in ALLOWED_EVENT_TYPES:
            raise ValueError("事件类型不合法")

        match = validate_event(
            conn,
            match_id,
            player_id,
            related_player_id,
            event_type,
        )
        ensure_event_match_live(match)

        with conn.cursor() as cursor:
            cursor.execute(
                """
                UPDATE MatchEvent
                SET player_id = %s,
                    related_player_id = %s,
                    minute = %s,
                    stoppage_minute = %s,
                    event_type = %s
                WHERE event_id = %s
                """,
                (
                    player_id,
                    related_player_id,
                    minute,
                    stoppage,
                    event_type,
                    event_id,
                ),
            )
        recalc_scope(
            conn,
            int(match["season_id"]),
            int(match["tournament_id"]),
        )
        conn.commit()
        return jsonify({"message": "事件已更新，比分和统计已刷新"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.delete("/api/events/<int:event_id>")
@require_admin
def delete_event(event_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT m.season_id, m.tournament_id, m.`status`
                FROM MatchEvent AS me
                INNER JOIN `Match` AS m ON m.match_id = me.match_id
                WHERE me.event_id = %s
                """,
                (event_id,),
            )
            scope = cursor.fetchone()
            if scope is None:
                return jsonify({"error": "事件不存在"}), 404

            if str(scope.get("status", "")).strip() != "live":
                return jsonify({"error": "只有比赛处于进行中状态时，才能新增、修改或删除比赛事件"}), 400

            cursor.execute(
                "DELETE FROM MatchEvent WHERE event_id = %s",
                (event_id,),
            )
        recalc_scope(
            conn,
            int(scope["season_id"]),
            int(scope["tournament_id"]),
        )
        conn.commit()
        return jsonify({"message": "事件已删除，比分和统计已刷新"})
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


# -------------------- Appearances --------------------

@app.get("/api/matches/<int:match_id>/appearances")
def list_appearances(match_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    ma.appearance_id,
                    ma.match_id,
                    ma.player_id,
                    p.player_name,
                    p.team_id,
                    t.team_name,
                    ma.is_starting,
                    ma.minute_on,
                    ma.minute_off
                FROM MatchAppearance AS ma
                INNER JOIN Player AS p ON p.player_id = ma.player_id
                INNER JOIN Team AS t ON t.team_id = p.team_id
                WHERE ma.match_id = %s
                ORDER BY t.team_name, ma.is_starting DESC, p.number
                """,
                (match_id,),
            )
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


@app.post("/api/matches/<int:match_id>/appearances")
@require_admin
def create_appearance(match_id: int):
    conn = get_db_connection()
    try:
        data = json_body()
        player_id = positive_int(data.get("player_id"), "player_id")
        minute_on = nonnegative_int(data.get("minute_on", 0), "minute_on")
        minute_off = nonnegative_int(data.get("minute_off", 90), "minute_off")
        is_starting = bool(data.get("is_starting", True))
        if minute_on > minute_off or minute_off > 130:
            raise ValueError("出场时间不合法")

        match = fetch_match(conn, match_id)
        if player_team(conn, player_id) not in {
            int(match["home_team_id"]),
            int(match["away_team_id"]),
        }:
            raise ValueError("球员不属于本场参赛球队")

        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO MatchAppearance (
                    match_id, player_id, is_starting,
                    minute_on, minute_off
                )
                VALUES (%s, %s, %s, %s, %s)
                """,
                (
                    match_id,
                    player_id,
                    is_starting,
                    minute_on,
                    minute_off,
                ),
            )
            appearance_id = cursor.lastrowid
        recalc_scope(
            conn,
            int(match["season_id"]),
            int(match["tournament_id"]),
        )
        conn.commit()
        return jsonify({"appearance_id": appearance_id}), 201
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.put("/api/appearances/<int:appearance_id>")
@require_admin
def update_appearance(appearance_id: int):
    conn = get_db_connection()
    try:
        data = json_body()
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT ma.*, m.season_id, m.tournament_id
                FROM MatchAppearance AS ma
                INNER JOIN `Match` AS m ON m.match_id = ma.match_id
                WHERE ma.appearance_id = %s
                """,
                (appearance_id,),
            )
            old = cursor.fetchone()
        if old is None:
            return jsonify({"error": "出场记录不存在"}), 404

        minute_on = nonnegative_int(
            data.get("minute_on", old["minute_on"]),
            "minute_on",
        )
        minute_off = nonnegative_int(
            data.get("minute_off", old["minute_off"]),
            "minute_off",
        )
        is_starting = bool(data.get("is_starting", old["is_starting"]))
        if minute_on > minute_off or minute_off > 130:
            raise ValueError("出场时间不合法")

        with conn.cursor() as cursor:
            cursor.execute(
                """
                UPDATE MatchAppearance
                SET is_starting = %s, minute_on = %s, minute_off = %s
                WHERE appearance_id = %s
                """,
                (is_starting, minute_on, minute_off, appearance_id),
            )
        recalc_scope(
            conn,
            int(old["season_id"]),
            int(old["tournament_id"]),
        )
        conn.commit()
        return jsonify({"message": "出场记录已更新"})
    except ValueError as exc:
        conn.rollback()
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


@app.delete("/api/appearances/<int:appearance_id>")
@require_admin
def delete_appearance(appearance_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT m.season_id, m.tournament_id
                FROM MatchAppearance AS ma
                INNER JOIN `Match` AS m ON m.match_id = ma.match_id
                WHERE ma.appearance_id = %s
                """,
                (appearance_id,),
            )
            scope = cursor.fetchone()
            if scope is None:
                return jsonify({"error": "出场记录不存在"}), 404
            cursor.execute(
                "DELETE FROM MatchAppearance WHERE appearance_id = %s",
                (appearance_id,),
            )
        recalc_scope(
            conn,
            int(scope["season_id"]),
            int(scope["tournament_id"]),
        )
        conn.commit()
        return jsonify({"message": "出场记录已删除"})
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


# -------------------- Statistics --------------------

@app.get("/api/standings")
def standings():
    season_id = request.args.get("season_id", 1, type=int)
    tournament_id = request.args.get("tournament_id", 1, type=int)
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    s.team_id,
                    t.team_name,
                    s.played,
                    s.win,
                    s.draw,
                    s.loss,
                    s.goals_for,
                    s.goals_against,
                    CAST(s.goals_for AS SIGNED) - CAST(s.goals_against AS SIGNED) AS goal_diff,
                    s.points
                FROM Standing AS s
                INNER JOIN Team AS t ON t.team_id = s.team_id
                WHERE s.season_id = %s AND s.tournament_id = %s
                ORDER BY
                    s.points DESC,
                    goal_diff DESC,
                    s.goals_for DESC,
                    t.team_name ASC
                """,
                (season_id, tournament_id),
            )
            rows = cursor.fetchall()
        for rank, row in enumerate(rows, 1):
            row["rank_no"] = rank
        return jsonify(rows)
    finally:
        conn.close()


@app.get("/api/player-stats")
def player_stats():
    season_id = request.args.get("season_id", 1, type=int)
    tournament_id = request.args.get("tournament_id", 1, type=int)
    team_id = request.args.get("team_id", type=int)
    q = request.args.get("q", "").strip()

    clauses = [
        "ps.season_id = %s",
        "ps.tournament_id = %s",
    ]
    params: list[Any] = [season_id, tournament_id]
    if team_id is not None:
        clauses.append("p.team_id = %s")
        params.append(team_id)
    if q:
        clauses.append("p.player_name LIKE %s")
        params.append(f"%{q}%")

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                f"""
                SELECT
                    ps.player_id,
                    p.player_name,
                    p.number,
                    p.`position`,
                    p.team_id,
                    t.team_name,
                    ps.appearances,
                    ps.goals,
                    ps.assists,
                    ps.yellow_cards,
                    ps.red_cards
                FROM PlayerStat AS ps
                INNER JOIN Player AS p ON p.player_id = ps.player_id
                INNER JOIN Team AS t ON t.team_id = p.team_id
                WHERE {' AND '.join(clauses)}
                ORDER BY
                    ps.goals DESC,
                    ps.assists DESC,
                    ps.appearances ASC,
                    p.player_name
                """,
                tuple(params),
            )
            rows = cursor.fetchall()
        for rank, row in enumerate(rows, 1):
            row["rank_no"] = rank
        return jsonify(rows)
    finally:
        conn.close()


@app.get("/api/scorers")
def scorers():
    season_id = request.args.get("season_id", 1, type=int)
    tournament_id = request.args.get("tournament_id", 1, type=int)
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    ps.player_id,
                    p.player_name,
                    t.team_name,
                    ps.appearances,
                    ps.goals,
                    ps.assists,
                    ps.yellow_cards,
                    ps.red_cards
                FROM PlayerStat AS ps
                INNER JOIN Player AS p ON p.player_id = ps.player_id
                INNER JOIN Team AS t ON t.team_id = p.team_id
                WHERE ps.season_id = %s
                  AND ps.tournament_id = %s
                  AND ps.goals > 0
                ORDER BY
                    ps.goals DESC,
                    ps.assists DESC,
                    ps.appearances ASC,
                    p.player_name
                """,
                (season_id, tournament_id),
            )
            rows = cursor.fetchall()
        for rank, row in enumerate(rows, 1):
            row["rank_no"] = rank
        return jsonify(rows)
    finally:
        conn.close()


@app.post("/api/admin/recalculate")
@require_admin
def admin_recalculate():
    conn = get_db_connection()
    try:
        data = request.get_json(silent=True) or {}
        season_id = positive_int(data.get("season_id", 1), "season_id")
        tournament_id = positive_int(
            data.get("tournament_id", 1),
            "tournament_id",
        )
        result = recalculate_all(conn, season_id, tournament_id)
        conn.commit()
        return jsonify(
            {
                "message": "积分榜和球员统计已全部刷新",
                **result,
            }
        )
    except Exception as exc:
        conn.rollback()
        return handle_db_error(exc)
    finally:
        conn.close()


if __name__ == "__main__":
    if not os.getenv("DB_PASSWORD"):
        raise SystemExit("请先设置 DB_PASSWORD")
    if not ADMIN_KEY:
        raise SystemExit("请先设置 ADMIN_KEY")
    app.run(
        host="127.0.0.1",
        port=int(os.getenv("PORT", "5000")),
        debug=False,
        use_reloader=False,
    )
