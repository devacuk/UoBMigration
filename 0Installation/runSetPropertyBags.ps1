cls
cd c:\migration\0Installation\ #this seems to work
powershell.exe -version 2
#PREPROD
.\SetPropertyBags.ps1 -centralAdminUri "http://sharepoint:123456" `
    -mysiteuri "http://mysite.auniversity.ac.uk" `
    -uobmigrationperiodcheckweeks "6" `
    -uobmigrationarmed "true" `
    -recycleordelete "recycle"



