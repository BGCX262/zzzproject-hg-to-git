
create or replace view v_dates as 
with
all_dates as 
(  
  select to_date('31.12.2006','dd.mm.yyyy')+rownum dt 
  from dual 
  connect by level <= (sysdate+365 - to_date('01.01.2007','dd.mm.yyyy'))
)
--days
select to_char(dt,'yyyymmdd') as dt_id, 
to_char(dt,'yyyymmdd') as dt_id_fake, 
to_char(dt,'dd.mm.yyyy') as dt, 
to_char(dt,'yyyymm') as dt_parent
from all_dates

union

--months
select distinct dt_id, dt_id_fake,dt,dt_parent
from 
(
select to_char(dt,'yyyymm') as dt_id, 
to_char(add_months(last_day(dt)+1,-1),'yyyymmdd') as dt_id_fake, 
to_char(dt,'Month') as dt, 
to_char(dt,'yyyy')||'Q'||to_char(dt,'q') as dt_parent
from all_dates
)
union

--quarters
select distinct dt_id,dt_id_fake,dt, dt_parent
from 
(
select to_char(dt,'yyyy')||'Q'||to_char(dt,'q') as dt_id, 
case when to_number(to_char(dt,'q')) = 1 then to_char(dt,'yyyy') || '0101'
     when to_number(to_char(dt,'q')) = 2 then to_char(dt,'yyyy') || '0401'
     when to_number(to_char(dt,'q')) = 3 then to_char(dt,'yyyy') || '0701'
     when to_number(to_char(dt,'q')) = 4 then to_char(dt,'yyyy') || '1001'
     end dt_id_fake,
'Q'||to_char(dt,'Q') as dt, 
case when to_number(to_char(dt,'mm'))>6 then 'H2'|| to_char(dt,'YYYY') else 'H1'|| to_char(dt,'YYYY') end  as dt_parent
--to_char(dt,'YYYY') as dt_parent
from all_dates
)

union

--half years

select distinct dt_id,dt_id_fake,dt,dt_parent
from 
(
select
case when to_number(to_char(dt,'mm'))>6 then 'H2'||to_char(dt,'YYYY') else 'H1'||to_char(dt,'YYYY') end  as dt_id, 
case when to_number(to_char(dt,'mm'))>6 then to_char(dt,'YYYY') || '0701' else to_char(dt,'YYYY') || '0101' end as dt_id_fake,
case when to_number(to_char(dt,'mm'))>6 then 'H2' else 'H1' end as dt, 
to_char(dt,'YYYY') as dt_parent
from all_dates
)

union

--years
select distinct dt_id,dt_id_fake,dt, dt_parent
from 
(
select to_char(dt,'yyyy') as dt_id,
to_char(dt,'yyyy') || '0101' as dt_id_fake,
to_char(dt,'YYYY') as dt, 
null as dt_parent
from all_dates
)
;


