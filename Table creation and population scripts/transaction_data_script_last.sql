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
--select * from transactions_data;
--IDBR, IDIMS, TRASACTION_TYPE, IDKAMREP, IDCLIENT, IDPROD, IDHY, IDY, IDMONTH, IDWS, PACKS_PLAN, PACKS_FACK
--select distinct idhy from br;
--KAM 
--select IDBR, null, 'BR', 'KAM', IDKAM, IDCLIENT, IDPROD, IDHY, (select IDY from half_year where idhy=br.idhy), null, null, PACKS, null from br where idkam is not null; 
INSERT INTO transactions_data  
select TRANSACTIONS_ID_SEQ.nextval,IDBR, null, 'BR', 'KAM',  IDKAM, IDCLIENT, IDPROD, IDHY, (select IDY from half_year where idhy=br.idhy), null, null, PACKS, null, PACKS 
from br where idkam is not null
; 
commit;

--KAM 
--select * from ims;
--IDBR, IDIMS, TRASACTION_TYPE,  'KAM', IDKAMREP, IDCLIENT, IDPROD, IDHY, IDY, IDMONTH, IDWS, PACKS_PLAN, PACKS_FACK
INSERT INTO transactions_data  
select TRANSACTIONS_ID_SEQ.nextval, br.IDBR, ims.IDIMS, 'IMS', 'KAM', br.IDKAM, ims.IDCLIENT, ims.IDPROD, (select idhy from months where idmonth=ims.idmonth), (select IDY from half_year where idhy=(select idhy from months where idmonth=ims.idmonth)), ims.IDMONTH, ims.IDWS, null, ims.PACKS, ims.PACKS  
from ims, br
where ims.idclient=br.idclient
  and ims.idprod=br.idprod
  and br.idhy=(select idhy from months where idmonth=ims.idmonth)
  and br.idkam is not null
  ;
commit;

----------------------------
--IDBR, IDIMS, TRASACTION_TYPE, IDKAMREP, IDCLIENT, IDPROD, IDHY, IDY, IDMONTH, IDWS, PACKS_PLAN, PACKS_FACK
INSERT INTO transactions_data  
select TRANSACTIONS_ID_SEQ.nextval, null, ims.IDIMS, 'IMS', 'KAM', 
--------------------------
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
  --and t.idhy = (select max(idhy) from br)
  --and t.idhy = (select idhy from months where idmonth=ims.idmonth) 
 ) idkamrep,
--------------------------
 ims.IDCLIENT, ims.IDPROD, 
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

  
  /*

INSERT INTO transactions_data  
select IDBR, null, 'BR', IDREP, IDCLIENT, IDPROD, IDHY, (select IDY from half_year where idhy=br.idhy), null, null, PACKS, null from br where idkam is not null
; 
commit;
*/
create or replace view v_bonus as 
select  
  td.idy,
  td.idhy,
  DECODE(k.kam,sk.senkam,'Head of KAM','KAM') EmplType,
  k.idkam,
  k.kam,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type,
  sum(td.packs_plan * p.pricecip) BR,
  sum(td.packs_fack * p.pricecip) IMS,
  sum(td.packs * p.pricecip) CIP
  --sum(td.packs_plan) / sum(td.packs_fack) pers
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
  k.idkam,
  k.kam,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type;

create or replace view v_bonus_sk as 
select  
  DECODE(k.kam,sk.senkam,'Head of KAM','KAM') EmplType,
  k.idkam,
  k.kam,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type,
  sum(td.packs_plan * p.pricecip) BR,
  sum(td.packs_fack * p.pricecip) IMS,
  sum(td.packs * p.pricecip) CIP
  --sum(td.packs_plan) / sum(td.packs_fack) pers
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
  and EXISTS (SELECT 1 FROM SENKAMS S WHERE K.KAM LIKE S.SENKAM||'%')
  and td.idhy=7 
group by 
  DECODE(k.kam,sk.senkam,'Head of KAM','KAM'),
  k.idkam,
  k.kam,
  pg.idprodgr,
  pg.prodgr,
  td.trasaction_type;

DROP SEQUENCE PAYOUT_ID_SEQ;
CREATE SEQUENCE  PAYOUT_ID_SEQ  
  MINVALUE 1 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;

DROP TABLE PAYOUT_CURVE;
CREATE TABLE PAYOUT_CURVE
  (
    IDPAYOUT  NUMBER,
    YTDGOAL    NUMBER(6,3),
    TARGETINC   NUMBER(6,3)
  );
