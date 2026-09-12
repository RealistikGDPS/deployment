-- Every rename keeps the previous name so a player can still be found by a
-- name they no longer use. Self-service renames from the website are limited
-- to one per 30 days; `changed_by_user_id = user_id` marks those rows.
CREATE TABLE username_changes (
  id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id             INT UNSIGNED NOT NULL,
  changed_by_user_id  INT UNSIGNED NOT NULL,
  old_username        VARCHAR(20)  NOT NULL,
  new_username        VARCHAR(20)  NOT NULL,
  changed_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_username_changes_user (user_id, changed_by_user_id, changed_at DESC),
  KEY ix_username_changes_old (old_username),
  CONSTRAINT fk_username_changes_user FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_username_changes_actor FOREIGN KEY (changed_by_user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
