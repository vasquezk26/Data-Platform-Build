
SELECT
  _fivetran_deleted
  -- , been_hospitalized
  -- , blood_draw_issues
  -- , chronic_condition_diagnosis_dates
  -- , chronic_conditions
  -- , created_at
  -- , current_medications
  -- , had_issues_with_blood_draw
  -- , had_surgeries
  -- , has_chronic_condition
  -- , hospitalizations
  -- , id
  -- , patient_id
  -- , surgeries
  -- , taking_medications
  -- , updated_at
FROM
  {{ source('admin_backend', 'medical_hx') }}
WHERE
  _fivetran_deleted = False
