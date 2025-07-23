
SELECT
  _fivetran_active
  -- , created_at
  -- , event_id
  -- , form_id
  -- , id
  -- , submit_data
  -- , token
FROM
  {{ source('mso', 'typeform_submit') }}
WHERE
  _fivetran_active = True
