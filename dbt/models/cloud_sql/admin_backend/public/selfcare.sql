
SELECT
  _fivetran_active
  -- , description
  -- , id
  -- , name
FROM
  {{ source('admin_backend', 'selfcare') }}
WHERE
  _fivetran_active = True
