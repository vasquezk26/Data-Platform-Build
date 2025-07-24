resource "databricks_mws_networks" "this" {
  account_id   = var.databricks_account_id
  network_name = "${var.env}-${var.prefix}-network"
  gcp_network_info {
    network_project_id    = var.project_id
    vpc_id                = var.vpc_id
    subnet_id             = var.subnet_id
    subnet_region         = var.subnet_region
    # pod_ip_range_name     = "${var.workspace_display_name}-pods"
    # service_ip_range_name = "${var.workspace_display_name}-svc"
  }
}

// create workspace in given VPC
resource "databricks_mws_workspaces" "this" {
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
}

# Add access to workspace
resource "databricks_mws_permission_assignment" "add_group" {
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_group.admin_group.id
  permissions  = ["ADMIN"]
}
