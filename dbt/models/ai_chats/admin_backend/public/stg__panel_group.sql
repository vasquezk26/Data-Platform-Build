
SELECT
  _fivetran_active
  -- , creation_date
  -- , id
  -- , version
FROM
  {{ source('admin_backend', 'panel_group') }}
WHERE
  _fivetran_active = True
