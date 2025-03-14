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
etf_monthly_aggr as (
    SELECT
        inv.INVESTMENT_TYPE
        , dt.MONTH
        , dt.MONTHNUMBER
        , dt.YEAR
        , inv.SYMBOL
        , tckr.ETF_SYMBOL_DESC
        , inv.EXCHANGE
        , ((MAX(inv.LAST_CLSNG_PRC) - MIN(inv.FRST_CLSNG_PRC)) / MIN(inv.FRST_CLSNG_PRC)) * 100 as MTHLY_NET_CHNG_PCT
        , STDDEV(inv.DLY_RTRN) as MTHLY_VLTLTY
        , AVG(inv.VOLUME) as AVG_VLM
        , MIN((inv.HIGHEST_PRICE - inv.CLOSING_PRICE) / inv.HIGHEST_PRICE) as MAX_DRAWDOWN
    from {{ ref('modeled_vw_fct_investments') }} inv
    join {{ ref('modeled_dim_dt') }} dt 
        on  inv.DATE = dt.DATE
    join {{ ref('modeled_dim_ticker') }} tckr
        on tckr.TICKER_SK = inv.TICKER_SK
    where inv.INVESTMENT = 'ETFS'
    group by inv.SYMBOL, inv.INVESTMENT_TYPE, dt.MONTH, dt.MONTHNUMBER, dt.YEAR, ETF_SYMBOL_DESC, inv.EXCHANGE
    order by dt.YEAR, dt.MONTHNUMBER asc 
)

select * from etf_monthly_aggr
