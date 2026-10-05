-- Level listings read each visibility on its own and take the first rows of
-- each in sort order, so the visibility columns lead and the sort column follows.
ALTER TABLE levels
  ADD INDEX ix_levels_listing_likes (visibility, deleted_at, likes DESC, id DESC),
  ADD INDEX ix_levels_listing_downloads (visibility, deleted_at, downloads DESC, id DESC),
  ADD INDEX ix_levels_listing_uploaded (visibility, deleted_at, uploaded_at DESC, id DESC),
  ADD INDEX ix_levels_listing_featured (visibility, deleted_at, feature_order DESC, id DESC),
  ADD INDEX ix_levels_listing_rated (visibility, deleted_at, rated_at DESC, id DESC);
