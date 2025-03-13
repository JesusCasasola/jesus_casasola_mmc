{#-
-- ##########################################################################
-- 
--
-- ##########################################################################
-#}

{{- config(enabled=true
        , materialized = 'view'
) -}}

with
stocks_dedup as(
    select 
        *
        , ROW_NUMBER() OVER(PARTITION BY meta_symbol,meta_type,values_datetime ORDER BY values_datetime) AS row_nbr
    from {{ ref('stocks') }}
),

etfs_dedup as(
    select 
        *
        , ROW_NUMBER() OVER(PARTITION BY meta_symbol,meta_type,values_datetime ORDER BY values_datetime) AS row_nbr
    from {{ ref('etfs') }}
),

blended_investment as (
    select 
        'Crypto' as INVESTMENT
        , meta_type as INVESTMENT_TYPE
    from {{ ref('crypto') }}
    group by INVESTMENT, INVESTMENT_TYPE
    UNION 
    select 
        'Forex' as INVESTMENT
        , meta_type as INVESTMENT_TYPE
    from {{ ref('forex') }}
    group by INVESTMENT, INVESTMENT_TYPE
    UNION
    select 
        'Stocks' as INVESTMENT
        , meta_type as INVESTMENT_TYPE
    from stocks_dedup
    where row_nbr = 1
    group by INVESTMENT, INVESTMENT_TYPE
    UNION
    select 
        'ETFS' as INVESTMENT
        , meta_type as INVESTMENT_TYPE
    from etfs_dedup
    where row_nbr = 1
    group by INVESTMENT, INVESTMENT_TYPE
)

select * from blended_investment
