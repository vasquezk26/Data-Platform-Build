# ----------------------------------------------------------------------------
# PAT for Fivetran
# ----------------------------------------------------------------------------
resource "time_rotating" "rotate_30_days" {
  rotation_days = 30
}

resource "databricks_service_principal" "fivetran_sp" {
  display_name = "Fivetran Service Principal"
  provider     = databricks.mws
}

resource "databricks_mws_permission_assignment" "fivetran-sp-network-assignment" {
  workspace_id = var.workspace_id
  provider     = databricks.mws
  principal_id = databricks_service_principal.fivetran_sp.id
  permissions  = ["USER"]
  depends_on   = [databricks_service_principal.fivetran_sp]
}

resource "databricks_permissions" "token_usage" {
  authorization = "tokens"
  access_control {
    service_principal_name = databricks_service_principal.fivetran_sp.application_id
    permission_level       = "CAN_USE"
  }
  provider   = databricks
  depends_on = [databricks_mws_permission_assignment.fivetran-sp-network-assignment]
}

# Create token for Fivetran to access Databricks
resource "databricks_obo_token" "pat_for_fivetran" {
  comment = "Token for Fivetran - Terraform (created: ${time_rotating.rotate_30_days.rfc3339})"
  # Token is valid for 60 days but is rotated after 30 days.
  # Run `terraform apply` within 60 days to refresh before it expires.
  application_id   = databricks_service_principal.fivetran_sp.application_id
  lifetime_seconds = 60 * 24 * 60 * 60
  provider         = databricks
  depends_on       = [databricks_permissions.token_usage]
}

resource "google_secret_manager_secret" "databricks_pat_secret" {
  project   = var.project_id
  secret_id = "DATABRICKS_PAT_FOR_FIVETRAN"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "databricks_pat_secret_version" {
  secret      = google_secret_manager_secret.databricks_pat_secret.id
  secret_data = databricks_obo_token.pat_for_fivetran.token_value
}
# ----------------------------------------------------------------------------