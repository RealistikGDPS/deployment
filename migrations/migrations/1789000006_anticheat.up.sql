-- Anti-cheat bookkeeping. Stats updates are stored raw, so the server keeps a
-- change log of the counters a client may inflate, records where logins come
-- from, and files flags for a moderator to review instead of refusing writes
-- it cannot prove wrong.
CREATE TABLE user_stats_history (
  id                        INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  user_id                   INT UNSIGNED      NOT NULL,
  source                    ENUM('baseline', 'client', 'restore') NOT NULL,
  stars                     INT UNSIGNED      NOT NULL DEFAULT 0,
  moons                     INT UNSIGNED      NOT NULL DEFAULT 0,
  demons                    INT UNSIGNED      NOT NULL DEFAULT 0,
  diamonds                  INT UNSIGNED      NOT NULL DEFAULT 0,
  secret_coins              INT UNSIGNED      NOT NULL DEFAULT 0,
  user_coins                INT UNSIGNED      NOT NULL DEFAULT 0,
  demons_easy               SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_medium             SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_hard               SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_insane             SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_extreme            SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_easy_platformer    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_medium_platformer  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_hard_platformer    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_insane_platformer  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_extreme_platformer SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_weekly             SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_gauntlet           SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  demons_event              SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  created_at                DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_user_stats_history_user (user_id, created_at DESC),
  CONSTRAINT fk_user_stats_history_user FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- One row per game login, per fresh credential verification and per website
-- login. The address is the packed form, as in level_reports.
CREATE TABLE user_logins (
  id              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  user_id         INT UNSIGNED     NOT NULL,
  source          ENUM('game', 'web') NOT NULL,
  ip              VARBINARY(16)    NOT NULL,
  udid            VARCHAR(64)      NOT NULL DEFAULT '',
  platform        TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0 unknown, 1 ios, 2 android, 3 windows, 8 macos',
  game_version    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  binary_version  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  created_at      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_user_logins_user (user_id, created_at DESC),
  KEY ix_user_logins_ip (ip, created_at DESC),
  CONSTRAINT fk_user_logins_user FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- A flag is a suspicion, never a verdict: the write that raised it went
-- through. Evidence is whatever the check saw, for the moderator's eyes.
CREATE TABLE user_flags (
  id                   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id              INT UNSIGNED NOT NULL,
  kind                 ENUM('stats_ceiling', 'score_implausible', 'alt_account') NOT NULL,
  status               ENUM('open', 'dismissed', 'actioned') NOT NULL DEFAULT 'open',
  target_id            INT UNSIGNED NULL COMMENT 'level id for score flags',
  evidence             JSON         NOT NULL,
  created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at          DATETIME     NULL,
  resolved_by_user_id  INT UNSIGNED NULL,
  PRIMARY KEY (id),
  KEY ix_user_flags_queue (status, created_at DESC),
  KEY ix_user_flags_user (user_id, kind, status),
  CONSTRAINT fk_user_flags_user FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_user_flags_resolved_by FOREIGN KEY (resolved_by_user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE mod_actions
  MODIFY target_type ENUM('user', 'level', 'level_list', 'comment', 'account_comment', 'song', 'timely_level', 'map_pack', 'gauntlet', 'quest', 'secret_reward', 'role', 'server', 'flag') NOT NULL;

INSERT INTO role_permissions (role_id, permission) VALUES
  (3, 'flags.review'),
  (3, 'stats.restore'),
  (4, 'flags.review'),
  (4, 'stats.restore');
