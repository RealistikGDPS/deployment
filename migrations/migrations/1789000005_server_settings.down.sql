DELETE FROM role_permissions WHERE permission = 'admin.maintenance';

UPDATE user_permissions SET permission = 'panel.access' WHERE permission = 'admin.access';
UPDATE role_permissions SET permission = 'panel.access' WHERE permission = 'admin.access';

DELETE FROM mod_actions WHERE target_type = 'server';

ALTER TABLE mod_actions
  MODIFY target_type ENUM('user', 'level', 'level_list', 'comment', 'account_comment', 'song', 'timely_level', 'map_pack', 'gauntlet', 'quest', 'secret_reward', 'role') NOT NULL;

DROP TABLE server_settings;
