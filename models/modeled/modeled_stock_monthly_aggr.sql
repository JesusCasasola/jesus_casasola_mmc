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
stock_monthly_aggr as (
    SELECT
        inv.SYMBOL
        , dt.MONTH
        , dt.MONTHNUMBER
        , dt.YEAR
        , tckr.GRICS_CLSFCTN
        , COUNT(DISTINCT inv.DATE) as DAYS_ACTV
        , SUM(DLY_RTRN) / COUNT(DISTINCT inv.DATE) as AVG_DLY_RTRN
        , AVG(PRC_VLTLTY) as AVG_DLY_VLTLTY
        , SUM(VOLUME) as MTHLY_VLM
        , MIN(LOWEST_PRICE) as MIN_PRC
        , MAX(HIGHEST_PRICE) as MAX_PRC
        , AVG(CLOSING_PRICE) as AVG_MTHLY_CLSNG_PRC
        , MAX(HGH_LOW_SPRD) as MAX_HGH_LOW_SPRD
        , SUM(CASE WHEN (CLOSING_PRICE - OPENING_PRICE) > 0 then 1 ELSE 0 END) as TTL_PSTV_DAYS
        , SUM(CASE WHEN (CLOSING_PRICE - OPENING_PRICE) < 0 then 1 ELSE 0 END) as TTL_NGTV_DAYS
    from {{ ref('modeled_vw_fct_investments') }} inv
    join {{ ref('modeled_dim_dt') }} dt 
        on inv.DATE = dt.DATE
    join {{ ref('modeled_dim_ticker') }} tckr
        on tckr.TICKER_SK = inv.TICKER_SK
    where inv.INVESTMENT = 'Stocks'
    group by all
    order by dt.YEAR, dt.MONTHNUMBER asc 
)

select * from stock_monthly_aggr
