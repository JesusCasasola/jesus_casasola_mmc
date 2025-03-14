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
modeled_dim_dt as (
    select
        MD5(DATE) as DATE_SK
        , DATE
        , YEAR
        , SHORT_YEAR
        , MONTHNUMBER
        , DAY
        , MONTH
        , WEEK_DAY
        , YEAR_MONTH
        , QUARTER
        , QUARTER_YEAR
        , END_WEEK
        , FY
        , DATENUMBER
        , WEEK_NUMBER
        , QUARTER_NUMBER
        , SEMESTER_NUMBER
        , DAY_NAME
    from {{ ref('blended_date') }}
)

select * from modeled_dim_dt
