
SELECT
  _fivetran_active
  -- , appt_reference_id
  -- , city
  -- , confirmation_code
  -- , created_at
  -- , documents
  -- , id
  -- , lab_provider
  -- , patient_id
  -- , phlebotomy_provider
  -- , requisition_id
  -- , results_available
  -- , state
  -- , status
  -- , street_address
  -- , updated_at
  -- , visit_date
  -- , zip
FROM
  {{ source('admin_backend', 'visit') }}
WHERE
  _fivetran_active = True
