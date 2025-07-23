terraform {
  required_version = ">= 1.11.4"

  required_providers {
    fivetran = {
      source  = "fivetran/fivetran"
      version = ">= 1.8.1"
    }
  }
}
