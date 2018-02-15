cls
cd c:\migration\database\OneDrive
<#PREPROD#>
#todo
#[string] $Server= "BS-DB-xxxxxx\xxxxxx"
#[string] $Database = "SPMigration"
#[string] $uid = "university\xxxxxx" 
#[string] $pwd = "xxxxxxx" 
<#UNIDEV

.\uobonedriveusagereport.ps1 -Server "SP-MIG-xxxxxx\xxxxxx" `
-Database  "SPMigration" `
-uid "university\xxxxxxx" `
-pwd "xxxxxx" `
-force $TRUE `
-setCredential $false `
-truncate $true `
-LDAPPassword "xxxxxx" `
-admin "xxxxxxx@xxxxxxx.onmicrosoft.com" `
-pass "xxxxxxx" `
-mysiteHost "https://xxxxxxx-my.sharepoint.com"
#>
<#PROD#>
.\uobonedriveusagereport.ps1 -Server "BS-DB-xxxxxx\xxxxxxxx" `
-Database  "SPMigration" `
-uid "university\xxxxxx" `
-pwd "xxxxxx" `
-force $false `
-setCredential $false `
-truncate $true `
-LDAPPassword "xxxxxx" `
-admin "xxxxxx@xxxxxxx.onmicrosoft.com" `
-pass "xxxxxxx" `
-mysiteHost "https://xxxxxxxx-my.sharepoint.com"
