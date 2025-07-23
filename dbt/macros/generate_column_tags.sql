{% macro generate_column_tags(model_name) %}
  {% set model_meta = graph.nodes[model.unique_id] %}
  {% set column_tags = {} %}
  
  {% if model_meta.columns %}
    {% for column_name, column_info in model_meta.columns.items() %}
      {% set tags = [] %}
      
      {% if column_info.meta %}
        {% if column_info.meta.class and column_info.meta.class != '' %}
          {% set tags = tags + [column_info.meta.class] %}
        {% endif %}
        
        {% if column_info.meta.sensitivity and column_info.meta.sensitivity != '' %}
          {% set tags = tags + [column_info.meta.sensitivity] %}
        {% endif %}
      {% endif %}
      
      {% if tags %}
        {% set column_tags = column_tags.update({column_name: tags}) %}
      {% endif %}
    {% endfor %}
  {% endif %}
  
  {{ return(column_tags) }}
{% endmacro %}