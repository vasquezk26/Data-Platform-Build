
SELECT
  _fivetran_active
  -- , additional_tests_description
  -- , biomarker_id
  -- , causes_description
  -- , diseases_description
  -- , follow_ups_description
  -- , foods_to_avoid_description
  -- , foods_to_eat_description
  -- , id
  -- , in_range
  -- , name
  -- , neutral_range_type
  -- , out_of_range_type
  -- , self_care_description
  -- , sex
  -- , status
  -- , summary_description
  -- , supplements_description
  -- , symptoms_description
FROM
  {{ source('admin_backend', 'recommendation') }}
WHERE
  _fivetran_active = True
