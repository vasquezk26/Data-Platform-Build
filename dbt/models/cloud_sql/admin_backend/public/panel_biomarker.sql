
SELECT
  _fivetran_deleted
  -- , biomarker_id
  -- , panel_id
FROM
  {{ source('admin_backend', 'panel_biomarker') }}
WHERE
  _fivetran_deleted = False
