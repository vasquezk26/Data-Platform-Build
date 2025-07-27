
SELECT
  _fivetran_active
  -- , description
  -- , id
  -- , name
  -- , symptom_type
FROM
  {{ source('admin_backend', 'symptom') }}
WHERE
  _fivetran_active = True
