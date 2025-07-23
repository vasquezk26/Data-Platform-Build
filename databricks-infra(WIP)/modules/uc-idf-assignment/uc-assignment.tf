#this will assign the metastore to the workspace
resource "databricks_metastore_assignment" "this" {
  metastore_id = var.metastore_id
  workspace_id = var.workspace_id
}