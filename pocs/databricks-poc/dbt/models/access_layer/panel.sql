{% set raw_database = "RAW" %}
{% set raw_schema = "gcs_development_access_layer_public" %}
{{ config(schema='access_layer') }}

SELECT
    * EXCEPT (
        `_fivetran_synced`
        , `_fivetran_start`
        , `_fivetran_end`
        , `_fivetran_active`
    )
FROM
    {{ var('raw_access_layer_schema') }}.panel
WHERE _fivetran_active = TRUE
