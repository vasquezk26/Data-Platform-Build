################################################
# Establish Taxonomies and Policy Tags
#
# For example:
# pii - high sensitivity
#  |-- ssn
#  |-- date_of_birth
#
# pii - moderate sensitivity
#  |-- address
#  |-- name
#  |-- phone
#  |-- email
#
# health - high sensitivity
#  |-- biomarkers
#  |-- clinical_notes
#
################################################
# References:
# - https://cloud.google.com/bigquery/docs/column-data-masking-intro
# - https://cloud.google.com/bigquery/docs/column-level-security-intro
# - https://cloud.google.com/bigquery/docs/best-practices-policy-tags
# - https://cloud.google.com/iam/docs/understanding-roles#datacatalog.categoryFineGrainedReader
################################################

data "google_iam_policy" "low_finegrained_reader" {
  binding {
    role = "roles/datacatalog.categoryFineGrainedReader"
    members = [
      "allAuthenticatedUsers",
    ]
  }
}

resource "google_data_catalog_taxonomy" "high_sensitivity_pii" {
  display_name           = "high_sensitivity_pii"
  description            = "A collection of policy tags"
  region                 = "us"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}

resource "google_data_catalog_policy_tag" "high_sensitivity_pii_tag" {
  taxonomy     = google_data_catalog_taxonomy.high_sensitivity_pii.id
  display_name = "High Sensitivity PII Policy"
  description  = "<Add Description>"
}

resource "google_data_catalog_policy_tag" "ssn" {
  taxonomy          = google_data_catalog_taxonomy.high_sensitivity_pii.id
  display_name      = "Social Security Number"
  description       = "<Add Description>"
  parent_policy_tag = google_data_catalog_policy_tag.high_sensitivity_pii_tag.id
}
resource "google_data_catalog_policy_tag" "date_of_birth" {
  taxonomy          = google_data_catalog_taxonomy.high_sensitivity_pii.id
  display_name      = "Date of Birth"
  description       = "<Add Description>"
  parent_policy_tag = google_data_catalog_policy_tag.high_sensitivity_pii_tag.id
}

resource "google_data_catalog_policy_tag" "moderate_health_policy_tag" {
  taxonomy     = google_data_catalog_taxonomy.health.id
  display_name = "Moderate risk"
  description  = "A policy tag normally associated with moderate security items"
}
resource "google_data_catalog_policy_tag" "high_health_policy_tag" {
  taxonomy     = google_data_catalog_taxonomy.health.id
  display_name = "High risk"
  description  = "A policy tag normally associated with high security items"
}

resource "google_data_catalog_policy_tag" "pii_moderate_policy_tag" {
  taxonomy     = google_data_catalog_taxonomy.pii.id
  display_name = "PII - Moderate"
  description  = "A policy tag normally associated with moderate security items"
}
resource "google_data_catalog_policy_tag" "address_policy_tag" {
  taxonomy          = google_data_catalog_taxonomy.pii.id
  display_name      = "Address"
  description       = "A street address, or the granular part of an address"
  parent_policy_tag = google_data_catalog_policy_tag.pii_moderate_policy_tag.id
}

resource "google_data_catalog_policy_tag" "name_policy_tag" {
  taxonomy          = google_data_catalog_taxonomy.pii.id
  display_name      = "Name"
  description       = "A persons first, last, or full name"
  parent_policy_tag = google_data_catalog_policy_tag.pii_moderate_policy_tag.id
}
resource "google_data_catalog_policy_tag" "phone_policy_tag" {
  taxonomy          = google_data_catalog_taxonomy.pii.id
  display_name      = "Phone Number"
  description       = "A persons phone number"
  parent_policy_tag = google_data_catalog_policy_tag.pii_moderate_policy_tag.id
}

resource "google_data_catalog_policy_tag" "pii_high_policy_tag" {
  taxonomy     = google_data_catalog_taxonomy.pii.id
  display_name = "PII - High"
  description  = "A policy tag normally associated with high security items"
}

resource "google_data_catalog_policy_tag" "ssn_policy_tag" {
  taxonomy          = google_data_catalog_taxonomy.pii.id
  display_name      = "SSN"
  description       = "Social Security Number"
  parent_policy_tag = google_data_catalog_policy_tag.pii_high_policy_tag.id
}

