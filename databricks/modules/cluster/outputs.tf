output "cluster_id" {
  description = "ID of the created cluster"
  value       = databricks_cluster.this.id
}

output "cluster_name" {
  description = "Name of the created cluster"
  value       = databricks_cluster.this.cluster_name
}

output "default_tags" {
  description = "Default tags applied to the cluster"
  value       = databricks_cluster.this.default_tags
}

output "driver_node_type_id" {
  description = "Driver node type ID"
  value       = databricks_cluster.this.driver_node_type_id
}

output "node_type_id" {
  description = "Worker node type ID"
  value       = databricks_cluster.this.node_type_id
}

output "spark_version" {
  description = "Spark version of the cluster"
  value       = databricks_cluster.this.spark_version
}

output "state" {
  description = "Current state of the cluster"
  value       = databricks_cluster.this.state
}

output "url" {
  description = "URL of the cluster in Databricks workspace"
  value       = databricks_cluster.this.url
}