set define off
set verify off
set serveroutput on size 1000000
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
begin wwv_flow.g_import_in_progress := true; end; 
/
 
--       AAAA       PPPPP   EEEEEE  XX      XX
--      AA  AA      PP  PP  EE       XX    XX
--     AA    AA     PP  PP  EE        XX  XX
--    AAAAAAAAAA    PPPPP   EEEE       XXXX
--   AA        AA   PP      EE        XX  XX
--  AA          AA  PP      EE       XX    XX
--  AA          AA  PP      EEEEEE  XX      XX
begin
select value into wwv_flow_api.g_nls_numeric_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
execute immediate 'alter session set nls_numeric_characters=''.,''';
end;
/
-- Workspace, user group, user and team development export
-- Generated 2011.09.20 01:01:53 by ADMIN
-- This script can be run in sqlplus as the owner of the Oracle Apex owner.
begin
    wwv_flow_api.set_security_group_id(p_security_group_id=>1281423458935712);
end;
/
----------------
-- W O R K S P A C E
-- Creating a workspace will not create database schemas or objects.
-- This API creates only the meta data for this APEX workspace
prompt  Creating workspace AMGTEST...
begin
wwv_flow_fnd_user_api.create_company (
  p_id                           => 1281520586935747,
  p_provisioning_company_id      => 1281423458935712,
  p_short_name                   => 'AMGTEST',
  p_first_schema_provisioned     => 'MDB_REP',
  p_company_schemas              => 'MDB_REP',
  p_expire_fnd_user_accounts     => '',
  p_account_lifetime_days        => '',
  p_fnd_user_max_login_failures  => '',
  p_allow_plsql_editing          => 'Y',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_to_be_purged_yn        => 'Y',
  p_source_identifier            => 'AMGTEST',
  p_builder_notification_message => '');
end;
/
----------------
-- G R O U P S
--
prompt  Creating Groups...
----------------
-- U S E R S
-- User repository for use with apex cookie based authenticaion.
--
prompt  Creating Users...
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id      => '1281327510935712',
  p_user_name    => 'ADMIN',
  p_first_name   => '',
  p_last_name    => '',
  p_description  => '',
  p_email_address=> 'ru@ru.ru',
  p_web_password => '38B521D200A458066145D7569E0CFC4D',
  p_web_password_format => 'HEX_ENCODED_DIGEST_V2',
  p_group_ids    => '',
  p_developer_privs=> 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema=> 'MDB_REP',
  p_account_locked=> 'N',
  p_account_expiry=> to_date('201109132233','YYYYMMDDHH24MI'),
  p_failed_access_attempts=> 0,
  p_change_password_on_first_use=> 'Y',
  p_first_password_use_occurred=> 'Y',
  p_allow_app_building_yn=> 'Y',
  p_allow_sql_workshop_yn=> 'Y',
  p_allow_websheet_dev_yn=> 'Y',
  p_allow_team_development_yn=> 'Y',
  p_allow_access_to_schemas => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id      => '1696218406251330',
  p_user_name    => 'ADMINISTRATOR',
  p_first_name   => '',
  p_last_name    => '',
  p_description  => '',
  p_email_address=> 'admin@amgen.com',
  p_web_password => '7DAFB2249AA6BEF04B607418528F5DD3',
  p_web_password_format => 'HEX_ENCODED_DIGEST_V2',
  p_group_ids    => '',
  p_developer_privs=> '',
  p_default_schema=> 'MDB_REP',
  p_account_locked=> 'N',
  p_account_expiry=> to_date('201108220047','YYYYMMDDHH24MI'),
  p_failed_access_attempts=> 0,
  p_change_password_on_first_use=> 'N',
  p_first_password_use_occurred=> 'N',
  p_allow_app_building_yn=> 'Y',
  p_allow_sql_workshop_yn=> 'Y',
  p_allow_websheet_dev_yn=> 'Y',
  p_allow_team_development_yn=> 'Y',
  p_allow_access_to_schemas => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id      => '1695908364248516',
  p_user_name    => 'AFRIDMAN',
  p_first_name   => 'Alexander',
  p_last_name    => 'Fridman',
  p_description  => '',
  p_email_address=> 'afridman@amgen.com',
  p_web_password => '54514EDFDD188BD4417A5FBE25AB0151',
  p_web_password_format => 'HEX_ENCODED_DIGEST_V2',
  p_group_ids    => '',
  p_developer_privs=> '',
  p_default_schema=> 'MDB_REP',
  p_account_locked=> 'N',
  p_account_expiry=> to_date('201108220059','YYYYMMDDHH24MI'),
  p_failed_access_attempts=> 0,
  p_change_password_on_first_use=> 'N',
  p_first_password_use_occurred=> 'N',
  p_allow_app_building_yn=> 'Y',
  p_allow_sql_workshop_yn=> 'Y',
  p_allow_websheet_dev_yn=> 'Y',
  p_allow_team_development_yn=> 'Y',
  p_allow_access_to_schemas => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id      => '1696505724257211',
  p_user_name    => 'CONTROLLER',
  p_first_name   => '',
  p_last_name    => '',
  p_description  => '',
  p_email_address=> 'controller@amgen.com',
  p_web_password => 'B4C02DFBFA58D3864B05C0EC0C16E8F3',
  p_web_password_format => 'HEX_ENCODED_DIGEST_V2',
  p_group_ids    => '',
  p_developer_privs=> '',
  p_default_schema=> 'MDB_REP',
  p_account_locked=> 'N',
  p_account_expiry=> to_date('201108100000','YYYYMMDDHH24MI'),
  p_failed_access_attempts=> 0,
  p_change_password_on_first_use=> 'N',
  p_first_password_use_occurred=> 'N',
  p_allow_app_building_yn=> 'N',
  p_allow_sql_workshop_yn=> 'N',
  p_allow_websheet_dev_yn=> 'N',
  p_allow_team_development_yn=> 'Y',
  p_allow_access_to_schemas => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id      => '1513226319026290',
  p_user_name    => 'TEST',
  p_first_name   => '',
  p_last_name    => '',
  p_description  => '',
  p_email_address=> 'test@mail.ru',
  p_web_password => '901D6071A2F9FF29E9A9E46195289AE6',
  p_web_password_format => 'HEX_ENCODED_DIGEST_V2',
  p_group_ids    => '',
  p_developer_privs=> '',
  p_default_schema=> 'MDB_REP',
  p_account_locked=> 'N',
  p_account_expiry=> to_date('201107250000','YYYYMMDDHH24MI'),
  p_failed_access_attempts=> 0,
  p_change_password_on_first_use=> 'N',
  p_first_password_use_occurred=> 'N',
  p_allow_app_building_yn=> 'N',
  p_allow_sql_workshop_yn=> 'N',
  p_allow_websheet_dev_yn=> 'N',
  p_allow_team_development_yn=> 'Y',
  p_allow_access_to_schemas => '');
end;
/
commit;
begin 
execute immediate 'begin dbms_session.set_nls( param => ''NLS_NUMERIC_CHARACTERS'', value => '''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''','''''''''''') || ''''''''); end;';
end;
/
set verify on
set feedback on
prompt  ...done
