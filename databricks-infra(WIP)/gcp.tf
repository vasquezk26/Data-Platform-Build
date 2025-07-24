Cmodule "demo_sa_provisioning" {
  source = "./modules/gcp-sa-provisioning"

  project_id    = var.project_id
  prefix        = "demo-databricks-tfm-${var.env}"
  delegate_from = ["serviceAccount:${var.databricks_google_service_account}"]

  providers = {
    google = google
  }
}

import {
  to = module.demo_sa_provisioning.google_service_account.sa2
  id = "demo-databricks-tfm-dev-sa2@function-health-databricks-dev.iam.gserviceaccount.com"
}
