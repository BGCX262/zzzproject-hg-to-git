spool logs\clients_update.log

update clients t
set idreg = (select geography_id from geography where geography_name = (select distinct reg from regs where idreg = t.idreg) and geography_type = 'REGION');

--insert missing cities in geography
declare
 l_cnt number;
begin
 for i in (select distinct city, idreg from clients where city is not null) loop
    select count(geography_id) into l_cnt from geography where geography_type = 'CITY' and geography_name = i.city;
    if l_cnt = 0 then
     insert into geography values(geography_id_seq.nextval,i.idreg,'CITY',	i.city);
    end if;
 end loop;
end;
/

--insert cities ids instead of city

update clients t
set city = (select geography_id from geography where geography_name = city and geography_type = 'CITY')
where city <> 'Москва' and city <> 'Санкт-Петербург';

update clients t
 set city = (select geography_id from geography where geography_type in ('REGION','CIYT') and geography_name = 'Москва')
 where city = 'Москва';

update clients t
 set city = (select geography_id from geography where geography_type in ('REGION','CIYT') and geography_name = 'Санкт-Петербург')
 where city = 'Санкт-Петербург';

commit;

spool off


exit;
