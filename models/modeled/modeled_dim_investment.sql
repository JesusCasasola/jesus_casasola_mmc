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
modeled_dim_investment as (
    select
        MD5(INVESTMENT||INVESTMENT_TYPE) as INVESTMENT_SK
        , INVESTMENT
        , INVESTMENT_TYPE
    from {{ ref('blended_investments') }}
)

select * from modeled_dim_investment
