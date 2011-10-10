spool logs\reports_script.log

create or replace view v_bonus_new as 
select  
  td.idy,
  td.idhy,
  e.employee_type EmplType,
  (select employee_parent from employee where employee_id=e.employee_id) as manager_employee_id,
  e.employee_name,
  e.employee_id,
  pg.idprodgr,
  pg.prodgr,
  td.TRANSACTION_TYPE,
  sum(td.packs_plan) as packs,
  sum(td.packs_plan * p.pricecip) BR,
  sum(td.packs_fack * p.pricecip) IMS,
  sum(td.packs * p.pricecip) CIP
from
  transactions_data td, 
  products p,
  prodgrs pg,
  employee e,
  employee_client ec
where 
  td.idprod=p.idprod
  and p.idprodgr = pg.idprodgr
  and e.employee_id = ec.employee_id
  and td.idclient=ec.client_id
  and ec.idhy=td.idhy
group by 
  td.idy,
  td.idhy,
  e.employee_type,
  e.employee_id,
  e.employee_name,
  pg.idprodgr,
  pg.prodgr,
  td.TRANSACTION_TYPE;
  
create or replace view v_prepare_calculation_new as  
select 
  v.*,
  (select 
      sum(d.YVALUE)
    from
      cip_schema s,
      cip_schema_empl e,
      cip_schema_detail d
    where 
      e.idkamrep = v.employee_id
      and s.idy=v.idy
      and s.idhy=v.idhy
      and e.idschema=d.idschema
      and s.idschema=e.idschema) base,
  (select 
    min(d.prodsplit)
  from
    cip_schema s,
    cip_schema_empl e,
    cip_schema_detail d
  where 
    e.idkamrep = v.employee_id
    and s.idy=v.idy
    and s.idhy=v.idhy
    and (d.idprodgr=v.idprodgr or d.idprodgr is null)
    and e.idschema=d.idschema
    and s.idschema=e.idschema) prodsplit,
    ( select 
      round( sum(v1.ims) / sum(v1.br) ,2) 
    from
      v_bonus_new v1
    where
        v1.employee_id=v.employee_id
        and v1.idhy=v.idhy
        and v1.idy=v.idy
     group by v1.employee_id) goal_achievement,
    ( select 
      decode(sum(v1.br),0,0,round( sum(v1.ims) / sum(v1.br) ,2) )
    from
      v_bonus_new v1
    where
        v1.employee_id=v.employee_id
        and v1.idhy=v.idhy
        and v1.idy=v.idy
        and v1.idprodgr=v.idprodgr
     group by v1.employee_id) goal_achievement_prod
from 
  v_bonus_new v
;

create or replace view v_total_bonus_new as
select 
  vpc.*,
  (select 
    targetinc   
  from
    payout_curve pc
  where 
    (pc.YTDGoal BETWEEN vpc.goal_achievement_prod and vpc.goal_achievement_prod
    or
    (vpc.goal_achievement_prod > 3 and pc.YTDGoal=3))
    ) payout_curve_prod,
    (select 
    targetinc   
  from
    payout_curve pc
  where 
    (pc.YTDGoal BETWEEN vpc.goal_achievement and vpc.goal_achievement
    or
    (vpc.goal_achievement > 3 and pc.YTDGoal=3))
    ) payout_curve
from  
  v_prepare_calculation_new vpc;
  
create or replace view v_pivot_total_new as
(select 
  *
from  (select 
        idy,
        idhy,
        empltype,
        manager_employee_id,
        employee_id,
        employee_name, 
        base, 
        prodgr, 
        ims, 
        br, 
        prodsplit, 
        goal_achievement, 
        payout_curve , 
        goal_achievement_prod, 
        payout_curve_prod 
      from v_total_bonus_new) t
            pivot (
                sum(ims) as sum_ims, 
                sum(br) as sum_br, 
                min(prodsplit) as psplit, 
                min(goal_achievement_prod) as goal_achievement, 
                min(payout_curve_prod) as payout_curve_prod 
              for (prodgr) in ('AN' as AN, 'AO' as AO, 'Mi' as Mi, 'Npl' as Npl, 'Vbx' as Vbx)
            )
);

