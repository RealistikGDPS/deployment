ALTER TABLE levels
  DROP INDEX ix_levels_likes,
  DROP INDEX ix_levels_downloads,
  DROP INDEX ix_levels_uploaded,
  DROP INDEX ix_levels_featured,
  DROP INDEX ix_levels_rated,
  ADD INDEX ix_levels_likes (deleted_at, visibility, likes DESC, id DESC),
  ADD INDEX ix_levels_downloads (deleted_at, visibility, downloads DESC, id DESC),
  ADD INDEX ix_levels_uploaded (deleted_at, visibility, uploaded_at DESC, id DESC),
  ADD INDEX ix_levels_featured (deleted_at, visibility, feature_order DESC, id DESC),
  ADD INDEX ix_levels_rated (deleted_at, visibility, rated_at DESC, id DESC);

ALTER TABLE level_lists
  DROP INDEX ix_level_lists_likes,
  DROP INDEX ix_level_lists_downloads,
  DROP INDEX ix_level_lists_uploaded,
  DROP INDEX ix_level_lists_rated,
  ADD INDEX ix_level_lists_likes (deleted_at, visibility, likes DESC, id DESC),
  ADD INDEX ix_level_lists_downloads (deleted_at, visibility, downloads DESC, id DESC),
  ADD INDEX ix_level_lists_uploaded (deleted_at, visibility, uploaded_at DESC, id DESC),
  ADD INDEX ix_level_lists_rated (deleted_at, visibility, rated_at DESC, id DESC),
  ADD INDEX ix_level_lists_suggested (deleted_at, visibility, updated_at DESC, id DESC);
