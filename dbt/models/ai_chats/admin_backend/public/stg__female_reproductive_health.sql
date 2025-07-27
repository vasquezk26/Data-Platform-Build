
SELECT
  _fivetran_deleted
  -- , birth_control_type
  -- , created_at
  -- , current_menstrual_status
  -- , currently_on_birth_control
  -- , currently_pregnant
  -- , date_of_last_period
  -- , id
  -- , patient_id
  -- , prior_pregnancies
  -- , time_on_birth_control
  -- , trying_to_conceive
  -- , updated_at
FROM
  {{ source('admin_backend', 'female_reproductive_health') }}
WHERE
  _fivetran_deleted = False
