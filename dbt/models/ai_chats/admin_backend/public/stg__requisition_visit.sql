
SELECT
  _fivetran_deleted
  -- , requisition_id
  -- , visit_id
FROM
  {{ source('admin_backend', 'requisition_visit') }}
WHERE
  _fivetran_deleted = False
