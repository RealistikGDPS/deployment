-- Legendary levels award 4 creator points and mythic 5; the rating column
-- (0 none, 1 epic, 2 legendary, 3 mythic) is the bonus on top of rated and
-- featured. Recompute every user from the levels they hold.
UPDATE user_stats s
LEFT JOIN (
  SELECT user_id, SUM((stars > 0) + (feature_order > 0) + rating) AS points
  FROM levels WHERE deleted_at IS NULL GROUP BY user_id
) l ON l.user_id = s.user_id
SET s.creator_points = COALESCE(l.points, 0);
