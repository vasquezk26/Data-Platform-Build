variable "metastore_id" {
  description = "The ID of the Databricks Unity Catalog metastore"
  type        = string
}

variable "external_locations" {
  description = "Map of external locations to create"
  type = map(object({
    url        = string
    comment    = string
    group      = string
    privileges = list(string)
  }))
}

variable "workspace_id" {
  description = "The ID of the Databricks workspace to bind the catalog to"
  type        = string
}

variable "env" {
  description = "Short Environment Identifier (dev, prod)"
  type        = string
}