create or replace view 
v_excel_report as
select * from v_pivot_total_new
union
select 
 td.idy, td.idhy, e.employee_type, e.employee_id,e.employee_id, e.employee_name,
 (select 
      sum(d.YVALUE)
    from
      cip_schema s,
      cip_schema_empl e,
      cip_schema_detail d
    where 
      e.idkamrep = e.employee_id
      --and e.empltype in ('KAM','SKAM')      
      and s.idy=td.idy
      and s.idhy=td.idhy
      and e.idschema=d.idschema
      and s.idschema=e.idschema) base,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
from employee e, 
 (select distinct idy, idhy from transactions_data) td
where e.employee_parent in (99,98)
order by 4,5 desc
;

create or replace view v_report_employee_table as
select 
  lvl_1.employee_id as empl_1_id,
  lvl_2.employee_id as empl_manager_id,
  lvl_3.employee_id as empl_employee_id,
  lvl_1.employee_name as employee_group,
  lvl_2.employee_name as manager_name,
  lvl_3.employee_name as employee_name
from 
  employee lvl_1, 
  employee lvl_2, 
  (select employee_id, employee_parent, employee_name from employee 
   union
   select employee_id,employee_id as employee_parent, employee_name
   from employee
   where employee_parent in (98,99)
  ) lvl_3
where 
  lvl_1.employee_id=lvl_2.employee_parent
  and lvl_2.employee_id=lvl_3.employee_parent
order by 2
;

create or replace view v_db1_empl_client as
select 
e.*,
h.hy,
ecq.idhy,
ecq.qvt_clients
from 
  half_year h,
  v_report_employee_table e,
  (
    select 
      ec.idhy,
      ec.employee_id, 
      count(ec.client_id) as qvt_clients 
    from 
      employee_client ec
    group by 
      ec.idhy,
      ec.employee_id) ecq
where 
  h.idhy=ecq.idhy
  and ecq.employee_id=e.empl_employee_id  
;

create or replace view v_db2_empl_pf as
select 
e.*,
h.hy,
ecp.idhy,
ecp.qvt_month,
ecp.v_plan,
ecp.v_fact
from 
  half_year h,
  v_report_employee_table e,
  (
    select 
      ec.idhy, 
      ec.employee_id,
      count(distinct td.idmonth) as qvt_month,
      sum(td.packs_plan) as v_plan,
      sum(td.packs_fack) as v_fact
    from 
      employee_client ec,
      transactions_data td
    where 
        td.idhy=ec.idhy
        and td.idclient = ec.client_id
    group by 
      ec.idhy, 
      ec.employee_id
  ) ecp
where 
  h.idhy=ecp.idhy
  and ecp.employee_id=e.empl_employee_id  
;

create or replace view v_db3_prodgr as
select
  hy.hy,
  hy.idhy,
  pg.prodgr,
  sum(td.packs_plan) as v_plan,
  sum(td.packs_fack) as v_fact
from 
  transactions_data td,
  products p,
  prodgrs pg,
  half_year hy
where 
  p.idprod=td.idprod
  and pg.idprodgr=p.idprodgr
  and hy.idhy=td.idhy
group by 
  hy.hy,
  hy.idhy,
  pg.prodgr
;

create or replace view v_report_geography_table as
select 
  ar.geography_id as area_id,
  su.geography_id as subarea_id,
  re.geography_id as region_id,
  ar.geography_name as area,
  su.geography_name as subarea,
  re.geography_name as region
from
geography ar,
geography su,
geography re
where
  ar.geography_id=su.geography_parent
  and su.geography_id=re.geography_parent
;

create or replace view v_db4_geog_pf as
select 
  geo.*,
  h.hy,
  gc.idhy,
  gc.qvt_month,
  gc.v_plan,
  gc.v_fact
from 
  half_year h,
  v_report_geography_table geo,
  (select 
      td.idhy, 
      g.geography_id,
      g.geography_parent,
      g.geography_name,
      count(distinct td.idmonth) as qvt_month,
      sum(td.packs_plan) as v_plan,
      sum(td.packs_fack) as v_fact
    from 
      transactions_data td,
      geography g,
      clients cc
    where 
        g.geography_id = cc.idreg
        and cc.idclient = td.idclient
    group by 
      td.idhy,
      g.geography_id,
      g.geography_parent,
      g.geography_name) gc
where 
  h.idhy=gc.idhy
  and geo.region_id=gc.geography_id
