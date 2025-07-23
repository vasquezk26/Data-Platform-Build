
SELECT
  _fivetran_deleted
  -- , created_at
  -- , event_id
  -- , id
  -- , updated_at
  -- , visit_id
FROM
  {{ source('admin_backend', 'visit_meta_data') }}
WHERE
  _fivetran_deleted = False
