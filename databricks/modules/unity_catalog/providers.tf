terraform {
  required_version = "~> 1.11.4"
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version = "~> 1.84.0"
      configuration_aliases = [
        databricks.mws,
        databricks.workspace
      ]
    }
    google = {
      source = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }
    null = {
      source = "hashicorp/null" 
      version = "~> 3.0"
    }
  }
}



