terraform {
  required_version = "~> 1.11.4"
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      version               = "~> 1.84.0"
      configuration_aliases = [databricks.mws, databricks]
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }

  }
}



