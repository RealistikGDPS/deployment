DELETE FROM role_permissions WHERE permission = 'levels.reupload';
DELETE FROM user_permissions WHERE permission = 'levels.reupload';
ALTER TABLE levels
  DROP INDEX ux_levels_official,
  DROP COLUMN official_id;
