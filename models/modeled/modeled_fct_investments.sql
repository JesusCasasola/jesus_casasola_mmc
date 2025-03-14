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
investment_source as(
    select 
        MD5('Crypto'||meta_type) as INVESTMENT_SK            
        , MD5(meta_symbol) as TICKER_SK
        , MD5(meta_exchange) as MARKETPLACE_SK
        , MD5(values_datetime) as DATE_SK
        , values_open as OPENING_PRICE
        , values_close as CLOSING_PRICE
        , values_high as HIGHEST_PRICE
        , values_low as LOWEST_PRICE
        , null as VOLUME
    from {{ ref('crypto') }}
    UNION
    select 
        MD5('ETFS'||meta_type) as INVESTMENT_SK            
        , MD5(meta_symbol) as TICKER_SK
        , MD5(meta_exchange) as MARKETPLACE_SK
        , MD5(values_datetime) as DATE_SK
        , values_open as OPENING_PRICE
        , values_close as CLOSING_PRICE
        , values_high as HIGHEST_PRICE
        , values_low as LOWEST_PRICE
        , values_volume as VOLUME
    from {{ ref('etfs') }}
    UNION
    select 
        MD5('Forex'||meta_type) as INVESTMENT_SK            
        , MD5(meta_symbol) as TICKER_SK
        , null as MARKETPLACE_SK
        , MD5(values_datetime) as DATE_SK
        , values_open as OPENING_PRICE
        , values_close as CLOSING_PRICE
        , values_high as HIGHEST_PRICE
        , values_low as LOWEST_PRICE
        , null as VOLUME
    from {{ ref('forex') }}
    UNION
    select 
        MD5('Stocks'||meta_type) as INVESTMENT_SK            
        , MD5(meta_symbol) as TICKER_SK
        , MD5(meta_exchange) as MARKETPLACE_SK
        , MD5(values_datetime) as DATE_SK
        , values_open as OPENING_PRICE
        , values_close as CLOSING_PRICE
        , values_high as HIGHEST_PRICE
        , values_low as LOWEST_PRICE
        , values_volume as VOLUME
    from {{ ref('stocks') }}
),

fct_investments as (
    select 
        s.INVESTMENT_SK            
        , s.TICKER_SK
        , s.MARKETPLACE_SK
        , s.DATE_SK
        , i.INVESTMENT
        , i.INVESTMENT_TYPE
        , m.EXCHANGE
        , t.CURRENCY
        , t.SYMBOL
        , d.DATE
        , s.OPENING_PRICE
        , s.CLOSING_PRICE
        , s.HIGHEST_PRICE
        , s.LOWEST_PRICE
        , s.VOLUME
    from investment_source s
    join {{ ref('modeled_dim_investment') }} i
        on i.INVESTMENT_SK = s.INVESTMENT_SK
    join {{ ref('modeled_dim_ticker') }} t
        on t.TICKER_SK = s.TICKER_SK
    join {{ ref('modeled_dim_dt') }} d
        on d.DATE_SK = s.DATE_SK
    left join {{ ref('modeled_dim_marketplace') }} m
        on m.MARKETPLACE_SK = s.MARKETPLACE_SK
) 
select * from fct_investments
