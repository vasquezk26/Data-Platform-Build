
SELECT
  _fivetran_deleted
  -- , package_id
  -- , result_id
FROM
  {{ source('admin_backend', 'result_package') }}
WHERE
  _fivetran_deleted = False
