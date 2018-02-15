#Must be SharePoint Administrator URL  runas admin
#this works, may take a few minutes to provision


<#  
    .SYNOPSIS
    this works this is the step after provisioning to add secondary admin to Onedrive personal sites
    .DESCRIPTION
    grants admin access to folks onedrives which isnt default behaviour
    .EXAMPLE
    TODO e.g. MigrateUsersMysitesToOneDrives.ps1 -onPremiseMyonedriveURIPart "https://mysite.xxxxxx.ac.uk/user" -o365OnedriveURIPart "https://xxxxxx-my.sharepoint.com/personal" -sourcePasswordPlain "xxxxxx" -destinationPasswordPlain "xxxxxxx" -onPremiseAdministratorAdminAccount  "UNIVERSITY\xxxxxx" -o365AdminAccount "admin@xxxxxxx.onmicrosoft.com" -destinationListName "Documents" -sourceListName "MyFiles"
    .NOTES
    Author : xxxxxx O'Brien - t.xxxxxx@xxxxxx.ac.uk
    Version:        1.0
    Creation Date:  20th October 2017
    Purpose/Change: University of Brighton OneDrive migrations
    .LINK
    https://itwiki.brighton.ac.uk/migration
#>
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$destinationPasswordPlain, #xxxxxx
    [Parameter(Mandatory=$True)]
    [string]$o365AdminAccount, #admin@xxxxxx.onmicrosoft.com
    [Parameter(Mandatory=$True)]
    [string]$tenantName, #xxxxxx
    [Parameter(Mandatory=$True)]
    [string]$secondaryAdmin1, #admin@xxxxxx.onmicrosoft.com
    [Parameter(Mandatory=$False)]
    [string]$secondaryAdmin2  #admin@xxxxxx.onmicrosoft.com
)
clear









cls
$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")

$webUrl = "https://xxxxxx@xxxxxx-admin.sharepoint.com";
$mysitewebUrl = "https://xxxxxx@xxxxxx-my.sharepoint.com";
$username = "xxxxxx@xxxxxx.onmicrosoft.com";
$Password = "xxxxxxxxxx"
$cred = New-Object -TypeName System.Management.Automation.PSCredential `
    -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
Connect-SPOService -Url $webUrl -Credential $cred



Request-SPOPersonalSite -UserEmails "D.xxxxx@xxxxxx.ac.uk";
Request-SPOPersonalSite -UserEmails "J.M.xxxxxx@xxxxxx.ac.uk";



#example two, grant secondary admin


$thisPath = Split-Path -Parent $PSCommandPath 
Import-Csv $thisPath\..\usermapping\UsersToMigrate.csv -Delimiter "|" | ForEach-Object {
    #$username = $_.username
    $o365login = $_.o365login
    $department = $_.department
    $o365urlpart = $_.o365urlpart

    $sitename = "https://unibrightonac-my.sharepoint.com/personal/$o365urlpart"
    try
    {
        Request-SPOPersonalSite -UserEmails $_.o365login
        Write-Output "Provisioned OneDrive for $_.o365login" 
    }
    catch [System.Exception]
    {
        Write-Output  $Error[0].Exception
    }

}