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
select dt as real_date,
  TO_CHAR(dt,'yyyymmdd') AS dt_id,
  TO_CHAR(dt,'yyyymmdd')      AS dt_id_fake,
  to_char(dt,'dd.mm.yyyy')    as dt,
  to_char(dt,'yyyymm')        as dt_parent,
  'Date' as dt_type
FROM all_dates
UNION
--months
select distinct add_months(last_day(real_date)+1,-1) as real_date,
  dt_id,
  dt_id_fake,
  dt,
  dt_parent,
  'Month' as dt_type
FROM
  (SELECT TO_CHAR(dt,'yyyymm')                        AS dt_id,
    TO_CHAR(add_months(last_day(dt)+1,-1),'yyyymmdd') AS dt_id_fake,
    TO_CHAR(dt,'Month')                               AS dt,
    TO_CHAR(dt,'yyyy')
    ||'Q'
    ||to_char(dt,'q') as dt_parent,
    dt as real_date
  FROM all_dates
  )
UNION
--quarters
select distinct 
  to_date(dt_id_fake,'yyyymmdd') as real_date,
  dt_id,
  dt_id_fake,
  dt,
  dt_parent,
  'Quarter' as dt_type
FROM
  (SELECT TO_CHAR(dt,'yyyy')
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
    CASE
      WHEN to_number(TO_CHAR(dt,'mm'))>6
      THEN 'H2'
        || TO_CHAR(dt,'YYYY')
      ELSE 'H1'
        || to_char(dt,'YYYY')
    end as dt_parent,
    dt as real_date
  FROM all_dates
  )
UNION
--half years
select distinct 
  to_date(dt_id_fake,'yyyymmdd') as real_date,
  dt_id,
  dt_id_fake,
  dt,
  dt_parent,
  'HalfYear' as dt_type
FROM
  (SELECT
    CASE
      WHEN to_number(TO_CHAR(dt,'mm'))>6
      THEN 'H2'
        ||TO_CHAR(dt,'YYYY')
      ELSE 'H1'
        ||TO_CHAR(dt,'YYYY')
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
    END                AS dt,
    TO_CHAR(dt,'YYYY') AS dt_parent
  FROM all_dates
  )
UNION
--years
select distinct 
  to_date(dt_id_fake,'yyyymmdd') as real_date,
  dt_id,
  dt_id_fake,
  dt,
  dt_parent,
  'Year' as dt_type
FROM
  (SELECT TO_CHAR(dt,'yyyy') AS dt_id,
    TO_CHAR(dt,'yyyy')
    || '0101'          AS dt_id_fake,
    TO_CHAR(dt,'YYYY') AS dt,
    NULL               AS dt_parent
  from all_dates
  );
  
 spool off 
 exit; 