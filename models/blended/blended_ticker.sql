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

blended_ticker as (
    select 
        meta_symbol as SYMBOL
        , split_part(SYMBOL,'/',1) as CURRENCY
        , split_part(SYMBOL,'/',2) as CURRENCY_QUOTE
        , meta_currency_base as CURRENCY_NAME
        , meta_currency_quote as CURRENCY_QUOTE_NAME
    from {{ ref('crypto') }}
    group by all
    UNION
    select 
        meta_symbol as SYMBOL
        , meta_currency as CURRENCY
        , null as CURRENCY_QUOTE
        , 'US Dollar' as CURRENCY_NAME
        , null as CURRENCY_QUOTE_NAME
    from etfs_dedup
    where row_nbr = 1
    group by all
    UNION
    select
        meta_symbol as SYMBOL
        , meta_currency as CURRENCY
        , null as CURRENCY_QUOTE
        , 'US Dollar' as CURRENCY_NAME
        , null as CURRENCY_QUOTE_NAME
    from stocks_dedup
    where row_nbr = 1
    group by all
    UNION
    select 
        meta_symbol as SYMBOL
        , split_part(SYMBOL,'/',1) as CURRENCY
        , split_part(SYMBOL,'/',2) as CURRENCY_QUOTE
        , meta_currency_base as CURRENCY_NAME
        , meta_currency_quote as CURRENCY_QUOTE_NAME
    from {{ ref('forex') }}
    group by all
)

select * from blended_ticker
