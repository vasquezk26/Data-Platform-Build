{{
  config(
    alias='biomarker_result'
  )
}}

SELECT
  _fivetran_deleted
  -- , biomarker_id
  -- , biomarker_name
  -- , collection_site
  -- , created_at
  -- , date_of_service
  -- , id
  -- , measurement_units
  -- , ordering_physician_id
  -- , quest_biomarker_id
  -- , quest_reference_range
  -- , test_result
  -- , test_result_out_of_range
  -- , updated_at
  -- , visit_id
FROM
  {{ source('admin_backend', 'biomarker_result') }}
WHERE
  _fivetran_deleted = False
