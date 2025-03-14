{#-
-- ##########################################################################
-- 
--
-- ##########################################################################
-#}

{{- config(enabled=true
        , materialized = 'table'
) -}}

with
modeled_dim_marketplace as (
    select
        MD5(EXCHANGE) as MARKETPLACE_SK
        , EXCHANGE
        , EXCHANGE_TZ
    from {{ ref('blended_marketplace') }}
)

select * from modeled_dim_marketplace
