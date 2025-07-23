# The sensitive values will be pulled in by cloudbuild from Secret Manager during deployment
variable "transaction_stripe_fivetran_db_password" {
  description = "Password for the Fivetran database user"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "project" {
  description = "The project to deploy to, if not set the default provider project is used."
  default     = "function-health-dev-env"
}

variable "env" {
  type        = string
  description = "Environment. development, testing, staging, or production"
  default     = "development"
}

variable "short_env" {
  type        = string
  description = "Environment abbreviation: dev, test, prod"
  default     = "dev"
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


variable "cloud_sql_availability_type" {
  description = "Availability type for the Cloud SQL instance"
  type        = string
  default     = "ZONAL"
}