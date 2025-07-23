resource "google_datastream_connection_profile" "source" {
  display_name          = "Postgresql Source"
  location              = "us-central1"
  connection_profile_id = "source-profile"

  postgresql_profile {
    hostname = "dummy-db"
    port     = 5432
    username = "dp_stream"
    password = "demo"
    database = "postgres"
  }
}

/* iLRyYAkh+8~^[%iI */
resource "google_datastream_connection_profile" "destination" {
  display_name          = "BigQuery Destination"
  location              = "us-central1"
  connection_profile_id = "destination-profile"

  bigquery_profile {}
}

resource "google_datastream_stream" "default" {
  display_name  = "Postgres to GCS"
  location      = "us-central1"
  stream_id     = "psql-to-gcs-stream"
  desired_state = "RUNNING"

  source_config {
    source_connection_profile = google_datastream_connection_profile.source.id
    postgresql_source_config {
      max_concurrent_backfill_tasks = 12
      publication                   = "publication"
      replication_slot              = "replication_dp_stream_1"
      include_objects {
        postgresql_schemas {
          schema = "public"
          # postgresql_tables {
          #     table = ""
          #     postgresql_columns {
          #         column = ""
          #     }
          # }
        }
      }
      # exclude_objects {
      #     postgresql_schemas {
      #         schema = "schema"
      #         postgresql_tables {
      #             table = "table"
      #             postgresql_columns {
      #                 column = "column"
      #             }
      #         }
      #     }
      # }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.destination.id
    gcs_destination_config {
      path                   = "gs://fh-dev-ai_datastream/dummy-db"
      file_rotation_mb       = 200
      file_rotation_interval = "60s"
      json_file_format {
        schema_file_format = "NO_SCHEMA_FILE"
        compression        = "GZIP"
      }
    }
  }

  backfill_all {
    # postgresql_excluded_objects {
    #     postgresql_schemas {
    #         schema = "public"
    #         postgresql_tables {
    #             table = "table"
    #             postgresql_columns {
    #                 column = "column"
    #             }
    #         }
    #     }
    # }
  }
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}