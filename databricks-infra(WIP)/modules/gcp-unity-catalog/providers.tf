terraform {
  required_version = "~> 1.11.4"
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.mws, databricks, databricks.workspace]
      version               = "~> 1.84.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }

  }
}