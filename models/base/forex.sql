{#-
-- ##########################################################################
-- Model Variables and Configuration Settings 
--
-- ##########################################################################
-#}

{{- config(enabled=true
        , materialized = 'table'
) -}}

WITH 
    source_data AS (
        SELECT *
        FROM {{ source('raw_stg', 'stg_forex') }}
    WHERE 1=1
)

SELECT * FROM source_data