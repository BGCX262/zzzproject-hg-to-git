
spool logs\transaction_data.log

DROP SEQUENCE TRANSACTIONS_ID_SEQ;
CREATE SEQUENCE  TRANSACTIONS_ID_SEQ  
  MINVALUE 1 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE TRANSACTIONS_DATA;
CREATE TABLE TRANSACTIONS_DATA
  (
    IDTRAN NUMBER,
    IDBR    NUMBER(11,0) ,
    IDIMS    NUMBER(11,0),
    TRANSACTION_TYPE varchar(4),
    --KAMREP VARCHAR(4),
    --IDKAMREP   NUMBER(11,0),
    IDCLIENT NUMBER(11,0),
    IDPROD   NUMBER(11,0),
	REAL_DATE date,
	REAL_DATE_TYPE varchar2(30),
    --IDHY     NUMBER(11,0),
    --IDY     NUMBER(11,0),
    --IDMONTH NUMBER(11,0),
    IDWS    NUMBER(11,0),
    PACKS_PLAN    NUMBER(5,0) DEFAULT 0,
    PACKS_FACK    NUMBER(5,0) DEFAULT 0,
    PACKS    NUMBER(5,0) DEFAULT 0 ,
	COMMENTS varchar2(1024),
	EXTRA_ID	number default null,
	EXTRA_CODE varchar2(30) default null,
	EXTRA_TEXT varchar2(4000) default null
  );

ALTER TABLE TRANSACTIONS_DATA
ADD CONSTRAINT PK_TRANSACTIONS PRIMARY KEY
(
  IDTRAN
)
ENABLE
;

insert into transactions_data  
select transactions_id_seq.nextval,idbr, null, 'BR',  idclient, idprod, case when idhy=7 then to_date('01.01.2011','dd.mm.yyyy') when idhy=8 then to_date('01.07.2011','dd.mm.yyyy') else to_date('31.12.2071','dd.mm.yyyy') end , 'HalfYear', null, packs, null, packs, null, null, null , null
from br where idkam is not null;
; 
commit;



--insert into transactions_data  
--select TRANSACTIONS_ID_SEQ.nextval, br.IDBR, ims.IDIMS, 'IMS', null as kam /*'KAM'*/, null as idkam /*br.IDKAM*/, ims.IDCLIENT, ims.IDPROD, (select idhy from months where idmonth=ims.idmonth), (select IDY from half_year where idhy=(select idhy from months where idmonth=ims.idmonth)), ims.IDMONTH, ims.IDWS, null, ims.PACKS, ims.PACKS  
--from ims, br
--where ims.idclient=br.idclient
 -- and ims.idprod=br.idprod
 -- and br.idhy=(select idhy from months where idmonth=ims.idmonth)
 -- and br.idkam is not null
 -- ;
--commit;


--insert into transactions_data  
--select TRANSACTIONS_ID_SEQ.nextval, null, ims.IDIMS, 'IMS', null as kam /*'KAM'*/, 
--(select max(maxkam) from 
--(
--select  b.idhy, c2.city, count(distinct b.idkam) qvt, min(b.idkam) minkam, max(b.idkam) maxkam 
--from 
 -- br b, clients c2
--where b.idclient=c2.idclient
--and c2.city is not null
--group by  b.idhy, c2.city
--) t
-- where 
--  t.minkam=t.maxkam and
 -- t.city = c.city 
-- ) idkamrep,ims.IDCLIENT, ims.IDPROD, 
--- (select idhy from months where idmonth=ims.idmonth), 
-- (select IDY from half_year where idhy=(select idhy from months where idmonth=ims.idmonth)), 
 --ims.IDMONTH, ims.IDWS, null, ims.PACKS, ims.PACKS  
--from ims, clients c
--where 
 -- ims.idclient=c.idclient and
 -- ims.idims not in ( 
 -- select ims1.IDIMS
 -- from ims ims1, br br1
 -- where ims1.idclient=br1.idclient
 --   and ims1.idprod=br1.idprod
 --   and br1.idhy=(select idhy from months where idmonth=ims1.idmonth)
 --   and br1.idkam is not null)