;
 
 
--Denis inserts new dashboards
create or replace view db_check_region as
select c.idclient, r.*
from clients c,
(
select 'Area' as geography_type, area as region, region_id
from v_report_geography_table g
union
select 'Subarea' as geography_type, subarea as region, region_id
from v_report_geography_table g
union
select 'Region' as geography_type, region as region, region_id
from v_report_geography_table g) r
where c.idreg=r.region_id
;

create or replace view v_transaction_data as   
select 
  ec.employee_id, 
  ec.idprod, 
  (select idprodgr from products_new where idprod=ec.idprod) as idprodgr, 
  d.real_date, 
  to_char(td.real_date,'YYYY') as real_year, 
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
from 
  employee_client ec,
  v_dates d,
  transactions_data td
where d.dt_report = (select v2.dt_report from  v_dates v2 where  v2.dt_type = 'HalfYear' and v2.real_date = ec.real_date)
  and td.idprod = ec.idprod
  and td.idclient=ec.client_id
  and td.real_date = d.real_date
--and d.dt_report = '2011-H1'
--and ec.client_id = 472
--and ec.employee_id=121
;

CREATE OR REPLACE VIEW db_pgsales_calc
AS
  SELECT
    NULL          AS LINK,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date)) AS price,
    d.dt_type,
    td.transaction_type,
    d.dt_id,
    pg.prodgr,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    products_new p,
    prodgrs pg,
    v_dates d
  WHERE
    p.idprodgr           =pg.idprodgr
  AND td.idprod          = p.idprod
  AND d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.transaction_type in ('IMS','IMP') --- ITM,TTM
  GROUP BY
    d.dt_report,
    td.transaction_type,
    d.dt_type,
    d.dt_id,
    pg.prodgr
  ORDER BY
    d.dt_id,
    pg.prodgr;

CREATE OR REPLACE VIEW db_pgtotal_calc
AS
  SELECT
    NULL          AS LINK,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date)) AS price,
    d.dt_type,
    d.dt_id,
    pg.prodgr,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    products_new p,
    prodgrs pg,
    v_dates d
  WHERE
    p.idprodgr           =pg.idprodgr
  AND td.idprod          = p.idprod
  AND d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.transaction_type in ('IMS','IMP') --- ITM,TTM
  GROUP BY
    d.dt_report,
    d.dt_type,
    d.dt_id,
    pg.prodgr
  ORDER BY
    d.dt_id,
    pg.prodgr;

CREATE OR REPLACE VIEW db_gsales_calc
AS
  SELECT
    NULL          AS LINK,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date)) AS price,
    d.dt_type,
    td.transaction_type,
    d.dt_id,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    v_dates d
  WHERE
   d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.transaction_type in ('IMS','IMP') --- ITM
  GROUP BY
    d.dt_report,
    td.transaction_type,
    d.dt_type,
    d.dt_id
  ORDER BY
    d.dt_id ;

CREATE OR REPLACE VIEW db_total_calc
AS
  SELECT
    NULL          AS LINK,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date)) AS price,
    d.dt_type,
    d.dt_id,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    v_dates d
  WHERE
   d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.transaction_type in ('IMS','IMP') --- ITM
  GROUP BY
    d.dt_report,
    d.dt_type,
    d.dt_id
  ORDER BY
    d.dt_id ;

create or replace view db_sales_reports as	
select 'Units' as reports, transaction_type, minreal_date, dt_id, dt_type, period, units, 
accumulate_value(transaction_type,dt_type, minreal_date) as units_accum,
previous_value(transaction_type,dt_type, minreal_date) as previous_units,
case 
when previous_value(transaction_type,dt_type, minreal_date) = 0 THEN 0
ELSE
round((units - previous_value(transaction_type,dt_type, minreal_date))/previous_value(transaction_type,dt_type, minreal_date),3)*100
END  as rost
from db_gsales_calc
-- multi report
union
select 'CIP RUR' as reports, transaction_type, minreal_date, dt_id, dt_type, period, price as units, 
accumulate_value(transaction_type,dt_type, minreal_date) as units_accum,
previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR') as previous_units,
case 
when previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR') = 0 THEN 0
ELSE
round((price - previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR'))/previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR'),3)*100
END  as rost
from db_gsales_calc
;

