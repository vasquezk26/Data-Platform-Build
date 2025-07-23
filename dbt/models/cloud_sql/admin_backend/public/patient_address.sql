
SELECT
  _fivetran_active
  -- , address_type
  -- , city
  -- , created_at
  -- , id
  -- , patient_id
  -- , phone_number
  -- , postal_code
  -- , state
  -- , street_address
  -- , updated_at
FROM
  {{ source('admin_backend', 'patient_address') }}
WHERE
  _fivetran_active = True
