# TODO: Uncomment the below when we are ready to port over stripe data connector
# variable "transaction_stripe_fivetran_db_password" {
#   description = "Password for the Fivetran database user"
#   type        = string
#   sensitive   = true
# }

variable "fivetran_api_key" {
  description = "FIVETRAN API key"
  type        = string
  sensitive   = true
}

variable "fivetran_api_secret" {
  description = "FIVETRAN API Secret"
  type        = string
  sensitive   = true
}

variable "project" {
  type        = string
  description = "The project to deploy to, if not set the default provider project is used."
  default     = "function-health-databricks-dev"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., development, staging, production)"
  default     = "development"
}

variable "env" {
  type        = string
  description = "Short environment name (e.g., dev, stg, prod)"
  default     = "dev"
}

# --------------------------------------------------------------------------------------------
# Cloud SQL Database public IP addresses or DNS names
# We will use IP addresses until we have DNS names for the databases.
# --------------------------------------------------------------------------------------------
variable "mso_db_host" {
  type        = string
  description = "MSO Cloud SQL Database public IP address or DNS name"
}

variable "access_code_db_host" {
  type        = string
  description = "Access Code Cloud SQL Database public IP address or DNS name"
}

variable "transaction_db_host" {
  type        = string
  description = "Transaction Cloud SQL Database public IP address or DNS name"
}

variable "member_app_core_db_host" {
  type        = string
  description = "Member App Core Backend Cloud SQL Database public IP address or DNS name"
}

variable "admin_app_backend_v2_db_host" {
  type        = string
  description = "Admin App Backend V2 Cloud SQL Database public IP address or DNS name"
}
# --------------------------------------------------------------------------------------------