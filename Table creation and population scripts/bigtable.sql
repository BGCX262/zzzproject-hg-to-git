spool logs\bigtable_create.log

drop table db_bigtable;
create table db_bigtable (
  report_type varchar2(100),
  measure varchar2(100),
  transaction_type varchar2(100),
  product varchar2 (100),
  minreal_date date,
  dt_id	varchar2(100),
  dt_type	varchar2(100),
  period varchar2(100),
  geography_type varchar2(200),
  geography varchar2(200),
  volume number,
  plan_volume number,
  aplan_volume number,
  aplan_pers number,
  previous_volume number,
  accum_volume number,
  growth number,
  volume_diff number default null,
  sys_info varchar2(100)
);

create index i_report_type on db_bigtable(report_type);
create index i_measure on db_bigtable(measure);
create index i_transaction_type on db_bigtable(transaction_type);
create index i_product on db_bigtable(product);
create index i_minreal_date on db_bigtable(minreal_date);
create index i_dt_id on db_bigtable(dt_id);
create index i_dt_type on db_bigtable(dt_type);
create index i_period on db_bigtable(period);
create index i_geography_type on db_bigtable(geography_type);
create index i_geography on db_bigtable(geography);
create index i_volume on db_bigtable(volume);
create index i_plan_volume on db_bigtable(plan_volume);
create index i_aplan_volume on db_bigtable(aplan_volume);
create index i_aplan_pers on db_bigtable(aplan_pers);
create index i_previous_volume on db_bigtable(previous_volume);
create index i_accum_volume on db_bigtable(accum_volume);
create index i_growth on db_bigtable(growth);
create index i_volume_diff on db_bigtable(volume_diff);
create index i_sys_info on db_bigtable(sys_info);



create or replace
procedure update_bigtable (t in number default 0)

is
begin
  dbms_output.put_line('start: '||to_char(sysdate,'dd.mm.yyyy hh:mi'));
  delete from db_bigtable;
--step 1: insert ITM data by Product / UNITS
  insert into db_bigtable 
  select 
    'SalesByProductTotalRussia' as report_type,
    'Units' as measure,
    transaction_type, 
    prodgr, 
    minreal_date, 
    dt_id, 
    dt_type,
    period, 
    null,
    'Total Russia',
    units, 
    get_plan(transaction_type, prodgr, null, null, dt_type, minreal_date),
    get_accfact(transaction_type, prodgr, null, null, dt_type, minreal_date),
    case 
      when get_plan(transaction_type, prodgr, null, null, dt_type, minreal_date) = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, prodgr, null, null, dt_type, minreal_date)/get_plan(transaction_type, prodgr, null, null, dt_type, minreal_date),3)*100
    END as planpers,
    previous_value(transaction_type,dt_type, minreal_date, prodgr) as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date, prodgr) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, prodgr) = 0 THEN 0
    ELSE
      round((units - previous_value(transaction_type,dt_type, minreal_date, prodgr))/previous_value(transaction_type,dt_type, minreal_date, prodgr),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date, prodgr) - accumulate_value('IMS',dt_type, minreal_date, prodgr) as volume_diff,
    'Step1'
  from 
    db_pgsales_calc;

--step 2: insert ITM data by Product / CIP RUR
  insert into db_bigtable 
  select
    'SalesByProductTotalRussia' as report_type,
    'CIP RUR' as measure,
    transaction_type, 
    prodgr, 
    minreal_date, 
    dt_id, 
    dt_type,
    period, 
    null,
    'Total Russia',
    priceCR, 
    get_plan(transaction_type, prodgr, null, null, dt_type, minreal_date,'CIPRUR'),
    get_accfact(transaction_type, prodgr, null, null, dt_type, minreal_date,'CIPRUR'),
    case 
      when get_plan(transaction_type, prodgr, null, null, dt_type, minreal_date,'CIPRUR') = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, prodgr, null, null, dt_type, minreal_date,'CIPRUR')/get_plan(transaction_type, prodgr, null, null, dt_type, minreal_date,'CIPRUR'),3)*100
    END as planpers,
    previous_value(transaction_type,dt_type, minreal_date, prodgr, 'CIPRUR') as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date, prodgr) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, prodgr, 'CIPRUR') = 0 THEN 0
    ELSE
      round((priceCR - previous_value(transaction_type,dt_type, minreal_date, prodgr, 'CIPRUR'))/previous_value(transaction_type,dt_type, minreal_date, prodgr, 'CIPRUR'),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date, prodgr) - accumulate_value('IMS',dt_type, minreal_date, prodgr) as volume_diff,
    'Step2'
  from 
    db_pgsales_calc;
      
