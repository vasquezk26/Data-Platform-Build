resource "databricks_sql_endpoint" "warehouse" {
  name                      = var.warehouse_name
  cluster_size              = var.cluster_size
  max_num_clusters          = var.max_num_clusters
  min_num_clusters          = var.min_num_clusters
  auto_stop_mins            = var.auto_stop_mins
  enable_serverless_compute = var.enable_serverless_compute
}
