
SELECT
  _fivetran_deleted
  -- , comments_before_booking
  -- , created_at
  -- , how_did_they_hear_about_function
  -- , id
  -- , patient_id
  -- , purpose_for_joining_function
  -- , ten_year_health_goals
  -- , updated_at
FROM
  {{ source('admin_backend', 'motivational') }}
WHERE
  _fivetran_deleted = False
