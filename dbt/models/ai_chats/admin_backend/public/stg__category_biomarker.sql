{{
  config(
    alias='category_biomarker'
  )
}}

SELECT
  _fivetran_deleted
  -- , biomarker_id
  -- , category_id
FROM
  {{ source('admin_backend', 'category_biomarker') }}
WHERE
  _fivetran_deleted = False
