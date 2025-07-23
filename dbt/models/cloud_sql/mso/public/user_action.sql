
SELECT
  _fivetran_active
  -- , action
  -- , created_time
  -- , id
  -- , input_values
  -- , user_id
FROM
  {{ source('mso', 'user_action') }}
WHERE
  _fivetran_active = True
