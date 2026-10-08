-- The song tool takes an MP3 from the player rather than fetching one.
UPDATE server_settings SET `key` = 'song_upload_enabled' WHERE `key` = 'song_reupload_enabled';

-- Uploading is open to every account; a dedicated ban type shuts one player
-- out of songs without touching their levels.
ALTER TABLE user_bans
  MODIFY type ENUM('account', 'comment', 'upload', 'leaderboard', 'creator', 'demon_list', 'song_upload') NOT NULL;

INSERT INTO role_permissions (role_id, permission) VALUES
  (1, 'songs.upload'),
  (3, 'users.ban.song_upload');
