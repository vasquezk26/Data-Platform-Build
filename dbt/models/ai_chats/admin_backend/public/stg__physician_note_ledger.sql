
SELECT
  _fivetran_deleted
  -- , created_at
  -- , id
  -- , note_editor_id
  -- , physician_note_id
  -- , physician_note_record_id
  -- , updated_at
FROM
  {{ source('admin_backend', 'physician_note_ledger') }}
WHERE
  _fivetran_deleted = False
