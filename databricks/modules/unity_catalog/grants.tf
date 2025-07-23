resource "databricks_grants" "external_location_grants" {
  for_each          = var.external_locations
  external_location = databricks_external_location.all[each.key].id

  grant {
    principal  = each.value.group
    privileges = each.value.privileges
  }
}