
SELECT
  _fivetran_active
  -- , category_id
  -- , content
  -- , created_at
  -- , id
  -- , requisition_id
  -- , updated_at
  -- , user_id
FROM
  {{ source('admin_backend', 'physician_note') }}
WHERE
  _fivetran_active = True
