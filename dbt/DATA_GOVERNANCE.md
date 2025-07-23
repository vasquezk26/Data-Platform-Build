# Data Governance System

## Overview

This PR adds automated data governance to our Databricks setup using dbt. It handles column-level data masking, different access levels for different user groups, and makes sure PII data stays protected no matter what.

## Architecture

### Hybrid Policy-First Design

The system uses a two-tier approach to ensure data is protected from the moment it's created:

1. **Catalog-Level Safety Net** (`on-run-start`) - Default-deny policy that masks all data
2. **Schema-Specific Fine-Grained Policies** (`on-run-end`) - Role-based access control

```
dbt run
    ↓
on-run-start → Pre-flight validation → Create governance schema → Deploy catalog-wide default-deny policy
    ↓
🛡️ ALL DATA MASKED BY DEFAULT
    ↓
Models created (instantly protected by catalog policy)
    ↓
Post-hooks apply column tags
    ↓
on-run-end → Deploy schema-specific role-based policies
    ↓
Role-Based Data Access Applied
```

## Key Features

### ✅ Fail-Safe Security
- **Default-deny posture**: All data masked until explicitly allowed
- **Eliminates timing windows**: Data protected before model creation
- **Fail toward over-protection**: System errors result in data masking, not exposure

### ✅ Universal PII Protection
- **No exceptions**: ALL users (including admins) see PII data as 'REDACTED'
- **Tag-based**: Any column tagged with `class=pii` is always masked
- **Immutable**: No role can override PII protection

### ✅ Role-Based Access Control
- **Admins**: See all data except PII
- **Health Readers**: See safe public + health-internal data (no PII)
- **Regular Users**: See only safe public data (no PII)

### ✅ Environment-Aware
- **Dev**: Uses `dbr-dev-admins` + `dbr-dev-health-reader-beta`
- **Prod**: Uses `dbr-prod-admins` + `dbr-prod-health-reader-beta`
- **Automatic switching**: Based on `_ENV` environment variable

## File Structure

```
dbt/
├── macros/
│   ├── deploy_catalog_level_policy.sql      # Catalog-wide safety net
│   ├── deploy_masking_functions.sql         # Schema-specific policies
│   ├── apply_databricks_column_tags.sql     # Column tagging (post-hook)
│   └── get_known_groups.sql                 # Environment-aware groups
├── dbt_project.yml                          # Hybrid hooks configuration
└── cloudbuild_dbt.yaml                      # CI/CD pipeline

fivetran/bronze_columns/
└── admin_backend.csv                        # Governance metadata source

scripts/
└── generate_admin_backend_models_yml.py     # Dynamic model generation
```

## How It Works

### 1. CSV-Driven Governance (Currently only)
- **Source**: `fivetran/bronze_columns/admin_backend.csv`
- **Structure**: Database, Schema, Table, Column, Class, Sensitivity
- **Example**:
  ```csv
  admin_backend,public,disease,name,none,public
  admin_backend,public,patient,ssn,pii,internal
  admin_backend,public,biomarker,result,health,internal
  ```

### 2. Dynamic Model Generation (Currently only)
- **Script**: `generate_admin_backend_models_yml.py`
- **Function**: Reads CSV and creates `models.yml` with column metadata
- **Execution**: Runs in CI/CD before dbt compilation

### 3. Column Tagging
- **Macro**: `apply_databricks_column_tags.sql`
- **Trigger**: Post-hook after each model creation
- **Function**: Applies Unity Catalog tags to columns based on metadata

### 4. Policy Deployment
- **Catalog Policy**: Creates default-deny safety net before any models run
- **Schema Policies**: Creates role-specific access rules after models complete

## Access Control Matrix(Example Use)

| Column Tags | Regular Users | Health Readers | Admins | Notes |
|------------|---------------|----------------|---------|-------|
| `class=none, sensitivity=public` | ✅ Visible | ✅ Visible | ✅ Visible | Safe for everyone |
| `class=health, sensitivity=internal` | ❌ Masked | ✅ Visible | ✅ Visible | Health readers only |
| `class=none, sensitivity=internal` | ❌ Masked | ❌ Masked | ✅ Visible | Admins only |
| `class=genetic, sensitivity=any` | ❌ Masked | ❌ Masked | ✅ Visible | Admins only |
| `class=pii, sensitivity=any` | ❌ Masked | ❌ Masked | ❌ Masked | **NO ONE sees PII** |

## Setup and Deployment

