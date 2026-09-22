-- The demon list is ordered by hand: a placement is a level at a position, 1
-- being the hardest. Live positions are kept contiguous by the service through
-- range shifts, so there is deliberately no unique key on position. A removed
-- level keeps its row and its records; placing it again revives them. Points
-- are derived from the position on read and never stored.
CREATE TABLE demon_list_placements (
  id                INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  level_id          INT UNSIGNED      NOT NULL,
  position          SMALLINT UNSIGNED NOT NULL,
  requirement       TINYINT UNSIGNED  NOT NULL DEFAULT 100 COMMENT 'minimum percent for a record',
  video_url         VARCHAR(255)      NOT NULL DEFAULT '',
  added_by_user_id  INT UNSIGNED      NOT NULL,
  created_at        DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at        DATETIME          NULL,
  PRIMARY KEY (id),
  UNIQUE KEY ux_demon_list_placements_level (level_id),
  KEY ix_demon_list_placements_position (deleted_at, position),
  CONSTRAINT fk_demon_list_placements_level FOREIGN KEY (level_id) REFERENCES levels (id),
  CONSTRAINT fk_demon_list_placements_added_by FOREIGN KEY (added_by_user_id) REFERENCES users (id),
  CONSTRAINT ck_demon_list_placements_requirement CHECK (requirement BETWEEN 1 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- A record is a player's claimed percent on a listed level. Approving one
-- supersedes the player's earlier approved record on that placement.
CREATE TABLE demon_list_records (
  id                   INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  placement_id         INT UNSIGNED     NOT NULL,
  user_id              INT UNSIGNED     NOT NULL,
  percent              TINYINT UNSIGNED NOT NULL,
  status               ENUM('pending', 'approved', 'rejected', 'superseded') NOT NULL DEFAULT 'pending',
  video_url            VARCHAR(255)     NOT NULL DEFAULT '',
  raw_footage_url      VARCHAR(255)     NOT NULL DEFAULT '',
  notes                VARCHAR(500)     NOT NULL DEFAULT '',
  review_note          VARCHAR(255)     NOT NULL DEFAULT '' COMMENT 'shown to the player',
  submitted_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reviewed_at          DATETIME         NULL,
  reviewed_by_user_id  INT UNSIGNED     NULL,
  deleted_at           DATETIME         NULL,
  PRIMARY KEY (id),
  KEY ix_demon_list_records_queue (status, deleted_at, submitted_at DESC),
  KEY ix_demon_list_records_placement (placement_id, status, deleted_at, percent DESC),
  KEY ix_demon_list_records_user (user_id, status, deleted_at),
  CONSTRAINT fk_demon_list_records_placement FOREIGN KEY (placement_id) REFERENCES demon_list_placements (id),
  CONSTRAINT fk_demon_list_records_user FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_demon_list_records_reviewed_by FOREIGN KEY (reviewed_by_user_id) REFERENCES users (id),
  CONSTRAINT ck_demon_list_records_percent CHECK (percent BETWEEN 1 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE mod_actions
  MODIFY target_type ENUM('user', 'level', 'level_list', 'comment', 'account_comment', 'song', 'timely_level', 'map_pack', 'gauntlet', 'quest', 'secret_reward', 'role', 'server', 'flag', 'demon_list_placement', 'demon_list_record') NOT NULL;

ALTER TABLE user_bans
  MODIFY type ENUM('account', 'comment', 'upload', 'leaderboard', 'creator', 'demon_list') NOT NULL;

-- Roles can be created from the admin area, so the new one takes whatever id
-- is free and is found by its name.
INSERT INTO roles (name, description, priority) VALUES
  ('list_moderator', 'Orders the demon list and reviews its records.', 20);

INSERT INTO role_permissions (role_id, permission) VALUES
  (1, 'demon_list.submit'),
  (3, 'demon_list.manage'),
  (3, 'demon_list.review'),
  (3, 'users.ban.demon_list');

INSERT INTO role_permissions (role_id, permission)
  SELECT id, permission FROM roles
  JOIN (
    SELECT 'demon_list.manage' AS permission
    UNION ALL SELECT 'demon_list.review'
    UNION ALL SELECT 'users.ban.demon_list'
    UNION ALL SELECT 'users.unban'
    UNION ALL SELECT 'admin.access'
  ) AS grants
  WHERE roles.name = 'list_moderator';
