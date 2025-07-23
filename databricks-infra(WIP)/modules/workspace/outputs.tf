output "workspace_id" {
  value = databricks_mws_workspaces.this.workspace_id
}

output "workspace_url" {
  description = "The full URL of the Databricks workspace for provider configuration. Needed for other modules to connect to this workspace."
  value       = databricks_mws_workspaces.this.workspace_url
}