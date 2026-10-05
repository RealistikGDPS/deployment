ALTER TABLE level_lists
  DROP INDEX ix_level_lists_listing_likes,
  DROP INDEX ix_level_lists_listing_downloads,
  DROP INDEX ix_level_lists_listing_uploaded,
  DROP INDEX ix_level_lists_listing_rated,
  DROP INDEX ix_level_lists_listing_suggested;

ALTER TABLE levels
  DROP INDEX ix_levels_listing_likes,
  DROP INDEX ix_levels_listing_downloads,
  DROP INDEX ix_levels_listing_uploaded,
  DROP INDEX ix_levels_listing_featured,
  DROP INDEX ix_levels_listing_rated;
