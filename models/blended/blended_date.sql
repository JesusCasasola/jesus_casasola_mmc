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
blended_date as (
    select
        DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))::date as DATE,
        year(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) YEAR,
        substr(year(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))),3,2) SHORT_YEAR,
        month(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) MONTHNUMBER,
        day(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) DAY,
        MONTHNAME(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) MONTH,
        DAYOFWEEKISO(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) WEEK_DAY,
        case when month(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) > 10 then
        year(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) || month(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01')))
        else year(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) || '0' || month(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) end YEAR_MONTH,
        'Qrt ' || DATE_PART(QUARTER, DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) QUARTER,
        'Q' || DATE_PART(QUARTER, DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) || ' ' || year(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) QUARTER_YEAR,
        DATEADD(dd, 7-dayofweek(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))), to_date('2013-01-01')) as END_WEEK,
        'FY'||substr(year(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))),3,2) FY,
        year(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01')))||
        substring('0'||month(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))), length('0'||month(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))))-1, 2) ||
        substring('0'||day(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))), length('0'||day(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))))-1, 2) as DATENUMBER,
        week(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) WEEK_NUMBER,
        DATE_PART(QUARTER, DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) QUARTER_NUMBER,
        case when month(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) <= 6 then 1 else 2 end SEMESTER_NUMBER,
        dayname(DATEADD(DAY, 1*SEQ4(), to_date('2013-01-01'))) DAY_NAME
    from TABLE(GENERATOR(ROWCOUNT => (365*15)+1 ))
)

select * from blended_date
