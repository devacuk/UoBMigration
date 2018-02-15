#depends on sqltools powershell cmdlets, so cant be run on SharePoint 2010 WFE, run on the migration server

cls
cd c:\migration\database\LDAP

<#PROD
#>
.\generateLDAP.ps1 -Server "BS-DB-xxxxx\xxxxxx" `
-Database  "SPMigration" `
-uid "university\xxxxxx" `
-pwd "xxxxxx" `
-force $false `
-setCredential $false `
-truncate $true `
-LDAPPassword "xxxxxx" `
-filter "(&(|(uobusertype=w*)(uobusertype=sr)))" `
-ldap_server "ldap.xxxxxx.ac.uk" `
-domain "university" `
-dc "dc-pro01.$domain_fq" `
-ldap_people_ou "ou=people,dc=xxxxxx,dc=ac,dc=uk"


