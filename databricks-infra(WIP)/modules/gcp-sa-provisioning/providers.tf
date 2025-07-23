terraform {
  required_version = "~> 1.11.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }

  }
}

data "google_client_openid_userinfo" "me" {
}