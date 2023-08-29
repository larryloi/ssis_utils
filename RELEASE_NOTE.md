# Release Note

## V 2.15.0

####Scope of changes

|**Subject**|**Description**|
|:------------------------------------|:--------------------------------|
|**Enable SSIS job steps run as proxy account**  | Enable SSIS job steps run as proxy account during job deployment  |

#### Enable SSIS job steps run as proxy account

>**DB migration**
>>
- 20191016104727_etl_job_steps_add_column_proxy_name.rb
- 20191017065140_alter_ds_sp_etl_job_step_create_wz_ssis_proxy.rb


>**seed data updated**
>>
- Added proxy_name into all etl_job_env.yml (proxy name is SSISProxyLogin by default)
- seed.rb update; save ssis proxy login when subsystem is SSIS

>**Deployment Pre-requisites**
>>
- Proxy Login need to be created in SQL Server before deploy SSIS jobs

>**Deployment Steps**
>>
```
1. from windows-based deployment server ex.BIADM01
2. checkout the tag
3. open cmd
4. change directory to root/scripts
5. run menu.bat under command promopt
6. run rake db:migrate
7. run rake db:seed
8. run ssis job deployment
9. enable related SQL server job for the environment
```

---


## V 2.14.0

####Scope of changes

|**Subject**|**Description**|
|:------------------------------------|:--------------------------------|
|**Table auditing ETL rollout, archive data backup job enhancement**  |   Add table auditing ETL jobs and archive data backup job check delay |

#### New deployment Menu

>**DB migration**
>>
- 20190905173469_create_sp_archive_data_backup_check_delay.sql
- 20190905173921_alter_ds_sp_archive_data_job_deploy_original.sql
- 20190905174132_alter_ds_sp_archive_data_job_deploy_updated.sql


>**seed data updated**
>>
- Add jobs Landbased-OpenPlatform_anubis_ldm_table_auditing_01


>**Deployment Steps**
>>
```
1. from windows-based deployment server ex.BIADM01
2. checkout the tag
3. open cmd
4. change directory to root/scripts
5. run menu.bat under command promopt
6. run rake db:migrate
7. run rake db:seed
8. enable related SQL server job for the environment
```


---

## V 2.10.0

####Scope of changes

|**Subject**|**Description**|
|:------------------------------------|:--------------------------------|
|**New deployment Menu**  |   Easier the deployment steps|

#### New deployment Menu

>**Scripts**
>>
- scripts/archive_data_job_deploy.bat
- scripts/archive_data_job_deploy.ps1
- scripts/db_migrate.bat
- scripts/menu.bat
- scripts/menu.ps1
- scripts/ssis_job_deploy.bat
- scripts/ssis_job_deploy.ps1


>**Deployment server Prerequisites**
>>
- powershell 5.0
- powershell modules required PSReadLine, SqlServer
- ruby 2.3.3p222 (2016-11-21 revision 56859) [x64-mingw32]
- gem version 2.5.2
- Rails 4.2.6

>**Provided functions**
>>
- Run rake db:seed
- Run rake db:migrate:status
- Run rake db:migrate:up by version
- Run rake db:migrate:down by version
- Run ssis job deployment - SQL Server jobs
- Run archive data job deploy - SQL Server jobs

>**Deployment Steps**
>>
```
1. from windows-based deployment server ex.BIADM01
2. checkout the tag
3. change directory to scripts
4. run menu.bat under command promopt
5. enable related SQL server job for the environment
```


---

## V 2.0.0

####Scope of changes
|**Subject**|**Description**|
|:------------------------------------|:--------------------------------|
|**SQL Server ETL Data Archive Rollout**  |   Provide automation process for data archive and delete. For more information: http://conf.sd.laxino.com/x/qr9q|

#### SQL Server ETL Data Archive Rollout
>**New data models**
>>
- arc_databases
- arc_tables
- arc_logs

>**New stored procedures**
>>
- ds_sp_arc_tables_get_backup_time
- ds_sp_arc_prepare_backup_path
- ds_sp_arc_logs_insert
- ds_sp_arc_export_table_by_date
- ds_sp_arc_backup
- ds_sp_arc_tables_get_delete_time
- ds_sp_arc_delete_table_by_date
- ds_sp_arc_delete

>**Prerequisites**
>>
- ssis_utils_`ENV` is required
- ssis SQL Server login must be sysadmin role

>**Deployment Steps**
>>
```
1. create ssis_utils_<env> database from instance
2. from DMS server/ service path (ssis/ssis_utils)
3. checkout the tag
4. change directory to DDL under rails root
5. run rake db:migrate RAILS_ENV=ENV
6. run rake db:seed RAILS_ENV=ENV
7. from BIADM01 server
8. run scripts "scripts/archive_data_job_deploy.bat" (Windows version) recommended.
9. set arc_databases.state to 1 to enable backup feature in database level
10. set arc_tables.state to 1 to enable backup feature; set 2 to enable backup and delete feature in table level
11. adjust the proper value for date_key, backup_batch_interval_hour, backup_delay_interval_hour, backup_data_start_at, backup_data_end_at, delete_batch_interval_hour, delete_delay_interval_day, delete_data_start_at, delete_data_end_at
12. enable related SQL server job for the environment
```


---



## V 1.0.0

####Scope of changes
|**Subject**|**Description**|
|:------------------------------------|:--------------------------------|
|**SQL Server ETL jobs deployment scripts**  |   SSIS Utils initial version; SQL Server SSIS job deployment automation. For more information: http://conf.sd.laxino.com/x/Bbtq|

#### SQL Server ETL jobs deployment scripts
>**New data models**
>>
- etl_jobs
- etl_job_steps
- etl_job_step_params
- etl_job_schedules

>**New stored procedures**
>>
- ds_sp_etl_job_ssis_config_check
- ds_sp_etl_job_step_check
- ds_sp_etl_job_step_create
- ds_sp_etl_job_create
- ds_sp_etl_job_deploy
- ds_sp_etl_job_ssis_config_list

>**Prerequisites**
>>
- Target SSIS projects must be deployed
- Target SSIS projects environments must be defined
- Target etl_table_maps data must be deployed in data-mart databases
- Target etl_tabble_maps id value in data-mart databases must be consist with etl_jobs, etl_job_steps, etl_job_step_params
- ssis_utils_`ENV` is required
- ssis SQL Server login must be sysadmin role

>**Deployment Steps**
>>
```
1. create ssis_utils_ENV database from instance
2. from DMS server/ service path (ssis/ssis_utils)
3. checkout the tag
4. change directory to DDL under rails root
5. run rake db:migrate RAILS_ENV=ENV
6. run rake db:seed RAILS_ENV=ENV
7a. run scripts "scripts/ssis_job_deploy.bat" (Windows version) recommended.
7b. run scripts "ruby scripts/ssis_job_deploy.rb" (Ruby version) to deploy jobs.
8. enable related SQL server job for the environment
```

---


