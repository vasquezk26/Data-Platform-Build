# variable "databricks_workspace_url" {
#   type        = string
#   description = "The URL of the Databricks workspace to which resources will be deployed (e.g., https://<region>.gcp.databricks.com)."
# }

variable "databricks_workspace_id" {
  type        = string
  description = "The unique identifier of the Databricks workspace in which resources will be managed."
}

variable "google_region" {
  type        = string
  description = "Google Cloud region where the resources will be created"
}

variable "google_project" {
  type        = string
  description = "The Google Cloud project ID where the Databricks workspace and associated resources will be created."
}

variable "prefix" {
  type        = string
  description = "Prefix to use in generated resources name"
}

variable "env" {
  type        = string
  description = "Environment (e.g., dev, prod)"
}

variable "metastore_id" {
  type        = string
  description = "ID of the regional metastore"
}

variable "catalog_name" {
  type        = string
  description = "Name to assign to default catalog"
}