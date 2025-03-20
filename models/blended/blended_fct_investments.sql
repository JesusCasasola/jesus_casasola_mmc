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
investment_source as(
    select 
        'Crypto' as INVESTMENT
        , meta_type as INVESTMENT_TYPE  
        , meta_symbol as SYMBOL
        , meta_exchange as EXCHANGE
        , values_datetime as DATE
        , values_open as OPENING_PRICE
        , values_close as CLOSING_PRICE
        , values_high as HIGHEST_PRICE
        , values_low as LOWEST_PRICE
        , null as VOLUME
    from {{ ref('crypto') }}
    UNION
    select           
        'ETFS' as INVESTMENT
        , meta_type as INVESTMENT_TYPE  
        , meta_symbol as SYMBOL
        , meta_exchange as EXCHANGE
        , values_datetime as DATE
        , values_open as OPENING_PRICE
        , values_close as CLOSING_PRICE
        , values_high as HIGHEST_PRICE
        , values_low as LOWEST_PRICE
        , values_volume as VOLUME
    from {{ ref('etfs') }}
    UNION
    select           
        'Forex' as INVESTMENT
        , meta_type as INVESTMENT_TYPE  
        , meta_symbol as SYMBOL
        , null as EXCHANGE
        , values_datetime as DATE
        , values_open as OPENING_PRICE
        , values_close as CLOSING_PRICE
        , values_high as HIGHEST_PRICE
        , values_low as LOWEST_PRICE
        , null as VOLUME
    from {{ ref('forex') }}
    UNION
    select          
        'Stocks' as INVESTMENT
        , meta_type as INVESTMENT_TYPE  
        , meta_symbol as SYMBOL
        , meta_exchange as EXCHANGE
        , values_datetime as DATE
        , values_open as OPENING_PRICE
        , values_close as CLOSING_PRICE
        , values_high as HIGHEST_PRICE
        , values_low as LOWEST_PRICE
        , values_volume as VOLUME
    from {{ ref('stocks') }}
) 

select * from investment_source
