/*CREATE OR REPLACE force VIEW BR_Value
AS
SELECT BR.IDKAM ,
       IDRep.VALUE ,
       BR.IDClient ,
       BR.IDProd ,
       BR.Packs ,
       BR.IDHY ,
       Packs * PriceCIP ValueCIP  ,
       Clients.City 
  FROM Products 
         JOIN ( Clients 
                JOIN BR 
                 ON Clients.IDClient = BR.IDClient
                 ) 
          ON Products.IDProd = BR.IDProd;


CREATE OR REPLACE force VIEW BR_ProdGrs
AS
SELECT DISTINCT ProdGrs.ProdGr ,
                Half_Year.HY ,
                SUM(BR_Value.ValueCIP) Sum_ValueCIP  ,
                Areas.Areas 
  FROM ( ( ( ProdGrs 
             JOIN Products 
              ON ProdGrs.IDProdGr = Products.IDProdGr
              ) 
           JOIN BR_Value 
            ON Products.IDProd = BR_Value.IDProd
            ) 
         JOIN Half_Year 
          ON BR_Value.IDHY = Half_Year.IDHY
          ) 
         JOIN ( ( Areas 
                  JOIN Regs 
                   ON Areas.IDArea = Regs.IDArea
                   ) 
                JOIN Clients 
                 ON Regs.IDReg = Clients.IDReg
                 ) 
          ON BR_Value.IDClient = Clients.IDClient
  GROUP BY ProdGrs.ProdGr,Half_Year.HY,Half_Year.IDHY,Areas.Areas;


CREATE OR REPLACE force VIEW BR_Value_KAMs
AS
SELECT DISTINCT BR_Value.IDKAM ,
                BR_Value.IDHY ,
                SUM(BR_Value.ValueCIP) Sum_ValueCIP  
  FROM BR_Value 
  GROUP BY BR_Value.IDKAM,BR_Value.IDHY;


CREATE OR REPLACE force VIEW BR_Value_Reps
AS
SELECT DISTINCT IDRep.VALUE ,
                BR_Value.IDHY ,
                SUM(BR_Value.ValueCIP) Sum_ValueCIP  ,
                BusUnits.BusUnit 
  FROM ( BusUnits 
         JOIN ProdGrs 
          ON BusUnits.IDBusUnit = ProdGrs.IDBusUnit
          ) 
         JOIN ( BR_Value 
                JOIN Products 
                 ON BR_Value.IDProd = Products.IDProd
                 ) 
          ON ProdGrs.IDProdGr = Products.IDProdGr
  GROUP BY IDRep.VALUE,BR_Value.IDHY,BusUnits.BusUnit;


CREATE OR REPLACE force VIEW Clients_
AS
SELECT IMS.IDProd ,
       IMS.IDMonth ,
       IMS.IDClient ,
       BR.IDKAM ,
       Clients.City ,
       Clients.IDReg ,
       SUM(IMS.Packs) Sum_Packs  
  FROM ( Clients 
         JOIN IMS 
          ON Clients.IDClient = IMS.IDClient
          ) 
         JOIN BR 
          ON Clients.IDClient = BR.IDClient
  GROUP BY IMS.IDProd,IMS.IDMonth,IMS.IDClient,BR.IDKAM,Clients.City,Clients.IDReg;


CREATE OR REPLACE force VIEW IMS_Value
AS
SELECT IMS.IDClient ,
       Clients.City ,
       IMS.IDProd ,
       IMS.Packs ,
       IMS.IDWS ,
       NULL * PriceCIP ValueCIP  ,
       NULL * PriceNet ValueNet  ,
       Months.Month 
  FROM Months 
         JOIN ( ( ProdGrs 
                  JOIN Products 
                   ON ProdGrs.IDProdGr = Products.IDProdGr
                   ) 
                JOIN ( Clients 
                       JOIN ( Discounts 
                              JOIN IMS 
                               ON Discounts.IDWS = IMS.IDWS
                               ) 
                        ON Clients.IDClient = IMS.IDClient
                        ) 
                 ON ( Products.IDProd = IMS.IDProd )
                AND ( ProdGrs.IDProdGr = Discounts.IDProdGr )
                 ) 
          ON Months.IDMonth = IMS.IDMonth;


CREATE OR REPLACE force VIEW IMS_ProdGrs
AS
SELECT DISTINCT ProdGrs.ProdGr ,
                SUM(IMS_Value.ValueCIP) Sum_ValueCIP  ,
                SUM(IMS_Value.ValueNet) Sum_ValueNet  ,
                Months.Month 
  FROM ( ( ProdGrs 
           JOIN Products 
            ON ProdGrs.IDProdGr = Products.IDProdGr
            ) 
         JOIN IMS_Value 
          ON Products.IDProd = IMS_Value.IDProd
          ) 
         JOIN Months 
          ON IMS_Value.IDMonth = Months.IDMonth
  GROUP BY ProdGrs.ProdGr,Months.Month;


CREATE OR REPLACE force VIEW IMS_Product_Groups
AS
SELECT DISTINCT ProdGrs.ProdGr ,
                Years.Y ,
                SUM(IMS_Value.ValueCIP) Sum_ValueCIP  ,
                SUM(IMS_Value.ValueNet) Sum_ValueNet  ,
                Areas.Areas 
  FROM Years 
         JOIN ( ( Areas 
                  JOIN Regs 
                   ON Areas.IDArea = Regs.IDArea
                   ) 
                JOIN ( ( ( IMS_Value 
                           JOIN ( ProdGrs 
                                  JOIN Products 
                                   ON ProdGrs.IDProdGr = Products.IDProdGr
                                   ) 
                            ON IMS_Value.IDProd = Products.IDProd
                            ) 
                         JOIN ( Half_Year 
                                JOIN Months 
                                 ON Half_Year.IDHY = Months.IDHY
                                 ) 
                          ON IMS_Value.IDMonth = Months.IDMonth
                          ) 
                       JOIN Clients 
                        ON IMS_Value.IDClient = Clients.IDClient
                        ) 
                 ON Regs.IDReg = Clients.IDReg
                 ) 
          ON Years.IDY = Half_Year.IDY
  GROUP BY ProdGrs.ProdGr,Years.Y,Areas.Areas;


CREATE OR REPLACE force VIEW IMS_Value_Detailed_KAMs
AS
SELECT DISTINCT KAMs.KAM ,
                IMS_Value.ValueCIP ,
                IMS_Value.IDClient ,
                Clients.City ,
                IMS_Value.IDProd ,
                IMS_Value.Packs ,
                IMS_Value.IDMonth ,
                Years.Y 
  FROM Years 
         JOIN ( Half_Year 
                JOIN ( ( ( ( Clients 
                             JOIN IMS_Value 
                              ON Clients.IDClient = IMS_Value.IDClient
                              ) 
                           JOIN BR_Value 
                            ON Clients.IDClient = BR_Value.IDClient
                            ) 
                         JOIN KAMs 
                          ON BR_Value.IDKAM = KAMs.IDKAM
                          ) 
                       JOIN Months 
                        ON ( BR_Value.IDHY = Months.IDHY )
                       AND ( IMS_Value.IDMonth = Months.IDMonth )
                        ) 
                 ON ( Half_Year.IDHY = Months.IDHY )
                AND ( Half_Year.IDHY = BR_Value.IDHY )
                 ) 
          ON Years.IDY = Half_Year.IDY
  GROUP BY KAMs.KAM,IMS_Value.ValueCIP,IMS_Value.IDClient,Clients.City,IMS_Value.IDProd,IMS_Value.Packs,IMS_Value.IDMonth,Years.Y,Half_Year.HY;


CREATE OR REPLACE force VIEW IMS_Value_Detailed_Reps
AS
SELECT Reps.Emp ,
       IMS_Value.ValueCIP ,
       IMS_Value.IDClient ,
       Clients.City ,
       IMS_Value.IDProd ,
       IMS_Value.Packs ,
       IMS_Value.IDMonth 
  FROM Reps 
         JOIN ( Half_Year 
                JOIN ( ( ( Clients 
                           JOIN IMS_Value 
                            ON Clients.IDClient = IMS_Value.IDClient
                            ) 
                         JOIN BR_Value 
                          ON ( IMS_Value.IDProd = BR_Value.IDProd )
                         AND ( Clients.IDClient = BR_Value.IDClient )
                          ) 
                       JOIN Months 
                        ON ( BR_Value.IDHY = Months.IDHY )
                       AND ( IMS_Value.IDMonth = Months.IDMonth )
                        ) 
                 ON ( Half_Year.IDHY = Months.IDHY )
                AND ( Half_Year.IDHY = BR_Value.IDHY )
                 ) 
          ON Reps.IDRep = IDRep.VALUE
  GROUP BY Reps.Emp,IMS_Value.ValueCIP,IMS_Value.IDClient,Clients.City,IMS_Value.IDProd,IMS_Value.Packs,IMS_Value.IDMonth,Half_Year.HY;


CREATE OR REPLACE force VIEW IMS_BR_Performance
AS
SELECT BR.IDClient ,
       Clients.City ,
       BR.IDProd ,
       Years.Y ,
       SUM(BR.Packs) Sum_BR_Packs  ,
       SUM(IMS.Packs) Sum_IMS_Packs  ,
       Sum_BR_Packs * NULL ValueBR  ,
       Sum_IMS_Packs * NULL ValueIMS  ,
       ValueIMS / ValueBR PERCENT  ,
       BR.IDKAM ,
       Months.Month 
  FROM Years 
         JOIN ( Products 
                JOIN ( Clients 
                       JOIN ( Half_Year 
                              JOIN ( Months 
                                     JOIN ( IMS 
                                            JOIN BR 
                                             ON IMS.IDProd = BR.IDProd
                                             ) 
                                      ON ( Months.IDMonth = IMS.IDMonth )
                                     AND ( Months.IDHY = BR.IDHY )
                                      ) 
                               ON ( Half_Year.IDHY = BR.IDHY )
                              AND ( Half_Year.IDHY = Months.IDHY )
                               ) 
                        ON ( Clients.IDClient = IMS.IDClient )
                       AND ( Clients.IDClient = BR.IDClient )
                        ) 
                 ON ( Products.IDProd = IMS.IDProd )
                AND ( Products.IDProd = BR.IDProd )
                 ) 
          ON Years.IDY = Half_Year.IDY
  GROUP BY BR.IDClient,Clients.City,BR.IDProd,Years.Y,BR.IDKAM,Months.Month,IMS.IDMonth,Products.PriceCIP;


CREATE OR REPLACE force VIEW IMS_Value_Performance_KAMs
AS
SELECT DISTINCT IMS_BR_Performance.IDKAM ,
                SUM(IMS_BR_Performance.ValueIMS) Sum_ValueIMS  
  FROM IMS_BR_Performance 
  GROUP BY IMS_BR_Performance.IDKAM;


CREATE OR REPLACE force VIEW IMS_Value_Performance_Reps
AS
SELECT DISTINCT IMS_Value_Detailed_Reps.Emp Выражение1  ,
                SUM(IMS_Value_Detailed_Reps.ValueCIP) Sum_ValueCIP  
  FROM IMS_Value_Detailed_Reps 
  GROUP BY IMS_Value_Detailed_Reps.Emp;


CREATE OR REPLACE force VIEW IMS_Value_
AS
SELECT DISTINCT IMS_Value.IDClient ,
                IMS_Value.City ,
                IMS_Value.IDProd ,
                SUM(IMS_Value.Packs) Sum_Packs  ,
                SUM(IMS_Value.ValueCIP) Sum_IMS_Value_ValueCIP  ,
                BR_Value.ValueCIP Sum_BR_Value_ValueCIP  ,
                BR_Value.Packs ,
                BR_Value.IDKAM ,
                BR_Value.IDHY 
  FROM ( ( Clients 
           JOIN BR_Value 
            ON Clients.IDClient = BR_Value.IDClient
            ) 
         JOIN IMS_Value 
          ON ( BR_Value.IDClient = IMS_Value.IDClient )
         AND ( BR_Value.IDProd = IMS_Value.IDProd )
         AND ( Clients.IDClient = IMS_Value.IDClient )
          ) 
         JOIN Months 
          ON ( Months.IDHY = BR_Value.IDHY )
         AND ( IMS_Value.IDMonth = Months.IDMonth )
  GROUP BY IMS_Value.IDClient,IMS_Value.City,IMS_Value.IDProd,BR_Value.ValueCIP,BR_Value.Packs,BR_Value.IDKAM,BR_Value.IDHY;


CREATE OR REPLACE force VIEW IMS_
AS
SELECT IMS.IDProd ,
       Products.IDProdGr ,
       ProdGrs.IDBusUnit ,
       IMS.Packs ,
       IMS.IDClient ,
       Clients.City ,
       Clients.IDReg ,
       IMS.Remarks ,
       IMS.IDMonth 
  FROM ( ProdGrs 
         JOIN Products 
          ON ProdGrs.IDProdGr = Products.IDProdGr
          ) 
         JOIN ( Clients 
                JOIN IMS 
                 ON Clients.IDClient = IMS.IDClient
                 ) 
          ON Products.IDProd = IMS.IDProd;
 */         

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


