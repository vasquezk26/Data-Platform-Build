terraform {
  required_version = "~> 1.11.4"

  required_providers {
    databricks = {
      source                = "databricks/databricks"
      version               = "~> 1.84.0"
      configuration_aliases = [databricks.mws]
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# provider "databricks" {
#   alias                  = "mws"
#   host                   = "https://accounts.gcp.databricks.com"
#   account_id             = var.databricks_account_id
#   google_service_account = "cloud-build@function-health-databricks-dev.iam.gserviceaccount.com" # var.databricks_google_service_account
# }

# data "google_client_openid_userinfo" "me" {
# }


# data "google_client_config" "current" {
# }

resource "random_string" "suffix" {
  special = false
  upper   = false
  length  = 6
}

# provider "google" {
#   project = var.project_id
#   region  = var.region
#   google_service_account = var.databricks_google_service_account
# }