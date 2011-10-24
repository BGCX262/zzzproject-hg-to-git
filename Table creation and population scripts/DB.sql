spool logs\db_sql_create.log

CREATE OR REPLACE VIEW V_REPORT_GEOGRAPHY_TABLE
AS
  SELECT ar.geography_id AS area_id,
    su.geography_id      AS subarea_id,
    re.geography_id      AS region_id,
    ar.geography_name    AS area,
    su.geography_name    AS subarea,
    re.geography_name    AS region
  FROM geography ar,
    geography su,
    geography re
  WHERE ar.geography_id=su.geography_parent
  AND su.geography_id  =re.geography_parent;

CREATE OR REPLACE VIEW V_DATES
                             AS
  SELECT dt                  AS real_date,
    TO_CHAR(dt,'yyyymmdd')   AS dt_id,
    TO_CHAR(dt,'yyyymmdd')   AS dt_id_fake,
    TO_CHAR(dt,'dd.mm.yyyy') AS dt,
    TO_CHAR(dt,'dd.mm.yyyy') AS dt_report,
    TO_CHAR(dt,'yyyymm')     AS dt_parent,
    'Date'                   AS dt_type
  FROM all_dates
  UNION ALL
  --months
  SELECT dt                                           AS real_date,
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
  FROM all_dates
  UNION ALL
  --quarters
  SELECT dt AS real_date,
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
  FROM all_dates
  UNION ALL
  --half years
  SELECT dt AS real_date,
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
  FROM all_dates
  UNION ALL
  --years
  SELECT dt            AS real_date,
    TO_CHAR(dt,'yyyy') AS dt_id,
    TO_CHAR(dt,'yyyy')
    || '0101'          AS dt_id_fake,
    TO_CHAR(dt,'YYYY') AS dt,
    TO_CHAR(dt,'YYYY') AS dt_report,
    NULL               AS dt_parent,
    'Year'             AS dt_type
  FROM all_dates
  UNION ALL
  --ydt
  SELECT "REAL_DATE",
    "DT_ID",
    "DT_ID_FAKE",
    "DT",
    "DT_REPORT",
    "DT_PARENT",
    "DT_TYPE"
  FROM
    (SELECT dt                                          AS real_date,
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
    FROM all_dates
    )
  WHERE dt_type <> '-';    
  
CREATE OR REPLACE VIEW DB_CHECK_REGION
AS
  SELECT c.idclient,
    r."GEOGRAPHY_TYPE",
    r."REGION",
    r."REGION_ID"
  FROM clients c,
    (SELECT 'Area' AS geography_type,
      area         AS region,
      region_id
    FROM v_report_geography_table g
    UNION 
    SELECT 'Subarea' AS geography_type,
      subarea        AS region,
      region_id
    FROM v_report_geography_table g
    UNION
    SELECT 'Region' AS geography_type,
      region        AS region,
      region_id
    FROM v_report_geography_table g
    ) r
  WHERE c.idreg=r.region_id;

CREATE OR REPLACE VIEW V_TRANSACTION_DATA
AS
  SELECT ec.employee_id,
    ec.idprod,
    (SELECT idprodgr FROM products_new WHERE idprod=ec.idprod
    ) AS idprodgr,
    d.real_date,
    TO_CHAR(td.real_date,'YYYY') AS real_year,
    d.dt_report,
    d.dt_type,
    d.dt,
    ec.client_id,
    ec.plan_pct,
    ec.link_type,
    td.packs,
    td.packs_fack,
    td.packs_plan,
    td.transaction_type
  FROM employee_client ec,
    v_dates d,
    transactions_data td
  WHERE d.dt_report =
    (SELECT v2.dt_report
    FROM v_dates v2
    WHERE v2.dt_type = 'HalfYear'
    AND v2.real_date = ec.real_date
    )
  AND td.idprod    = ec.idprod
  AND td.idclient  =ec.client_id
  AND td.real_date = d.real_date;  
  
 CREATE OR REPLACE VIEW DB_PGSALES_CALC AS
  SELECT NULL                                         AS LINK,
    d.dt_report                                       AS period,
    SUM(td.packs)                                     AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPRUR')) AS priceCR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPUSD')) AS priceCU,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETRUR')) AS priceNR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETUSD')) AS priceNU,
    d.dt_type,
    td.transaction_type,
    d.dt_id,
    pg.prodgr,
    MIN(td.real_date) AS minreal_date
  FROM transactions_data td,
    products_new p,
    prodgrs pg,
    v_dates d
  WHERE p.idprodgr         =pg.idprodgr
  AND td.idprod            = p.idprod
  AND d.real_date          = td.real_date
  AND d.dt_type           != 'Date'
  AND td.transaction_type IN ('IMS','IMP') --- ITM,TTM
  GROUP BY d.dt_report,
    td.transaction_type,
    d.dt_type,
    d.dt_id,
    pg.prodgr
  ORDER BY d.dt_id,
    pg.prodgr;
    
