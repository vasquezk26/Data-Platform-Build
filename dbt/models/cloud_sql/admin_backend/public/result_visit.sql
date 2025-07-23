
SELECT
  _fivetran_deleted
  -- , result_id
  -- , visit_id
FROM
  {{ source('admin_backend', 'result_visit') }}
WHERE
  _fivetran_deleted = False
