# --
# Terraform - Backend configuration
# --

terraform {
  required_version = "~> 1.10.3"

  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.15.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }
  }
}

# --
# Terraform - Providers Configuration
# --

provider "google-beta" {
  project = var.project
  region  = var.region
}

provider "google" {
  project = var.project
  region  = var.region
}
