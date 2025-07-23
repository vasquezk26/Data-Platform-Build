
SELECT
  _fivetran_active
  -- , category_name
  -- , description
  -- , id
  -- , status
FROM
  {{ source('admin_backend', 'category') }}
WHERE
  _fivetran_active = True
