data "terraform_remote_state" "databricks" {
  backend = "gcs"

  config = {
    bucket = "functionhealth-databricks-tf-state-${var.env}"
    prefix = "data-platform-infra/databricks/"
  }
}
