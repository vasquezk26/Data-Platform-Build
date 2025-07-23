
SELECT
  _fivetran_active
  -- , version_num
FROM
  {{ source('admin_backend', 'alembic_version') }}
WHERE
  _fivetran_active = True