ALTER TABLE payout_curve
ADD CONSTRAINT PK_PAYOUT PRIMARY KEY
(
  IDPAYOUT
)
ENABLE
;

DELETE  FROM PAYOUT_CURVE;

insert into payout_curve select PAYOUT_ID_SEQ.nextval, 3, 5.27 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.99, 5.25 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.98, 5.24 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.97, 5.23 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.96, 5.21 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.95, 5.2 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.94, 5.19 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.93, 5.17 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.92, 5.16 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.91, 5.15 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.9, 5.13 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.89, 5.12 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.88, 5.11 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.87, 5.09 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.86, 5.08 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.85, 5.07 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.84, 5.05 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.83, 5.04 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.82, 5.03 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.81, 5.01 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.8, 5 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.79, 4.99 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.78, 4.97 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.77, 4.96 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.76, 4.95 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.75, 4.93 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.74, 4.92 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.73, 4.91 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.72, 4.89 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.71, 4.88 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.7, 4.87 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.69, 4.85 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.68, 4.84 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.67, 4.83 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.66, 4.81 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.65, 4.8 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.64, 4.79 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.63, 4.77 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.62, 4.76 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.61, 4.75 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.6, 4.73 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.59, 4.72 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.58, 4.71 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.57, 4.69 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.56, 4.68 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.55, 4.67 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.54, 4.65 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.53, 4.64 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.52, 4.63 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.51, 4.61 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.5, 4.6 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.49, 4.59 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.48, 4.57 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.47, 4.56 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.46, 4.55 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.45, 4.53 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.44, 4.52 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.43, 4.51 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.42, 4.49 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.41, 4.48 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.4, 4.47 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.39, 4.45 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.38, 4.44 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.37, 4.43 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.36, 4.41 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.35, 4.4 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.34, 4.39 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.33, 4.37 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.32, 4.36 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.31, 4.35 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.3, 4.33 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.29, 4.32 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.28, 4.31 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.27, 4.29 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.26, 4.28 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.25, 4.27 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.24, 4.25 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.23, 4.24 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.22, 4.23 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.21, 4.21 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.2, 4.2 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.19, 4.19 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.18, 4.17 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.17, 4.16 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.16, 4.15 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.15, 4.13 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.14, 4.12 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.13, 4.11 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.12, 4.09 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.11, 4.08 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.1, 4.07 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.09, 4.05 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.08, 4.04 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.07, 4.03 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.06, 4.01 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.05, 4 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.04, 3.99 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.03, 3.97 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.02, 3.96 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2.01, 3.95 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 2, 3.93 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.99, 3.92 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.98, 3.91 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.97, 3.89 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.96, 3.88 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.95, 3.87 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.94, 3.85 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.93, 3.84 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.92, 3.83 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.91, 3.81 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.9, 3.8 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.89, 3.79 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.88, 3.77 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.87, 3.76 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.86, 3.75 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.85, 3.73 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.84, 3.72 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.83, 3.71 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.82, 3.69 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.81, 3.68 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.8, 3.67 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.79, 3.65 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.78, 3.64 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.77, 3.63 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.76, 3.61 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.75, 3.6 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.74, 3.59 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.73, 3.57 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.72, 3.56 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.71, 3.55 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.7, 3.53 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.69, 3.52 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.68, 3.51 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.67, 3.49 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.66, 3.48 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.65, 3.47 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.64, 3.45 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.63, 3.44 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.62, 3.43 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.61, 3.41 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.6, 3.4 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.59, 3.39 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.58, 3.37 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.57, 3.36 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.56, 3.35 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.55, 3.33 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.54, 3.32 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.53, 3.31 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.52, 3.29 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.51, 3.28 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.5, 3.27 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.49, 3.25 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.48, 3.24 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.47, 3.23 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.46, 3.21 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.45, 3.2 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.44, 3.19 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.43, 3.17 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.42, 3.16 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.41, 3.15 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.4, 3.13 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.39, 3.12 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.38, 3.11 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.37, 3.09 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.36, 3.08 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.35, 3.07 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.34, 3.05 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.33, 3.04 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.32, 3.03 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.31, 3.01 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.3, 3 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.29, 2.93 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.28, 2.87 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.27, 2.8 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.26, 2.73 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.25, 2.67 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.24, 2.6 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.23, 2.53 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.22, 2.47 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.21, 2.4 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.2, 2.33 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.19, 2.27 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.18, 2.2 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.17, 2.13 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.16, 2.07 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.15, 2 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.14, 1.93 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.13, 1.87 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.12, 1.8 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.11, 1.73 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.1, 1.67 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.09, 1.6 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.08, 1.53 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.07, 1.47 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.06, 1.4 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.05, 1.33 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.04, 1.27 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.03, 1.2 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.02, 1.13 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1.01, 1.07 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 1, 1 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.99, 0.95 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.98, 0.9 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.97, 0.85 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.96, 0.8 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.95, 0.75 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.94, 0.7 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.93, 0.65 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.92, 0.6 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.91, 0.55 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.9, 0.5 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.89, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.88, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.87, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.86, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.85, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.84, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.83, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.82, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.81, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.8, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.79, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.78, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.77, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.76, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.75, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.74, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.73, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.72, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.71, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.7, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.69, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.68, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.67, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.66, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.65, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.64, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.63, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.62, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.61, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.6, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.59, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.58, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.57, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.56, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.55, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.54, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.53, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.52, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.51, 0 from dual;
insert into payout_curve select PAYOUT_ID_SEQ.nextval, 0.5, 0 from dual;
commit;

