<#  
    .SYNOPSIS
    Demonstrates a working mechanism to provision a site collection using patterns and practices
    .DESCRIPTION
    todo

#>
Param(
    [Parameter(Mandatory=$True)]
    [string]$o365OnedriveURIPart, #https://brightondev-my.sharepoint.com/personal
    [Parameter(Mandatory=$True,Position=1)]
    [string]$mappingfile,#"SitesToMigrate.csv"
    [Parameter(Mandatory=$True)]
    [string]$adminUrl, #"https://xxxxx-admin.sharepoint.com/"
    [string]$sourcePasswordPlain, #xxxx/xxxx/xxxxx
    [Parameter(Mandatory=$True)]
    [string]$destinationPasswordPlain, #xxxxxxxxx
    [Parameter(Mandatory=$True)]
    [string]$o365AdminAccount #admin@xxxxxxxx.onmicrosoft.com
    [Parameter(Mandatory=$True)]
    [string]$o365SharePointAdminAccount #"xxxxx2@xxxxxxx.onmicrosoft.com" --NOT USED 
)

clear
 = ''
$ = 

###we'll loop through the IA files and build site
$newSiteCollectionUrl = 'https://xxxxxxx.sharepoint.com/teams/xxxxx'
$title = "xxxxx"
$Invocation = (Get-Variable MyInvocation -Scope 0).Value
$ScriptPath = Split-Path $Invocation.MyCommand.Path
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $o365AdminAccount, $(convertto-securestring $destinationPasswordPlain -asplaintext -force)
Connect-PnPOnline -Url $adminUrl -credentials $cred

#todo
#loop through mapping file and cleardown site collections
#then...
#loop through list of site collections, provison, ready for migration
$mappingFilePath = Join-Path $ScriptPath $mappingFile
##this will handle deleting the sites
#Import-Csv $mappingFilePath -Delimiter "|" | ForEach-Object {
#    write-host $_

    #dont work access denied Remove-PnPTenantSite -Url $newSiteCollectionUrl -Force -SkipRecycleBin
    
#}

Import-Csv $mappingFilePath -Delimiter "|" | ForEach-Object {
    write-host "provisioning site $_.destinationSiteTitle"    
    new-pnptenantsite -title $_.destinationSiteTitle -url $_.destinationSiteUri -owner $_.destinationSiteOwner -TimeZone 4 -Template $_.destinationSiteTemplate -Description $_.destinationSiteDescription -Force
}

# need url scheme of https://brightondev.sharepoint.com/sites/is or teams
#need to specify owner and then the template id to use.  store the in a mapping file
#columns in the mapping file 
#sourceSiteCollection, destinationSiteUri, destinationSiteTitle, destinationSiteQuota, destinationSiteOwner, destinationSiteTemplate, destinationSite