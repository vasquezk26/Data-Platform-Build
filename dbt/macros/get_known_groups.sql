{% macro get_admin_group() %}
  {% set env = env_var('_ENV', 'dev') %}
  {% if env == 'prod' %}
    {% set admin_group = 'dbr-prod-admins' %}
  {% else %}
    {% set admin_group = 'dbr-dev-admins' %}
  {% endif %}
  {{ return(admin_group) }}
{% endmacro %}

{% macro get_known_groups() %}
  {% set env = env_var('_ENV', 'dev') %}
  {% set groups = {
    'admin': 'dbr-' ~ env ~ '-admins',
    'health_readers': 'dbr-' ~ env ~ '-health-reader-beta'
  } %}
  {{ return(groups) }}
{% endmacro %}