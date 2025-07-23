{% set raw_database = "RAW" %}
{% set raw_schema = "GCP_DEVELOPMENT_ADMIN_BACKEND_PUBLIC" %}

SELECT
  * EXCLUDE ("_FIVETRAN_SYNCED", 
    "_FIVETRAN_START",
	  "_FIVETRAN_END",
	  "_FIVETRAN_ACTIVE")
FROM
  {{raw_database}}.{{raw_schema}}.patient_address
WHERE _FIVETRAN_ACTIVE = TRUE