create or replace view db_total_reports as	
select  minreal_date, dt_id, dt_type, period, units, 
accumulate_value('IMP',dt_type, minreal_date) - accumulate_value('IMS',dt_type, minreal_date) as units_diff,
accumulate_value(null,dt_type, minreal_date )as units_accum,
previous_value(null ,dt_type, minreal_date) as previous_units,
case 
when previous_value(null,dt_type, minreal_date) = 0 THEN 0
ELSE
round((units - previous_value(null,dt_type, minreal_date))/previous_value(null,dt_type, minreal_date),3)*100
END  as rost
from db_total_calc
;

create or replace view db_sales_pg_reports as	
select transaction_type,prodgr, minreal_date, dt_id, dt_type, period, units, 
accumulate_value(transaction_type,dt_type, minreal_date, prodgr) as units_accum,
previous_value(transaction_type,dt_type, minreal_date, prodgr) as previous_units,
case 
when previous_value(transaction_type,dt_type, minreal_date, prodgr) = 0 THEN 0
ELSE
round((units - previous_value(transaction_type,dt_type, minreal_date, prodgr))/previous_value(transaction_type,dt_type, minreal_date, prodgr),3)*100
END  as rost
from db_pgsales_calc
;

create or replace view db_total_pg_reports as	
select prodgr, minreal_date, dt_id, dt_type, period, units, 
accumulate_value('IMP',dt_type, minreal_date) - accumulate_value('IMS',dt_type, minreal_date) as units_diff,
accumulate_value(null,dt_type, minreal_date, prodgr) as units_accum,
previous_value(null,dt_type, minreal_date, prodgr) as previous_units,
case 
when previous_value(null,dt_type, minreal_date, prodgr) = 0 THEN 0
ELSE
round((units - previous_value(null,dt_type, minreal_date, prodgr))/previous_value(null,dt_type, minreal_date, prodgr),3)*100
END  as rost
from db_pgtotal_calc
;

create or replace view db_region_calc as
select null as link, t.* from (
SELECT
    'Region' as geography_type,
    g.region,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date)) AS price,
    d.dt_type,
    d.dt_id,
    pg.prodgr,
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
    pg.prodgr
union
SELECT
    'Subarea' as geography_type,
    g.subarea,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date)) AS price,
    d.dt_type,
    d.dt_id,
    pg.prodgr,
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
    pg.prodgr
union
  SELECT
    'Area' as geography_type,
    g.area,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    SUM(td.packs * get_price(td.idprod,td.real_date)) AS price,
    d.dt_type,
    d.dt_id,
    pg.prodgr,
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
    pg.prodgr
) t
ORDER BY
    t.geography_type,
    t.dt_id,
    t.prodgr;
    
create or replace view db_region_report as
select 
    geography_type,
    region,
    period,
    dt_type,
    dt_id,
    prodgr,
    minreal_date,
    units,
    previous_value('IMS',dt_type, minreal_date, prodgr,'Units',geography_type,region) as previous_units
from
  db_region_calc
;

--funcitons
create or replace
function get_price(
  product_id in number,
  dateid in date,
  price_type in varchar2 default 'CIP', --CIP, NET
  currency_type in varchar2 default 'RUR'--USD, RUR
  ) 
  return number
is
  val number := NULL;
Begin
  return nvl(val,2);
end;
/

create or replace
function previous_value(
  tran_type in varchar2,
  date_type in varchar2,
  dateid in date,
  pgroup in varchar2 default null,
  return_value varchar2 default 'Units', --Units, RUR
  g_type in varchar2 default null,
  g_region in varchar2 default null
  ) 
  return number
is
  val number := NULL;
  Volume number := NULL;
  HY varchar2(20) := NULL;
