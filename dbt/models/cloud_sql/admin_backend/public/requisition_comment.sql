
SELECT
  _fivetran_deleted
  -- , comment
  -- , created_at
  -- , creator_id
  -- , deleted
  -- , id
  -- , requisition_id
  -- , updated_at
FROM
  {{ source('admin_backend', 'requisition_comment') }}
WHERE
  _fivetran_deleted = False
