module "main" {
  source                                  = "../."
  deletion_protection                     = true
  env                                     = "prod"
  disk_size                               = 50
  db_tier                                 = "db-custom-4-8192"
  transaction_stripe_fivetran_db_password = var.transaction_stripe_fivetran_db_password
  cloud_sql_availability_type           = "REGIONAL"
}
