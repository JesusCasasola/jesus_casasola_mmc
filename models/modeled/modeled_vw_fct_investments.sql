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
vw_fct_investments as (
    select
        *
        , (CLOSING_PRICE - OPENING_PRICE) / OPENING_PRICE * 100 as DLY_RTRN
        , (HIGHEST_PRICE - LOWEST_PRICE) / OPENING_PRICE * 100 as PRC_VLTLTY
        , (HIGHEST_PRICE - LOWEST_PRICE) as HGH_LOW_SPRD
        , FIRST_VALUE(CLOSING_PRICE) OVER (PARTITION BY SYMBOL ORDER BY DATE) as FRST_CLSNG_PRC
        , LAST_VALUE(CLOSING_PRICE) OVER (PARTITION BY SYMBOL ORDER BY DATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as LAST_CLSNG_PRC
    from {{ ref('modeled_fct_investments') }} inv
)
select * from vw_fct_investments
