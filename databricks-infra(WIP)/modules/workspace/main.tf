resource "databricks_mws_networks" "this" {
  provider     = databricks.mws
  account_id   = var.databricks_account_id
  network_name = "${var.workspace_display_name}-network" # The network name is derived from workspace_display_name, e.g., if workspace_display_name is "demo-dev", the network name will be "demo-dev-network".
  gcp_network_info {
    network_project_id = var.project_id
    vpc_id             = var.vpc_id
    subnet_id          = var.subnet_id
    subnet_region      = var.subnet_region
  }
}

// create workspace in given VPC
resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_display_name # e.g. "demo-dev"
  location       = var.subnet_region
  cloud_resource_container {
    gcp {
      project_id = var.project_id
    }
  }
  network_id = databricks_mws_networks.this.network_id

  token {}
}

# Lookup the Admin group
data "databricks_group" "admin_group" {
  display_name = var.admin_group_name
  provider     = databricks.mws
}

# Add access to workspace
resource "databricks_mws_permission_assignment" "add_group" {
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_group.admin_group.id
  permissions  = ["ADMIN"]
  provider     = databricks.mws
}

# Assign the Unity Catalog metastore to the workspace
resource "databricks_metastore_assignment" "this" {
  metastore_id = var.metastore_id
  provider     = databricks.mws
  workspace_id = databricks_mws_workspaces.this.workspace_id
}

# Assign ConductorOne Service Principal to the workspace
resource "databricks_mws_permission_assignment" "conductorone-sp-workspace-assignment" {
  workspace_id = databricks_mws_workspaces.this.workspace_id
  provider     = databricks.mws
  principal_id = var.conductorone_sp_id
  permissions  = ["ADMIN"]
}

resource "databricks_mws_permission_assignment" "account-sp-network-assignment" {
  workspace_id = databricks_mws_workspaces.this.workspace_id
  provider     = databricks.mws
  principal_id = var.conductorone_sp_id
  permissions  = ["ADMIN"]
}