-- CIP_BASE  
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
INSERT INTO CIP_SCHEMA SELECT 3,'REP 5 H12011', 7, 5 FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 4,'REP AN, Mi H12011', 7, 5 FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 5,'REP AO, Vbx H12011', 7, 5 FROM DUAL;
INSERT INTO CIP_SCHEMA SELECT 6,'REP AO, Npl H12011', 7, 5 FROM DUAL;

commit;


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

INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,1, 'KAM', K.IDKAM FROM KAMS K WHERE NOT EXISTS (SELECT 1 FROM SENKAMS S WHERE K.KAM LIKE S.SENKAM||'%');
INSERT INTO CIP_SCHEMA_EMPL SELECT CIPEMP_ID_SEQ.nextval,2, 'SKAM', K.IDKAM FROM KAMS K WHERE EXISTS (SELECT 1 FROM SENKAMS S WHERE K.KAM LIKE S.SENKAM||'%');

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
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 1, null, 1, 123874, 247748, 133402   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 2, null, 1, 129937, 259875, 173250   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 3, 1, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 3, 2, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 3, 3, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 3, 4, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 3, 5, 0.2, 17325, 34650, 28875   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 4, 1, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 4, 3, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 5, 2, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 5, 5, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 6, 2, 0.5, 43313, 86625, 57750   from dual;
insert into cip_schema_detail select CIPDET_ID_SEQ.nextval, 6, 4, 0.5, 43313, 86625, 57750   from dual;

commit;

create or replace view v_prepare_calculation as  
select 
  v.*,
  (select 
      sum(d.HVALUE+d.KSO) 
    from
      cip_schema s,
      cip_schema_empl e,
      cip_schema_detail d
    where 
      e.idkamrep = v.idkam
      and s.idy=v.idy
      and s.idhy=v.idhy
      and e.idschema=d.idschema
      and s.idschema=e.idschema) base,
  (select 
    --min(decode(e.empltype,'SKAM', 2, 'DKAM', 3, d.prodsplit)) ps
    min(d.prodsplit)
  from
    cip_schema s,
    cip_schema_empl e,
    cip_schema_detail d
  where 
    e.idkamrep = v.idkam
    and s.idy=v.idy
    and s.idhy=v.idhy
    and (d.idprodgr=v.idprodgr or d.idprodgr is null)
    and e.idschema=d.idschema
    and s.idschema=e.idschema) prodsplit,
    ( select 
      --v1.idkam, 
      round( sum(v1.br) / sum(v1.ims) ,2) persent
    from
      v_bonus v1
    where
        --v1.idprodgr=4 and
        v1.idkam=v.idkam
        and v1.idhy=v.idhy
        and v1.idy=v.idy
     group by v1.idkam) kpersent
     
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
    (pc.YTDGoal BETWEEN vpc.kpersent and vpc.kpersent
    or
    (vpc.kpersent > 3 and pc.YTDGoal=3))
    ) k
from  
  v_prepare_calculation vpc;

create or replace view v_pivot_total as
(select * 
from  (select empltype, kam, base, prodgr, ims, br, prodsplit, kpersent, k from v_total_bonus)
pivot (sum(ims) as sum_ims, sum(br) as sum_br, min(prodsplit) as psplit for (prodgr) in ('AN' as AN, 'A0' as A0, 'Mi' as Mi, 'Npl' as Npl, 'Vbx' as Vbx))
);

exit;