--step 3: insert ITM data by Product / CIP USD
  insert into db_bigtable 
  select
    'SalesByProductTotalRussia' as report_type,
    'CIP USD' as measure,
    transaction_type, 
    prodgr, 
    minreal_date, 
    dt_id, 
    dt_type,
    period, 
    null,
    'Total Russia',
    priceCU, 
    get_plan(transaction_type, prodgr, null, null, dt_type, minreal_date, 'CIPUSD'),
    get_accfact(transaction_type, prodgr, null, null, dt_type, minreal_date, 'CIPUSD'),
    case 
      when get_plan(transaction_type, prodgr, null, null, dt_type, minreal_date, 'CIPUSD') = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, prodgr, null, null, dt_type, minreal_date, 'CIPUSD')/get_plan(transaction_type, prodgr, null, null, dt_type, minreal_date, 'CIPUSD'),3)*100
    END as planpers,
    previous_value(transaction_type,dt_type, minreal_date, prodgr, 'CIPUSD') as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date, prodgr) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, prodgr, 'CIPUSD') = 0 THEN 0
    ELSE
      round((priceCU - previous_value(transaction_type,dt_type, minreal_date, prodgr, 'CIPUSD'))/previous_value(transaction_type,dt_type, minreal_date, prodgr, 'CIPUSD'),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date, prodgr) - accumulate_value('IMS',dt_type, minreal_date, prodgr) as volume_diff,
    'Step3'
  from 
    db_pgsales_calc;

--step 4: insert ITM data by Product / NET RUR
  insert into db_bigtable 
  select
    'SalesByProductTotalRussia' as report_type,
    'NET RUR' as measure,
    transaction_type, 
    prodgr, 
    minreal_date, 
    dt_id, 
    dt_type,
    period, 
    null,
    'Total Russia',
    priceNR, 
    0,
    0,
    0,
    previous_value(transaction_type,dt_type, minreal_date, prodgr, 'NETRUR') as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date, prodgr) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, prodgr, 'NETRUR') = 0 THEN 0
    ELSE
      round((priceNR - previous_value(transaction_type,dt_type, minreal_date, prodgr, 'NETRUR'))/previous_value(transaction_type,dt_type, minreal_date, prodgr, 'NETRUR'),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date, prodgr) - accumulate_value('IMS',dt_type, minreal_date, prodgr) as volume_diff,
    'Step4'
  from 
    db_pgsales_calc;
    
--step 5: insert ITM data by Product / NET USD
  insert into db_bigtable   
  select
    'SalesByProductTotalRussia' as report_type,
    'NET USD' as measure,
    transaction_type, 
    prodgr, 
    minreal_date, 
    dt_id, 
    dt_type,
    period, 
    null,
    'Total Russia',
    priceNU, 
    0,
    0,
    0,
    previous_value(transaction_type,dt_type, minreal_date, prodgr, 'NETUSD') as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date, prodgr) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, prodgr, 'NETUSD') = 0 THEN 0
    ELSE
      round((priceNU - previous_value(transaction_type,dt_type, minreal_date, prodgr, 'NETUSD'))/previous_value(transaction_type,dt_type, minreal_date, prodgr, 'NETUSD'),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date, prodgr) - accumulate_value('IMS',dt_type, minreal_date, prodgr) as volume_diff,
    'Step5'
  from 
    db_pgsales_calc;

--step 6: insert ITM data by AllProducts / Units
  insert into db_bigtable 
  select 
    'SalesAllProductsTotalRussia' as report_type,
    'Units' as measure, 
    transaction_type, 
    'All products' as product, 
    minreal_date, 
    dt_id, 
    dt_type, 
    period, 
    null,
    'Total Russia',
    units as volume,
    get_plan(transaction_type, null, null, null, dt_type, minreal_date),
    get_accfact(transaction_type, null, null, null, dt_type, minreal_date),
    case 
      when get_plan(transaction_type, null, null, null, dt_type, minreal_date) = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, null, null, null, dt_type, minreal_date)/get_plan(transaction_type, null, null, null, dt_type, minreal_date),3)*100
    END as planpers,
    previous_value(transaction_type,dt_type, minreal_date) as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date) = 0 THEN 0
    ELSE
      round((units - previous_value(transaction_type,dt_type, minreal_date))/previous_value(transaction_type,dt_type, minreal_date),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date) - accumulate_value('IMS',dt_type, minreal_date) as volume_diff,
    'Step6'
  from 
    db_gsales_calc;

