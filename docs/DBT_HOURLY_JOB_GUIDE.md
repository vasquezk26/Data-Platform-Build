# DBT Hourly Job Documentation

## Overview

This documentation covers the automated hourly execution of dbt models in Databricks. The system runs dbt models every hour to keep data fresh and up-to-date.

## Table of Contents

1. [Architecture](#architecture)
2. [Files Overview](#files-overview)
3. [Setup Instructions](#setup-instructions)
4. [Job Configuration](#job-configuration)
5. [Execution Flow](#execution-flow)
6. [Manual Operations](#manual-operations)
7. [Monitoring & Troubleshooting](#monitoring--troubleshooting)
8. [Access Management](#access-management)

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Databricks    │    │   DBT Project    │    │   Data Models   │
│   Scheduler     │───▶│   Execution      │───▶│   Refresh       │
│   (Hourly)      │    │   (Notebook)     │    │   (Tables)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         ▼                        ▼                        ▼
   Job Triggers          dbt run/test              Updated Tables
   Every Hour            Commands                  in Unity Catalog
```

## Files Overview

### Core Files

| File | Purpose | Location |
|------|---------|----------|
| `dbt_hourly_job.py` | Main execution notebook | `/databricks/jobs/dbt_hourly/` |
| `job_config.json` | Job configuration template | `/databricks/jobs/dbt_hourly/` |
| `SETUP_ACCESS.md` | Access configuration guide | `/databricks/jobs/dbt_hourly/` |
| `install_dbt.sh` | Cluster init script | `/scripts/` |

### Related DBT Files

| File Pattern | Purpose | Location |
|--------------|---------|----------|
| `stg__*.sql` | Staging model files | `/dbt/models/ai_chats/admin_backend/public/` |
| `models.yml` | Model configurations & aliases | `/dbt/models/ai_chats/admin_backend/public/` |
| `dbt_project.yml` | DBT project configuration | `/dbt/` |
| `profiles.yml` | Environment-specific configs | `/dbt/environments/{env}/` |

## Setup Instructions

### 1. Prerequisites

- Databricks workspace with Unity Catalog enabled
- Service principal: `dbt-prod` (or `dbt-dev` for development)
- Admin access to create jobs and clusters
- Git repository integrated with Databricks workspace

### 2. Upload Files to Databricks

```bash
# 1. Import the notebook to your workspace
# Via Databricks UI: Import > dbt_hourly_job.py

# 2. Upload init script to workspace
# Via Databricks UI: Upload install_dbt.sh to /Workspace/Repos/data-platform-infra/scripts/
```

### 3. Create Service Principal

```bash
# Create service principal
databricks service-principals create --display-name "dbt-prod"

# Grant workspace access
databricks permissions update \
  --object-type workspace \
  --object-id / \
  --access-control-list '[{"service_principal_name": "dbt-prod", "permission_level": "CAN_USE"}]'
```

### 4. Configure Unity Catalog Permissions

```sql
-- Grant catalog and schema permissions
GRANT USE CATALOG ON CATALOG `your_catalog` TO `dbt-prod`;
GRANT USE SCHEMA ON SCHEMA `your_catalog.db_admin_backend` TO `dbt-prod`;
GRANT CREATE TABLE ON SCHEMA `your_catalog.db_admin_backend` TO `dbt-prod`;
GRANT SELECT ON SCHEMA `your_catalog.bronze_admin_backend` TO `dbt-prod`;
```

### 5. Create Databricks Job

#### Option A: Via UI
1. Go to Databricks workspace → Jobs
2. Click "Create Job"
3. Configure using settings from `job_config.json`
4. Set schedule to `0 * * * *` (every hour)

#### Option B: Via API
```bash
# Update paths in job_config.json first, then:
curl -X POST \
  -H "Authorization: Bearer $DATABRICKS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @job_config.json \
  "https://$DATABRICKS_HOST/api/2.1/jobs/create"
```

## Job Configuration

### Key Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `env` | Target environment | `prod` | `dev`, `prod` |
| `models` | Model selection pattern | `""` (all) | `ai_chats.admin_backend`, `stg__patient` |
| `skip_tests` | Skip test execution | `false` | `true`, `false` |

### Schedule Configuration

```json
{
  "schedule": {
    "quartz_cron_expression": "0 * * * *",  // Every hour at minute 0
    "timezone_id": "UTC",
    "pause_status": "UNPAUSED"
  }
}
```

### Cluster Configuration

```json
{
  "new_cluster": {
    "cluster_name": "dbt-hourly-job-cluster",
    "spark_version": "13.3.x-scala2.12",
    "node_type_id": "i3.xlarge",
    "num_workers": 2,
    "data_security_mode": "USER_ISOLATION",
    "single_user_name": "dbt-prod"
  }
}
```

## Execution Flow

### 1. Job Trigger
- **Automatic**: Every hour at minute 0 (e.g., 1:00, 2:00, 3:00)
- **Manual**: Via Databricks UI or API call

### 2. Cluster Lifecycle
```
Cluster Start → Init Script → DBT Install → Notebook Ready
     ↓              ↓            ↓             ↓
 ~2-3 mins      ~1-2 mins    ~30 secs      Ready
```

### 3. Notebook Execution Steps

```python
# Step 1: Parameter Setup
env = "prod"                    # From job parameter
models = ""                     # From job parameter  
skip_tests = False              # From job parameter

# Step 2: Environment Configuration
os.environ['_ENV'] = env
os.chdir("/Workspace/Repos/your-repo/dbt")

# Step 3: DBT Model Execution
subprocess.run(['dbt', 'run', '--profiles-dir', f'environments/{env}'])

# Step 4: Test Execution (if not skipped)
subprocess.run(['dbt', 'test', '--profiles-dir', f'environments/{env}'])

# Step 5: Notification
send_notification(success_status, env, models)
```

### 4. Data Model Updates

| Source File | Target Table | Alias |
|-------------|--------------|-------|
| `stg__patient.sql` | `your_catalog.db_admin_backend.patient` | `patient` |
| `stg__exercise.sql` | `your_catalog.db_admin_backend.exercise` | `exercise` |
| `stg__biomarker.sql` | `your_catalog.db_admin_backend.biomarker` | `biomarker` |

## Manual Operations

### Run Job Manually

#### Via Databricks UI
1. Navigate to Jobs → "DBT Hourly Models Execution"
2. Click "Run Now"
3. Optionally modify parameters:
   - Change `env` to `dev` for development
   - Set `models` to `stg__patient` for specific model
   - Set `skip_tests` to `true` to skip testing

#### Via API
```bash
# Get job ID first
JOB_ID=$(databricks jobs list --output json | jq '.jobs[] | select(.settings.name=="DBT Hourly Models Execution") | .job_id')

# Run with default parameters
databricks jobs run-now --job-id $JOB_ID

# Run with custom parameters
databricks jobs run-now --job-id $JOB_ID --notebook-params '{"env": "dev", "models": "stg__patient"}'
```

### Run DBT Commands Directly

```bash
# SSH into cluster or use Databricks notebook
cd /Workspace/Repos/your-repo/dbt

# Run all models
dbt run --profiles-dir environments/prod

# Run specific models
dbt run --models ai_chats.admin_backend --profiles-dir environments/prod

# Run tests
dbt test --profiles-dir environments/prod

# Debug configuration
dbt debug --profiles-dir environments/prod
```

## Monitoring & Troubleshooting

### Job Monitoring

#### Databricks UI
- **Jobs Page**: View run history, success/failure rates
- **Run Details**: Click on specific run for detailed logs
- **Cluster Logs**: View driver/executor logs for debugging

#### Key Metrics to Monitor
- **Success Rate**: Target >95% success rate
- **Execution Time**: Typical run: 5-15 minutes
- **Data Freshness**: Tables updated every hour
- **Error Patterns**: Common failure reasons

### Common Issues & Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Permission Denied** | `Access denied to catalog/schema` | Check Unity Catalog permissions for `dbt-prod` |
| **Cluster Start Failure** | Job fails before notebook runs | Verify cluster configuration and quotas |
| **DBT Command Failure** | `dbt run` returns non-zero exit code | Check dbt logs, verify profiles.yml |
| **Profile Not Found** | `Could not find profile` | Ensure profiles.yml exists in correct path |
| **Network Issues** | Timeouts, connection errors | Check network policies, firewall rules |

### Debugging Steps

1. **Check Job Run Details**
   ```
   Jobs UI → Select failed run → View logs
   ```

2. **Verify DBT Configuration**
   ```bash
   # In notebook or cluster terminal
   dbt debug --profiles-dir environments/prod
   ```

3. **Test DBT Commands Manually**
   ```bash
   # Run single model to isolate issues
   dbt run --models stg__patient --profiles-dir environments/prod
   ```

4. **Check Cluster Logs**
   ```
   Cluster UI → Event Log → Driver Logs
   ```

## Access Management

### Service Principal Permissions

```sql
-- Required Unity Catalog permissions
GRANT USE CATALOG ON CATALOG `prod_catalog` TO `dbt-prod`;
GRANT USE SCHEMA ON SCHEMA `prod_catalog.db_admin_backend` TO `dbt-prod`;
GRANT CREATE TABLE ON SCHEMA `prod_catalog.db_admin_backend` TO `dbt-prod`;
GRANT SELECT ON SCHEMA `prod_catalog.bronze_admin_backend` TO `dbt-prod`;

-- For development environment
GRANT USE CATALOG ON CATALOG `dev_catalog` TO `dbt-dev`;
GRANT USE SCHEMA ON SCHEMA `dev_catalog.dev_db_admin_backend` TO `dbt-dev`;
GRANT CREATE TABLE ON SCHEMA `dev_catalog.dev_db_admin_backend` TO `dbt-dev`;
```

### Job Access Control

Jobs are accessible to:
- Service principal: `dbt-prod` (CAN_MANAGE_RUN)
- Group: `admins` (CAN_MANAGE_RUN)

---

## Quick Reference

### File Locations
- **Notebook**: `/Workspace/Repos/data-platform-infra/databricks/jobs/dbt_hourly/dbt_hourly_job`
- **DBT Project**: `/Workspace/Repos/data-platform-infra/dbt/`
- **Profiles**: `/Workspace/Repos/data-platform-infra/dbt/environments/prod/profiles.yml`

### Key Commands
```bash
# Manual job run
databricks jobs run-now --job-id <JOB_ID>

# DBT debug
dbt debug --profiles-dir environments/prod

# Run specific models
dbt run --models ai_chats.admin_backend --profiles-dir environments/prod
```

### Support Contacts
- **Data Platform Team**: data-platform@company.com
- **Slack Channel**: #data-platform-support

---

*Last Updated: [Current Date]*