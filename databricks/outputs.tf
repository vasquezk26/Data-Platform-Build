output "fivetran_destination_sql_warehouse_host" {
  value = module.warehouse_for_jobs.sql_warehouse_host
}

output "fivetran_destination_sql_warehouse_http_path" {
  value = module.warehouse_for_jobs.sql_warehouse_http_path
}

output "pat_for_fivetran" {
  value = google_secret_manager_secret_version.databricks_pat_secret_version.secret_data
  sensitive = true
}

output "metastore_id" {
  description = "ID of the existing Unity Catalog metastore"
  value       = data.databricks_metastore.existing.id
}