Begin
if g_type is null then
  if pgroup is null then
    if date_type = 'Year' THEN
        SELECT
         sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and to_char(td.real_date,'yyyy') = to_char(add_months(dateid,-12),'yyyy');  
    end if;
    
    if date_type = 'Month' THEN
        SELECT
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and to_char(td.real_date,'mmyyyy') = to_char(add_months(dateid,-12),'mmyyyy');  
    end if;    
    
    if date_type = 'Quarter' THEN
        SELECT
         sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and to_char(td.real_date,'yyyy-q') = to_char(add_months(dateid,-12),'yyyy-q'); 
    end if;
    
     if date_type = 'HalfYear' THEN
        select 
          dt_report into HY
        from  
          v_dates
        where 
          dt_type = 'HalfYear'
          and real_date = add_months(dateid,-12);
  
        SELECT
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and td.real_date in (select real_date from v_dates where dt_report = HY); 
    end if;
  end if;
  
  if pgroup is not null then
    if date_type = 'Year' THEN
        SELECT
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup) 
        and to_char(td.real_date,'yyyy') = to_char(add_months(dateid,-12),'yyyy');  
    end if;
    
    if date_type = 'Month' THEN
        SELECT
         sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        and to_char(td.real_date,'mmyyyy') = to_char(add_months(dateid,-12),'mmyyyy');  
    end if;
    
    if date_type = 'Quarter' THEN
       SELECT
         sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        and to_char(td.real_date,'yyyy-q') = to_char(add_months(dateid,-12),'yyyy-q'); 
    end if;
    
     if date_type = 'HalfYear' THEN
        select 
          dt_report into HY
        from  
          v_dates
        where 
          dt_type = 'HalfYear'
          and real_date = add_months(dateid,-12);
  
        SELECT
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        and td.real_date in (select real_date from v_dates where dt_report = HY); 
    end if;
    
  end if;
end if;
if g_type is not null then
  if date_type = 'Year' THEN
        SELECT
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td,
          clients c
        WHERE
        td.idclient = c.idclient
        and td.transaction_type in (nvl(tran_type,'IMS'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup) 
        and to_char(td.real_date,'yyyy') = to_char(add_months(dateid,-12),'yyyy')
        and exists (select 1 from db_check_region t where t.region_id=c.idreg and t.geography_type=g_type and t.region = g_region );  
    end if;
    
    if date_type = 'Month' THEN
        SELECT
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td,
          clients c
        WHERE
        td.idclient = c.idclient
        and td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        and exists (select 1 from db_check_region t where t.region_id=c.idreg and t.geography_type=g_type and t.region = g_region )
        and to_char(td.real_date,'mmyyyy') = to_char(add_months(dateid,-12),'mmyyyy');  
    end if;
    
     if date_type = 'Quarter' THEN
       SELECT
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td,
          clients c
        WHERE
        td.idclient = c.idclient
        and td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        and exists (select 1 from db_check_region t where t.region_id=c.idreg and t.geography_type=g_type and t.region = g_region )
        and to_char(td.real_date,'yyyy-q') = to_char(add_months(dateid,-12),'yyyy-q'); 
    end if;
    
     if date_type = 'HalfYear' THEN
        select 
          dt_report into HY
        from  
          v_dates
        where 
          dt_type = 'HalfYear'
          and real_date = add_months(dateid,-12);
  
        SELECT
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date)) into val, volume
        FROM
          transactions_data td,
          clients c
        WHERE
        td.idclient = c.idclient
        and td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        and exists (select 1 from db_check_region t where t.region_id=c.idreg and t.geography_type=g_type and t.region = g_region )
        and td.real_date in (select real_date from v_dates where dt_report = HY); 
    end if;
end if;
  if return_value = 'Units' then return nvl(val,0);
  else return nvl(volume,0);
  end if;
end;
/

create or replace
function accumulate_value(
  tran_type in varchar2,
  date_type in varchar2,
  dateid in date,
  pgroup in varchar2 default null
  ) 
  return number
is
  val number := NULL;
