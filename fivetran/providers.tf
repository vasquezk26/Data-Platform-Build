terraform {
  required_version = ">= 1.11.4"

  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.33, < 7.0.0"
    }

    fivetran = {
      source  = "fivetran/fivetran"
      version = ">= 1.8.1"
    }
  }
}

provider "fivetran" {
  api_key    = var.fivetran_api_key
  api_secret = var.fivetran_api_secret
}
