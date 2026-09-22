DELETE FROM role_permissions WHERE permission IN ('demon_list.submit', 'demon_list.manage', 'demon_list.review', 'users.ban.demon_list');
DELETE FROM user_permissions WHERE permission IN ('demon_list.submit', 'demon_list.manage', 'demon_list.review', 'users.ban.demon_list');
DELETE FROM role_permissions WHERE role_id IN (SELECT id FROM roles WHERE name = 'list_moderator');
DELETE FROM user_roles WHERE role_id IN (SELECT id FROM roles WHERE name = 'list_moderator');
DELETE FROM roles WHERE name = 'list_moderator';

DELETE FROM mod_actions WHERE target_type IN ('demon_list_placement', 'demon_list_record');

ALTER TABLE mod_actions
  MODIFY target_type ENUM('user', 'level', 'level_list', 'comment', 'account_comment', 'song', 'timely_level', 'map_pack', 'gauntlet', 'quest', 'secret_reward', 'role', 'server', 'flag') NOT NULL;

DELETE FROM user_bans WHERE type = 'demon_list';

ALTER TABLE user_bans
  MODIFY type ENUM('account', 'comment', 'upload', 'leaderboard', 'creator') NOT NULL;

DROP TABLE demon_list_records;
DROP TABLE demon_list_placements;
