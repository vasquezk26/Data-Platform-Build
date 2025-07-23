output "databricks_metastore_id" {
  description = "ID of the existing Unity Catalog metastore"
  value       = data.databricks_metastore.existing.id
}

# output "pat_for_fivetran" {
#   value = google_secret_manager_secret_version.databricks_pat_secret_version.secret_data
#   sensitive = true
# }

output "workspaces" {
  description = "Databricks workspaces"
  value       = data.databricks_mws_workspaces.this.ids
}