
SELECT
  _fivetran_deleted
  -- , alcohol
  -- , alcohol_frequency
  -- , created_at
  -- , diet
  -- , id
  -- , patient_id
  -- , physically_active
  -- , smoker
  -- , smoking_frequency
  -- , updated_at
FROM
  {{ source('admin_backend', 'patient_behavior_info') }}
WHERE
  _fivetran_deleted = False
