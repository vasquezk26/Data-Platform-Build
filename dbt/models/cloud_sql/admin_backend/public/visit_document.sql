
SELECT
  _fivetran_active
  -- , created_at
  -- , deleted
  -- , doc_status
  -- , doc_type
  -- , id
  -- , updated_at
  -- , url
  -- , visible
  -- , visit_id
FROM
  {{ source('admin_backend', 'visit_document') }}
WHERE
  _fivetran_active = True
