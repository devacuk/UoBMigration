<#
.SYNOPSIS
  Provision OneDrive and Set Permissions
.DESCRIPTION
  Provisions OneDrive for list for users and add administrator account to provisioned sites
  Step 1: Update the "Input variables" section to suit your tenant
  Step 2: Make sure you have latest version of SharePoint Client SDK: http://www.microsoft.com/en-us/download/confirmation.aspx?id=35585
  Step 3: And Install latest version of Azure Module for Powershell and MSOL signin assistnat from here http://technet.microsoft.com/en-us/library/jj151815.aspx
  
.EXAMPLE
   Set-OneDriveProvisonAndPermissions.ps1 
.OUTPUTS
   
#>

#Input Variables Begin
	#Credentials Store Location
	$credFile="acredfile.xml"
	#Log File location
	$Logfile = "OneDriveProvisionReport.log"
	#O365 Global admin
	$O365AdminAccount = "xxxxxx@xxxxxx.onmicrosoft.com";
	#O365 Onedrive admin
	$OneDriveAdminAccount = "xxxxxxx@xxxxxx.onmicrosoft.com";
                             
	#O365 Admin site URL
	$webUrl = "https://xxxxxx-my.sharepoint.com"
	#List of OneDrive users (seperated by CSV)
	$OneDriveUsers = "xxxxxx@xxxxxx.onmicrosoft.com"#,"C.xxxxx@xxx.xxxxxx.ac.uk"	
    
# Input Variables End


function LogWrite
{
  param([string]$logstring)

  $dateTime = get-date -format G
  Write-Host " "
  Write-Host $dateTime $logstring
  Add-Content $Logfile -Value " "
  Add-Content $Logfile -Value ( $dateTime  + $logstring)

}

function Get-MSOLCredentials() {
 
    if ((Get-Module Microsoft.Online.SharePoint.PowerShell).Count -eq 0) {
        Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
    }
	
	If (Test-Path ($credFile))
	{
  		$cred = Import-Clixml $credFile
	}
	Else
	{
		Get-Credential $O365AdminAccount | Export-Clixml $credFile
		$cred = Import-Clixml $credFile
	}

    
	LogWrite ("**-- Loaded MSOL credentials from $credFile  --*")
}

function Create-OneDriveSites()
{
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.UserProfiles")

	#Must be SharePoint Administrator URL
	
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($webUrl)
	$web = $ctx.Web
	$cred = Import-Clixml $credFile	
	$ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($cred.Username,$cred.Password)
	
	$ctx.Load($web)
	$ctx.ExecuteQuery()

	$loader =[Microsoft.SharePoint.Client.UserProfiles.ProfileLoader]::GetProfileLoader($ctx)

	#To Get Profile
	$profile = $loader.GetUserProfile()
	$ctx.Load($profile)
	$ctx.ExecuteQuery()
	#$profile 

	#To enqueue Profile
	$loader.CreatePersonalSiteEnqueueBulk($OneDriveUsers) 
	$loader.Context.ExecuteQuery()

	LogWrite ("**-- Site Provision complete for $OneDriveUsers --*") 
	
	
}

function Assign-Administrator()
{
	$pos = $O365AdminAccount.IndexOf("@")
	#Email Domain
	$emailDomain = $O365AdminAccount.Substring($pos+1)
	#Email Domain with underscore
	$emailDomainURL =  $emailDomain -replace '\.','_'
	#OneDrive root site URL
	$OneDriveSiteColl = $webUrl -replace '-admin','-my'
	#SharePoint Online Domain
	$spoDomain = $emailDomain -replace '.com',''
	

	$cred = Import-Clixml $credFile
	Connect-SPOService -Url $webUrl -credential $cred
    #$colUsers = Get-SPOUser -Site $OneDriveSiteColl | Where-Object {$_.LoginName -like "*$emailDomain*"}
	$colUsers = Get-SPOUser -Site $OneDriveSiteColl | Where-Object {$OneDriveUsers -contains $_.LoginName}
    $colUsers = $colUsers.LoginName | ForEach-Object { $_.TrimEnd($emailDomain) } | ForEach-Object { $_.TrimEnd("@") }
    $colUsers | ForEach-Object { 
		$mySiteURL = $OneDriveSiteColl + '/personal/' + $_ + '_' + $emailDomainURL + '/'
		Set-SPOUser -Site $mySiteURL -LoginName $OneDriveAdminAccount -IsSiteCollectionAdmin $true 
		LogWrite ("**-- Added $OneDriveAdminAccount as Site Admin to $mySiteURL  --*") 
	}
	
	
}


try
{
    cls
	Get-MSOLCredentials
	Create-OneDriveSites
    Assign-Administrator
	
}
catch
{
  LogWrite ($_.Exception.Message)
  LogWrite ($_.Exception.ItemName)
  LogWrite ($_.CategoryInfo)
}
finally
{
  # Dispose afterwards
}