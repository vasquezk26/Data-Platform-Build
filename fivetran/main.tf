# TODO: Uncomment the below when we are ready to port over stripe data connector
# # --------------------------------------------------------------------------------------------
# # Stripe data to Postgres DB
# # --------------------------------------------------------------------------------------------
# module "transaction_stripe_db" {
#   source                                  = "./modules/stripe"
#   deletion_protection                     = false
#   transaction_stripe_fivetran_db_password = var.transaction_stripe_fivetran_db_password
# }

# --------------------------------------------------------------------------------------------
# Dataricks Destination
# --------------------------------------------------------------------------------------------
module "databricks_destination_fh_bronze" {
  source = "./modules/databricks_destination"

  destination_group_name = "${var.environment}_databricks_bronze"
  databricks_host        = data.terraform_remote_state.databricks.outputs.fivetran_destination_sql_warehouse_host
  databricks_catalog     = "bronze"
  databricks_http_path   = data.terraform_remote_state.databricks.outputs.fivetran_destination_sql_warehouse_http_path
  databricks_pat         = data.terraform_remote_state.databricks.outputs.pat_for_fivetran
  external_location      = "gs://bronze-database-datalake-${var.env}"

  providers = {
    fivetran = fivetran
  }
}
# --------------------------------------------------------------------------------------------
# Cloud SQL Connectors
# --------------------------------------------------------------------------------------------
module "mso_utils" {
  source                    = "./modules/postgres_connector"
  project                   = var.project
  group_id                  = module.databricks_destination_fh_bronze.destination_id
  database                  = "mso"
  destination_schema_prefix = "${var.env}_mso"
  host                      = var.mso_db_host
  secret_name               = "MSO_REPLICATION_USER_PASSWORD"
  schemas                   = local.bronze_schemas.mso
}

module "access_code_service" {
  source                    = "./modules/postgres_connector"
  project                   = var.project
  group_id                  = module.databricks_destination_fh_bronze.destination_id
  database                  = "${var.environment}-accesscode"
  destination_schema_prefix = "${var.env}_accesscode"
  host                      = var.access_code_db_host
  secret_name               = "ACCESS_CODE_SERVICE_REPLICATION_USER_PASSWORD"
  schemas                   = local.bronze_schemas.accesscode
}

module "transaction_service" {
  source                    = "./modules/postgres_connector"
  project                   = var.project
  group_id                  = module.databricks_destination_fh_bronze.destination_id
  database                  = "${var.environment}-transaction"
  destination_schema_prefix = "${var.env}_transaction"
  host                      = var.transaction_db_host
  secret_name               = "TRANSACTION_SERVICE_REPLICATION_USER_PASSWORD"
  schemas                   = local.bronze_schemas.transaction
}

module "member_app_core_backend" {
  source                    = "./modules/postgres_connector"
  project                   = var.project
  group_id                  = module.databricks_destination_fh_bronze.destination_id
  database                  = "${var.environment}-member-app-core-backend"
  destination_schema_prefix = "${var.env}_member_app_core_backend"
  host                      = var.member_app_core_db_host
  secret_name               = "MEMBER_APP_CORE_BACKEND_REPLICATION_USER_PASSWORD"
  schemas                   = local.bronze_schemas.member_app_core_backend
}

module "admin_app_backend_v2" {
  source                    = "./modules/postgres_connector"
  project                   = var.project
  group_id                  = module.databricks_destination_fh_bronze.destination_id
  database                  = "${var.environment}-admin-backend"
  destination_schema_prefix = "${var.env}_admin_backend"
  host                      = var.admin_app_backend_v2_db_host
  secret_name               = "ADMIN_APP_BACKEND_V2_REPLICATION_USER_PASSWORD"
  schemas                   = local.bronze_schemas.admin_backend
}
# --------------------------------------------------------------------------------------------