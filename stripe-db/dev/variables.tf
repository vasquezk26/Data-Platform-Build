variable "transaction_stripe_fivetran_db_password" {
  description = "Password for the Fivetran database user"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}
