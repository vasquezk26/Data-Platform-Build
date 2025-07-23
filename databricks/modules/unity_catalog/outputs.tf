output "databricks_service_account_email" {
  value = databricks_storage_credential.main.databricks_gcp_service_account[0].email
  description = "The Databricks-managed GCP service account email for storage credential."
}
