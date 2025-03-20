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
    select * 
        , MD5(INVESTMENT||INVESTMENT_TYPE) as INVESTMENT_SK            
        , MD5(SYMBOL) as TICKER_SK
        , MD5(EXCHANGE) as MARKETPLACE_SK
        , MD5(DATE) as DATE_SK
    from {{ ref('blended_fct_investments') }} 
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
