terraform {
  backend "gcs" {}
  required_version = "~> 1.11.4"
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.84.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }

  }
}

provider "google" {
  project = var.project_id
  region  = var.google_region
}

# data "databricks_service_principal" "account_sp" {
#   display_name = "tfm-account-sp-dev"
#   provider     = databricks.mws
# }
# data "google_secret_manager_secret_version_access" "databricks_account_sp_client_secret_version" {
#   secret  = var.account_sp_client_secret_id
#   project = var.project_id
# }

# # Testing an account-level provider for Databricks resources using a Service Principal with OAuth
# provider "databricks" {
#   alias         = "account"
#   host          = "https://accounts.gcp.databricks.com"
#   account_id    = var.databricks_account_id
#   client_id     = var.account_sp_client_id
#   client_secret = data.google_secret_manager_secret_version_access.databricks_account_sp_client_secret_version.secret_data
# }

# Account-level provider for MWS resources
provider "databricks" {
  alias                  = "mws"
  host                   = "https://accounts.gcp.databricks.com"
  account_id             = var.databricks_account_id
  google_service_account = var.databricks_google_service_account # module.fh_sa_provisioning.service_account_email # 
}

# Workspace-level Databricks provider for the Jobs workspace
provider "databricks" {
  alias                  = "jobs_workspace"
  host                   = module.jobs_workspace.workspace_url
  google_service_account = var.databricks_google_service_account # module.fh_sa_provisioning.service_account_email # 
  # client_id     = data.databricks_service_principal.account_sp.id
  # client_secret = data.google_secret_manager_secret_version_access.databricks_account_sp_client_secret_version.secret_data
}

# Workspace-level Databricks provider for the Jobs workspace
provider "databricks" {
  alias                  = "adhoc_workspace"
  host                   = module.adhoc_workspace.workspace_url
  google_service_account = var.databricks_google_service_account # module.fh_sa_provisioning.service_account_email # 
  # client_id     = var.account_sp_client_id
  # client_secret = data.google_secret_manager_secret_version_access.databricks_account_sp_client_secret_version.secret_data
}
