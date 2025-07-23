module "main" {
  source                                  = "../."
  deletion_protection                     = false
  transaction_stripe_fivetran_db_password = var.transaction_stripe_fivetran_db_password
}
