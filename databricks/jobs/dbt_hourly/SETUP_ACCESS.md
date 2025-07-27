# Databricks Access Setup for DBT Hourly Job

## Required Permissions

### 1. Workspace Permissions
The service principal or user running the job needs:
- **Workspace access**: Ability to access the Databricks workspace
- **Repo access**: Read access to the Git repository containing dbt code
- **Notebook execution**: Permission to run notebooks

### 2. Cluster Permissions
- **Create clusters**: For job-managed clusters
- **Attach to clusters**: If using existing shared clusters
- **Cluster usage**: Permission to run workloads on assigned clusters

### 3. Unity Catalog Permissions
For dbt to access and create tables:
```sql
-- Grant permissions to service principal or user
GRANT USE CATALOG ON CATALOG `your_catalog` TO `service-principal-name`;
GRANT USE SCHEMA ON SCHEMA `your_catalog.db_admin_backend` TO `service-principal-name`;
GRANT CREATE TABLE ON SCHEMA `your_catalog.db_admin_backend` TO `service-principal-name`;
GRANT SELECT ON SCHEMA `your_catalog.bronze_schema` TO `service-principal-name`;
```

### 4. Secret Scope Access (if using)
If your dbt profiles use secrets:
```bash
# Grant access to secret scope
databricks secrets put-acl --scope dbt-secrets --principal service-principal-name --permission READ
```

## Setup Options

### Option A: Service Principal (Recommended)
Create a dedicated service principal for automated jobs:

```bash
# Create service principal
databricks service-principals create --display-name "dbt-hourly-job-sp"

# Add to workspace
databricks workspace-conf update --conf '{"enableTokensConfig": "true"}'

# Grant workspace access
databricks permissions update --object-type workspace --object-id / --access-control-list '[{"service_principal_name": "dbt-hourly-job-sp", "permission_level": "CAN_USE"}]'
```

### Option B: Dedicated User Account
Create a dedicated user account for the dbt job:
1. Add user to Databricks workspace
2. Assign appropriate groups/permissions
3. Generate personal access token for authentication

## Job Configuration Updates

Update your `job_config.json` to include access settings:

```json
{
  "name": "DBT Hourly Models Execution",
  "access_control_list": [
    {
      "service_principal_name": "dbt-prod",
      "permission_level": "CAN_MANAGE_RUN"
    },
    {
      "group_name": "admins", 
      "permission_level": "CAN_MANAGE_RUN"
    }
  ],
  "job_clusters": [
    {
      "job_cluster_key": "dbt_cluster",
      "new_cluster": {
        "cluster_name": "dbt-hourly-job-cluster",
        "spark_version": "13.3.x-scala2.12",
        "node_type_id": "i3.xlarge",
        "num_workers": 2,
        "data_security_mode": "USER_ISOLATION",
        "single_user_name": "dbt-prod"
      }
    }
  ]
}
```

## Environment-Specific Permissions

### Development Environment
```sql
-- Dev permissions (more restrictive)
GRANT USE CATALOG ON CATALOG `dev_catalog` TO `dbt-dev-sp`;
GRANT USE SCHEMA ON SCHEMA `dev_catalog.dev_db_admin_backend` TO `dbt-dev-sp`;
GRANT CREATE TABLE ON SCHEMA `dev_catalog.dev_db_admin_backend` TO `dbt-dev-sp`;
```

### Production Environment
```sql
-- Production permissions
GRANT USE CATALOG ON CATALOG `prod_catalog` TO `dbt-prod-sp`;
GRANT USE SCHEMA ON SCHEMA `prod_catalog.db_admin_backend` TO `dbt-prod-sp`;
GRANT CREATE TABLE ON SCHEMA `prod_catalog.db_admin_backend` TO `dbt-prod-sp`;
GRANT SELECT ON SCHEMA `prod_catalog.bronze_admin_backend` TO `dbt-prod-sp`;
```

## Verification Steps

1. **Test cluster access**:
   ```python
   # In a notebook, verify the service principal can create clusters
   spark.sql("SHOW CATALOGS").show()
   ```

2. **Test dbt execution**:
   ```bash
   # Test dbt commands with the service principal
   dbt debug --profiles-dir environments/prod
   dbt run --models ai_chats.admin_backend --dry-run
   ```

3. **Test job execution**:
   - Run the job manually first
   - Check logs for permission errors
   - Verify tables are created in correct schemas

## Security Best Practices

1. **Principle of least privilege**: Only grant minimum required permissions
2. **Environment separation**: Use different service principals for dev/prod
3. **Regular access review**: Audit permissions quarterly
4. **Token rotation**: Rotate access tokens regularly
5. **Monitoring**: Set up alerts for failed job runs due to permission issues

## Troubleshooting Common Issues

### "Access Denied" Errors
- Check Unity Catalog permissions
- Verify service principal has workspace access
- Ensure cluster permissions are correct

### "Cluster Not Found" Errors
- Verify cluster creation permissions
- Check job cluster configuration
- Ensure service principal can access specified node types

### "Schema Not Found" Errors
- Check catalog and schema permissions
- Verify schema names match dbt profiles
- Ensure proper environment variable setup