resource "databricks_external_location" "all" {
  for_each        = var.external_locations
  metastore_id    = var.metastore_id
  name            = each.key
  url             = each.value.url
  credential_name = databricks_storage_credential.main.name
  comment         = each.value.comment
  # skip_validation = true
  # The skip_validation is set to true to avoid validation errors during creation. This is just a test.
  depends_on = [ databricks_storage_credential.main ]
}

resource "random_id" "credential_suffix" {
  byte_length = 4
}

resource "databricks_storage_credential" "main" {
  name = "external_creds_${random_id.credential_suffix.id}"
  databricks_gcp_service_account {}
}

#Adding a single catalog
resource "databricks_catalog" "fh_bronze" {
  name         = "fh_bronze"
  storage_root = var.external_locations.bronze_database.url
  comment      = var.external_locations.bronze_database.comment
  properties = {
    purpose = "Bronze data lake"
  }
}

resource "databricks_grants" "fh_bronze" {
  catalog = databricks_catalog.fh_bronze.name
  # grant {
  #   principal  = var.external_locations.bronze_database.group
  #   privileges = ["BROWSE", "USE_CATALOG", "CREATE_SCHEMA", "USE_SCHEMA", "CREATE_TABLE"]
  # }

  grant {
    principal = "dbr-${var.env}-admins"
    privileges = ["USE_CATALOG", "USE_SCHEMA", "APPLY_TAG", "BROWSE", "EXECUTE", "SELECT", "MODIFY", 
    "CREATE_SCHEMA", "CREATE_TABLE", "CREATE_MODEL", "CREATE_FUNCTION", "MANAGE"]
  }

  grant {
    principal = "dbt-${var.env}"
    privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "EXECUTE", "SELECT", "MODIFY", 
    "CREATE_SCHEMA", "CREATE_TABLE", "CREATE_MODEL", "CREATE_FUNCTION"]
  }
}

resource "databricks_workspace_binding" "fh_bronze" {
  securable_name = databricks_catalog.fh_bronze.name
  workspace_id   = var.workspace_id
}

resource "databricks_catalog" "silver" {
  name         = "silver"
  storage_root = var.external_locations.silver_database.url
  comment      = var.external_locations.silver_database.comment
  properties = {
    purpose = "Silver data lake"
  }
}

resource "databricks_grants" "silver" {
  catalog = databricks_catalog.silver.name
  grant {
    principal  = var.external_locations.silver_database.group
    privileges = ["USE_CATALOG", "USE_SCHEMA", "APPLY_TAG", "BROWSE", "EXECUTE", "SELECT", 
      "MODIFY", "CREATE_SCHEMA", "CREATE_TABLE", "CREATE_MODEL", "CREATE_FUNCTION", "MANAGE"]
  }

  grant {
    principal = "dbt-${var.env}"
    privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "EXECUTE", "SELECT", "MODIFY", 
    "CREATE_SCHEMA", "CREATE_TABLE", "CREATE_MODEL", "CREATE_FUNCTION"]
  }
}

resource "databricks_workspace_binding" "silver" {
  securable_name = databricks_catalog.silver.name
  workspace_id   = var.workspace_id
}