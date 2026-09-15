UPDATE user_stats s
LEFT JOIN (
  SELECT user_id, SUM((stars > 0) + (feature_order > 0) + (rating > 0)) AS points
  FROM levels WHERE deleted_at IS NULL GROUP BY user_id
) l ON l.user_id = s.user_id
SET s.creator_points = COALESCE(l.points, 0);
