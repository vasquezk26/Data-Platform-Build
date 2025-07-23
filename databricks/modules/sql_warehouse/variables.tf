variable "warehouse_name" {
  description = "Name of the SQL Warehouse"
  type        = string
}

variable "cluster_size" {
  description = "Warehouse cluster size (e.g., 2X-Small, Small, Medium)"
  type        = string
  default     = "2X-Small"
}

variable "min_num_clusters" {
  description = "Minimum number of clusters"
  type        = number
  default     = 1
}

variable "max_num_clusters" {
  description = "Maximum number of clusters"
  type        = number
  default     = 1
}

variable "auto_stop_mins" {
  description = "Minutes before auto shutdown"
  type        = number
  default     = 10
}

variable "enable_serverless_compute" {
  description = "Enable serverless SQL Warehouse"
  type        = bool
  default     = true
}
