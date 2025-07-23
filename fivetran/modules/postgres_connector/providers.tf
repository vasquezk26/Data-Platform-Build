terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.33, < 7.0.0"
    }

    fivetran = {
      source  = "fivetran/fivetran"
      version = ">= 1.7.0"
    }
  }
}
