
SELECT
  _fivetran_deleted
  -- , id
  -- , is_priority1
  -- , is_priority2
  -- , priority1_range
  -- , priority2_range
  -- , sex_specific_id
FROM
  {{ source('admin_backend', 'critical') }}
WHERE
  _fivetran_deleted = False
