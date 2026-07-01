SET NAMES utf8mb4;

DROP VIEW IF EXISTS MatchDetailView;
DROP VIEW IF EXISTS MatchScoreView;

DROP TABLE IF EXISTS PlayerStat;
DROP TABLE IF EXISTS Standing;
DROP TABLE IF EXISTS MatchEvent;
DROP TABLE IF EXISTS MatchAppearance;
DROP TABLE IF EXISTS `Match`;
DROP TABLE IF EXISTS Player;
DROP TABLE IF EXISTS Team;
DROP TABLE IF EXISTS Tournament;
DROP TABLE IF EXISTS Season;

CREATE TABLE Season (
    season_id    INT PRIMARY KEY AUTO_INCREMENT,
    season_name  VARCHAR(50) NOT NULL,
    start_date   DATE NOT NULL,
    end_date     DATE NOT NULL,
    CONSTRAINT uk_season_name UNIQUE (season_name),
    CONSTRAINT chk_season_date CHECK (end_date > start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='赛季信息表';

CREATE TABLE Tournament (
    tournament_id   INT PRIMARY KEY AUTO_INCREMENT,
    tournament_name VARCHAR(100) NOT NULL,
    organizer       VARCHAR(100) NOT NULL,
    CONSTRAINT uk_tournament_name UNIQUE (tournament_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='赛事信息表';

CREATE TABLE Team (
    team_id    INT PRIMARY KEY AUTO_INCREMENT,
    team_name  VARCHAR(100) NOT NULL,
    city       VARCHAR(50) NOT NULL,
    coach_name VARCHAR(80) NOT NULL,
    CONSTRAINT uk_team_name UNIQUE (team_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='球队信息表';

CREATE TABLE Player (
    player_id    INT PRIMARY KEY AUTO_INCREMENT,
    team_id      INT NOT NULL,
    player_name  VARCHAR(80) NOT NULL,
    number       TINYINT UNSIGNED NOT NULL,
    `position`   VARCHAR(20) NOT NULL,
    CONSTRAINT fk_player_team
        FOREIGN KEY (team_id) REFERENCES Team(team_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT uk_player_number UNIQUE (team_id, number),
    CONSTRAINT chk_player_number CHECK (number BETWEEN 1 AND 99),
    CONSTRAINT chk_player_position CHECK (
        `position` IN ('Goalkeeper', 'Defender', 'Midfielder', 'Forward')
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='球员信息表';

CREATE TABLE `Match` (
    match_id       INT PRIMARY KEY AUTO_INCREMENT,
    season_id      INT NOT NULL,
    tournament_id  INT NOT NULL,
    home_team_id   INT NOT NULL,
    away_team_id   INT NOT NULL,
    round_no       SMALLINT UNSIGNED NOT NULL,
    match_date     DATETIME NOT NULL,
    `status`       VARCHAR(20) NOT NULL DEFAULT 'scheduled',
    CONSTRAINT fk_match_season
        FOREIGN KEY (season_id) REFERENCES Season(season_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_match_tournament
        FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_match_home
        FOREIGN KEY (home_team_id) REFERENCES Team(team_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_match_away
        FOREIGN KEY (away_team_id) REFERENCES Team(team_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_match_teams CHECK (home_team_id <> away_team_id),
    CONSTRAINT chk_match_status CHECK (
        `status` IN ('scheduled', 'live', 'finished', 'postponed', 'cancelled')
    ),
    CONSTRAINT uk_match_fixture UNIQUE (
        season_id, tournament_id, round_no, home_team_id, away_team_id
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='比赛基础信息表；比分由事件视图计算';

CREATE TABLE MatchAppearance (
    appearance_id INT PRIMARY KEY AUTO_INCREMENT,
    match_id      INT NOT NULL,
    player_id     INT NOT NULL,
    is_starting   BOOLEAN NOT NULL DEFAULT TRUE,
    minute_on     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    minute_off    SMALLINT UNSIGNED NOT NULL DEFAULT 90,
    CONSTRAINT fk_appearance_match
        FOREIGN KEY (match_id) REFERENCES `Match`(match_id)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_appearance_player
        FOREIGN KEY (player_id) REFERENCES Player(player_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT uk_match_appearance UNIQUE (match_id, player_id),
    CONSTRAINT chk_appearance_minutes CHECK (
        minute_on <= minute_off AND minute_off <= 130
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='球员单场出场记录，用于统计出场次数';

CREATE TABLE MatchEvent (
    event_id          INT PRIMARY KEY AUTO_INCREMENT,
    match_id          INT NOT NULL,
    player_id         INT NOT NULL,
    related_player_id INT NULL,
    minute            SMALLINT UNSIGNED NOT NULL,
    stoppage_minute   SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    event_type        VARCHAR(30) NOT NULL,
    CONSTRAINT fk_event_match
        FOREIGN KEY (match_id) REFERENCES `Match`(match_id)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_event_player
        FOREIGN KEY (player_id) REFERENCES Player(player_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_event_related_player
        FOREIGN KEY (related_player_id) REFERENCES Player(player_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_event_time CHECK (
        minute <= 130 AND stoppage_minute <= 20
    ),
    CONSTRAINT chk_event_players CHECK (
        related_player_id IS NULL OR related_player_id <> player_id
    ),
    CONSTRAINT chk_event_type CHECK (
        event_type IN (
            'goal', 'penalty_goal', 'own_goal',
            'yellow_card', 'red_card', 'substitution'
        )
    ),
    CONSTRAINT chk_event_related_rule CHECK (
        (event_type = 'substitution' AND related_player_id IS NOT NULL)
        OR
        (event_type IN ('goal', 'penalty_goal'))
        OR
        (event_type IN ('own_goal', 'yellow_card', 'red_card')
         AND related_player_id IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='比赛事件；related_player_id 表示助攻者或换上球员';

CREATE TABLE Standing (
    standing_id   INT PRIMARY KEY AUTO_INCREMENT,
    season_id     INT NOT NULL,
    tournament_id INT NOT NULL,
    team_id       INT NOT NULL,
    played        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    win           SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    draw          SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    loss          SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    goals_for     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    goals_against SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    points        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_stand_season
        FOREIGN KEY (season_id) REFERENCES Season(season_id)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_stand_tournament
        FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_stand_team
        FOREIGN KEY (team_id) REFERENCES Team(team_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT uk_standing UNIQUE (season_id, tournament_id, team_id),
    CONSTRAINT chk_standing_sum CHECK (played = win + draw + loss),
    CONSTRAINT chk_standing_points CHECK (points = win * 3 + draw)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='物化积分榜，由统计服务全量重算';

CREATE TABLE PlayerStat (
    stat_id       INT PRIMARY KEY AUTO_INCREMENT,
    season_id     INT NOT NULL,
    tournament_id INT NOT NULL,
    player_id     INT NOT NULL,
    appearances   SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    goals         SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    assists       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    yellow_cards  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    red_cards     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_ps_season
        FOREIGN KEY (season_id) REFERENCES Season(season_id)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_ps_tournament
        FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_ps_player
        FOREIGN KEY (player_id) REFERENCES Player(player_id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT uk_playerstat UNIQUE (season_id, tournament_id, player_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='物化球员赛季统计，由统计服务全量重算';

CREATE VIEW MatchScoreView AS
SELECT
    m.match_id,
    COALESCE(SUM(
        CASE
            WHEN me.event_type IN ('goal', 'penalty_goal')
                 AND p.team_id = m.home_team_id THEN 1
            WHEN me.event_type = 'own_goal'
                 AND p.team_id = m.away_team_id THEN 1
            ELSE 0
        END
    ), 0) AS home_score,
    COALESCE(SUM(
        CASE
            WHEN me.event_type IN ('goal', 'penalty_goal')
                 AND p.team_id = m.away_team_id THEN 1
            WHEN me.event_type = 'own_goal'
                 AND p.team_id = m.home_team_id THEN 1
            ELSE 0
        END
    ), 0) AS away_score
FROM `Match` AS m
LEFT JOIN MatchEvent AS me ON me.match_id = m.match_id
LEFT JOIN Player AS p ON p.player_id = me.player_id
GROUP BY m.match_id;

CREATE VIEW MatchDetailView AS
SELECT
    m.match_id,
    m.season_id,
    m.tournament_id,
    m.round_no,
    m.match_date,
    m.home_team_id,
    ht.team_name AS home_team_name,
    m.away_team_id,
    at.team_name AS away_team_name,
    ms.home_score,
    ms.away_score,
    m.`status`
FROM `Match` AS m
INNER JOIN Team AS ht ON ht.team_id = m.home_team_id
INNER JOIN Team AS at ON at.team_id = m.away_team_id
INNER JOIN MatchScoreView AS ms ON ms.match_id = m.match_id;
