-- Operator-editable settings read at request time. One row per key; a key
-- that is absent takes the default declared on the ServerSettings model, so a
-- new setting needs no migration. Values are text and parsed by the model.
CREATE TABLE server_settings (
  `key`               VARCHAR(64)   NOT NULL,
  value               VARCHAR(1024) NOT NULL,
  updated_by_user_id  INT UNSIGNED  NULL,
  updated_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`key`),
  CONSTRAINT fk_server_settings_user FOREIGN KEY (updated_by_user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO server_settings (`key`, value) VALUES
  ('registration_enabled', 'true'),
  ('level_uploads_enabled', 'true'),
  ('song_reupload_enabled', 'false'),
  ('level_reupload_enabled', 'false'),
  ('download_pc_url', ''),
  ('download_android_url', '');

-- Settings changes and maintenance jobs have no row of their own; they are
-- logged against target 'server' with target_id 0.
ALTER TABLE mod_actions
  MODIFY target_type ENUM('user', 'level', 'level_list', 'comment', 'account_comment', 'song', 'timely_level', 'map_pack', 'gauntlet', 'quest', 'secret_reward', 'role', 'server') NOT NULL;

-- The Streamlit panel is replaced by the website's /admin area.
UPDATE role_permissions SET permission = 'admin.access' WHERE permission = 'panel.access';
UPDATE user_permissions SET permission = 'admin.access' WHERE permission = 'panel.access';

INSERT INTO role_permissions (role_id, permission) VALUES
  (3, 'admin.maintenance');
