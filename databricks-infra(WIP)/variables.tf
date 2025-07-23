# --------
# These are non-sensitive but environment-specific. They come from trigger or tfvars
# --------

variable "env" {
  type        = string
  description = "Short Environment name (e.g., development, staging, production)"
  # No default - must be specified per environment
}

variable "environment" {
  type        = string
  description = "Full Environment name (e.g., development, staging, production)"
  default     = "development"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID"
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
}

# variable "account_sp_client_id" {
#   description = "Client ID for the service principal used in the Databricks account"
#   type        = string

# }

# variable "account_sp_client_secret_id" {
#   description = "ID of the secret containing the account-level service principal client secret"
#   type        = string
# }

variable "google_region" {
  description = "GCP region for the Databricks workspace"
  type        = string
  default     = "us-central1"
}

variable "metastore_id" {
  description = "Databricks metastore ID"
  type        = string
}

variable "databricks_google_service_account" {
  description = "GCP service account email used to authenticate with Databricks"
  type        = string
}

variable "conductorone_sp_name" {
  description = "The display name of the ConductorOne Service Principal to assign to all workspaces"
  type        = string
}