--;
--commit;

insert into transactions_data  
select transactions_id_seq.nextval, null,idims, 'IMS',  idclient, idprod, (select month from months m where m.idmonth = i.idmonth), 'Month', idws, null, packs, packs, null, null, null , null
from ims i;

commit;
--
--Update transactions_data for new products
--

update transactions_data td
set idprod = (select pn.idprod from products_new pn, products po where pn.prod = po.prod and po.idprod = td.idprod) ;

commit;
--

DROP SEQUENCE CIP_ID_SEQ;
CREATE SEQUENCE  CIP_ID_SEQ  
  MINVALUE 10 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE CIP_SCHEMA;
CREATE TABLE CIP_SCHEMA
  (
    IDSCHEMA   NUMBER(11,0) ,
    SCHEMA_NAME  VARCHAR2(100),
    real_date date,
	real_date_type varchar2(100)
  );
ALTER TABLE CIP_SCHEMA
ADD CONSTRAINT PK_CIP PRIMARY KEY
(
  IDSCHEMA
)
ENABLE
;

DELETE FROM CIP_SCHEMA;
INSERT INTO CIP_SCHEMA SELECT 1,'KAM SCHEMA H12011', to_date('01.01.2011','dd.mm.yyyy'), 'HalfYear' FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 2,'HEAD OF KAM SCHEMA H12011', to_date('01.01.2011','dd.mm.yyyy'), 'HalfYear' FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 3,'REP COMB 5 H12011', to_date('01.01.2011','dd.mm.yyyy'), 'HalfYear' FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 4,'REP NEPHRO 2 AN, Mi H12011', to_date('01.01.2011','dd.mm.yyyy'), 'HalfYear' FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 5,'REP ONCO 2 AO, Vbx H12011', to_date('01.01.2011','dd.mm.yyyy'), 'HalfYear' FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 6,'REP ONCO 3 AO, Npl, Vbx H12011', to_date('01.01.2011','dd.mm.yyyy'), 'HalfYear' FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 7,'REP ONCO 2 AO, Npl H12011', to_date('01.01.2011','dd.mm.yyyy'), 'HalfYear' FROM DUAL;
 
 DROP SEQUENCE CIPEMP_ID_SEQ;
CREATE SEQUENCE  CIPEMP_ID_SEQ  
  MINVALUE 1 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE CIP_SCHEMA_EMPL;
CREATE TABLE CIP_SCHEMA_EMPL
  (
    IDCIPEMP NUMBER,
    IDSCHEMA NUMBER(11,0) ,
    EMPLTYPE VARCHAR(4),
    IDKAMREP NUMBER(11,0)
  );
  
ALTER TABLE CIP_SCHEMA_EMPL
ADD CONSTRAINT PK_CIPEMP PRIMARY KEY
(
  IDCIPEMP
)
ENABLE
;

delete from cip_schema_empl;
insert into cip_schema_empl select cipemp_id_seq.nextval,1, 'KAM', employee_id from employee where employee_type = 'KAM';
insert into cip_schema_empl select cipemp_id_seq.nextval,1, 'SKAM', employee_id from employee where employee_type = 'SKAM';
insert into cip_schema_empl select cipemp_id_seq.nextval,6, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 1) from dual;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,7, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 8) FROM DUAL;
insert into cip_schema_empl select cipemp_id_seq.nextval,6, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 9) from dual;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 10) FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 11) FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 12) FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 3) FROM DUAL;
insert into cip_schema_empl select cipemp_id_seq.nextval,4, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 7) from dual;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 13) FROM DUAL;
insert into cip_schema_empl select cipemp_id_seq.nextval,4, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 14) from dual;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,3, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 15) FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,3, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 4) FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,3, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 6) FROM DUAL;
insert into cip_schema_empl select cipemp_id_seq.nextval,6, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 2) from dual;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', (select (select employee_id from employee where employee_type = 'REP' and employee_name = emp) from reps t where idrep = 5) FROM DUAL;

