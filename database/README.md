# UoB Migration scripts #

> to prepare the database so that mapping files can be made

### setup ###
* you need sql management studio
* you need some MS libraries to enable the server to import csv / excel https://www.microsoft.com/en-us/download/confirmation.aspx?displayLang=en&id=23734
* we setup [a server] to do this 
* you need an ldap extract
* you need a mysites extract


### database items ###
various functions and views to joing the ldap and mysites tuples.  allows the end user to filter and split these sets of users to create mapping files.

#### database tables ####


| environment	| run from 	| path	| script	| database	| table | 
|---------------|-----------|-------|-----------|-----------|-------| 
| unidev	| sp-mig	| C:\migration\Database\LDAP	| rungenerateldap.csv	| sp-xxx-dev01\xxxxxx\SPMigration	[SPMigration].[dbo].[LDAPData]| 
| unidev	| sp-mig	| C:\migration\Database\OneDrive	| runUoBOneDriveUsageReport.ps1	| sp-xxx-dev01\xxxxxx\SPMigration	[SPMigration].[dbo].[OneDrive]| 
| unidev	| haldus	| C:\Migration\Database	| runMySitesReporttFinal.ps1	| bs-db-xxx\xxxxxxx\SPMigration	[SPMigration].[dbo].[mysites]| 
| unidev	| haldus	| C:\Migration\Database	| runUsersMigratedReportFinal.ps1	| bs-db-xxxx\xxxxxx\SPMigration	[SPMigration].[dbo].[dateMigrated]| 

#### views ####
vwLDAPJOINMySites

[README.md markup guide](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)



