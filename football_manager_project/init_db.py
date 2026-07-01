from __future__ import annotations

import os
import re
from pathlib import Path
from typing import Iterable

import pymysql

from stat_service import recalculate_all

BASE_DIR = Path(__file__).resolve().parent
DB_NAME = os.getenv("DB_NAME", "football_manager")
ADMIN_USER = os.getenv("DB_ADMIN_USER", "root")
ADMIN_PASSWORD = os.getenv("DB_ADMIN_PASSWORD", os.getenv("DB_PASSWORD", ""))
APP_USER = os.getenv("DB_APP_USER", "football_app")
APP_PASSWORD = os.getenv("DB_APP_PASSWORD", "")


def split_sql(script: str) -> Iterable[str]:
    """按分号切分 SQL，同时忽略字符串和注释中的分号。"""
    buffer: list[str] = []
    in_single = False
    in_double = False
    in_line_comment = False
    in_block_comment = False
    escape = False
    i = 0

    while i < len(script):
        ch = script[i]
        nxt = script[i + 1] if i + 1 < len(script) else ""

        if in_line_comment:
            if ch == "\n":
                in_line_comment = False
                buffer.append(ch)
            i += 1
            continue

        if in_block_comment:
            if ch == "*" and nxt == "/":
                in_block_comment = False
                i += 2
            else:
                i += 1
            continue

        if not in_single and not in_double:
            if ch == "-" and nxt == "-":
                in_line_comment = True
                i += 2
                continue
            if ch == "#":
                in_line_comment = True
                i += 1
                continue
            if ch == "/" and nxt == "*":
                in_block_comment = True
                i += 2
                continue

        if ch == "'" and not in_double and not escape:
            in_single = not in_single
        elif ch == '"' and not in_single and not escape:
            in_double = not in_double

        if ch == ";" and not in_single and not in_double:
            statement = "".join(buffer).strip()
            if statement:
                yield statement
            buffer = []
        else:
            buffer.append(ch)

        escape = ch == "\\" and not escape
        if ch != "\\":
            escape = False
        i += 1

    statement = "".join(buffer).strip()
    if statement:
        yield statement


def execute_script(conn, path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    with conn.cursor() as cursor:
        for statement in split_sql(text):
            cursor.execute(statement)


def valid_identifier(value: str, field: str) -> str:
    if not re.fullmatch(r"[A-Za-z0-9_]+", value):
        raise ValueError(f"{field}只能包含字母、数字和下划线")
    return value


def main() -> None:
    if not ADMIN_PASSWORD:
        raise SystemExit(
            "请先设置 DB_ADMIN_PASSWORD（MySQL root 或管理员密码）。"
        )
    if not APP_PASSWORD:
        raise SystemExit("请先设置 DB_APP_PASSWORD（应用账户密码）。")

    db_name = valid_identifier(DB_NAME, "DB_NAME")
    app_user = valid_identifier(APP_USER, "DB_APP_USER")

    admin_conn = pymysql.connect(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=ADMIN_USER,
        password=ADMIN_PASSWORD,
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False,
    )

    try:
        with admin_conn.cursor() as cursor:
            cursor.execute(
                f"""
                CREATE DATABASE IF NOT EXISTS `{db_name}`
                CHARACTER SET utf8mb4
                COLLATE utf8mb4_unicode_ci
                """
            )
        admin_conn.commit()
    finally:
        admin_conn.close()

    schema_conn = pymysql.connect(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=ADMIN_USER,
        password=ADMIN_PASSWORD,
        database=db_name,
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False,
    )

    try:
        execute_script(schema_conn, BASE_DIR / "schema.sql")
        execute_script(schema_conn, BASE_DIR / "sample_data.sql")
        schema_conn.commit()

        # 创建最小权限应用账户，同时兼容 localhost 与 127.0.0.1。
        with schema_conn.cursor() as cursor:
            for host in ("localhost", "127.0.0.1"):
                cursor.execute(
                    f"CREATE USER IF NOT EXISTS '{app_user}'@'{host}' "
                    "IDENTIFIED BY %s",
                    (APP_PASSWORD,),
                )
                cursor.execute(
                    f"ALTER USER '{app_user}'@'{host}' IDENTIFIED BY %s",
                    (APP_PASSWORD,),
                )
                cursor.execute(
                    f"GRANT SELECT, INSERT, UPDATE, DELETE "
                    f"ON `{db_name}`.* TO '{app_user}'@'{host}'"
                )
            cursor.execute("FLUSH PRIVILEGES")
        schema_conn.commit()

        result = recalculate_all(schema_conn, 1, 1)
        schema_conn.commit()

        with schema_conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS n FROM Team")
            team_count = int(cursor.fetchone()["n"])
            cursor.execute("SELECT COUNT(*) AS n FROM Player")
            player_count = int(cursor.fetchone()["n"])
            cursor.execute("SELECT COUNT(*) AS n FROM `Match`")
            match_count = int(cursor.fetchone()["n"])
            cursor.execute("SELECT COUNT(*) AS n FROM MatchEvent")
            event_count = int(cursor.fetchone()["n"])

        print("数据库初始化完成")
        print(f"数据库：{db_name}")
        print(f"应用账号：{app_user}")
        print(f"球队：{team_count}")
        print(f"球员：{player_count}")
        print(f"比赛：{match_count}")
        print(f"事件：{event_count}")
        print(f"积分榜行数：{result['standing_rows']}")
        print(f"球员统计行数：{result['player_stat_rows']}")
    except Exception:
        schema_conn.rollback()
        raise
    finally:
        schema_conn.close()


if __name__ == "__main__":
    main()
