# ----------------------------------------------------------------------------------------------------------------------
# Retrieve data from resources created in service repo
# ----------------------------------------------------------------------------------------------------------------------
data "google_secret_manager_secret_version" "password" {
  project = var.project
  secret  = var.secret_name
  version = "latest"
}
