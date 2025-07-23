variable "databricks_host" {
  type = string
}

variable "databricks_catalog" {
  type = string
}

variable "databricks_http_path" {
  type = string
}

variable "databricks_pat" {
  type = string
}

variable "destination_group_name" {
  type = string
}

variable "external_location" {
  type        = string
  description = "External GCP bucket location for the Databricks destination"
}