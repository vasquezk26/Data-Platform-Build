
SELECT
  _fivetran_active
  -- , biological_sex
  -- , can_schedule_in_beta_states
  -- , created_at
  -- , date_joined
  -- , dob
  -- , ethnic_origin
  -- , fname
  -- , id
  -- , lname
  -- , patient_firebase_id
  -- , patient_identifier
  -- , preferred_name
  -- , pronouns
  -- , shirt_size
  -- , ssn
  -- , updated_at
FROM
  {{ source('admin_backend', 'patient') }}
WHERE
  _fivetran_active = True
