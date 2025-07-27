
SELECT
  _fivetran_active
  -- , biological_sex
  -- , description
  -- , id
  -- , name
  -- , status
  -- , version
FROM
  {{ source('admin_backend', 'package') }}
WHERE
  _fivetran_active = True
