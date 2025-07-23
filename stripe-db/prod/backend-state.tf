terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = "functionhealth-tf-state-prod"
    prefix = "prod-core-tfstate/fivetran-transaction-stripe"
  }
}
 