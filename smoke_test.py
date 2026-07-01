from __future__ import annotations

import os
import sys

import pymysql


def main() -> None:
    conn = pymysql.connect(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "football_app"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "football_manager"),
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
    )
    try:
        checks = {
            "Season": 1,
            "Tournament": 1,
            "Team": 6,
            "Player": 66,
            "Match": 16,
            "MatchEvent": 62,
            "MatchAppearance": 330,
            "Standing": 6,
            "PlayerStat": 66,
        }
        with conn.cursor() as cursor:
            for table, expected in checks.items():
                cursor.execute(f"SELECT COUNT(*) AS n FROM `{table}`")
                actual = int(cursor.fetchone()["n"])
                print(f"{table}: {actual}")
                if actual != expected:
                    raise AssertionError(
                        f"{table}期望{expected}行，实际{actual}行"
                    )

            cursor.execute(
                """
                SELECT COUNT(*) AS n
                FROM `Match` AS m
                INNER JOIN MatchScoreView AS s ON s.match_id = m.match_id
                WHERE m.`status` = 'finished'
                """
            )
            assert int(cursor.fetchone()["n"]) == 15

            cursor.execute(
                """
                SELECT team_id, points
                FROM Standing
                ORDER BY points DESC, goals_for - goals_against DESC
                LIMIT 1
                """
            )
            leader = cursor.fetchone()
            print(f"榜首球队ID: {leader['team_id']}, 积分: {leader['points']}")

        print("数据库冒烟检查通过")
    finally:
        conn.close()


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"检查失败：{exc}", file=sys.stderr)
        raise
