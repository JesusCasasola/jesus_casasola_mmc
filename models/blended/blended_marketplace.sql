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

blended_marketplace as (
    select 
        meta_exchange as EXCHANGE
        , null as EXCHANGE_TZ
    from {{ ref('crypto') }}
    group by EXCHANGE, EXCHANGE_TZ
    UNION
    select 
        meta_exchange as EXCHANGE
        , meta_exchange_timezone as EXCHANGE_TZ
    from etfs_dedup
    where row_nbr = 1
    group by EXCHANGE, EXCHANGE_TZ
    UNION
    select 
        meta_exchange as EXCHANGE
        , meta_exchange_timezone as EXCHANGE_TZ
    from stocks_dedup
    where row_nbr = 1
    group by EXCHANGE, EXCHANGE_TZ
)

select * from blended_marketplace