### Prerequisites
- Databricks Unity Catalog enabled
- dbt with Databricks adapter
- Service principal with `USE CATALOG`, `CREATE_SCHEMA`,`CREATE_FUNCTION`,`USE_SCHEMA`, `MANAGE` permissions
- Required Databricks groups created

### Environment Variables
```yaml
# CI/CD Pipeline
_ENV: dev  # or 'prod'
```

### Databricks Groups Required (Currently only available)
- **Dev**: `dbr-dev-admins`, `dbr-dev-health-reader-beta`
- **Prod**: `dbr-prod-admins`, `dbr-prod-health-reader-beta`

### Deployment Steps
1. **Generate models.yml**: `python scripts/generate_admin_backend_models_yml.py`
2. **Run dbt**: `dbt run` (triggers all governance macros automatically)
3. **Verify**: Check Unity Catalog for tags and policies

## Testing

### Local Testing
```bash
# Test single model with governance
dbt run -s biomarker

# Check governance logs
# Look for: "🛡️ SAFETY NET ACTIVE" and "✅ All schemas processed successfully"
```

### Group-Based Testing
Create test policies in Databricks SQL Editor to simulate different user groups:

```sql
-- Test as health reader
CREATE OR REPLACE POLICY test_health_reader_policy
ON SCHEMA silver.db_admin_backend
COLUMN MASK silver.db_admin_backend.mask_restricted
TO `your_email@functionhealth.com`
FOR TABLES
MATCH COLUMNS NOT (
  (hasTagValue('class','none') AND hasTagValue('sensitivity','public')) OR
  (hasTagValue('class','health') AND hasTagValue('sensitivity','internal'))
) OR hasTagValue('class','pii') AS col
ON COLUMN col;
```

## Troubleshooting

### Common Issues

#### "USE CATALOG permissions" error
- **Cause**: Service principal lacks Unity Catalog permissions
- **Fix**: Grant `USE CATALOG` permission on target catalog
- **Permissions Needed**: `MANAGE`,`USE_CATALOG`,`CREATE_SCHEMA`,`USE_SCHEMA`,`CREATE_FUNCTION`,`MODIFY`,`EXECUTE` 

#### "Schema not found" error  
- **Cause**: Governance schema doesn't exist
- **Fix**: System auto-creates `governance` schema on first run

#### Views not getting masked
- **Expected**: Schema-level policies work on both tables and views
- **Check**: Verify tags are applied to view columns

#### User in multiple groups
- **Behavior**: Most permissive policy wins
- **Best Practice**: Avoid overlapping group memberships

### Debug Mode
Add debug logs to any macro:
```sql
{% do log("DEBUG: execute=" ~ execute ~ ", target.type=" ~ target.type, info=True) %}
```

## Security Considerations

### Data Classification
- **PII**: Social Security Numbers, Credit Cards, Personal IDs
- **Health**: Medical diagnoses, treatment data, health records  
- **Genetic**: DNA sequences, genetic markers, hereditary data
- **None**: Non-sensitive business data

### Access Principles
1. **Least Privilege**: Users get minimum access needed for their role
2. **Default Deny**: All data masked until explicitly allowed
3. **Immutable PII Protection**: No role overrides for personally identifiable information
4. **Audit Trail**: All governance actions logged in dbt runs

### Compliance
- **HIPAA**: Health data protected with role-based access
- **GDPR**: PII universally masked across all roles

## Maintenance

### Adding New Data Sources
1. Update CSV with new table/column metadata
2. Add class/sensitivity tags for each column
3. Run `generate_admin_backend_models_yml.py`
4. Deploy with `dbt run`

### Modifying Access Rules
1. Update policy logic in `deploy_masking_functions.sql`
2. Test with role simulation
3. Deploy via dbt pipeline

### Adding New Environments
1. Create new Databricks groups (e.g., `dbr-staging-admins`)
2. Update `get_known_groups.sql` with new environment logic
3. Configure `_ENV` variable in CI/CD

## Support

### Logs and Monitoring
- **dbt logs**: Governance execution details
- **Unity Catalog**: Policy and tag audit logs  
- **Databricks**: Query history for access patterns

### Key Log Messages
- `🛡️ SAFETY NET ACTIVE`: Catalog policy deployed successfully
- `✅ All schemas processed successfully`: All governance applied
- `🚫 ALWAYS MASKED FOR EVERYONE: class=pii`: PII protection active

For issues or questions, check the troubleshooting section above or consult the team's data governance documentation.