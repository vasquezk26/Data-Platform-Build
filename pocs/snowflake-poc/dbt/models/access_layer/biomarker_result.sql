{% set raw_database = "RAW" %}
{% set raw_schema = "GCP_DEVELOPMENT_ADMIN_BACKEND_PUBLIC" %}
{{ config(schema='access_layer') }}

SELECT
  * EXCLUDE ("_FIVETRAN_SYNCED")
FROM
  {{raw_database}}.{{raw_schema}}.biomarker_result
