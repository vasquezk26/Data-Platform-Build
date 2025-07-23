
SELECT
  _fivetran_deleted
  -- , exercise_id
  -- , recommendation_id
FROM
  {{ source('admin_backend', 'recommendation_exercise') }}
WHERE
  _fivetran_deleted = False
