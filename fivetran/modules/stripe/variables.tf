variable "transaction_stripe_fivetran_db_password" {
  description = "Password for the Fivetran database user"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The GCP region where resources will be created"
  type        = string
  default     = "us-central1"
}

variable "db_tier" {
  description = "The machine type to use for the database instance"
  type        = string
  default     = "db-f1-micro"
}

variable "disk_size" {
  description = "Starting size of disk space"
  type        = number
  default     = 10
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the database instance"
  type        = bool
  default     = true
}

variable "project" {
  type        = string
  description = "The project to deploy to, if not set the default provider project is used."
  default     = "function-health-databricks-dev"
}

# Some repos use short_env and env. Devops is standardizing to env and environment
variable "env" {
  type        = string
  description = "Environment. dev, stg, prod"
  default     = "dev"
}
