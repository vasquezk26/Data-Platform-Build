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

# Account-level provider for MWS resources
provider "databricks" {
  alias                  = "mws"
  host                   = "https://accounts.gcp.databricks.com"
  account_id             = var.databricks_account_id
  google_service_account = "cloud-build@function-health-databricks-dev.iam.gserviceaccount.com"
}

provider "databricks" {
  host                   = module.workspace.workspace_url
  google_service_account = "cloud-build@function-health-databricks-dev.iam.gserviceaccount.com" #Testing
}

# Workspace-level Databricks provider
provider "databricks" {
  alias                  = "workspace"
  host                   = module.workspace.workspace_url
  google_service_account = var.databricks_google_service_account
}