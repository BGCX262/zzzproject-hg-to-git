spool logs\create_or_replace_views.log

create or replace view all_dates
as
SELECT to_date('31.12.2006','dd.mm.yyyy')+rownum dt
  FROM dual
    CONNECT BY level <= (sysdate+365 - to_date('01.01.2007','dd.mm.yyyy'));
	
create or replace view v_dates as 
--AS
--WITH all_dates AS
--  (SELECT to_date('31.12.2006','dd.mm.yyyy')+rownum dt
 -- FROM dual
 --   CONNECT BY level <= (sysdate+365 - to_date('01.01.2007','dd.mm.yyyy'))
--  )
--days
 SELECT
    dt                       AS real_date,
    TO_CHAR(dt,'yyyymmdd')   AS dt_id,
    TO_CHAR(dt,'yyyymmdd')   AS dt_id_fake,
    TO_CHAR(dt,'dd.mm.yyyy') AS dt,
    TO_CHAR(dt,'dd.mm.yyyy') AS dt_report,
    TO_CHAR(dt,'yyyymm')     AS dt_parent,
    'Date'                   AS dt_type
  FROM
    all_dates
  UNION ALL
  --months
  SELECT
    dt                                       AS real_date,
    TO_CHAR(dt,'yyyymm')                              AS dt_id,
    TO_CHAR(add_months(last_day(dt)+1,-1),'yyyymmdd') AS dt_id_fake,
    TO_CHAR(dt,'Month')                               AS dt,
    TO_CHAR(dt,'yyyy')
    ||'-'
    || TO_CHAR(dt,'Month') AS dt_report,
    TO_CHAR(dt,'yyyy')
    ||'Q'
    ||TO_CHAR(dt,'q') AS dt_parent,
    'Month'           AS dt_type
  FROM
    all_dates
  UNION ALL
  --quarters
  SELECT
    dt AS real_date,
    TO_CHAR(dt,'yyyy')
    ||'Q'
    ||TO_CHAR(dt,'q') AS dt_id,
    CASE
      WHEN to_number(TO_CHAR(dt,'q')) = 1
      THEN TO_CHAR(dt,'yyyy')
        || '0101'
      WHEN to_number(TO_CHAR(dt,'q')) = 2
      THEN TO_CHAR(dt,'yyyy')
        || '0401'
      WHEN to_number(TO_CHAR(dt,'q')) = 3
      THEN TO_CHAR(dt,'yyyy')
        || '0701'
      WHEN to_number(TO_CHAR(dt,'q')) = 4
      THEN TO_CHAR(dt,'yyyy')
        || '1001'
    END dt_id_fake,
    'Q'
    ||TO_CHAR(dt,'Q') AS dt,
    TO_CHAR(dt,'yyyy')
    || '-Q'
    || TO_CHAR(dt,'Q') AS dt_report,
    CASE
      WHEN to_number(TO_CHAR(dt,'mm'))>6
      THEN TO_CHAR(dt,'YYYY')
        ||'H2'
      ELSE TO_CHAR(dt,'YYYY')
        ||'H1'
    END       AS dt_parent,
    'Quarter' AS dt_type
    -- dt as real_date,
  FROM
    all_dates
  UNION ALL
  --half years
  SELECT
    dt AS real_date,
    CASE
      WHEN to_number(TO_CHAR(dt,'mm'))>6
      THEN TO_CHAR(dt,'YYYY')
        ||'H2'
      ELSE TO_CHAR(dt,'YYYY')
        ||'H1'
    END AS dt_id,
    CASE
      WHEN to_number(TO_CHAR(dt,'mm'))>6
      THEN TO_CHAR(dt,'YYYY')
        || '0701'
      ELSE TO_CHAR(dt,'YYYY')
        || '0101'
    END AS dt_id_fake,
    CASE
      WHEN to_number(TO_CHAR(dt,'mm'))>6
      THEN 'H2'
      ELSE 'H1'
    END AS dt,
    TO_CHAR(dt,'yyyy')
    || '-'
    ||
    CASE
      WHEN to_number(TO_CHAR(dt,'mm'))>6
      THEN 'H2'
      ELSE 'H1'
    END                AS dt_report,
    TO_CHAR(dt,'YYYY') AS dt_parent,
    'HalfYear'         AS dt_type
  FROM
    all_dates
  UNION ALL
  --years
  SELECT
    dt AS real_date,
    TO_CHAR(dt,'yyyy')    AS dt_id,
    TO_CHAR(dt,'yyyy')
    || '0101'          AS dt_id_fake,
    TO_CHAR(dt,'YYYY') AS dt,
    TO_CHAR(dt,'YYYY') AS dt_report,
    NULL               AS dt_parent,
    'Year'             AS dt_type
  FROM
    all_dates
  UNION ALL
  --ydt
  SELECT
    "REAL_DATE",
    "DT_ID",
    "DT_ID_FAKE",
    "DT",
    "DT_REPORT",
    "DT_PARENT",
    "DT_TYPE"
  FROM
    (
      SELECT
        dt                     AS real_date,
        TO_CHAR(dt,'yyyymm')                              AS dt_id,
        TO_CHAR(add_months(last_day(dt)+1,-1),'yyyymmdd') AS dt_id_fake,
        TO_CHAR(dt,'Month')                               AS dt,
        TO_CHAR(dt,'yyyy')                                AS dt_report,
        TO_CHAR(dt,'yyyy')
        ||'Q'
        ||TO_CHAR(dt,'q') AS dt_parent,
        CASE
          WHEN dt BETWEEN to_date('01.01.'
            ||TO_CHAR(dt,'yyyy'),'dd.mm.yyyy')
          AND to_date(TO_CHAR(last_day(sysdate),'dd.mm')
            ||'.'
            ||TO_CHAR(dt,'yyyy'),'dd.mm.yyyy')
          THEN 'YTD'
          ELSE '-'
        END AS dt_type
      FROM
        all_dates
    )
  WHERE
    dt_type <> '-';
  
 spool off 
 exit; 