/*INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,1, 'KAM', K.IDKAM FROM KAMS K WHERE NOT EXISTS (SELECT 1 FROM SENKAMS S WHERE K.KAM LIKE S.SENKAM||'%');
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,2, 'SKAM', K.IDKAM FROM KAMS K WHERE EXISTS (SELECT 1 FROM SENKAMS S WHERE K.KAM LIKE S.SENKAM||'%');
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 1 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,7, 'REP', 8 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 9 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 10 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 11 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 12 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 3 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 7 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 13 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 14 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,3, 'REP', 15 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,3, 'REP', 4 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,3, 'REP', 6 FROM DUAL;

INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 2 FROM DUAL;
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 5 FROM DUAL;*/

commit;

DROP SEQUENCE CIPDET_ID_SEQ;
CREATE SEQUENCE  CIPDET_ID_SEQ  
  MINVALUE 1 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE CIP_SCHEMA_DETAIL;
CREATE TABLE CIP_SCHEMA_DETAIL
  (
    IDSCHEMADET NUMBER,
    IDSCHEMA NUMBER(6,3) ,
    IDPRODGR   NUMBER(6,3),
    PRODSPLIT    NUMBER(3,1),
    HVALUE   NUMBER(38,2),
    YVALUE   NUMBER(38,2), 
    KSO      NUMBER(38,2)
  );
  
ALTER TABLE CIP_SCHEMA_DETAIL
ADD CONSTRAINT PK_CIPDET PRIMARY KEY
(
  IDSCHEMADET
)
ENABLE
;

delete from cip_schema_detail;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,1, null, 1, 123874, 247748, 133402   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,2, null, 1, 129937, 259875, 173250   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,3, 1, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,3, 2, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,3, 3, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,3, 4, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,3, 5, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,4, 1, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,4, 3, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,5, 2, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,5, 5, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,6, 2, 0.4, 43313, 0, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,6, 4, 0.2, 43313, 0, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,6, 5, 0.4, 43313, 173250, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,7, 2, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval,7, 4, 0.5, 43313, 86625, 57750   from dual;

commit;

--insert into reps select 17, 'Ночевкина', 2 from dual;
--insert into reps select 18, 'Лисюкова', 1 from dual;

/*commit; 

drop table senreps; 
CREATE TABLE senreps
  (
    IDREPS   NUMBER(11,0) ,
    IDSENREPS  NUMBER(11,0)
  ); 

insert into senreps select 1, 17 from dual;
insert into senreps select 2, 17 from dual;
insert into senreps select 8, 17 from dual;
insert into senreps select 9, 17 from dual;
insert into senreps select 10, 17 from dual;
insert into senreps select 11, 17 from dual;
insert into senreps select 12, 17 from dual;

insert into senreps select 5, 18 from dual;
insert into senreps select 3, 18 from dual;
insert into senreps select 7, 18 from dual;
insert into senreps select 13, 18 from dual;
insert into senreps select 14, 18 from dual;
insert into senreps select 15, 18 from dual;
insert into senreps select 4, 18 from dual;

commit;*/

drop sequence PAYOUT_ID_SEQ;
create sequence  PAYOUT_ID_SEQ  minvalue 100 maxvalue 999999999999999999999999 increment by 1  nocycle ;

drop table payout_curve;
create table payout_curve 
(
idpayout number,
ytdgoal number,
targetinc number
);

alter table payout_curve add constraint pk_payout primary key
(
  idpayout
) enable;


create or replace
procedure 
        pr_payout_curve(start_with number, threshold number, excellence number)
is 
  i number;
  steps number;
