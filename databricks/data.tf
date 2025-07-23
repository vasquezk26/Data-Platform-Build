data "terraform_remote_state" "devops_infra" {
  backend = "gcs"

  config = {
    bucket = "functionhealth-databricks-tf-state-${var.env}"
    prefix = "data-platform-databricks/shared-infra/"
  }
}

data "databricks_metastore" "existing" {
  provider = databricks.mws
  region   = var.region
}