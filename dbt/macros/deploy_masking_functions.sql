{% macro deploy_masking_functions() %}
  {% do log("DEBUG: execute=" ~ execute ~ ", target.type=" ~ target.type, info=True) %}
  {% if execute and target.type == 'databricks' %}
    
    {% do log("🚀 Starting masking functions deployment...", info=True) %}
    
    {# Discover schemas dynamically #}
    {% set schemas_query %}
      SELECT schema_name 
      FROM {{ target.database }}.information_schema.schemata 
      WHERE schema_name NOT IN ('information_schema', 'default')
      ORDER BY schema_name
    {% endset %}
    
    {% do log("🔍 Discovering schemas in database: " ~ target.database, info=True) %}
    
    {% set schemas_result = run_query(schemas_query) %}
    {% set schema_names = schemas_result.columns[0].values() %}
    
    {% do log("✅ Found " ~ schema_names|length ~ " schemas: " ~ schema_names|join(', '), info=True) %}
    
    {% if schema_names|length == 0 %}
      {% do log("⚠️  No schemas found to process", info=True) %}
    {% else %}
      
      {% set admin_group = get_admin_group() %}
      {% set known_groups = get_known_groups() %}
      
      {% do log("ℹ️  Masking Logic:", info=True) %}
      {% do log("   🔒 MASKED: All columns except explicitly allowed combinations", info=True) %}
      {% do log("   🔓 UNMASKED (Everyone): class=none AND sensitivity=public", info=True) %}
      {% do log("   🏥 UNMASKED (Health Readers): class=health AND sensitivity=internal", info=True) %}
      {% do log("   🚫 ALWAYS MASKED FOR EVERYONE: class=pii (regardless of sensitivity)", info=True) %}
      {% do log("   👥 ADMINS: " ~ admin_group ~ " can see all data unmasked (EXCEPT PII)", info=True) %}
      {% do log("   🩺 HEALTH READERS: " ~ known_groups.health_readers ~ " can see health-internal data (but NO PII)", info=True) %}
      {% do log("   📋 KNOWN GROUPS: " ~ known_groups.values() | join(', '), info=True) %}
      
      {% for schema_name in schema_names %}
        {% do log("🔨 Processing schema: " ~ target.database ~ "." ~ schema_name, info=True) %}
        
        {# Create masking function #}
        {% set create_function_sql %}
          CREATE FUNCTION IF NOT EXISTS `{{ target.database }}`.`{{ schema_name }}`.`mask_restricted`(val STRING)
          RETURNS STRING
          LANGUAGE SQL
          DETERMINISTIC
          COMMENT 'Masking function for sensitive data - returns REDACTED for unauthorized users'
          RETURN 'REDACTED'
        {% endset %}
        
        {% do log("   📝 Creating masking function: " ~ target.database ~ "." ~ schema_name ~ ".mask_restricted", info=True) %}
        
        {% set function_result = run_query(create_function_sql) %}
        {% do log("   ✅ Masking function created successfully", info=True) %}
        
        {# Apply admin policy - admins see everything unmasked EXCEPT PII #}
        {% set admin_policy_sql %}
          CREATE OR REPLACE POLICY admin_full_access
          ON SCHEMA `{{ target.database }}`.`{{ schema_name }}`
          COMMENT 'Admin policy: full access to all data EXCEPT PII'
          COLUMN MASK `{{ target.database }}`.`{{ schema_name }}`.`mask_restricted`
          TO `{{ admin_group }}`
          FOR TABLES
          MATCH COLUMNS hasTagValue('class','pii') AS col
          ON COLUMN col
        {% endset %}
        
        {# Apply health reader policy - limited access to safe + health-internal data, NO PII #}
        {% set health_reader_policy_sql %}
          CREATE OR REPLACE POLICY health_reader_limited_access
          ON SCHEMA `{{ target.database }}`.`{{ schema_name }}`
          COMMENT 'Health reader policy: access to safe public data and health-internal data only, NO PII'
          COLUMN MASK `{{ target.database }}`.`{{ schema_name }}`.`mask_restricted`
          TO `{{ known_groups.health_readers }}`
          FOR TABLES
          MATCH COLUMNS NOT (
            (hasTagValue('class','none') AND hasTagValue('sensitivity','public')) OR
            (hasTagValue('class','health') AND hasTagValue('sensitivity','internal'))
          ) OR hasTagValue('class','pii') AS col
          ON COLUMN col
        {% endset %}
        
        {# Apply default policy - everyone else sees only safe public data, NO PII #}
        {% set default_policy_sql %}
          CREATE OR REPLACE POLICY default_user_access
          ON SCHEMA `{{ target.database }}`.`{{ schema_name }}`
          COMMENT 'Default policy: access to safe public data only, NO PII'
          COLUMN MASK `{{ target.database }}`.`{{ schema_name }}`.`mask_restricted`
          TO `account users`
          EXCEPT `{{ admin_group }}`, `{{ known_groups.health_readers }}`
          FOR TABLES
          MATCH COLUMNS NOT (hasTagValue('class','none') AND hasTagValue('sensitivity','public')) OR hasTagValue('class','pii') AS col
          ON COLUMN col
        {% endset %}
        
        {% do log("   📝 Applying masking policies to schema: " ~ target.database ~ "." ~ schema_name, info=True) %}
        
        {% set admin_result = run_query(admin_policy_sql) %}
        {% do log("   ✅ Admin policy applied successfully", info=True) %}
        
        {% set health_result = run_query(health_reader_policy_sql) %}
        {% do log("   ✅ Health reader policy applied successfully", info=True) %}
        
        {% set default_result = run_query(default_policy_sql) %}
        {% do log("   ✅ Default user policy applied successfully", info=True) %}
        
      {% endfor %}
      
      {% do log("🎉 Masking deployment completed!", info=True) %}
      {% do log("✅ Successfully processed " ~ schema_names|length ~ "/" ~ schema_names|length ~ " schemas", info=True) %}
      {% do log("✅ All schemas processed successfully", info=True) %}
      
    {% endif %}
    
  {% else %}
    {% do log("⏩ SKIPPED: Masking functions deployment (not executing or not Databricks)", info=True) %}
  {% endif %}
{% endmacro %}