begin
  delete from payout_curve;
  steps:= 0;
  
   FOR i in 50..300 LOOP
    if i < threshold then
      insert into payout_curve select PAYOUT_ID_SEQ.nextval, i/100, 0 from dual;  
    end if;
    if i >= threshold and i < excellence then
      insert into payout_curve select PAYOUT_ID_SEQ.nextval, i/100, (start_with + steps)/100 from dual;  
      steps := steps + 5;
    end if;
    if i >= excellence then
      insert into payout_curve select PAYOUT_ID_SEQ.nextval, i/100, (start_with + steps)/100 from dual;  
      steps := steps + 1;
    end if;
    
  END LOOP;
end pr_payout_curve;
/

exec pr_payout_curve(50,90,130);
/

create or replace function month_return(months varchar2) return varchar2
is
l_vc_arr2    apex_application_global.vc_arr2;
l_month varchar2(255);
l_result varchar2(4000);
begin
 l_vc_arr2 := APEX_UTIL.STRING_TO_TABLE(months,':');
       for z in 1..l_vc_arr2.count loop
               select to_char(month,'mm.yy') into l_month from months where idmonth = l_vc_arr2(z);
               l_result := l_result || l_month ||';';
       end loop;
 return l_result;
end;
/

/*
create or replace force view v_bonus as 
select  
  td.idy,
  td.idhy,
  'KAM' EmplType,
  k.idsenkam,
  k.idkam,
  k.kam,
  pg.idprodgr,
  pg.prodgr,
  td.TRANSACTION_TYPE,
  sum(td.packs_plan * p.pricecip) BR,
  sum(td.packs_fack * p.pricecip) IMS,
  sum(td.packs * p.pricecip) CIP
from
  transactions_data td, 
  products p,
  prodgrs pg,
  kams k,
  senkams sk
where 
  td.idprod=p.idprod
  and p.idprodgr = pg.idprodgr
  and k.idsenkam=sk.idsenkam
  and td.kamrep='KAM'
  and td.idkamrep=k.idkam
  --and td.idhy=7
group by 
  td.idy,
  td.idhy,
  DECODE(k.kam,sk.senkam,'Head of KAM','KAM'),
  k.idsenkam,
  k.idkam,
  k.kam,
  pg.idprodgr,
  pg.prodgr,
  td.TRANSACTION_TYPE;

create or replace force view v_prepare_calculation as  
select 
  v.*,
  (select 
      sum(d.YVALUE)
    from
      cip_schema s,
      cip_schema_empl e,
      cip_schema_detail d
    where 
      e.idkamrep = v.idkam
      and e.empltype in ('KAM','SKAM')      
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
    e.idkamrep = v.idkam
    and e.empltype in ('KAM','SKAM')
    and s.idy=v.idy
    and s.idhy=v.idhy
    and (d.idprodgr=v.idprodgr or d.idprodgr is null)
    and e.idschema=d.idschema
    and s.idschema=e.idschema) prodsplit,
    ( select 
      round( sum(v1.ims) / sum(v1.br) ,2) 
    from
      v_bonus v1
    where
        v1.idkam=v.idkam
        and v1.idhy=v.idhy
        and v1.idy=v.idy
     group by v1.idkam) goal_achievement,
    ( select 
      decode(sum(v1.br),0,0,round( sum(v1.ims) / sum(v1.br) ,2) )
    from
      v_bonus v1
    where
        v1.idkam=v.idkam
        and v1.idhy=v.idhy
        and v1.idy=v.idy
        and v1.idprodgr=v.idprodgr
     group by v1.idkam) goal_achievement_prod
from 
  v_bonus v
;

create or replace force view v_total_bonus as
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
  v_prepare_calculation vpc;

create or replace force view v_pivot_total as
(select 
  *
from  (select 
        idy,
        idhy,
        empltype, 
        idsenkam,
        kam, 
        base, 
        prodgr, 
        ims, 
        br, 
        prodsplit, 
        goal_achievement, 
        payout_curve , 
        goal_achievement_prod, 
        payout_curve_prod 
      from v_total_bonus) t
            pivot (
                sum(ims) as sum_ims, 
                sum(br) as sum_br, 
                min(prodsplit) as psplit, 
                min(goal_achievement_prod) as goal_achievement, 
                min(payout_curve_prod) as payout_curve_prod 
              for (prodgr) in ('AN' as AN, 'AO' as AO, 'Mi' as Mi, 'Npl' as Npl, 'Vbx' as Vbx)
            )
);

create or replace force view v_kams as
  SELECT 
    K.IDKAM, 
    SK.IDSENKAM 
  FROM 
    KAMS K, 
    SENKAMS SK 
  WHERE 
    K.IDSENKAM=SK.IDSENKAM AND 
    EXISTS (SELECT 1 FROM SENKAMS S WHERE K.KAM LIKE S.SENKAM||'%')
;


create or replace force view v_bonus_sk as 
select  
  td.idy,
  td.idhy,
  'Head of KAM' EmplType,
  vsk.idsenkam,
  vsk.idkam,
  sk.senkam kam,
  pg.idprodgr,
  pg.prodgr,
  td.TRANSACTION_TYPE,
  sum(td.packs_plan * p.pricecip) BR,
  sum(td.packs_fack * p.pricecip) IMS,
  sum(td.packs * p.pricecip) CIP
from
  transactions_data td, 
  products p,
  prodgrs pg,
  kams k,
  senkams sk,
  v_kams vsk
where 
      td.idprod=p.idprod
  and p.idprodgr = pg.idprodgr
  and k.idsenkam=sk.idsenkam
  and sk.idsenkam=vsk.idsenkam
  and td.kamrep='KAM'
  and td.idkamrep=k.idkam
 -- and td.idhy=7 
group by 
  td.idy,
  td.idhy,
  vsk.idsenkam,
  vsk.idkam,
  sk.senkam,
  pg.idprodgr,
  pg.prodgr,
  td.TRANSACTION_TYPE;

create or replace force view v_sk_prepare_calculation as  
select 
  v.*,
  (select 
      sum(d.YVALUE)
    from
      cip_schema s,
      cip_schema_empl e,
      cip_schema_detail d
    where 
      e.idkamrep = v.idkam
      and e.empltype = 'SKAM'
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
    e.idkamrep = v.idkam
    and e.empltype='SKAM'
    and s.idy=v.idy
    and s.idhy=v.idhy
    and (d.idprodgr=v.idprodgr or d.idprodgr is null)
    and e.idschema=d.idschema
    and s.idschema=e.idschema) prodsplit,
    ( select 
      round( sum(v1.ims) / sum(v1.br) ,2) 
    from
      v_bonus_sk v1
    where
        v1.idkam=v.idkam
        and v1.idhy=v.idhy
        and v1.idy=v.idy
     group by v1.idkam) goal_achievement,
    ( select 
      decode(sum(v1.br),0,0,round( sum(v1.ims) / sum(v1.br) ,2) )
    from
      v_bonus_sk v1
    where
        v1.idkam=v.idkam
        and v1.idhy=v.idhy
        and v1.idy=v.idy
        and v1.idprodgr=v.idprodgr
     group by v1.idkam) goal_achievement_prod
from 
  v_bonus_sk v
;

create or replace force view v_sk_total_bonus as
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
  v_sk_prepare_calculation vpc;

create or replace force view v_sk_pivot_total as
(select 
  *
from  (select 
        idy,
        idhy,
        empltype, 
        idsenkam,
        kam, 
        base, 
        prodgr, 
        ims, 
        br, 
        prodsplit, 
        goal_achievement, 
        payout_curve , 
        goal_achievement_prod, 
        payout_curve_prod 
      from v_sk_total_bonus) t
            pivot (
                sum(ims) as sum_ims, 
                sum(br) as sum_br, 
                min(prodsplit) as psplit, 
                min(goal_achievement_prod) as goal_achievement, 
                min(payout_curve_prod) as payout_curve_prod 
              for (prodgr) in ('AN' as AN, 'AO' as AO, 'Mi' as Mi, 'Npl' as Npl, 'Vbx' as Vbx)
            )
);

create or replace force view v_bonus_rep as 
select  
  td.idy,
  td.idhy,
  'Reps' EmplType,
  sr.idsenreps,
  r.idrep,
  r.emp rep,
  pg.idprodgr,
  pg.prodgr,
  td.TRANSACTION_TYPE,
  sum(td.packs_plan * p.pricecip) BR,
  sum(td.packs_fack * p.pricecip) IMS,
  sum(td.packs * p.pricecip) CIP
from
  transactions_data td, 
  products p,
  prodgrs pg,
  reps r,
  senreps sr
where 
      td.idprod=p.idprod
  and p.idprodgr = pg.idprodgr
  and td.kamrep='REP'
  and td.idkamrep=r.idrep
  and sr.idreps=r.idrep
  --and td.idhy=7 
group by 
  td.idy,
  td.idhy,
  sr.idsenreps,
  idrep,
  r.emp,
  pg.idprodgr,
  pg.prodgr,
  td.TRANSACTION_TYPE;

create or replace force view v_rep_prepare_calculation as  
select 
  v.*,
  (select 
      sum(d.YVALUE)
    from
      cip_schema s,
      cip_schema_empl e,
      cip_schema_detail d
    where 
      e.idkamrep = v.idrep
      and e.empltype='REP'
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
    e.idkamrep = v.idrep
    and e.empltype='REP'
    and s.idy=v.idy
    and s.idhy=v.idhy
    and (d.idprodgr=v.idprodgr or d.idprodgr is null)
    and e.idschema=d.idschema
    and s.idschema=e.idschema) prodsplit,
    ( select 
      round( sum(v1.ims) / sum(v1.br) ,2) 
    from
      v_bonus_rep v1
    where
        v1.idrep=v.idrep
        and v1.idhy=v.idhy
        and v1.idy=v.idy
     group by v1.idrep) goal_achievement,
    ( select 
      decode(sum(v1.br),0,0,round( sum(v1.ims) / sum(v1.br) ,2) )
    from
      v_bonus_rep v1
    where
        v1.idrep=v.idrep
        and v1.idhy=v.idhy
        and v1.idy=v.idy
        and v1.idprodgr=v.idprodgr
     group by v1.idrep) goal_achievement_prod
from 
  v_bonus_rep v
;

create or replace force view v_rep_total_bonus as
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
  v_rep_prepare_calculation vpc;

create or replace force view v_rep_pivot_total as
(select 
  *
from  (select 
        idy,
        idhy,
        empltype,
        idsenreps,
        rep, 
        base, 
        prodgr, 
        ims, 
        br, 
        prodsplit, 
        goal_achievement, 
        payout_curve , 
        goal_achievement_prod, 
        payout_curve_prod 
      from v_rep_total_bonus) t
            pivot (
                sum(ims) as sum_ims, 
                sum(br) as sum_br, 
                max(prodsplit) as psplit, 
                min(goal_achievement_prod) as goal_achievement, 
                min(payout_curve_prod) as payout_curve_prod 
              for (prodgr) in ('AN' as AN, 'AO' as AO, 'Mi' as Mi, 'Npl' as Npl, 'Vbx' as Vbx)
            )
);
*/
/*
insert into employee_client
select employee_client_id_seq.nextval as ids, t.idhy, t.empl, t.idclient, t.idprod,'EXPL' as link_type, 1 as plan_pct 
from 
(select distinct b.idhy, 
(select e.employee_id from employee e, kams k where e.employee_name=k.kam and e.employee_type in ('KAM','SKAM') and k.idkam = b.idkam) as empl,
b.idclient,
pn.idprod
from br b, products_new pn
where b.idkam is not null
) t
;

commit;

insert into employee_client
select employee_client_id_seq.nextval as ids, t.idhy, t.empl, t.idclient, t.idprod, 'EXPL' as link_type, 1 as plan_pct 
from 
(select distinct b.idhy, 
(select e.employee_id from employee e, reps r where e.employee_name=r.emp and e.employee_type in ('REP','SREP') and r.idrep = b.idrep) as empl,
b.idclient,
pn.idprod
from br b, products_new pn
where b.idrep is not null
) t
;

commit;
*/

