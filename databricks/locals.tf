locals {
  external_locations = {
    bronze_database = {
      url        = "gs://fh-bronze-database-datalake-${var.env}-fh"
      comment    = "External location for data storage."
      group      = "dbr-${var.env}-admins"
      privileges = ["READ_FILES", "WRITE_FILES", "CREATE_EXTERNAL_TABLE", "MANAGE"]
    }
    # Add more locations as needed
    silver_database = {
      url        = "gs://fh-silver-database-datalake-${var.env}-fh"
      comment    = "Silver location"
      group      = "dbr-${var.env}-admins"
      privileges = ["READ_FILES", "WRITE_FILES", "CREATE_EXTERNAL_TABLE", "MANAGE"]
    }
  }
}