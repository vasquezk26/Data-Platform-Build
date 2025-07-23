resource "fivetran_group" "databricks_destination_group" {
  name = var.destination_group_name
}

resource "fivetran_destination" "databricks_destination" {
  group_id           = fivetran_group.databricks_destination_group.id
  service            = "databricks"
  time_zone_offset   = "0"
  region             = "GCP_US_CENTRAL1"
  trust_certificates = true
  trust_fingerprints = false
  run_setup_tests    = true

  config {
    server_host_name       = var.databricks_host
    port                   = "443"
    catalog                = var.databricks_catalog
    http_path              = var.databricks_http_path
    auth_type              = "PERSONAL_ACCESS_TOKEN"
    personal_access_token  = var.databricks_pat
    create_external_tables = true
    external_location      = var.external_location
  }
}
