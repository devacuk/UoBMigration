clear
#clears down onedrives to enable testing... you will have to provision onedrives from scratch after running this using RunMigration.ps1!
$mappingfile = '../usermapping/UsersToMigrate.csv'

#DEV  use this for development
$adminUrl = "https://xxxxxx-admin.sharepoint.com/"
$username = "xxxxxx@xxxxxx.onmicrosoft.com" #needs to be sharepoint admin, not global
$password = "xxxxxx"
$tenancyurl = "https://xxxxxx.sharepoint.com"
$mySiteUriFragment = "https://xxxxxx-my.sharepoint.com/personal"

$Invocation = (Get-Variable MyInvocation -Scope 0).Value
$ScriptPath = Split-Path $Invocation.MyCommand.Path
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
Connect-PnPOnline -Url $adminUrl -credentials $cred
$mappingFilePath = Join-Path $ScriptPath $mappingFile
#this will handle deleting the sites
Import-Csv $mappingFilePath -Delimiter "|" | ForEach-Object {
    $lanid = $_.lanid
    $o365urlpart = $_.o365urlpart
    $destsiteurl = "$mySiteUriFragment/$o365urlpart"
    write-host "url:  $lanid $destsiteurl"
    Remove-PnPTenantSite -Url $destsiteurl -Force -SkipRecycleBin 
}