resource "google_data_catalog_taxonomy" "pii" {
  region                 = "us-central1"
  display_name           = "pii"
  description            = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}

resource "google_data_catalog_taxonomy" "health" {
  region                 = "us-central1"
  display_name           = "health"
  description            = "A collection of PHI policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}


##############################
# BigQuery Data Policy
#
# Within BigQuery, we can establish masking policies that will return masked data 
# instead of permission denied errors.
##############################

resource "google_bigquery_datapolicy_data_policy" "ssn_data_policy" {
  location         = "us-central1"
  data_policy_id   = "ssn_data_policy"
  policy_tag       = google_data_catalog_policy_tag.ssn_policy_tag.id
  data_policy_type = "DATA_MASKING_POLICY"
  data_masking_policy {
    predefined_expression = "LAST_FOUR_CHARACTERS"
  }
}

resource "google_bigquery_datapolicy_data_policy" "address_data_policy" {
  location         = "us-central1"
  data_policy_id   = "address_data_policy"
  policy_tag       = google_data_catalog_policy_tag.address_policy_tag.id
  data_policy_type = "DATA_MASKING_POLICY"
  data_masking_policy {
    predefined_expression = "DEFAULT_MASKING_VALUE"
  }
}

resource "google_bigquery_datapolicy_data_policy" "phone_data_policy" {
  location         = "us-central1"
  data_policy_id   = "phone_data_policy"
  policy_tag       = google_data_catalog_policy_tag.phone_policy_tag.id
  data_policy_type = "DATA_MASKING_POLICY"
  data_masking_policy {
    predefined_expression = "DEFAULT_MASKING_VALUE"
  }
}


resource "google_bigquery_dataset" "admin_app_backendpublic" {
  dataset_id = "admin_app_backendpublic"
  location   = "us-central1"
}

resource "google_bigquery_routine" "custom_masking_routine" {
  dataset_id           = google_bigquery_dataset.admin_app_backendpublic.dataset_id
  routine_id           = "custom_masking_routine"
  routine_type         = "SCALAR_FUNCTION"
  language             = "SQL"
  data_governance_type = "DATA_MASKING"
  definition_body      = "SAFE.REGEXP_REPLACE(ssn, '[0-9]', 'X')"
  return_type          = "{\"typeKind\" :  \"STRING\"}"

  arguments {
    name      = "ssn"
    data_type = "{\"typeKind\" :  \"STRING\"}"
  }
}

data "google_iam_policy" "masked_reader_policy" {
  binding {
    role = "roles/bigquerydatapolicy.maskedReader"
    # role = "roles/bigquerydatapolicy.viewer"
    members = [
      "user:zack.shapiro@functionhealth.com",
    ]
  }
}

resource "google_bigquery_datapolicy_data_policy_iam_policy" "policy" {
  data_policy_id = google_bigquery_datapolicy_data_policy.ssn_data_policy.data_policy_id
  #data_policy_id = google_data_catalog_policy_tag.pii_moderate_policy_tag.id
  policy_data = data.google_iam_policy.masked_reader_policy.policy_data
}

data "google_iam_policy" "unmasked_reader_policy" {
  binding {
    role = "roles/datacatalog.categoryFineGrainedReader"
    members = [
      "user:zack.shapiro@functionhealth.com",
    ]
  }
}

resource "google_data_catalog_policy_tag_iam_policy" "dc_policy" {
  policy_tag  = google_data_catalog_policy_tag.pii_moderate_policy_tag.id
  policy_data = data.google_iam_policy.unmasked_reader_policy.policy_data
}


##############################
# Test Service Account
##############################
resource "google_project_iam_member" "sa_data_viewer" {
  project = var.project
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:bq-read-only-user@function-health-dev-env.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "sa_read_session" {
  project = var.project
  role    = "roles/bigquery.readSessionUser"
  member  = "serviceAccount:bq-read-only-user@function-health-dev-env.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "sa_job_user" {
  project = var.project
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:bq-read-only-user@function-health-dev-env.iam.gserviceaccount.com"
}