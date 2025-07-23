
SELECT
  _fivetran_active
  -- , description
  -- , id
  -- , name
FROM
  {{ source('admin_backend', 'disease') }}
WHERE
  _fivetran_active = True
