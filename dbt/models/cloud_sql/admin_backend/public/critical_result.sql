
SELECT
  _fivetran_deleted
  -- , created_at
  -- , critical_reviewed
  -- , date_time_critical_reviewed
  -- , id
  -- , level
  -- , updated_at
  -- , visit_id
FROM
  {{ source('admin_backend', 'critical_result') }}
WHERE
  _fivetran_deleted = False
