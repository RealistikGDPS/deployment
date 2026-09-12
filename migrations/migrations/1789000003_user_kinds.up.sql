-- Non-player accounts, such as a bot holding levels reuploaded from the
-- official servers. `kind` is identity, not capability: what a bot may do is
-- still decided by its roles. Non-players never rank and their levels stay
-- out of the curated listings. Members are only ever appended.

ALTER TABLE users
  ADD COLUMN kind ENUM('player', 'bot') NOT NULL DEFAULT 'player' AFTER username,
  ADD INDEX ix_users_kind (kind);
