
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
    TRASACTION_TYPE VARCHAR(4),
    KAMREP VARCHAR(4),
    IDKAMREP   NUMBER(11,0),
    IDCLIENT NUMBER(11,0),
    IDPROD   NUMBER(11,0),
    IDHY     NUMBER(11,0),
    IDY     NUMBER(11,0),
    IDMONTH NUMBER(11,0),
    IDWS    NUMBER(11,0),
    PACKS_PLAN    NUMBER(5,0) DEFAULT 0,
    PACKS_FACK    NUMBER(5,0) DEFAULT 0,
    PACKS    NUMBER(5,0) DEFAULT 0    
  );

ALTER TABLE TRANSACTIONS_DATA
ADD CONSTRAINT PK_TRANSACTIONS PRIMARY KEY
(
  IDTRAN
)
ENABLE
;

INSERT INTO transactions_data  
select TRANSACTIONS_ID_SEQ.nextval,IDBR, null, 'BR', 'KAM',  IDKAM, IDCLIENT, IDPROD, IDHY, (select IDY from half_year where idhy=br.idhy), null, null, PACKS, null, PACKS 
from br where idkam is not null
; 
commit;



INSERT INTO transactions_data  
select TRANSACTIONS_ID_SEQ.nextval, br.IDBR, ims.IDIMS, 'IMS', 'KAM', br.IDKAM, ims.IDCLIENT, ims.IDPROD, (select idhy from months where idmonth=ims.idmonth), (select IDY from half_year where idhy=(select idhy from months where idmonth=ims.idmonth)), ims.IDMONTH, ims.IDWS, null, ims.PACKS, ims.PACKS  
from ims, br
where ims.idclient=br.idclient
  and ims.idprod=br.idprod
  and br.idhy=(select idhy from months where idmonth=ims.idmonth)
  and br.idkam is not null
  ;
commit;


INSERT INTO transactions_data  
select TRANSACTIONS_ID_SEQ.nextval, null, ims.IDIMS, 'IMS', 'KAM', 
(select max(maxkam) from 
(
select  b.idhy, c2.city, count(distinct b.idkam) qvt, min(b.idkam) minkam, max(b.idkam) maxkam 
from 
  br b, clients c2
where b.idclient=c2.idclient
and c2.city is not null
group by  b.idhy, c2.city
) t
 where 
  t.minkam=t.maxkam and
  t.city = c.city 
 ) idkamrep,ims.IDCLIENT, ims.IDPROD, 
 (select idhy from months where idmonth=ims.idmonth), 
 (select IDY from half_year where idhy=(select idhy from months where idmonth=ims.idmonth)), 
 ims.IDMONTH, ims.IDWS, null, ims.PACKS, ims.PACKS  
from ims, clients c
where 
  ims.idclient=c.idclient and
  ims.idims not in ( 
  select ims1.IDIMS
  from ims ims1, br br1
  where ims1.idclient=br1.idclient
    and ims1.idprod=br1.idprod
    and br1.idhy=(select idhy from months where idmonth=ims1.idmonth)
    and br1.idkam is not null)
;
commit;

  



INSERT INTO transactions_data  
select TRANSACTIONS_ID_SEQ.nextval,IDBR, null, 'BR', 'REP',  IDREP, IDCLIENT, IDPROD, IDHY, (select IDY from half_year where idhy=br.idhy), null, null, PACKS, null, PACKS 
from br where idrep is not null
; 
commit;
 

INSERT INTO transactions_data  
select TRANSACTIONS_ID_SEQ.nextval,br.IDBR, ims.IDIMS, 'IMS', 'REP', br.IDREP, ims.IDCLIENT, ims.IDPROD, (select idhy from months where idmonth=ims.idmonth), (select IDY from half_year where idhy=(select idhy from months where idmonth=ims.idmonth)), ims.IDMONTH, ims.IDWS, null, ims.PACKS, ims.PACKS  
from ims, br
where ims.idclient=br.idclient
  and ims.idprod=br.idprod
  and br.idhy=(select idhy from months where idmonth=ims.idmonth)
  and br.idrep is not null
  ;