Begin
 --type_call='ACCUM'
  if pgroup is null then
    if date_type = 'Year' THEN
        SELECT
         sum(td.packs) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and td.real_date <= to_date('31.12.'||to_char(dateid,'yyyy'),'dd.mm.yyyy');  
    end if;
    
    if date_type = 'Month' THEN
        SELECT
         sum(td.packs) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        --and to_char(td.real_date,'mmyyyy') <= to_char(add_months(dateid,-12),'mmyyyy'); 
        and td.real_date <= last_day(dateid); 
    end if;
    
     if date_type = 'Quarter' THEN
        SELECT
         sum(td.packs) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        --and to_char(td.real_date,'mmyyyy') <= to_char(add_months(dateid,-12),'mmyyyy'); 
        and td.real_date <= (
          select max(real_date) 
          from v_dates where dt_report in (
            select 
              dt_report 
            from  
              v_dates
            where   
              dt_type = 'Quarter'
              and real_date = dateid)
        ); 
    end if;
    
     if date_type = 'HalfYear' THEN
        SELECT
         sum(td.packs) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        --and to_char(td.real_date,'mmyyyy') <= to_char(add_months(dateid,-12),'mmyyyy'); 
        and td.real_date <= (
          select max(real_date) 
          from v_dates where dt_report in (
            select 
              dt_report 
            from  
              v_dates
            where   
              dt_type = 'HalfYear'
              and real_date = dateid)
        ); 
    end if;
      
  end if;
  
  if pgroup is not null then
    if date_type = 'Year' THEN
        SELECT
         sum(td.packs) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        --and to_char(td.real_date,'yyyy') <= to_char(add_months(dateid,-12),'yyyy');  
        and td.real_date <= to_date('31.12.'||to_char(dateid,'yyyy'),'dd.mm.yyyy');   
    end if;
    
    if date_type = 'Month' THEN
        SELECT
         sum(td.packs) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        --and to_char(td.real_date,'mmyyyy') <= to_char(add_months(dateid,-12),'mmyyyy');
        and td.real_date <= last_day(dateid);  
    end if;
    
    if date_type = 'Quarter' THEN
         SELECT
         sum(td.packs) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        and td.real_date <= (
          select max(real_date) 
          from v_dates where dt_report in (
            select 
              dt_report 
            from  
              v_dates
            where   
              dt_type = 'Quarter'
              and real_date = dateid)
        ); 
    end if;
    
     if date_type = 'HalfYear' THEN
        SELECT
         sum(td.packs) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        and td.real_date <= (
          select max(real_date) 
          from v_dates where dt_report in (
            select 
              dt_report 
            from  
              v_dates
            where   
              dt_type = 'HalfYear'
              and real_date = dateid)
        ); 
    end if;
  end if;
  return nvl(val,0);
end;
/

----bigtable
drop table db_bigtable;
create table db_bigtable (
  measure varchar2(100),
  transaction_type varchar2(100),
  product varchar2 (100),
  minreal_date date,
  dt_id	varchar2(100),
  dt_type	varchar2(100),
  period varchar2(100),
  units number,
  price number,
  previous_units number,
  accum_units number,
  growth number,
  sys_info varchar2(100)
);

create or replace
procedure update_bigtable (t in number)
is
begin

  delete from db_bigtable;
  --step 1: select * from db_bigtable
  insert into db_bigtable 
  select 
  'Units' as measure, 
  transaction_type, 
  'Total' as product, 
  minreal_date, 
  dt_id, 
  dt_type, 
  period, 
  units,
  0,
  previous_value(transaction_type,dt_type, minreal_date) as previous_units,
  accumulate_value(transaction_type,dt_type, minreal_date) as accum_units,
  case 
  when previous_value(transaction_type,dt_type, minreal_date) = 0 THEN 0
  ELSE
  round((units - previous_value(transaction_type,dt_type, minreal_date))/previous_value(transaction_type,dt_type, minreal_date),3)*100
  END  as growth,
  'Step 1'
  from db_gsales_calc;
  
end;
/

----strart script
CREATE OR REPLACE VIEW db_pgsales_itm
AS
  SELECT
    NULL          AS LINK,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    d.dt_type,
    td.transaction_type,
    d.dt_id,
    pg.prodgr
  FROM
    transactions_data td,
    products_new p,
    prodgrs pg,
    v_dates d
  WHERE
    p.idprodgr           =pg.idprodgr
  AND td.idprod          = p.idprod
  AND d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.transaction_type='IMS' --- ITM
  GROUP BY
    d.dt_report,
    td.transaction_type,
    d.dt_type,
    d.dt_id,
    pg.prodgr
  ORDER BY
    d.dt_id ;

CREATE OR REPLACE VIEW db_gsales_itm
AS
  SELECT
    NULL          AS LINK,
    d.dt_report   AS period,
    SUM(td.packs) AS units,
    d.dt_type,
    td.transaction_type,
    d.dt_id,
    min(td.real_date) as minreal_date
  FROM
    transactions_data td,
    v_dates d
  WHERE
   d.real_date        = td.real_date
  AND d.dt_type         != 'Date'
  AND td.transaction_type='IMS' --- ITM
  GROUP BY
    d.dt_report,
    td.transaction_type,
    d.dt_type,
    d.dt_id
  ORDER BY
    d.dt_id ;

---
 
 
 
spool off

exit;