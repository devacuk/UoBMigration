#running from prod to legacy dev of SharePoint team for initial testing
cls
cd C:\migration\3PostMigrationSteps
.\AddSecondaryAdminToOnedrives.ps1 -destinationPasswordPlain "xxxxxxxxxxxx" `
-o365AdminAccount "xxxxxx@xxxxxxxx.onmicrosoft.com" `
-tenantName "xxxxxxxx" `
-secondaryAdmin1 "xxxxxx@xxxxxxx.onmicrosoft.com" `
-secondaryAdmin2 "" 