
SELECT
  _fivetran_deleted
  -- , comment
  -- , created_at
  -- , creator_id
  -- , id
  -- , requisition_comment_id
FROM
  {{ source('admin_backend', 'requisition_comment_log') }}
WHERE
  _fivetran_deleted = False
