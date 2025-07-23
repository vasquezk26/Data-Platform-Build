variable "databricks_account_id" {
  description = "The account ID associated with Databricks"
  type        = string
}

variable "workspace_display_name" {
  description = "Name of the Databricks workspace"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "vpc_id" {
  description = "The VPC name where the Databricks workspace will be created"
  type        = string
}

variable "subnet_id" {
  description = "The subnet name where the Databricks workspace will be created"
  type        = string
}

variable "subnet_region" {
  description = "The region of the subnet where the Databricks workspace will be created"
  type        = string
  default     = "us-central1"
}

variable "admin_group_name" {
  description = "The ID of the group that will have admin access to the Databricks workspace"
  type        = string
}

variable "metastore_id" {
  description = "The ID of the Unity Catalog metastore to assign to the workspace"
  type        = string
}

variable "conductorone_sp_id" {
  description = "The ID of the ConductorOne Service Principal to assign to the workspace"
  type        = number

}