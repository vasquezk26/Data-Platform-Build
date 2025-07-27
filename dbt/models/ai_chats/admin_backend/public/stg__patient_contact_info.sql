
SELECT
  _fivetran_deleted
  -- , city
  -- , created_at
  -- , email
  -- , id
  -- , patient_id
  -- , phone_number
  -- , state
  -- , street_address
  -- , updated_at
  -- , zip
FROM
  {{ source('admin_backend', 'patient_contact_info') }}
WHERE
  _fivetran_deleted = False
