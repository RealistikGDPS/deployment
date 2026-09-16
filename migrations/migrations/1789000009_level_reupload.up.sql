-- A level copied from the official servers remembers its id there; the unique
-- key means each official level is reuploaded at most once.
ALTER TABLE levels
  ADD COLUMN official_id INT UNSIGNED NULL AFTER original_id,
  ADD UNIQUE KEY ux_levels_official (official_id);
INSERT INTO role_permissions (role_id, permission) VALUES (1, 'levels.reupload');
