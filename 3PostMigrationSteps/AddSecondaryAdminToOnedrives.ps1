

DONT USE THIS NOW AS WE HAVE MANY LIVE STUDENTS IN THE TENANCY THIS APPROACH DOESNT SUIT



<#  
    .SYNOPSIS
    this works this is the step after provisioning to add secondary admin to Onedrive personal sites
    .DESCRIPTION
    grants admin access to folks onedrives which isnt default behaviour
    .EXAMPLE
    TODO e.g. MigrateUsersMysitesToOneDrives.ps1 -onPremiseMyonedriveURIPart "https://mysite.brighton.ac.uk/user" -o365OnedriveURIPart "https://brightondev-my.sharepoint.com/personal" -sourcePasswordPlain "Farum/Pr0dd/Adminnn" -destinationPasswordPlain "RutlesBeatles6" -onPremiseAdministratorAdminAccount  "UNIVERSITY\sap9" -o365AdminAccount "admin@brightondev.onmicrosoft.com" -destinationListName "Documents" -sourceListName "MyFiles"
    .NOTES
    Author : Tristian O'Brien - t.obrien2@brighton.ac.uk
    Version:        1.0
    Creation Date:  20th October 2017
    Purpose/Change: University of Brighton OneDrive migrations
    .LINK
    https://itwiki.brighton.ac.uk/migration
#>
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$destinationPasswordPlain, #RutlesBeatles6
    [Parameter(Mandatory=$True)]
    [string]$o365AdminAccount, #admin@brightondev.onmicrosoft.com
    [Parameter(Mandatory=$True)]
    [string]$tenantName, #brightondev
    [Parameter(Mandatory=$True)]
    [string]$secondaryAdmin1, #admin@brightondev.onmicrosoft.com
    [Parameter(Mandatory=$False)]
    [string]$secondaryAdmin2  #admin@brightondev.onmicrosoft.com
)
clear

$thisPath = Split-Path -Parent $PSCommandPath 
$LogFilePath  = "$thisPath\AdminUpdate-$(get-date -uformat '%Y-%m-%d-%H_%M').csv"
#Set Variables- o365AdminAccount must be a global admin account
$creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($o365AdminAccount, $(convertto-securestring $destinationPasswordPlain -asplaintext -force))
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $o365AdminAccount, $(convertto-securestring $destinationPasswordPlain -asplaintext -force)
Connect-SPOService -Url https://$tenantName-admin.sharepoint.com $cred 
$adminURI = "https://$tenantName-admin.sharepoint.com"
$onedriveURI = "https://$tenantName-my.sharepoint.com"
$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
$loadInfo3 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.userProfiles")
$proxyaddr = "$adminURI/_vti_bin/userProfileService.asmx?wsdl"
$userProfileService= New-WebServiceProxy -Uri $proxyaddr -UseDefaultCredential False
$userProfileService.Credentials = $cred
$strAuthCookie  = $creds.GetAuthenticationCookie($adminURI)
$uri = New-Object System.Uri($adminURI)
$container = New-Object System.Net.CookieContainer
$container.SetCookies($uri, $strAuthCookie)
$userProfileService.CookieContainer = $container
$userProfileResult  = $userProfileService.GetuserProfileByIndex(-1)
Write-Output "Starting- This could take a while."
$numProfiles  = $userProfileService.GetuserProfileCount()
$i = 1
While ($userProfileResult.NextValue -ne -1)
{
    Write-Output "Examining profile $i of  $numProfiles"
    "Examining profile $i of $numProfiles" | Out-File  $LogFilePath -Append
    $Prop = $userProfileResult.userProfile | Where-Object { $_.Name  -eq "PersonalSpace" }
    $Url= $Prop.Values[0].Value
    if ($Url) {
        $sitename = $onedriveURI + $Url
        try
        {
            $temp1 = Set-SPOUser -Site $sitename -LoginName $secondaryadmin1 -IsSiteCollectionAdmin $true
            Write-Output "Updated Secondary Admins for:" $sitename
            "Updated Secondary Admin for: $sitename" | Out-File  $LogFilePath -Append
        }
        catch [System.Exception]
        {
            Write-Output  $Error[0].Exception
            $Error[0].Exception| Out-File $LogFilePath -Append
        }
    }    
    $userProfileResult  = $userProfileService.GetuserProfileByIndex($userProfileResult.NextValue)
    $i++
}
Write-Output "Completed assigning secondary admin to all users" 