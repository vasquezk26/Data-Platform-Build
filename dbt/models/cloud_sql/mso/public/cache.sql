
SELECT
  _fivetran_active
  -- , expires_after
  -- , key
  -- , modified_time
  -- , value
FROM
  {{ source('mso', 'cache') }}
WHERE
  _fivetran_active = True
