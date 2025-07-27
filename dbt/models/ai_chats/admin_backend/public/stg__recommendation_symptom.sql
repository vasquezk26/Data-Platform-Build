
SELECT
  _fivetran_deleted
  -- , recommendation_id
  -- , symptom_id
FROM
  {{ source('admin_backend', 'recommendation_symptom') }}
WHERE
  _fivetran_deleted = False