insert into employee_client
select 
  employee_client_id_seq.nextval as ids, t.real_date, t.empl, t.idclient, t.idprod, 'EXPL' as link_type, 1 as plan_pct 
from
    (select distinct
      case 
        when b.idhy = 7 then to_date('01.01.2011','dd.mm.yyyy')
        when b.idhy = 8 then to_date('01.07.2011','dd.mm.yyyy')
        else to_date('01.01.2121','dd.mm.yyyy')
      end as real_date,
      (select e.employee_id from employee e, reps r where e.employee_name=r.emp and e.employee_type in ('REP','SREP') and r.idrep = b.idrep) as empl,
      b.idclient,
      (select p2.idprod from products p1, products_new p2 where p1.prod = p2.prod and p1.idprod = b.idprod) as idprod
    from br b
    where b.idrep is not null
) t;
commit;

insert into employee_client
select 
  employee_client_id_seq.nextval as ids, t.real_date, t.empl, t.idclient, t.idprod, 'EXPL' as link_type, 1 as plan_pct 
from
    (select distinct
      case 
        when b.idhy = 7 then to_date('01.01.2011','dd.mm.yyyy')
        when b.idhy = 8 then to_date('01.07.2011','dd.mm.yyyy')
        else to_date('01.01.2121','dd.mm.yyyy')
      end as real_date,
      (select e.employee_id from employee e, kams k where e.employee_name=k.kam and e.employee_type in ('KAM','SKAM') and k.idkam = b.idkam) as empl,
      b.idclient,
      (select p2.idprod from products p1, products_new p2 where p1.prod = p2.prod and p1.idprod = b.idprod) as idprod
    from br b
    where b.idkam is not null
) t;
commit;

