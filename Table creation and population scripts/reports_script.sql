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
  td.trasaction_type,
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
  td.trasaction_type;
  
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

spool off

exit;

