terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = "functionhealth-tf-state-dev"
    prefix = "data-platform/fivetran"
  }
}
 