create or replace
trigger  bi_transactions_data
  before insert or update on transactions_data
  for each row
begin

    if nvl(:new.packs_plan,0) <> 0 then
        :new.packs := :new.packs_plan;
    else 
        :new.packs := :new.packs_fack;
    end if;   
end; 
/


---dashboards and cubes
create or replace
function get_price(
  product_id in number,
  dateid in date,
  price_type in varchar2 default 'CIP', 
  currency_type in varchar2 default 'RUR'
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
  return_value varchar2 default 'Units', 
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
        and td.real_date <= last_day(dateid); 
    end if;
    
     if date_type = 'Quarter' THEN
        SELECT
         sum(td.packs) into val
        FROM
          transactions_data td
        WHERE
        td.transaction_type  in (nvl(tran_type,'IMS'),nvl(tran_type,'IMP'))
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
  previous_units number,
  accum_units number,
  growth number,
  volume_diff number default null,
  sys_info varchar2(100)
);

create or replace
procedure update_bigtable (t in number)

is
begin
  dbms_output.put_line('start: '||sysdate);
  delete from db_bigtable;
--step 1: insert ITM data by units
  insert into db_bigtable 
  select 
    'Sales' as report_type,
    'Units' as measure, 
    transaction_type, 
    'Total' as product, 
    minreal_date, 
    dt_id, 
    dt_type, 
    period, 
    null,
    null,
    units as volume,
    previous_value(transaction_type,dt_type, minreal_date) as previous_units,
    accumulate_value(transaction_type,dt_type, minreal_date) as accum_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date) = 0 THEN 0
    ELSE
      round((units - previous_value(transaction_type,dt_type, minreal_date))/previous_value(transaction_type,dt_type, minreal_date),3)*100
    END  as growth,
    0 as volume_diff,
    'Step1'
  from 
    db_gsales_calc;
  
