DELETE FROM role_permissions WHERE permission IN ('flags.review', 'stats.restore');

DELETE FROM mod_actions WHERE target_type = 'flag';

ALTER TABLE mod_actions
  MODIFY target_type ENUM('user', 'level', 'level_list', 'comment', 'account_comment', 'song', 'timely_level', 'map_pack', 'gauntlet', 'quest', 'secret_reward', 'role', 'server') NOT NULL;

DROP TABLE user_flags;
DROP TABLE user_logins;
DROP TABLE user_stats_history;