--step 7: insert ITM data by AllProducts / CIP RUR
  insert into db_bigtable 
  select 
    'SalesAllProductsTotalRussia' as report_type,
    'CIP RUR' as measure, 
    transaction_type, 
    'All products' as product, 
    minreal_date, 
    dt_id, 
    dt_type, 
    period, 
    null,
    'Total Russia',
    priceCR as volume,
    get_plan(transaction_type, null, null, null, dt_type, minreal_date, 'CIPRUR'),
    get_accfact(transaction_type, null, null, null, dt_type, minreal_date, 'CIPRUR'),
    case 
      when get_plan(transaction_type, null, null, null, dt_type, minreal_date, 'CIPRUR') = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, null, null, null, dt_type, minreal_date, 'CIPRUR')/get_plan(transaction_type, null, null, null, dt_type, minreal_date, 'CIPRUR'),3)*100
    END as planpers,
    previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR') as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR') = 0 THEN 0
    ELSE
      round((priceCR - previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR'))/previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR'),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date) - accumulate_value('IMS',dt_type, minreal_date) as volume_diff,
    'Step7'
  from 
    db_gsales_calc;

--step 8: insert ITM data by AllProducts / CIP USD
  insert into db_bigtable 
  select 
    'SalesAllProductsTotalRussia' as report_type,
    'CIP USD' as measure, 
    transaction_type, 
    'All products' as product, 
    minreal_date, 
    dt_id, 
    dt_type, 
    period, 
    null,
    'Total Russia',
    priceCU as volume,
    get_plan(transaction_type, null, null, null, dt_type, minreal_date, 'CIPUSD'),
    get_accfact(transaction_type, null, null, null, dt_type, minreal_date, 'CIPUSD'),
    case 
      when get_plan(transaction_type, null, null, null, dt_type, minreal_date, 'CIPUSD') = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, null, null, null, dt_type, minreal_date, 'CIPUSD')/get_plan(transaction_type, null, null, null, dt_type, minreal_date, 'CIPUSD'),3)*100
    END as planpers,
    previous_value(transaction_type,dt_type, minreal_date, null, 'CIPUSD') as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, null, 'CIPUSD') = 0 THEN 0
    ELSE
      round((priceCU - previous_value(transaction_type,dt_type, minreal_date, null, 'CIPUSD'))/previous_value(transaction_type,dt_type, minreal_date, null, 'CIPUSD'),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date) - accumulate_value('IMS',dt_type, minreal_date) as volume_diff,
    'Step8'
  from 
    db_gsales_calc;

--step 9: insert ITM data by AllProducts / NET RUR
  insert into db_bigtable 
  select 
    'SalesAllProductsTotalRussia' as report_type,
    'NET RUR' as measure, 
    transaction_type, 
    'All products' as product, 
    minreal_date, 
    dt_id, 
    dt_type, 
    period, 
    null,
    'Total Russia',
    priceNR as volume,
    0,
    0,
    0,
    previous_value(transaction_type,dt_type, minreal_date, null, 'NETRUR') as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, null, 'NETRUR') = 0 THEN 0
    ELSE
      round((priceNR - previous_value(transaction_type,dt_type, minreal_date, null, 'NETRUR'))/previous_value(transaction_type,dt_type, minreal_date, null, 'NETRUR'),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date) - accumulate_value('IMS',dt_type, minreal_date) as volume_diff,
    'Step9'
  from 
    db_gsales_calc;

--step 10: insert ITM data by AllProducts / NET USD
  insert into db_bigtable 
  select 
    'SalesAllProductsTotalRussia' as report_type,
    'NET USD' as measure, 
    transaction_type, 
    'All products' as product, 
    minreal_date, 
    dt_id, 
    dt_type, 
    period, 
    null,
    'Total Russia',
    priceNU as volume,
    0,
    0,
    0,
    previous_value(transaction_type,dt_type, minreal_date, null, 'NETUSD') as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, null, 'NETUSD') = 0 THEN 0
    ELSE
      round((priceNU - previous_value(transaction_type,dt_type, minreal_date, null, 'NETUSD'))/previous_value(transaction_type,dt_type, minreal_date, null, 'NETUSD'),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date) - accumulate_value('IMS',dt_type, minreal_date) as volume_diff,
    'Step10'
  from 
    db_gsales_calc;

