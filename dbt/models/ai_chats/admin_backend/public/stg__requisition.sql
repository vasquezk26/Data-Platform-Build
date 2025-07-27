
SELECT
  _fivetran_active
  -- , all_results_available
  -- , assigned_to
  -- , created_at
  -- , date_assigned
  -- , date_time_all_results_available
  -- , date_time_confirmed
  -- , date_time_final_results_received
  -- , date_time_is_correct
  -- , date_time_reviewed
  -- , id
  -- , is_correct
  -- , latest_visit_date
  -- , patient_id
  -- , patient_notes
  -- , physician_notes
  -- , requisition_group_id
  -- , requisition_state
  -- , reviewed
  -- , reviewing_physician_id
  -- , status
  -- , updated_at
FROM
  {{ source('admin_backend', 'requisition') }}
WHERE
  _fivetran_active = True