commit;
 

DROP SEQUENCE CIP_ID_SEQ;
CREATE SEQUENCE  CIP_ID_SEQ  
  MINVALUE 10 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE CIP_SCHEMA;
CREATE TABLE CIP_SCHEMA
  (
    IDSCHEMA   NUMBER(11,0) ,
    SCHEMA_NAME  VARCHAR(100),
    IDHY NUMBER (10,0),
    IDY NUMBER (10,0)
  );
ALTER TABLE CIP_SCHEMA
ADD CONSTRAINT PK_CIP PRIMARY KEY
(
  IDSCHEMA
)
ENABLE
;

DELETE FROM CIP_SCHEMA;
INSERT INTO CIP_SCHEMA SELECT 1,'KAM SCHEMA H12011', 7, 5 FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 2,'HEAD OF KAM SCHEMA H12011', 7, 5 FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 3,'REP COMB 5 H12011', 7, 5 FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 4,'REP NEPHRO 2 AN, Mi H12011', 7, 5 FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 5,'REP ONCO 2 AO, Vbx H12011', 7, 5 FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 6,'REP ONCO 3 AO, Npl, Vbx H12011', 7, 5 FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 7,'REP ONCO 2 AO, Npl H12011', 7, 5 FROM DUAL;
 
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
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,1, 'KAM', K.IDKAM FROM KAMS K WHERE NOT EXISTS (SELECT 1 FROM SENKAMS S WHERE K.KAM LIKE S.SENKAM||'%');
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
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,4, 'REP', 5 FROM DUAL;

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

insert into reps select 17, 'Ночевкина', 2 from dual;
insert into reps select 18, 'Лисюкова', 1 from dual;

commit; 

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

commit;


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

create or replace view v_bonus as 
select  
  td.idy,
  td.idhy,
  'KAM' EmplType,
  k.idsenkam,
  k.idkam,
  k.kam,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type,
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
  and td.idhy=7
group by 
  td.idy,
  td.idhy,
  DECODE(k.kam,sk.senkam,'Head of KAM','KAM'),
  k.idsenkam,
  k.idkam,
  k.kam,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type;

create or replace view v_prepare_calculation as  
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

create or replace view v_total_bonus as
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

create or replace view v_pivot_total as
(select 
  *
from  (select 
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

create or replace view v_kams as
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


create or replace view v_bonus_sk as 
select  
  td.idy,
  td.idhy,
  'Head of KAM' EmplType,
  vsk.idsenkam,
  vsk.idkam,
  sk.senkam kam,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type,
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
  and td.idhy=7 
group by 
  td.idy,
  td.idhy,
  vsk.idsenkam,
  vsk.idkam,
  sk.senkam,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type;

create or replace view v_sk_prepare_calculation as  
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

create or replace view v_sk_total_bonus as
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

create or replace view v_sk_pivot_total as
(select 
  *
from  (select 
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

create or replace view v_bonus_rep as 
select  
  td.idy,
  td.idhy,
  'Reps' EmplType,
  sr.idsenreps,
  r.idrep,
  r.emp rep,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type,
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
  and td.idhy=7 
group by 
  td.idy,
  td.idhy,
  sr.idsenreps,
  idrep,
  r.emp,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type;

create or replace view v_rep_prepare_calculation as  
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

create or replace view v_rep_total_bonus as
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

create or replace view v_rep_pivot_total as
(select 
  *
from  (select 
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

create or replace view all_employees
as
select idrep as emp_id, 'REP' as emp_type, emp as emp_name
from reps
union all
select idkam ,'KAM', kam
from kams
union all
select idsenkam, 'SKAM', senkam
from senkams; 

spool off

exit;
