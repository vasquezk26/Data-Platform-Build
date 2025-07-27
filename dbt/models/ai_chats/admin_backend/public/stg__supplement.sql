
SELECT
  _fivetran_active
  -- , description
  -- , id
  -- , name
  -- , supplement_group
FROM
  {{ source('admin_backend', 'supplement') }}
WHERE
  _fivetran_active = True
