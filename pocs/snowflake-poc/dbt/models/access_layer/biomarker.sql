{% set raw_database = "RAW" %}
{% set raw_schema = "GCP_DEVELOPMENT_ADMIN_BACKEND_PUBLIC" %}
{{ config(schema='access_layer') }}

SELECT
  * EXCLUDE ("_FIVETRAN_SYNCED", 
    "_FIVETRAN_START",
	  "_FIVETRAN_END",
	  "_FIVETRAN_ACTIVE")

FROM
  {{raw_database}}.{{raw_schema}}.biomarker
WHERE _FIVETRAN_ACTIVE = TRUE