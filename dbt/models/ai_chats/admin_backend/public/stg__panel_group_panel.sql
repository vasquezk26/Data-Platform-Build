
SELECT
  _fivetran_active
  -- , panel_group_id
  -- , panel_id
FROM
  {{ source('admin_backend', 'panel_group_panel') }}
WHERE
  _fivetran_active = True
