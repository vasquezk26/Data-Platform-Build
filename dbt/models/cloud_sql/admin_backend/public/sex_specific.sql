
SELECT
  _fivetran_active
  -- , biomarker_id
  -- , cross_reference_biomarkers
  -- , id
  -- , is_hormonal_cycle_affected
  -- , notes
  -- , one_line_description
  -- , optimal_range_high
  -- , optimal_range_low
  -- , quest_ref_range_high
  -- , quest_ref_range_low
  -- , resources_cited
  -- , sex
  -- , why_it_matters
FROM
  {{ source('admin_backend', 'sex_specific') }}
WHERE
  _fivetran_active = True
