variable "project" {
  description = "The project to deploy to, if not set the default provider project is used."
  default     = "function-health-dev-env"
}

variable "region" {
  description = "Region for cloud resources"
  default     = "us-central1"
}
