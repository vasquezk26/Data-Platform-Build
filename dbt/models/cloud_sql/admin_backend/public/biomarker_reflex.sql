
SELECT
  _fivetran_active
  -- , biomarker_id
  -- , biomarker_reflex_id
  -- , id
FROM
  {{ source('admin_backend', 'biomarker_reflex') }}
WHERE
  _fivetran_active = True
