# # ----------------------------------------------------------------------------------------------------------------------
# # Fivetran credentials
# # ----------------------------------------------------------------------------------------------------------------------
# resource "google_secret_manager_secret" "fivetran_api_key" {
#   project   = var.project
#   secret_id = "fivetran_api_key"
#   replication {
#     auto {}
#   }
# }

# resource "google_secret_manager_secret_version" "fivetran_api_key_version" {
#   secret      = google_secret_manager_secret.fivetran_api_key.id
#   secret_data = "ChangeMe123!" # This needs to be manually updated by fetching value from Fivetran
# }

# resource "google_secret_manager_secret" "fivetran_api_secret" {
#   project   = var.project
#   secret_id = "fivetran_api_secret"
#   replication {
#     auto {}
#   }
# }

# resource "google_secret_manager_secret_version" "fivetran_api_secret_version" {
#   secret      = google_secret_manager_secret.fivetran_api_secret.id
#   secret_data = "ChangeMe123!" # This needs to be manually updated by fetching value from Fivetran
# }
# # ----------------------------------------------------------------------------------------------------------------------
