#copy from dev server to wfe for execution locally, copy the other files as well
#THIS WILL NOT RUN ON THE MIGRATION SERVER as the migration server does not have sharepoint 2010 installed, is not joined to the farm and does not have the .dlls in order for Get-SPSIte to work
#we do not use PSRemoting as it is not robust enough
cls
cd c:\migration\1PreRequisites\ #this seems to work
#UNIDEV 
.\prerequisites.ps1 `
-onPremiseMysiteURIPart "http://mysite.dev.auniversity.ac.uk/user" `
-sourcePasswordPlain "Password1234" `
-sourceListName "Personal Documents" `
-domain "UNIDEV" `
-migrationfolder "c:\migration\"  
