
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


insert into transactions_data  
select transactions_id_seq.nextval,null,idimp, 'IMP', null, idpr, (select month from months m where m.idmonth = i.idmonth), 'Month', idws, null, qtty, qtty, null, null, null , null
from import i;


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

--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,1, 'KAM', K.IDKAM FROM KAMS K WHERE NOT EXISTS (SELECT 1 FROM SENKAMS S WHERE K.KAM LIKE S.SENKAM||'%');
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,2, 'SKAM', K.IDKAM FROM KAMS K WHERE EXISTS (SELECT 1 FROM SENKAMS S WHERE K.KAM LIKE S.SENKAM||'%');
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 1 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,7, 'REP', 8 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 9 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 10 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 11 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 12 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 3 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 7 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 13 FROM DUAL;
---INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 14 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,3, 'REP', 15 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,3, 'REP', 4 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,3, 'REP', 6 FROM DUAL;

--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,6, 'REP', 2 FROM DUAL;
--INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 5 FROM DUAL;

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

--commit; 

--drop table senreps; 
--CREATE TABLE senreps
--  (
--    IDREPS   NUMBER(11,0) ,
--    IDSENREPS  NUMBER(11,0)
--  ); 

--insert into senreps select 1, 17 from dual;
--insert into senreps select 2, 17 from dual;
--insert into senreps select 8, 17 from dual;
--insert into senreps select 9, 17 from dual;
--insert into senreps select 10, 17 from dual;
--insert into senreps select 11, 17 from dual;
--insert into senreps select 12, 17 from dual;

--insert into senreps select 5, 18 from dual;
--insert into senreps select 3, 18 from dual;
--insert into senreps select 7, 18 from dual;
--insert into senreps select 13, 18 from dual;
--insert into senreps select 14, 18 from dual;
--insert into senreps select 15, 18 from dual;
--insert into senreps select 4, 18 from dual;

--commit;

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


delete from employee_client;

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




spool off

exit;

