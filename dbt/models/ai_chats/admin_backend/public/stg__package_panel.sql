
SELECT
  _fivetran_deleted
  -- , package_id
  -- , panel_id
FROM
  {{ source('admin_backend', 'package_panel') }}
WHERE
  _fivetran_deleted = False
