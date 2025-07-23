variable "project" {
  type = string
}
variable "database" {
  type = string
}
variable "secret_name" {
  type = string
}

variable "group_id" {
  type = string
}

variable "port" {
  type    = number
  default = 5432
}

variable "username" {
  default = "replication_user"
  type    = string
}

variable "replication_slot" {
  type    = string
  default = "replication_dp_stream_1"
}
variable "publication_name" {
  type    = string
  default = "dp_datastream"
}

variable "sync_frequency" {
  type    = string
  default = "1440" # Sync every 24 hours
}

variable "daily_sync_time" {
  type    = string
  default = "03:00" # Sync at 3 AM
}

variable "host" {
  type        = string
  description = "DNS name or public IP address of the database instance"
}

variable "destination_schema_prefix" {
  type        = string
  description = "Prefix for the schema name in Databricks"
}

variable "schemas" {
  description = "Schema configuration with tables and sync modes"
  type = map(object({
    enabled = bool
    tables = map(object({
      enabled   = bool
      sync_mode = string
    }))
  }))
  default = {
    public = {
      enabled = true
      tables  = {}
    }
  }
}
