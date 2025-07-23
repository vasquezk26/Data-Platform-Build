{% macro deploy_catalog_level_policy() %}
  {% do log("DEBUG: execute=" ~ execute ~ ", target.type=" ~ target.type, info=True) %}
  {% if execute and target.type == 'databricks' %}
    
    {% do log("🚀 Deploying catalog-level safety net policy...", info=True) %}
    {% do log("🔧 Environment: " ~ env_var('_ENV', 'dev'), info=True) %}
    
    {# Create governance schema if it doesn't exist #}
    {% set create_schema_sql %}
      CREATE SCHEMA IF NOT EXISTS `{{ target.catalog }}`.`governance`
      COMMENT 'Schema for data governance functions and policies'
    {% endset %}
    
    {% do log("📝 Creating governance schema: " ~ target.catalog ~ ".governance", info=True) %}
    {% set schema_result = run_query(create_schema_sql) %}
    {% do log("✅ Governance schema created/verified", info=True) %}
    
    {# Create global masking function at catalog level #}
    {% set create_catalog_function_sql %}
      CREATE FUNCTION IF NOT EXISTS `{{ target.catalog }}`.`governance`.`mask_restricted_default`(val STRING)
      RETURNS STRING
      LANGUAGE SQL
      DETERMINISTIC
      COMMENT 'Default masking function for catalog-level safety net - returns REDACTED for unauthorized users'
      RETURN 'REDACTED'
    {% endset %}
    
    {% do log("📝 Creating catalog-level masking function: " ~ target.catalog ~ ".governance.mask_restricted_default", info=True) %}
    {% set function_result = run_query(create_catalog_function_sql) %}
    {% do log("✅ Catalog-level masking function created successfully", info=True) %}
    
    {# Apply catalog-wide default-deny policy #}
    {# This creates a safety net that masks ALL data in the catalog by default #}
    {# Only admins and the service principal running dbt can see unmasked data #}
    {# Schema-specific policies will later provide fine-grained access control #}
    
    {% set admin_group = get_admin_group() %}
    {% do log("🔑 Using admin group: " ~ admin_group, info=True) %}
    
    {# Get current service principal ID dynamically #}
    {# This ensures the dbt service principal can access system metadata during deployment #}
    {% set current_user_query %}
      SELECT current_user() as current_user
    {% endset %}
    {% set current_user_result = run_query(current_user_query) %}
    {% set current_user_value = current_user_result.columns[0].values()[0] %}
    {% do log("🔧 Using service principal: " ~ current_user_value, info=True) %}
    
    {% set catalog_policy_sql %}
      CREATE OR REPLACE POLICY catalog_default_deny
      ON CATALOG `{{ target.catalog }}`
      COMMENT 'Catalog-wide safety net: mask everything by default'
      COLUMN MASK `{{ target.catalog }}`.`governance`.`mask_restricted_default`
      TO `account users`                                    -- Apply to all users
      EXCEPT `{{ admin_group }}`, `{{ current_user_value }}` -- Except admins and dbt service principal
      FOR TABLES                                            -- Apply to all tables in catalog
      MATCH COLUMNS TRUE AS col                             -- Match all columns
      ON COLUMN col                                         -- Apply masking to matched columns
    {% endset %}
    
    {% do log("📝 Applying catalog-wide default-deny policy to catalog: " ~ target.catalog, info=True) %}
    {% set policy_result = run_query(catalog_policy_sql) %}
    {% do log("✅ Catalog-wide safety net policy applied successfully", info=True) %}
    
    {% do log("🛡️  SAFETY NET ACTIVE: All data in catalog is now masked by default", info=True) %}
    {% do log("ℹ️  Schema-specific policies will provide fine-grained access control", info=True) %}
    
  {% else %}
    {% do log("⏩ SKIPPED: Catalog-level policy deployment (not executing or not Databricks)", info=True) %}
  {% endif %}
{% endmacro %}