ALTER TABLE levels
  DROP INDEX ix_levels_listing_likes,
  DROP INDEX ix_levels_listing_downloads,
  DROP INDEX ix_levels_listing_uploaded,
  DROP INDEX ix_levels_listing_featured,
  DROP INDEX ix_levels_listing_rated;
