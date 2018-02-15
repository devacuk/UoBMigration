Import-Module Sharegate
clear
#make sure that you are connected to the internet!!

$mappingfile = 'SitesToMigrate.csv'
$tenancyUrl = "https://xxxxxxx.sharepoint.com"
$adminUrl = "https://xxxxxxxx-admin.sharepoint.com/"
$username = "admin@xxxxxxxx.onmicrosoft.com"
$password = "xxxxxxxxxxx"
$Invocation = (Get-Variable MyInvocation -Scope 0).Value
$ScriptPath = Split-Path $Invocation.MyCommand.Path
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
Connect-PnPOnline -Url $adminUrl -credentials $cred
#$ctx = Get-PnPContext

$sites = Get-PnPTenantSite -Detailed -Force
Write-Host "There are " $sites.count " site collections present"


<#this works, but we wanna get from mapping file various properties you see<
foreach($site in $sites){

    $site = Get-PnPTenantSite -Url $site.Url -Detailed
    #attempt to change owner
    Set-PnPTenantSite -Url $site.Url -StorageMaximumLevel 20240
    Set-PnPTenantSite -Url $site.Url -Owners "admin@xxxxxxxxx.onmicrosoft.com"
   
    Write-Host "Title       : " $site.Title
    Write-Host "URL         : " $site.Url
    Write-Host "Template    : " $site.Template
    Write-Host "Status      : " $site.Status
    Write-Host "Storage (MB): " $site.StorageMaximumLevel
    Write-Host "Used (MB)   : " $site.StorageUsage
    Write-Host "Resources   : " $site.UserCodeMaximumLevel
    Write-Host "Owner       : " $site.Owner
    Write-Host "Sharing     : " $site.SharingCapability
    Write-Host "subsites    : " $site.WebsCount
    Write-Host "-----------------------------------------"
}
#>




##another approach, to iterate thru all the mapping files 
$mappingFilePath = Join-Path $ScriptPath $mappingFile
Import-Csv $mappingFilePath -Delimiter "|" | ForEach-Object {
    $destinationSiteTitle = $_.destinationSiteTitle    
    $destinationSiteUri = $tenancyUrl+$_.destinationSiteUri
    $destinationSiteQuota = [convert]::ToInt32($_.destinationSiteQuota, 10) 
    Write-Host "adding admin as secondary admin to $destinationSiteUri setting Quota to $destinationSiteQuota."
    $site = Get-PnPTenantSite -Url $destinationSiteUri -Detailed
    #attempt to change owner
    Set-PnPTenantSite -Url $destinationSiteUri -StorageMaximumLevel $destinationSiteQuota -Owners "admin@xxxxxxxxx.onmicrosoft.com"
    #if we issue further commands, there needs to be some delay...
    #Set-PnPTenantSite -Url $destinationSiteUri -Owners "admin@brightondev.onmicrosoft.com"
    Write-Host "Title       : " $site.Title
    Write-Host "URL         : " $site.Url
    Write-Host "Template    : " $site.Template
    Write-Host "Status      : " $site.Status
    Write-Host "Storage (MB): " $site.StorageMaximumLevel
    Write-Host "Used (MB)   : " $site.StorageUsage
    Write-Host "Resources   : " $site.UserCodeMaximumLevel
    Write-Host "Owner       : " $site.Owner
    Write-Host "Sharing     : " $site.SharingCapability
    Write-Host "subsites    : " $site.WebsCount
    Write-Host "-----------------------------------------"

}
