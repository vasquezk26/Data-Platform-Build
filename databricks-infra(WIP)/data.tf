data "databricks_metastore" "existing" {
  metastore_id = var.metastore_id
  provider     = databricks.mws
}

data "databricks_mws_workspaces" "this" {
  provider = databricks.mws
}

data "databricks_service_principal" "conductorone_sp" {
  display_name = var.conductorone_sp_name # "conductor_one_sp"
  provider     = databricks.mws
}

data "terraform_remote_state" "devops_infra" {
  backend = "gcs"

  config = {
    bucket = "functionhealth-databricks-tf-state-${var.env}"
    prefix = "data-platform-databricks/shared-infra/"
  }
}
