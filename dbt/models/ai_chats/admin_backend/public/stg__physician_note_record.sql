
SELECT
  _fivetran_active
  -- , content
  -- , created_at
  -- , id
  -- , updated_at
FROM
  {{ source('admin_backend', 'physician_note_record') }}
WHERE
  _fivetran_active = True
