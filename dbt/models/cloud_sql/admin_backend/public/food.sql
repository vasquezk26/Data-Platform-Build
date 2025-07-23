
SELECT
  _fivetran_deleted
  -- , description
  -- , food_group
  -- , id
  -- , name
FROM
  {{ source('admin_backend', 'food') }}
WHERE
  _fivetran_deleted = False
