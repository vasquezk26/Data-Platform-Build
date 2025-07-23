output "sql_warehouse_host" {
  value = databricks_sql_endpoint.warehouse.odbc_params[0].hostname
}

output "sql_warehouse_http_path" {
  value = databricks_sql_endpoint.warehouse.odbc_params[0].path
}