DELETE FROM role_permissions WHERE permission IN ('songs.upload', 'users.ban.song_upload');
DELETE FROM user_permissions WHERE permission IN ('songs.upload', 'users.ban.song_upload');

DELETE FROM user_bans WHERE type = 'song_upload';

ALTER TABLE user_bans
  MODIFY type ENUM('account', 'comment', 'upload', 'leaderboard', 'creator', 'demon_list') NOT NULL;

UPDATE server_settings SET `key` = 'song_reupload_enabled' WHERE `key` = 'song_upload_enabled';
