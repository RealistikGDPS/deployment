ALTER TABLE messages
  DROP INDEX ix_messages_unread;

ALTER TABLE comments
  DROP INDEX ix_comments_level_recent,
  DROP INDEX ix_comments_level_liked,
  DROP INDEX ix_comments_list_recent,
  DROP INDEX ix_comments_list_liked,
  DROP INDEX ix_comments_user_recent,
  DROP INDEX ix_comments_user_liked,
  ADD INDEX ix_comments_level_recent (level_id, deleted_at, created_at DESC),
  ADD INDEX ix_comments_level_liked (level_id, deleted_at, likes DESC),
  ADD INDEX ix_comments_list_recent (list_id, deleted_at, created_at DESC),
  ADD INDEX ix_comments_list_liked (list_id, deleted_at, likes DESC),
  ADD INDEX ix_comments_user_recent (user_id, deleted_at, created_at DESC),
  ADD INDEX ix_comments_user_liked (user_id, deleted_at, likes DESC);
