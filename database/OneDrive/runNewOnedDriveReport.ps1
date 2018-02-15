cls
cd c:\migration\database\OneDrive
<#PREPROD#>
#todo
#[string] $Server= "BS-DB-xxxxxx\xxxxxxx"
#[string] $Database = "SPMigration"
#[string] $uid = "university\xxxxxx" #"university\xxxxxxx"#
#[string] $pwd = "xxxxxxx" 
<#UNIDEV

.\uobonedriveusagereport.ps1 -Server "SP-MIG-xxxxxxx\xxxxxx" `
-Database  "SPMigration" `
-uid "university\xxxxxx" `
-pwd "xxxxxx" `
-force $TRUE `
-setCredential $false `
-truncate $true `
-LDAPPassword "xxxxxx" `
-admin "xxxxxx@xxxxxx.onmicrosoft.com" `
-pass "xxxxxxx" `
-mysiteHost "https://xxxxxx-my.sharepoint.com"
#>
<#PROD#>


.\newOneDriveReportWorking.ps1 -Server "BS-DB-xxxxxx\xxxxxx" `
-Database  "SPMigration" `
-uid "university\xxxxxx" `
-pwd "xxxxxx" `
-force $false `
-setCredential $false `
-truncate $true `
-LDAPPassword "xxxxxx" `
-admin "xxxxxx@xxxxxx.onmicrosoft.com" `
-pass "xxxxxxx" `
-mysiteHost "https://xxxxxx-my.sharepoint.com"
