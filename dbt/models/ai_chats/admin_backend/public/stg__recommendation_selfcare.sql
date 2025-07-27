
SELECT
  _fivetran_deleted
  -- , recommendation_id
  -- , selfcare_id
FROM
  {{ source('admin_backend', 'recommendation_selfcare') }}
WHERE
  _fivetran_deleted = False
