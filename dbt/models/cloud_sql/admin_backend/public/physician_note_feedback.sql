
SELECT
  _fivetran_active
  -- , created_at
  -- , id
  -- , physician_note_id
  -- , score
  -- , updated_at
  -- , user_id
FROM
  {{ source('admin_backend', 'physician_note_feedback') }}
WHERE
  _fivetran_active = True
