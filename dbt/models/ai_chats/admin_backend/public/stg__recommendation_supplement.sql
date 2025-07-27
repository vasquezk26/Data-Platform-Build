
SELECT
  _fivetran_deleted
  -- , recommendation_id
  -- , supplement_id
FROM
  {{ source('admin_backend', 'recommendation_supplement') }}
WHERE
  _fivetran_deleted = False
