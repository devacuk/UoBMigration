clear
#this shows a working mechanism to provision a site collection using pnp
$mappingfile = 'SitesToMigrate.csv'
$adminUrl = "https://xxxxxxxx-admin.sharepoint.com/"
$username = "me@xxxxxxxx.onmicrosoft.com" #needs to be sharepoint admin, not global
$password = ""
$tenancyurl = "https://xxxxxxxxxx.sharepoint.com"
$Invocation = (Get-Variable MyInvocation -Scope 0).Value
$ScriptPath = Split-Path $Invocation.MyCommand.Path
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
Connect-PnPOnline -Url $adminUrl -credentials $cred
$mappingFilePath = Join-Path $ScriptPath $mappingFile
#this will handle deleting the sites
Import-Csv $mappingFilePath -Delimiter "|" | ForEach-Object {
    $site = $_.destinationSiteUri
    $url = "$tenancyUrl$site"
    write-host "url:  $url"
    Remove-PnPTenantSite -Url $url -Force -SkipRecycleBin 
}
