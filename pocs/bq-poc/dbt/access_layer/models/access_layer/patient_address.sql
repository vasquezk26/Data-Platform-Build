SELECT
  * except (datastream_metadata)
FROM
  `function-health-dev-env.admin_app_backendpublic.patient_address`
WHERE TRUE
QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC) = 1
