ALTER TABLE comments
  DROP INDEX ix_comments_level_recent,
  DROP INDEX ix_comments_level_liked,
  DROP INDEX ix_comments_list_recent,
  DROP INDEX ix_comments_list_liked,
  DROP INDEX ix_comments_user_recent,
  DROP INDEX ix_comments_user_liked,
  ADD INDEX ix_comments_level_recent (level_id, deleted_at, created_at DESC, id DESC),
  ADD INDEX ix_comments_level_liked (level_id, deleted_at, likes DESC, id DESC),
  ADD INDEX ix_comments_list_recent (list_id, deleted_at, created_at DESC, id DESC),
  ADD INDEX ix_comments_list_liked (list_id, deleted_at, likes DESC, id DESC),
  ADD INDEX ix_comments_user_recent (user_id, deleted_at, created_at DESC, id DESC),
  ADD INDEX ix_comments_user_liked (user_id, deleted_at, likes DESC, id DESC);

ALTER TABLE messages
  ADD INDEX ix_messages_unread (recipient_user_id, read_at, recipient_deleted_at);