CREATE OR REPLACE VIEW DB_GSALES_CALC
AS
  SELECT NULL                                         AS LINK,
    d.dt_report                                       AS period,
    SUM(td.packs)                                     AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPRUR')) AS priceCR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPUSD')) AS priceCU,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETRUR')) AS priceNR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETUSD')) AS priceNU,
    d.dt_type,
    td.transaction_type,
    d.dt_id,
    MIN(td.real_date) AS minreal_date
  FROM transactions_data td,
    v_dates d
  WHERE d.real_date        = td.real_date
  AND d.dt_type           != 'Date'
  AND td.transaction_type IN ('IMS','IMP') --- ITM
  GROUP BY d.dt_report,
    td.transaction_type,
    d.dt_type,
    d.dt_id
  ORDER BY d.dt_id;
  
create or replace view db_pgregion_calc as
select null as link, t.* from (
SELECT
    'Region' as geography_type,
    g.region,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPRUR')) AS priceCR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPUSD')) AS priceCU,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETRUR')) AS priceNR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETUSD')) AS priceNU,
    d.dt_type,
    d.dt_id,
    pg.prodgr,
    td.transaction_type,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    products_new p,
    prodgrs pg,
    v_dates d,
    clients c,
    V_REPORT_GEOGRAPHY_TABLE g
  WHERE
    p.idprodgr           =pg.idprodgr
  AND td.idprod          = p.idprod
  AND d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.idclient = c.idclient
  AND c.idreg = g.region_id
  AND td.transaction_type in ('IMS') --- ITM,TTM
  GROUP BY
    g.region,
    d.dt_report,
    d.dt_type,
    d.dt_id,
    td.transaction_type,
    pg.prodgr
union
SELECT
    'Subarea' as geography_type,
    g.subarea,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPRUR')) AS priceCR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPUSD')) AS priceCU,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETRUR')) AS priceNR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETUSD')) AS priceNU,
    d.dt_type,
    d.dt_id,
    pg.prodgr,
    td.transaction_type,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    products_new p,
    prodgrs pg,
    v_dates d,
    clients c,
    V_REPORT_GEOGRAPHY_TABLE g
  WHERE
    p.idprodgr           =pg.idprodgr
  AND td.idprod          = p.idprod
  AND d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.idclient = c.idclient
  AND c.idreg = g.region_id
  AND td.transaction_type in ('IMS') --- ITM,TTM
  GROUP BY
    g.subarea,
    d.dt_report,
    d.dt_type,
    d.dt_id,
    td.transaction_type,
    pg.prodgr
union
  SELECT
    'Area' as geography_type,
    g.area,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPRUR')) AS priceCR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPUSD')) AS priceCU,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETRUR')) AS priceNR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETUSD')) AS priceNU,
    d.dt_type,
    d.dt_id,
    pg.prodgr,
    td.transaction_type,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    products_new p,
    prodgrs pg,
    v_dates d,
    clients c,
    V_REPORT_GEOGRAPHY_TABLE g
  WHERE
    p.idprodgr           =pg.idprodgr
  AND td.idprod          = p.idprod
  AND d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.idclient = c.idclient
  AND c.idreg = g.region_id
  AND td.transaction_type in ('IMS') --- ITM,TTM
  GROUP BY
    g.area,
    d.dt_report,
    d.dt_type,
    d.dt_id,
    td.transaction_type,
    pg.prodgr
) t
ORDER BY
    t.geography_type,
    t.dt_id,
    t.prodgr;

create or replace view db_region_calc as
select null as link, t.* from (
SELECT
    'Region' as geography_type,
    g.region,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPRUR')) AS priceCR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPUSD')) AS priceCU,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETRUR')) AS priceNR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETUSD')) AS priceNU,
    d.dt_type,
    d.dt_id,
    td.transaction_type,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    v_dates d,
    clients c,
    V_REPORT_GEOGRAPHY_TABLE g
  WHERE
     d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.idclient = c.idclient
  AND c.idreg = g.region_id
  AND td.transaction_type in ('IMS') --- ITM,TTM
  GROUP BY
    g.region,
    d.dt_report,
    d.dt_type,
    d.dt_id,
    td.transaction_type
union
SELECT
    'Subarea' as geography_type,
    g.subarea,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPRUR')) AS priceCR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPUSD')) AS priceCU,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETRUR')) AS priceNR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETUSD')) AS priceNU,
    d.dt_type,
    d.dt_id,
    td.transaction_type,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    v_dates d,
    clients c,
    V_REPORT_GEOGRAPHY_TABLE g
  WHERE
     d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.idclient = c.idclient
  AND c.idreg = g.region_id
  AND td.transaction_type in ('IMS') --- ITM,TTM
  GROUP BY
    g.subarea,
    d.dt_report,
    d.dt_type,
    d.dt_id,
    td.transaction_type
union
  SELECT
    'Area' as geography_type,
    g.area,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPRUR')) AS priceCR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'CIPUSD')) AS priceCU,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETRUR')) AS priceNR,
    SUM(td.packs * get_price(td.idprod,td.real_date,td.idws,'NETUSD')) AS priceNU,
    d.dt_type,
    d.dt_id,
    td.transaction_type,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    v_dates d,
    clients c,
    V_REPORT_GEOGRAPHY_TABLE g
  WHERE
  d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.idclient = c.idclient
  AND c.idreg = g.region_id
  AND td.transaction_type in ('IMS') --- ITM,TTM
  GROUP BY
    g.area,
    d.dt_report,
    d.dt_type,
    d.dt_id,
    td.transaction_type
) t
ORDER BY
    t.geography_type,
    t.dt_id;
 
spool off

exit;
