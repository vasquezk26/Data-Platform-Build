{% macro apply_databricks_column_tags() %}
  {% if target.type == 'databricks' and execute %}
    {% set model_meta = graph.nodes[model.unique_id] %}
    {% set database = model.database %}
    {% set schema = model.schema %}
    {% set table_name = model.name %}
    
    {% if model_meta.columns %}
      {% for column_name, column_info in model_meta.columns.items() %}
        {% if column_info.meta %}
          {% set class_value = column_info.meta.class %}
          {% set sensitivity_value = column_info.meta.sensitivity %}
          
          {% if class_value and class_value != '' %}
            {% do log("Applying class tag to column: " ~ column_name ~ " = " ~ class_value, info=True) %}
            {% do run_query("ALTER TABLE `" ~ database ~ "`.`" ~ schema ~ "`.`" ~ table_name ~ "` ALTER COLUMN `" ~ column_name ~ "` SET TAGS ('class' = '" ~ class_value ~ "')") %}
          {% endif %}
          
          {% if sensitivity_value and sensitivity_value != '' %}
            {% do log("Applying sensitivity tag to column: " ~ column_name ~ " = " ~ sensitivity_value, info=True) %}
            {% do run_query("ALTER TABLE `" ~ database ~ "`.`" ~ schema ~ "`.`" ~ table_name ~ "` ALTER COLUMN `" ~ column_name ~ "` SET TAGS ('sensitivity' = '" ~ sensitivity_value ~ "')") %}
          {% endif %}
        {% endif %}
      {% endfor %}
    {% endif %}
  {% endif %}
{% endmacro %}