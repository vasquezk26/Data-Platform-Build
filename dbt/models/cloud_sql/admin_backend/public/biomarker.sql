
SELECT
  _fivetran_active
  -- , id
  -- , measurement_units
  -- , mode_of_acquisition
  -- , name
  -- , quest_biomarker_code
  -- , result_data_type
  -- , status
FROM
  {{ source('admin_backend', 'biomarker') }}
WHERE
  _fivetran_active = True
