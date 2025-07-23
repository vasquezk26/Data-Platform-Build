
SELECT
  _fivetran_active
  -- , description
  -- , frequency_per_year
  -- , id
  -- , mode_of_acquisition
  -- , name
  -- , quest_price
  -- , quest_test_code
  -- , sex
FROM
  {{ source('admin_backend', 'panel') }}
WHERE
  _fivetran_active = True
