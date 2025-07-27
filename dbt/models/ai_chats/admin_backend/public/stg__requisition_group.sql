
SELECT
  _fivetran_active
  -- , confirmation
  -- , created_at
  -- , date_time_confirmed
  -- , id
  -- , panel_group_id
  -- , patient_id
  -- , ready_for_confirmation
  -- , referring_physician_id
  -- , updated_at
FROM
  {{ source('admin_backend', 'requisition_group') }}
WHERE
  _fivetran_active = True
