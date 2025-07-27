
SELECT
  _fivetran_deleted
  -- , id
  -- , patient_id
  -- , patient_state
  -- , physician_notes
  -- , reviewed
  -- , reviewing_physician_id
FROM
  {{ source('admin_backend', 'result') }}
WHERE
  _fivetran_deleted = False
