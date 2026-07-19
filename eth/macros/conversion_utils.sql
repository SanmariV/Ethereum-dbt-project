
{% macro ethereum_conversion(column_name) %}

sum({{ column_name }})/1e18

{% endmacro %}

{% macro stablecoin_conversion(column_name) %}

sum({{ column_name }})/1e6

{% endmacro %}
