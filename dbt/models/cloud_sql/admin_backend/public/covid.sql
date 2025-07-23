
SELECT
  _fivetran_deleted
  -- , covid_date
  -- , covid_residual_symptoms
  -- , covid_severity
  -- , covid_vaccine_date_last_dosage
  -- , covid_vaccine_name
  -- , created_at
  -- , had_covid
  -- , has_covid_residual_symptoms
  -- , id
  -- , patient_id
  -- , updated_at
  -- , vaccinated_for_covid
FROM
  {{ source('admin_backend', 'covid') }}
WHERE
  _fivetran_deleted = False
