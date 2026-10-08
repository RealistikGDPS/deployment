-- The song tool takes an MP3 from the player rather than fetching one.
UPDATE server_settings SET `key` = 'song_upload_enabled' WHERE `key` = 'song_reupload_enabled';
INSERT INTO role_permissions (role_id, permission) VALUES (1, 'songs.upload');
