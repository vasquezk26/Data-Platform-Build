{% set raw_database = "RAW" %}
{% set raw_schema = "gcs_development_access_layer_public" %}

SELECT
    * EXCEPT (
        `_fivetran_synced`
    )
FROM
    {{ var('raw_access_layer_schema') }}.visit_package
