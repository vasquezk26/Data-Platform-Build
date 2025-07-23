{% set raw_database = "RAW" %}
{% set raw_schema = "gcs_development_access_layer_public" %}
{{ config(schema = 'access_layer') }}

SELECT
    * EXCEPT (
        `_fivetran_synced`
    )
FROM
    {{ var('raw_access_layer_schema') }}.biomarker_result
