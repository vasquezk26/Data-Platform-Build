
SELECT
  _fivetran_active
  -- , disease_id
  -- , recommendation_id
FROM
  {{ source('admin_backend', 'recommendation_disease') }}
WHERE
  _fivetran_active = True
