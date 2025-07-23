module "postgresql" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "~> 25.2"

  name                = "${var.short_env}-transaction-stripe"
  project_id          = local.project_id
  region              = var.region
  zone                = "${var.region}-a"
  database_version    = "POSTGRES_15"
  tier                = var.db_tier
  availability_type   = var.cloud_sql_availability_type
  disk_size           = var.disk_size
  disk_type           = "PD_SSD"
  deletion_protection = var.deletion_protection

  # Database flags
  database_flags = [
    {
      name  = "max_connections"
      value = "100"
    },
    {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  ]

  # Backup configuration
  backup_configuration = {
    enabled                        = true
    point_in_time_recovery_enabled = true
    start_time                     = "02:00"
    transaction_log_retention_days = 7
  }

  # Insights configuration
  insights_config = {
    query_insights_enabled  = true
    query_string_length     = 1024
    record_application_tags = true
    record_client_address   = false
  }

  # IP configuration
  ip_configuration = {
    ipv4_enabled       = true
    ssl_mode           = "ENCRYPTED_ONLY"
    allocated_ip_range = null
    private_network    = null
    authorized_networks = [
      {
        name  = "fivetran-sass"
        value = "35.234.176.144/29"
      }
    ]
  }

  password_validation_policy_config = {
    # Complexity Default - password must contain at least one lowercase, one uppercase, one number and one non-alphanumeric characters.
    complexity                  = "COMPLEXITY_DEFAULT"
    disallow_username_substring = true
    min_length                  = 8
    reuse_interval              = 1
  }

  # Database
  db_name = "transaction-stripe"

  user_name     = "postgres"
  user_password = var.transaction_stripe_fivetran_db_password

  # Native Users
  additional_users = [
    {
      name            = "fivetran"
      password        = var.transaction_stripe_fivetran_db_password
      random_password = false
    }
  ]

  # IAM Users
  iam_users = [
    {
      id    = "Data Infra Admins"
      email = "data-infra-admins@functionhealth.com"
      type  = "CLOUD_IAM_GROUP"
    },
    {
      id    = "Stripe Restricted PII Reader"
      email = "gcp-prod-stripe-restricted-pii-reader@functionhealth.com"
      type  = "CLOUD_IAM_GROUP"
    }
  ]
}