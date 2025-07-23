
SELECT
  _fivetran_active
  -- , data
  -- , id
  -- , updated_at
FROM
  {{ source('mso', 'intercom_ticket_type') }}
WHERE
  _fivetran_active = True
