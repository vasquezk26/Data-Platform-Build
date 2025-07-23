
SELECT
  _fivetran_deleted
  -- , description
  -- , exercise_type
  -- , id
  -- , name
FROM
  {{ source('admin_backend', 'exercise') }}
WHERE
  _fivetran_deleted = False