----------- Region ------------
--step 11: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesByProductByRegion' as report_type,
    'Units' as measure,
    transaction_type, 
    prodgr, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    units,
    get_plan(transaction_type, prodgr, geography_type, region, dt_type, minreal_date),
    get_accfact(transaction_type, prodgr, geography_type, region, dt_type, minreal_date),
    case 
      when get_plan(transaction_type, prodgr, geography_type, region, dt_type, minreal_date) = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, prodgr, geography_type, region, dt_type, minreal_date)/get_plan(transaction_type, prodgr, geography_type, region, dt_type, minreal_date),3)*100
    END as planpers,
    previous_value(transaction_type, dt_type, minreal_date, prodgr,'Units',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step11'
from
  db_pgregion_calc;
  
--step 12: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesByProductByRegion' as report_type,
    'CIP RUR' as measure,
    transaction_type, 
    prodgr, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    priceCR,
    get_plan(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPRUR'),
    get_accfact(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPRUR'),
    case 
      when get_plan(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPRUR') = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPRUR')/get_plan(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPRUR'),3)*100
    END as planpers,
    previous_value(transaction_type, dt_type, minreal_date, prodgr,'CIPRUR',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step12'
from
  db_pgregion_calc;

--step 13: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesByProductByRegion' as report_type,
    'CIPUSD' as measure,
    transaction_type, 
    prodgr, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    priceCU,
    get_plan(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPUSD'),
    get_accfact(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPUSD'),
    case 
      when get_plan(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPUSD') = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPUSD')/get_plan(transaction_type, prodgr, geography_type, region, dt_type, minreal_date,'CIPUSD'),3)*100
    END as planpers,
    previous_value(transaction_type, dt_type, minreal_date, prodgr,'CIPUSD',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step13'
from
  db_pgregion_calc;

--step 14: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesByProductByRegion' as report_type,
    'NETRUR' as measure,
    transaction_type, 
    prodgr, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    priceNR,
    0,
    0,
    0,
    previous_value(transaction_type, dt_type, minreal_date, prodgr,'NETRUR',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step14'
from
  db_pgregion_calc;  

--step 15: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesByProductByRegion' as report_type,
    'NET USD' as measure,
    transaction_type, 
    prodgr, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    priceNU,
    0,
    0,
    0,
    previous_value(transaction_type, dt_type, minreal_date, prodgr,'NETUSD',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step15'
from
  db_pgregion_calc;

----------- Region ------------
--step 16: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesAllProductsByRegion' as report_type,
    'Units' as measure,
    transaction_type, 
    'All products' as product, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    units,
    get_plan(transaction_type, null, geography_type, region, dt_type, minreal_date),
    get_accfact(transaction_type, null, geography_type, region, dt_type, minreal_date),
    case 
      when get_plan(transaction_type, null, geography_type, region, dt_type, minreal_date) = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, null, geography_type, region, dt_type, minreal_date)/get_plan(transaction_type, null, geography_type, region, dt_type, minreal_date),3)*100
    END as planpers,
    previous_value(transaction_type, dt_type, minreal_date, null,'Units',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step16'
from
  db_region_calc;
  
--step 17: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesAllProductsByRegion' as report_type,
    'CIP RUR' as measure,
    transaction_type, 
    'All products' as product, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    priceCR,
    get_plan(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPRUR'),
    get_accfact(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPRUR'),
    case 
      when get_plan(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPRUR') = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPRUR')/get_plan(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPRUR'),3)*100
    END as planpers,
    previous_value(transaction_type, dt_type, minreal_date, null,'CIPRUR',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step17'
from
  db_region_calc;

--step 18: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesAllProductsByRegion' as report_type,
    'CIPUSD' as measure,
    transaction_type, 
    'All products' as product, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    priceCU,
    get_plan(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPUSD'),
    get_accfact(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPUSD'),
    case 
      when get_plan(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPUSD') = 0 THEN 0
    ELSE
      round(get_accfact(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPUSD')/get_plan(transaction_type, null, geography_type, region, dt_type, minreal_date,'CIPUSD'),3)*100
    END as planpers,
    previous_value(transaction_type, dt_type, minreal_date, null,'CIPUSD',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step18'
from
  db_region_calc;

--step 19: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesAllProductsByRegion' as report_type,
    'NETRUR' as measure,
    transaction_type, 
    'All products' as product, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    priceNR,
    0,
    0,
    0,
    previous_value(transaction_type, dt_type, minreal_date, null,'NETRUR',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step19'
from
  db_region_calc;  

--step 20: insert ITM data by region by product
insert into db_bigtable  
  select 
    'SalesAllProductsByRegion' as report_type,
    'NET USD' as measure,
    transaction_type, 
    'All products' as product, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    priceNU,
    0,
    0,
    0,
    previous_value(transaction_type, dt_type, minreal_date, null,'NETUSD',geography_type,region) as previous_units,
    0 as units_accum,
    0 as growth,
    0 as volume_diff,
    'Step20'
from
  db_region_calc;

--finish
  commit;
  dbms_output.put_line('end: '||to_char(sysdate,'dd.mm.yyyy hh:mi'));

end;
/

spool off

exit;
