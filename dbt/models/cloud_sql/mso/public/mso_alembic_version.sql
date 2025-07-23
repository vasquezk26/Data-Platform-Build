
SELECT
  _fivetran_active
  -- , version_num
FROM
  {{ source('mso', 'alembic_version') }}
WHERE
  _fivetran_active = True
