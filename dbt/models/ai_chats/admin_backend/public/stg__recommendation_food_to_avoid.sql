
SELECT
  _fivetran_deleted
  -- , food_id
  -- , recommendation_id
FROM
  {{ source('admin_backend', 'recommendation_food_to_avoid') }}
WHERE
  _fivetran_deleted = False
