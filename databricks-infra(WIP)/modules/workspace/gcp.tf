# This is being done in the SRE repository, so we don't need to do it here.
# resource "google_compute_network" "dbx_private_vpc" {
#   project                 = var.project_id
#   name                    = "${var.workspace_display_name}-tf-network-${random_string.suffix.result}"
#   auto_create_subnetworks = false
# }

# resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
#   name                     = "${var.workspace_display_name}-dbx-${random_string.suffix.result}"
#   ip_cidr_range            = "10.0.0.0/16"
#   region                   = "us-central1"
#   project                  = var.project_id
#   network                  = google_compute_network.dbx_private_vpc.id
#   private_ip_google_access = true
# }

# resource "google_compute_router" "router" {
#   name    = "${var.workspace_display_name}-router-${random_string.suffix.result}"
#   region  = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
#   network = google_compute_network.dbx_private_vpc.id
#   project = var.project_id
# }

# resource "google_compute_router_nat" "nat" {
#   name                               = "${var.workspace_display_name}-router-nat-${random_string.suffix.result}"
#   router                             = google_compute_router.router.name
#   region                             = google_compute_router.router.region
#   project                            = google_compute_router.router.project
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
# }

# resource "databricks_mws_networks" "this" {
#   provider     = databricks.mws
#   account_id   = var.databricks_account_id
#   network_name = "${var.workspace_display_name}-${random_string.suffix.result}"
#   gcp_network_info {
#     network_project_id = var.project_id
#     vpc_id             = google_compute_network.dbx_private_vpc.name
#     subnet_id          = google_compute_subnetwork.network-with-private-secondary-ip-ranges.name
#     subnet_region      = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
#   }
# }