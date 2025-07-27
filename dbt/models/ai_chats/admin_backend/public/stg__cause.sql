{{
  config(
    alias='cause'
  )
}}

SELECT
  _fivetran_deleted
  -- , description
  -- , id
  -- , name
FROM
  {{ source('admin_backend', 'cause') }}
WHERE
  _fivetran_deleted = False
