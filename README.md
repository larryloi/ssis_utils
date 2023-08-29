# SSIS-Utils - DataMart SSIS Utils for Deployment processes and data archiving
Data solution project that provide a pipeline of financial/analytical data to build up reports; it is running MS SQL Server integration services technology transform source data from history database or staging area database (which is OLTP data model) to destination data mart database (which is OLAP data model).

## Scope of this repo
  - ssis utils provided utilities for maintenance ETL job run healthy
  - ssis job deployment
  - ssis packages for checking ETL delay status and sending alert
  - data archiving for fact tables

##### Components
  - dtsx - SQL Server integration service code
  - sp - store procedures

## Contributors
  - Jason Iong [jason.iong@ias.com] (jason.iong@ias.com) (Software Engineer)
  - Larry Loi [larry.loi@ias.com](larry.loi@ias.com)(Software Engineer)

## Introduction

>**Menu Functions**
>>
- Run DB migration Scripts
- Run ssis job deployment - SQL Server jobs
- Run archive data job deploy - SQL Server jobs

>**Usage**
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

>**Deployment server Prerequisites**
>>
- powershell 5.0
- powershell modules required PSReadLine, SqlServer
- ruby 2.3.3p222 (2016-11-21 revision 56859) [x64-mingw32]
- gem version 2.5.2
- Rails 4.2.6

>**Key files**
>>
- Scripts directory - root/scripts
- Menu executable - root/scripts/menu.bat
- seed data directory - DDL/db/seeds/