--step 2: insert ITM data by CIP RUR
  insert into db_bigtable 
  select 
    'Sales' as report_type,
    'CIP RUR' as measure, 
    transaction_type, 
    'Total' as product,
    minreal_date, 
    dt_id, 
    dt_type,
    period, 
    null,
    null,
    price as volume,
    accumulate_value(transaction_type,dt_type, minreal_date) as accum_units,
    previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR') as previous_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR') = 0 THEN 0
    ELSE
      round((price - previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR'))/previous_value(transaction_type,dt_type, minreal_date, null, 'CIPRUR'),3)*100
    END  as growth,
    0 as volume_diff,
    'Step2'
  from 
    db_gsales_calc;
    
--step 3: insert ITM + TTM
  insert into db_bigtable    
  select 
    'Total' as report_type,
    'Units' as measure,
    null as transaction_type, 
    'Total' as product,
    minreal_date, 
    dt_id, 
    dt_type, 
    period, 
    null,
    null,
    units, 
    accumulate_value(null,dt_type, minreal_date )as accum_units,
    previous_value(null ,dt_type, minreal_date) as previous_units,
    case 
      when previous_value(null,dt_type, minreal_date) = 0 THEN 0
    ELSE
      round((units - previous_value(null,dt_type, minreal_date))/previous_value(null,dt_type, minreal_date),3)*100
    END  as growth,
    0 as volume_diff,
    'Step3'
  from 
    db_total_calc;

--step 4: insert ITM data by product
  insert into db_bigtable   
  select 
    'SalesByProduct' as report_type,
    'Units' as measure,
    transaction_type, 
    prodgr, 
    minreal_date, 
    dt_id, 
    dt_type,
    period, 
    null,
    null,
    units, 
    accumulate_value(transaction_type,dt_type, minreal_date, prodgr) as accum_units,
    previous_value(transaction_type,dt_type, minreal_date, prodgr) as previous_units,
    case 
      when previous_value(transaction_type,dt_type, minreal_date, prodgr) = 0 THEN 0
    ELSE
      round((units - previous_value(transaction_type,dt_type, minreal_date, prodgr))/previous_value(transaction_type,dt_type, minreal_date, prodgr),3)*100
    END  as growth,
    0 as volume_diff,
    'Step4'
  from 
    db_pgsales_calc;     
  
--step 5: insert ITM+TTM data by product
  insert into db_bigtable   
  select 
    'TotalByProduct' as report_type,
    'Units' as measure,
    null as transaction_type, 
    prodgr, 
    minreal_date, 
    dt_id, 
    dt_type, 
    period,
    null,
    null,
    units, 
    accumulate_value(null,dt_type, minreal_date, prodgr) as units_accum,
    previous_value(null,dt_type, minreal_date, prodgr) as previous_units,
    case 
      when previous_value(null,dt_type, minreal_date, prodgr) = 0 THEN 0
    ELSE
      round((units - previous_value(null,dt_type, minreal_date, prodgr))/previous_value(null,dt_type, minreal_date, prodgr),3)*100
    END  as growth,
    accumulate_value('IMP',dt_type, minreal_date) - accumulate_value('IMS',dt_type, minreal_date) as volume_diff,
    'Step5'
  from 
    db_pgtotal_calc;
 
--step 6: insert ITM+TTM data by product
  insert into db_bigtable  
  select 
    'SalesByRegion' as report_type,
    'Units' as measure,
    null as transaction_type, 
    prodgr, 
    minreal_date,
    dt_id,
    dt_type,
    period,
    geography_type,
    region,
    units,
    0 as units_accum,
    previous_value('IMS',dt_type, minreal_date, prodgr,'Units',geography_type,region) as previous_units,
    0 as growth,
    0 as volume_diff,
    'Step6'
from
  db_region_calc;
  
  
--finish
  dbms_output.put_line('end: '||sysdate);
end;
/



spool off

exit;

