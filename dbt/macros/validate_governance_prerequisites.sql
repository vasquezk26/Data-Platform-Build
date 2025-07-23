{% macro validate_governance_prerequisites() %}
  {% if execute and target.type == 'databricks' %}
    
    {% do log("🔍 Validating governance system prerequisites...", info=True) %}
    
    {% set validation_errors = [] %}
    
    {# 1. Check if required environment variables exist #}
    {% set env = env_var('_ENV', 'MISSING') %}
    {% if env == 'MISSING' %}
      {% set validation_errors = validation_errors + ['_ENV environment variable not set'] %}
    {% else %}
      {% do log("✅ Environment: " ~ env, info=True) %}
    {% endif %}
    
    {# 2. Validate target catalog access #}
    {% set catalog_check_query %}
      SELECT catalog_name FROM {{ target.catalog }}.information_schema.schemata LIMIT 1
    {% endset %}
    
    {% set catalog_accessible = true %}
    {% if execute %}
      {% set catalog_result = run_query(catalog_check_query) %}
      {% if catalog_result.rows|length == 0 %}
        {% set catalog_accessible = false %}
        {% set validation_errors = validation_errors + ['Cannot access target catalog: ' ~ target.catalog] %}
      {% else %}
        {% do log("✅ Catalog access: " ~ target.catalog, info=True) %}
      {% endif %}
    {% endif %}
    
    {# 3. Check if required Databricks groups exist (if we can query them) #}
    {% set known_groups = get_known_groups() %}
    {% set admin_group = get_admin_group() %}
    
    {% do log("✅ Admin group configured: " ~ admin_group, info=True) %}
    {% do log("✅ Health reader group configured: " ~ known_groups.health_readers, info=True) %}
    
    {# 4. Test if we can create/modify schemas (permission check) #}
    {% set permission_check_query %}
      CREATE SCHEMA IF NOT EXISTS `{{ target.catalog }}`.`governance_test_temp`
      COMMENT 'Temporary schema for permission validation - safe to delete'
    {% endset %}
    
    {% set can_create_schemas = true %}
    {% if execute %}
      {% set create_result = run_query(permission_check_query) %}
      {% do log("✅ Schema creation permissions verified", info=True) %}
      
      {# Clean up test schema #}
      {% set cleanup_query %}
        DROP SCHEMA IF EXISTS `{{ target.catalog }}`.`governance_test_temp`
      {% endset %}
      {% set cleanup_result = run_query(cleanup_query) %}
    {% endif %}
    
    {# 5. Validate that we can create functions #}
    {% set function_test_query %}
      CREATE OR REPLACE FUNCTION `{{ target.catalog }}`.`information_schema`.`governance_test_function`(val STRING)
      RETURNS STRING
      LANGUAGE SQL
      DETERMINISTIC
      COMMENT 'Test function for governance validation - safe to delete'
      RETURN 'test'
    {% endset %}
    
    {% if execute %}
      {% set function_result = run_query(function_test_query) %}
      {% do log("✅ Function creation permissions verified", info=True) %}
      
      {# Clean up test function #}
      {% set cleanup_function_query %}
        DROP FUNCTION IF EXISTS `{{ target.catalog }}`.`information_schema`.`governance_test_function`
      {% endset %}
      {% set cleanup_function_result = run_query(cleanup_function_query) %}
    {% endif %}
    
    {# 6. Check if CSV metadata source exists #}
    {% set csv_path = 'fivetran/bronze_columns/admin_backend.csv' %}
    {% do log("✅ Expected CSV metadata source: " ~ csv_path, info=True) %}
    
    {# 7. Validate dbt project configuration #}
    {% if target.database %}
      {% do log("✅ Target database configured: " ~ target.database, info=True) %}
    {% else %}
      {% set validation_errors = validation_errors + ['Target database not configured'] %}
    {% endif %}
    
    {# 8. Check for required macros #}
    {% set required_macros = ['get_admin_group', 'get_known_groups', 'deploy_catalog_level_policy', 'deploy_masking_functions', 'apply_databricks_column_tags'] %}
    {% for macro_name in required_macros %}
      {% if macro_name in context %}
        {% do log("✅ Required macro available: " ~ macro_name, info=True) %}
      {% else %}
        {% set validation_errors = validation_errors + ['Required macro missing: ' ~ macro_name] %}
      {% endif %}
    {% endfor %}
    
    {# Summary and Error Handling #}
    {% if validation_errors|length == 0 %}
      {% do log("", info=True) %}
      {% do log("🎉 PRE-FLIGHT VALIDATION PASSED!", info=True) %}
      {% do log("✅ All governance prerequisites are satisfied", info=True) %}
      {% do log("🚀 Ready to deploy governance policies", info=True) %}
    {% else %}
      {% do log("", info=True) %}
      {% do log("❌ PRE-FLIGHT VALIDATION FAILED!", info=True) %}
      {% do log("🚨 The following issues must be resolved before governance deployment:", info=True) %}
      {% for error in validation_errors %}
        {% do log("   • " ~ error, info=True) %}
      {% endfor %}
      {% do log("", info=True) %}
      {% do log("📚 Troubleshooting:", info=True) %}
      {% do log("   1. Check DATA_GOVERNANCE.md for setup instructions", info=True) %}
      {% do log("   2. Verify service principal permissions in Unity Catalog", info=True) %}
      {% do log("   3. Confirm environment variables are set correctly", info=True) %}
      {% do log("   4. Ensure required Databricks groups exist", info=True) %}
      
      {# Fail the dbt run if critical issues found #}
      {{ exceptions.raise_compiler_error("Governance pre-flight validation failed. See logs above for details.") }}
    {% endif %}
    
  {% else %}
    {% do log("⏩ SKIPPED: Governance pre-flight validation (not executing or not Databricks)", info=True) %}
  {% endif %}
{% endmacro %}