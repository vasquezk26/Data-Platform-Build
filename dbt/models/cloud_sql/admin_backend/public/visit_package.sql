
SELECT
  _fivetran_deleted
  -- , package_id
  -- , visit_id
FROM
  {{ source('admin_backend', 'visit_package') }}
WHERE
  _fivetran_deleted = False
