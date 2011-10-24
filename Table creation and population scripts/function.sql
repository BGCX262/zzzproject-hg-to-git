spool logs\function_create.log

create or replace
function get_plan(  
  transaction_type varchar2,
  prod varchar2,
  gtype varchar2,
  gname varchar2,
  dtype varchar2,
  rdate date,
  return_value varchar2 default 'Units'
  ) 
  return number
is
  sdate date := NULL;
  edate date := NULL;
  volume number := null;
  geoname varchar2(100) :=gname;
  product varchar2(100) := prod;
  geotype varchar2(100) := gtype;
Begin
    geotype := nvl(gtype,'Area');
    if transaction_type != 'IMS' then
      return 0;
    end if;
    if gname = 'Total Russia' then
      geoname:= null;
    end if;

    if prod = 'All products' then
      product := null;
    end if;
    if dtype = 'Month' or dtype = 'HalfYear' then
      if to_number(to_char(rdate,'mm')) <=6 then
        sdate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
      if to_number(to_char(rdate,'mm')) > 6 then
        sdate := to_date('01.07.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.07.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
    end if;
    if dtype = 'Quarter' then
      if to_number(to_char(rdate,'q')) <=2 then
        sdate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
      if to_number(to_char(rdate,'q')) > 2 then
        sdate := to_date('01.07.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.07.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
    end if;
    if dtype = 'Year' then
        sdate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.07.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');  
    end if;     
    
    SELECT 
      sum(td.packs*get_price(td.idprod,td.real_date,null,return_value)) into volume
    FROM
      transactions_data td,
      clients c,
      products_new p,
      prodgrs pg,
      db_check_region t
    WHERE
    td.idclient = c.idclient
    and td.idclient = t.idclient
    and td.transaction_type in ('BR')
    and p.idprodgr=pg.idprodgr 
    and p.idprod=td.idprod 
    and (pg.prodgr=product or (td.idprod is not null and product is null))
    and t.region_id=c.idreg 
    and t.geography_type=geotype
    and (t.region = geoname or (td.idclient is not null and geoname is null))
    and td.real_date between sdate and edate;
   
   return nvl(volume,0);
end;
/

create or replace
function get_accfact(  
  transaction_type varchar2,
  prod varchar2,
  gtype varchar2,
  gname varchar2,
  dtype varchar2,
  rdate date,
  return_value varchar2 default 'Units'
  ) 
  return number
is
  sdate date := NULL;
  edate date := NULL;
  volume number := null;
  geoname varchar2(100) :=gname;
  product varchar2(100) := prod;
  geotype varchar2(100) := gtype;
Begin
    geotype := nvl(gtype,'Area');
    if transaction_type != 'IMS' then
      return 0;
    end if;
    if gname = 'Total Russia' then
      geoname:= null;
    end if;
    if prod = 'All products' then
      product := null;
    end if;
    if dtype = 'Month' then 
      if to_number(to_char(rdate,'mm')) <=6 then
        sdate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := rdate;
      end if;
      if to_number(to_char(rdate,'mm')) > 6 then
        sdate := to_date('01.07.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := rdate;
      end if;
    end if;
    if dtype = 'HalfYear' then
      if to_number(to_char(rdate,'mm')) <=6 then
        sdate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.06.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
      if to_number(to_char(rdate,'mm')) > 6 then
        sdate := to_date('01.07.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.12.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
    end if;
    if dtype = 'Quarter' then
      if to_number(to_char(rdate,'q')) = 1 then
        sdate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.03.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
      if to_number(to_char(rdate,'q')) = 2 then
        sdate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.06.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
      if to_number(to_char(rdate,'q')) = 3 then
        sdate := to_date('01.07.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.09.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
      if to_number(to_char(rdate,'q')) = 4 then
        sdate := to_date('01.07.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.12.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
      end if;
    end if;
    if dtype = 'Year' then
      if to_number(to_char(rdate,'mm')) <=6 then
        sdate := to_date('01.01.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');
        edate := to_date('01.12.'||to_char(rdate,'yyyy'),'dd.mm.yyyy');  
      end if;
    end if;      
     
    SELECT 
      sum(td.packs*get_price(td.idprod,td.real_date,null,return_value)) into volume
    FROM
      transactions_data td,
      clients c,
      products_new p,
      prodgrs pg,
      db_check_region t
    WHERE
    td.idclient = c.idclient
    and td.idclient = t.idclient
    and td.transaction_type in ('IMS')
    and p.idprodgr=pg.idprodgr 
    and p.idprod=td.idprod 
    and (pg.prodgr=product or (td.idprod is not null and product is null))
    and t.region_id=c.idreg 
    and (t.geography_type=geotype or (td.idclient is not null and geotype is null))
    and (t.region = geoname or (td.idclient is not null and geoname is null))
    and td.real_date between sdate and edate;
   
   return nvl(volume,0);
end;
/

/*
create or replace
function get_employee(
  client_id in number,
  product_id in number,
  dateid in date,
  search_type varchar2 default 'MIN'
  ) 
  return number
is
  val number := NULL;
  sdate date := NULL;
  edate date := NULL;
  nmonth number := NULL;
Begin
  nmonth := to_number(to_char(dateid,'mm'));
  sdate := dateid;
  if nmonth = 1 then
    edate := to_date('30.06.'||to_char(dateid,'yyyy'),'dd.mm.yyyy');
  end if;
  if nmonth = 7 then
    edate := to_date('31.12.'||to_char(dateid,'yyyy'),'dd.mm.yyyy');
  end if;
  
  select 
    employee_id
  from
    employee_client ce
  where 
  ;
  
  return nvl(val,2);
end;
/
*/

create or replace
function get_query(
  report varchar2 default 'One'
  ) 
  return varchar2
is
  sql_text varchar2(4000) := NULL;
Begin
  sql_text:= 'select null as link, period, sum(volume) as ITM from db_bigtable where transaction_type=''IMS'' group by period';
  return sql_text;  
end;
/

create or replace
function get_price(
  product_id in number,
  dateid in date,
  distributor_id in number,
  price_type in varchar2 default 'CIPRUR' -- Units; CIP RUR; CIP USD; NET RUR; NET USD
  ) 
  return number
is
  val number := NULL;
Begin
	if price_type = 'Units' then
		return 1;
	end if;
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
         sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and to_char(td.real_date,'yyyy') = to_char(add_months(dateid,-12),'yyyy');  
    end if;
    
    if date_type = 'Month' THEN
        SELECT
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and to_char(td.real_date,'mmyyyy') = to_char(add_months(dateid,-12),'mmyyyy');  
    end if;    
    
    if date_type = 'Quarter' THEN
        SELECT
         sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
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
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
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
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup) 
        and to_char(td.real_date,'yyyy') = to_char(add_months(dateid,-12),'yyyy');  
    end if;
    
    if date_type = 'Month' THEN
        SELECT
         sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
        and to_char(td.real_date,'mmyyyy') = to_char(add_months(dateid,-12),'mmyyyy');  
    end if;
    
    if date_type = 'Quarter' THEN
       SELECT
         sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
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
          sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
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
  if pgroup is not null then   
    if date_type = 'Year' THEN
          SELECT
            sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
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
            sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
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
            sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
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
            sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
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
    if pgroup is null then
      if date_type = 'Year' THEN
          SELECT
            sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
          FROM
            transactions_data td,
            clients c
          WHERE
          td.idclient = c.idclient
          and td.transaction_type in (nvl(tran_type,'IMS'))
          --and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup) 
          and to_char(td.real_date,'yyyy') = to_char(add_months(dateid,-12),'yyyy')
          and exists (select 1 from db_check_region t where t.region_id=c.idreg and t.geography_type=g_type and t.region = g_region );  
      end if;
      
      if date_type = 'Month' THEN
          SELECT
            sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
          FROM
            transactions_data td,
            clients c
          WHERE
          td.idclient = c.idclient
          and td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
          --and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
          and exists (select 1 from db_check_region t where t.region_id=c.idreg and t.geography_type=g_type and t.region = g_region )
          and to_char(td.real_date,'mmyyyy') = to_char(add_months(dateid,-12),'mmyyyy');  
      end if;
      
       if date_type = 'Quarter' THEN
         SELECT
            sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
          FROM
            transactions_data td,
            clients c
          WHERE
          td.idclient = c.idclient
          and td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
          --and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
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
            sum(td.packs), sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val, volume
          FROM
            transactions_data td,
            clients c
          WHERE
          td.idclient = c.idclient
          and td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
          --and exists (select 1 from products_new p, prodgrs pg where p.idprodgr=pg.idprodgr and p.idprod=td.idprod and pg.prodgr=pgroup)
          and exists (select 1 from db_check_region t where t.region_id=c.idreg and t.geography_type=g_type and t.region = g_region )
          and td.real_date in (select real_date from v_dates where dt_report = HY); 
      end if;
    end if;
end if;
  /*
  if return_value = 'Units' then return nvl(val,0);
  else return nvl(volume,0);
  end if;
  */
  return nvl(volume,0);
end;
/

create or replace
function accumulate_value(
  tran_type in varchar2,
  date_type in varchar2,
  dateid in date,
  return_value varchar2 default 'Units',
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
         sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        and td.real_date <= to_date('31.12.'||to_char(dateid,'yyyy'),'dd.mm.yyyy');  
    end if;
    
    if date_type = 'Month' THEN
        SELECT
         sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
        --and to_char(td.real_date,'mmyyyy') <= to_char(add_months(dateid,-12),'mmyyyy'); 
        and td.real_date <= last_day(dateid); 
    end if;
    
     if date_type = 'Quarter' THEN
        SELECT
         sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val
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
         sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val
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
         sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val
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
         sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val
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
         sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val
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
         sum(td.packs*get_price(td.idprod,td.real_date,idws,return_value)) into val
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


spool off

exit;
