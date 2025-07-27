
SELECT
  _fivetran_deleted
  -- , cause_id
  -- , recommendation_id
FROM
  {{ source('admin_backend', 'recommendation_cause') }}
WHERE
  _fivetran_deleted = False
