# ----------------------------------------------------------------------------
# Jobs Workspace
# ----------------------------------------------------------------------------
module "jobs_workspace" {
  source = "./modules/workspace"

  databricks_account_id  = var.databricks_account_id
  workspace_display_name = var.environment
  project_id             = var.project_id
  subnet_region          = var.google_region
  vpc_id                 = data.terraform_remote_state.devops_infra.outputs.jobs_vpc_name
  subnet_id              = data.terraform_remote_state.devops_infra.outputs.jobs_subnet_names[0]
  admin_group_name       = "dbr-${var.env}-admins"
  metastore_id           = data.databricks_metastore.existing.id
  conductorone_sp_id     = data.databricks_service_principal.conductorone_sp.id

  providers = {
    databricks.mws = databricks.mws
    google         = google
  }
}

# Assign groups and SPs to the jobs workspace
module "jobs_id_federation" {
  source = "./modules/uc-idf-assignment"

  metastore_id = data.databricks_metastore.existing.id
  workspace_id = module.jobs_workspace.workspace_id
  account_groups = { # Permission Options: ADMIN, USER
    "a" = { "group_name" = "dbr-${var.env}-admins", "permissions" = ["ADMIN"] }
  }
  service_principals = {
  }

  providers = {
    databricks = databricks.mws
  }

}

# ----------------------------------------------------------------------------
# Adhoc Workspace
# ----------------------------------------------------------------------------
module "adhoc_workspace" {
  source = "./modules/workspace"

  databricks_account_id  = var.databricks_account_id
  workspace_display_name = "adhoc-${var.env}"
  project_id             = var.project_id
  subnet_region          = var.google_region
  vpc_id                 = data.terraform_remote_state.devops_infra.outputs.adhoc_vpc_name
  subnet_id              = data.terraform_remote_state.devops_infra.outputs.adhoc_subnet_names[0]
  admin_group_name       = "dbr-${var.env}-admins"
  metastore_id           = data.databricks_metastore.existing.id
  conductorone_sp_id     = data.databricks_service_principal.conductorone_sp.id

  providers = {
    databricks.mws = databricks.mws
    google         = google
  }
}

# Assign groups and SPs to the adhoc workspace
module "adhoc_id_federation" {
  source = "./modules/uc-idf-assignment"

  metastore_id = data.databricks_metastore.existing.id
  workspace_id = module.adhoc_workspace.workspace_id
  account_groups = { # Permission Options: ADMIN, USER
    "admins group" = { "group_name" = "dbr-${var.env}-admins", "permissions" = ["ADMIN"] },
    "beta users"   = { "group_name" = "dbr-${var.env}-health-reader-beta", "permissions" = ["USER"] },
    "view only"    = { "group_name" = "dbr-view-only", "permissions" = ["USER"] },
  }
  service_principals = {
  }

  providers = {
    databricks = databricks.mws
  }

}

module "jobs_workspace_resources" {
  source = "./workspaces/jobs"

  project_id   = var.project_id
  workspace_id = module.jobs_workspace.workspace_id

  providers = {
    databricks.mws = databricks.mws
    databricks     = databricks.jobs_workspace
    google         = google
  }
}
