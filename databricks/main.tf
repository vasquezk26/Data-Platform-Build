# ----------------------------------------------------------------------------
# Databricks resources
# ----------------------------------------------------------------------------
# Create a demo-<ENV>[-<terraform.workspace>] Databricks workspace
# By providing a `_TERRAFORM_WORKSPACE` environment variable to the build, you can create multiple test workspaces for the same environment.
module "workspace" {
  source = "./modules/workspace"

  databricks_account_id  = var.databricks_account_id
  workspace_display_name = var.workspace_suffix != "" ? "demo-${var.environment}-${var.workspace_suffix}" : "demo-${var.environment}"
  project_id             = var.project_id
  env                    = var.environment
  vpc_id                 = data.terraform_remote_state.devops_infra.outputs.vpc_name
  subnet_id              = data.terraform_remote_state.devops_infra.outputs.subnet_names[0]
  subnet_region          = var.region
  admin_group_name       = "dbr-${var.environment}-admins"

  providers = {
    databricks = databricks.mws
  }
}

# ----------------------------------------------------------------------------
# Unity Catalog resources
# ----------------------------------------------------------------------------
# Create the Unity Catalog metastore
resource "databricks_metastore_assignment" "this" {
  metastore_id = data.databricks_metastore.existing.id
  workspace_id = module.workspace.workspace_id
}

resource "google_storage_bucket_iam_member" "uc_credential_reader" {
  for_each = local.external_locations
  bucket   = replace(each.value.url, "gs://", "")
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${module.unity_catalog.databricks_service_account_email}"

  depends_on = [module.unity_catalog]
}

resource "google_storage_bucket_iam_member" "uc_credential_writer" {
  for_each = local.external_locations
  bucket   = replace(each.value.url, "gs://", "")
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${module.unity_catalog.databricks_service_account_email}"

  depends_on = [module.unity_catalog]
}

resource "time_sleep" "wait_for_uc_iam" {
  depends_on = [
    google_storage_bucket_iam_member.uc_credential_reader,
    google_storage_bucket_iam_member.uc_credential_writer
  ]
  create_duration = "20s"
}

module "unity_catalog" {
  source                     = "./modules/unity_catalog"
  metastore_id               = data.databricks_metastore.existing.id 
  external_locations         = local.external_locations
  workspace_id               = module.workspace.workspace_id #needed for catalog binding
  env                        = var.env

  providers = {
    databricks.mws       = databricks.mws
    databricks.workspace = databricks.workspace

  }
  depends_on = [
    module.workspace, #using workspace to pull in the workspace_id
    databricks_metastore_assignment.this
  ]
}

# Create a SQL warehouse for jobs
module "warehouse_for_jobs" {
  source = "./modules/sql_warehouse"

  warehouse_name            = "${var.environment}-warehouse-for-jobs"
  cluster_size              = "Small"
  min_num_clusters          = 1
  max_num_clusters          = 2
  auto_stop_mins            = 10
  enable_serverless_compute = true

  providers = {
    databricks = databricks
  }
  depends_on = [
    module.workspace
  ]
}

# Create a general purpose cluster
module "general_cluster" {
  source = "./modules/cluster"

  cluster_name            = "${var.environment}-general-cluster"
  spark_version           = "15.4.x-scala2.12"
  node_type_id            = "n1-standard-4"
  enable_autoscaling      = true
  min_workers             = 1
  max_workers             = 4
  autotermination_minutes = 60
  data_security_mode      = "SINGLE_USER"
  runtime_engine          = "PHOTON"
  enable_elastic_disk     = true
  disk_type               = "pd-ssd"
  disk_size               = 100
  zone_id                 = "us-central1-a"
  
  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }

  custom_tags = {
    "Environment" = var.environment
    "Purpose"     = "General"
    "Team"        = "Data"
  }

  libraries = [
    {
      pypi = {
        package = "pandas==2.0.3"
      }
    },
    {
      pypi = {
        package = "numpy==1.24.3"
      }
    }
  ]

  providers = {
    databricks = databricks
  }
  depends_on = [
    module.workspace
  ]
}

# ----------------------------------------------------------------------------
# PAT for Fivetran
# ----------------------------------------------------------------------------
resource "time_rotating" "rotate_30_days" {
  rotation_days = 30
}

# Create token for Fivetran to access Databricks
resource "databricks_token" "pat_for_fivetran" {
  comment = "Token for Fivetran - Terraform (created: ${time_rotating.rotate_30_days.rfc3339})"
  # Token is valid for 60 days but is rotated after 30 days.
  # Run `terraform apply` within 60 days to refresh before it expires.
  lifetime_seconds = 60 * 24 * 60 * 60
}

resource "google_secret_manager_secret" "databricks_pat_secret" {
  project   = var.project_id
  secret_id = var.workspace_suffix != "" ? "DATABRICKS_PAT_FOR_FIVETRAN-${var.workspace_suffix}" : "DATABRICKS_PAT_FOR_FIVETRAN"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "databricks_pat_secret_version" {
  secret      = google_secret_manager_secret.databricks_pat_secret.id
  secret_data = databricks_token.pat_for_fivetran.token_value
}
# ----------------------------------------------------------------------------