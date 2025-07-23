resource "databricks_cluster" "this" {
  cluster_name            = var.cluster_name
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  driver_node_type_id     = var.driver_node_type_id != "" ? var.driver_node_type_id : var.node_type_id
  num_workers             = var.num_workers
  autotermination_minutes = var.autotermination_minutes

  dynamic "autoscale" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      min_workers = var.min_workers
      max_workers = var.max_workers
    }
  }

  spark_conf = merge(
    {
      "spark.databricks.delta.preview.enabled" : "true"
      "spark.sql.adaptive.enabled" : "true"
      "spark.sql.adaptive.coalescePartitions.enabled" : "true"
    },
    var.spark_conf
  )

  spark_env_vars = var.spark_env_vars

  dynamic "gcp_attributes" {
    for_each = var.zone_id != "" ? [1] : []
    content {
      use_preemptible_executors = var.use_preemptible_executors
      zone_id                   = var.zone_id
      boot_disk_size            = var.boot_disk_size
    }
  }

  dynamic "init_scripts" {
    for_each = var.init_scripts
    content {
      gcs {
        destination = init_scripts.value
      }
    }
  }

  custom_tags = var.custom_tags

  dynamic "library" {
    for_each = var.libraries
    content {
      dynamic "pypi" {
        for_each = contains(keys(library.value), "pypi") ? [library.value.pypi] : []
        content {
          package = pypi.value.package
          repo    = lookup(pypi.value, "repo", null)
        }
      }
      
      dynamic "maven" {
        for_each = contains(keys(library.value), "maven") ? [library.value.maven] : []
        content {
          coordinates = maven.value.coordinates
          repo        = lookup(maven.value, "repo", null)
          exclusions  = lookup(maven.value, "exclusions", null)
        }
      }
      
      dynamic "cran" {
        for_each = contains(keys(library.value), "cran") ? [library.value.cran] : []
        content {
          package = cran.value.package
          repo    = lookup(cran.value, "repo", null)
        }
      }
      
      dynamic "whl" {
        for_each = contains(keys(library.value), "whl") ? [library.value.whl] : []
        content {
          path = whl.value
        }
      }
      
      dynamic "jar" {
        for_each = contains(keys(library.value), "jar") ? [library.value.jar] : []
        content {
          path = jar.value
        }
      }
    }
  }

  data_security_mode          = var.data_security_mode
  runtime_engine              = var.runtime_engine
  single_user_name            = var.single_user_name
  enable_elastic_disk         = var.enable_elastic_disk
  disk_spec {
    disk_type {
      gcp_disk_type = var.disk_type
    }
    disk_size = var.disk_size
  }
}