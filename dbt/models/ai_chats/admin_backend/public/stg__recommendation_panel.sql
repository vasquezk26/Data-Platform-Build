
SELECT
  _fivetran_deleted
  -- , panel_id
  -- , recommendation_id
FROM
  {{ source('admin_backend', 'recommendation_panel') }}
WHERE
  _fivetran_deleted = False
