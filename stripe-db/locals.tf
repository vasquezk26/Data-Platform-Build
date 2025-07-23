locals {
  # Map of environment to project ID
  project_ids = {
    dev     = "function-health-dev-env"
    staging = "function-health-staging-env"
    prod    = "function-health-prod-env"
  }

  # Get project ID based on short_env variable, with error if invalid short_env
  project_id = try(
    local.project_ids[var.short_env],
    # If short_env not found in map, show error with available short_env's
    fail("Invalid environment '${var.short_env}'. Must be one of: ${join(", ", keys(local.project_ids))}")
  )
}