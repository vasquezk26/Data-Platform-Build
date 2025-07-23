# --------
# These are non-sensitive but environment-specific. They come from trigger or tfvars
# --------

variable "env" {
  type        = string
  description = "Short Environment Identifier (dev, prod)"
  # No default - must be specified per environment
}

variable "environment" {
  type        = string
  description = "Full Environment name (e.g., development, staging, production)"
  # No default - must be specified per environment
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID"
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for the deployment"
  default     = "us-central1"
}

variable "workspace_suffix" {
  description = "An optional suffix for the workspace name, useful for differentiating personal workspaces"
  type        = string
  default     = ""
}

variable "databricks_google_service_account" {
  description = "GCP service account email used to authenticate with Databricks"
  type        = string
  # No default - should be specified per environment
}