# ----------------------------------------------------------------------------------------------------------------------
# Fivetran setup
# ----------------------------------------------------------------------------------------------------------------------
# Presently this is a POC. Once databricks env is fully ready, we will replace with correct configuration.
resource "fivetran_connector" "connector" {
  service  = "google_cloud_postgresql"
  group_id = var.group_id

  trust_certificates = true
  trust_fingerprints = true
  run_setup_tests    = true

  destination_schema {
    prefix = var.destination_schema_prefix
  }

  config {
    host             = var.host
    port             = var.port
    database         = var.database
    user             = var.username
    password         = data.google_secret_manager_secret_version.password.secret_data
    connection_type  = "Directly"
    replication_slot = var.replication_slot
    publication_name = var.publication_name
    update_method    = "WAL_PGOUTPUT"
  }
}

resource "fivetran_connector_schedule" "schedule" {
  connector_id    = fivetran_connector.connector.id
  sync_frequency  = var.sync_frequency
  daily_sync_time = var.daily_sync_time

  paused            = false
  pause_after_trial = false

  schedule_type = "auto"
}

resource "fivetran_connector_schema_config" "schema_config" {
  provider               = fivetran
  connector_id           = fivetran_connector.connector.id
  schema_change_handling = "ALLOW_ALL"
  schemas                = var.schemas
}
