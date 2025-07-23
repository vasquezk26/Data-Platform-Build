SELECT
  * except (datastream_metadata)
FROM
  `function-health-dev-env.admin_app_backendpublic.patient`
WHERE TRUE
QUALIFY ROW_NUMBER() OVER (PARTITION BY patient_identifier ORDER BY datastream_metadata.source_timestamp DESC) = 1
