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
modeled_dim_ticker as (
    select
        MD5(SYMBOL) as TICKER_SK
        , CURRENCY
        , CURRENCY_QUOTE
        , CURRENCY_NAME
        , CURRENCY_QUOTE_NAME
        , SYMBOL
        , (case when SYMBOL IN ('IEFA') then 'International Developed Markets'
                when SYMBOL IN ('IEMG') then 'Emerging Markets'
                when SYMBOL IN ('IJH') then 'S&P MidCap 400'
                when SYMBOL IN ('IJR') then 'S&P SmallCap 600'
                when SYMBOL IN ('IVV', 'SPY') then 'S&P 500'
                when SYMBOL IN ('IWF') then 'Russell 1000 Growth'
                when SYMBOL IN ('QQQ') then 'NASDAQ 100'
                when SYMBOL IN ('IWM') then 'Russell 2000'
                else 'Other' end) as ETF_SYMBOL_DESC
        , (case when SYMBOL IN ('AAPL','NVDA','GOOG','MSFT') then 'IT'
                when SYMBOL IN ('AMZN','DPZ','TSLA') then 'Consumer_Discretionary'
                when SYMBOL IN ('NFLX') then 'Communication_Services'
                when SYMBOL IN ('MRNA') then 'Healthcare'
                when SYMBOL IN ('TSM') then 'Industrial'
                else 'Financial' end) as GRICS_CLSFCTN
    from {{ ref('blended_ticker') }}
)

select * from modeled_dim_ticker
