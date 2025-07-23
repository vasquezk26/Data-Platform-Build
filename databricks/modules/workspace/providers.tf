terraform {
  required_version = "~> 1.11.4"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.84.0"
    }
  }
}
