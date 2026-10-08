DELETE FROM role_permissions WHERE permission = 'songs.upload';
DELETE FROM user_permissions WHERE permission = 'songs.upload';
UPDATE server_settings SET `key` = 'song_reupload_enabled' WHERE `key` = 'song_upload_enabled';
