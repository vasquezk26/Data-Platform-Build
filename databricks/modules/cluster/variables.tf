variable "cluster_name" {
  description = "Name of the Databricks cluster"
  type        = string
}

variable "spark_version" {
  description = "Spark version for the cluster"
  type        = string
  default     = "15.4.x-scala2.12"
}

variable "node_type_id" {
  description = "Node type for worker nodes"
  type        = string
  default     = "n1-standard-4"
}

variable "driver_node_type_id" {
  description = "Node type for driver node (defaults to node_type_id if not specified)"
  type        = string
  default     = ""
}

variable "num_workers" {
  description = "Number of worker nodes (ignored if autoscaling is enabled)"
  type        = number
  default     = 2
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling"
  type        = bool
  default     = false
}

variable "min_workers" {
  description = "Minimum number of workers when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "max_workers" {
  description = "Maximum number of workers when autoscaling is enabled"
  type        = number
  default     = 8
}

variable "autotermination_minutes" {
  description = "Number of minutes before the cluster terminates automatically"
  type        = number
  default     = 60
}

variable "spark_conf" {
  description = "Additional Spark configuration parameters"
  type        = map(string)
  default     = {}
}

variable "spark_env_vars" {
  description = "Environment variables for Spark"
  type        = map(string)
  default     = {}
}

variable "use_preemptible_executors" {
  description = "Whether to use preemptible instances for executors"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "GCP zone ID for the cluster"
  type        = string
  default     = ""
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 50
}

variable "init_scripts" {
  description = "List of GCS paths to initialization scripts"
  type        = list(string)
  default     = []
}

variable "custom_tags" {
  description = "Custom tags for the cluster"
  type        = map(string)
  default     = {}
}

variable "libraries" {
  description = "List of libraries to install on the cluster"
  type = list(object({
    pypi = optional(object({
      package = string
      repo    = optional(string)
    }))
    maven = optional(object({
      coordinates = string
      repo        = optional(string)
      exclusions  = optional(list(string))
    }))
    cran = optional(object({
      package = string
      repo    = optional(string)
    }))
    whl = optional(string)
    jar = optional(string)
  }))
  default = []
}

variable "data_security_mode" {
  description = "Data security mode for the cluster"
  type        = string
  default     = "SINGLE_USER"
  validation {
    condition = contains([
      "NONE",
      "SINGLE_USER", 
      "USER_ISOLATION",
      "LEGACY_SINGLE_USER",
      "LEGACY_PASSTHROUGH",
      "LEGACY_TABLE_ACL"
    ], var.data_security_mode)
    error_message = "Invalid data security mode."
  }
}

variable "runtime_engine" {
  description = "Runtime engine for the cluster"
  type        = string
  default     = "STANDARD"
  validation {
    condition = contains([
      "STANDARD",
      "PHOTON"
    ], var.runtime_engine)
    error_message = "Invalid runtime engine."
  }
}

variable "single_user_name" {
  description = "Single user name for SINGLE_USER data security mode"
  type        = string
  default     = ""
}

variable "enable_elastic_disk" {
  description = "Whether to enable elastic disk"
  type        = bool
  default     = true
}

variable "disk_type" {
  description = "Type of disk for worker nodes"
  type        = string
  default     = "pd-standard"
  validation {
    condition = contains([
      "pd-standard",
      "pd-ssd"
    ], var.disk_type)
    error_message = "Invalid disk type."
  }
}

variable "disk_size" {
  description = "Size of the disk in GB"
  type        = number
  default     = 100
}