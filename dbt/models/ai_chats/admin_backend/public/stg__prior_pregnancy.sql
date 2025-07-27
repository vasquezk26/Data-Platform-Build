
SELECT
  _fivetran_deleted
  -- , count
  -- , created_at
  -- , female_reproductive_health_id
  -- , id
  -- , number_of_abortions
  -- , number_of_children
  -- , number_of_miscarriages
  -- , updated_at
FROM
  {{ source('admin_backend', 'prior_pregnancy') }}
WHERE
  _fivetran_deleted = False
