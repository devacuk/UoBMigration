cls
cd C:\migration\2MySiteOneDrive
<#PROD#>
.\MigrateUsersMysitesToOneDrives.ps1 -onPremiseMysiteURIPart "https://xxx.xxxxxxx.ac.uk" `
-o365OnedriveURIPart "https://unitenantrocks-my.sharepoint.com/personal" `
-sourcePasswordPlain "longstrongpassword" `
-destinationPasswordPlain "anotherlongpassword" `
-onPremiseAdministratorAdminAccount "UNIVERSITY\aserviceaccount" `
-o365AdminAccount "bigboss@unitenantrocks.onmicrosoft.com" `
-destinationListName "Documents" `
-sourceListName "MyFiles" `
-iterations 1 `
-check "PreserveTimeStamps" `
-domain "UNIVERSITY"
