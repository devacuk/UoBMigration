clear

#todo - after site is provisioned we need to add a MyFiles doclib and test that
#this script answers the questions over the old CreatePersonalSiteEnqueueBulk method not working.
#this one works with the xxx tenancy.  it was tested with the legcy dev tenant
#we saw that users who are licensed will have their own onedrive proisioned if it already is not done so
#this can be run from any windows machine even a client if some prerequisites are installed
<#Make sure to the items below are installed and up to date:

Prerequisites:
•Windows Management Framework 5.0 https://www.microsoft.com/en-us/download/details.aspx?id=50395
•.Net 4.6.2 or newer https://www.microsoft.com/en-us/download/details.aspx?id=53344
•Microsoft Online Services Sign-In Assistant https://www.microsoft.com/en-us/download/details.aspx?id=28177
•Azure AD Module PowerShell Command “Install-Module -Name AzureAD”
•SharePoint Online Client Components SDK https://www.microsoft.com/en-us/download/details.aspx?id=42038
•SharePoint Online Management Shell. https://www.microsoft.com/en-us/download/details.aspx?id=35588
•Remote Server Administration Tools for Windows 10 https://www.microsoft.com/en-us/download/details.aspx?id=45520
•Remote Server Administration Tools for Windows 7 https://www.microsoft.com/en-us/download/details.aspx?id=7887
•Reboot the server after any installs. Make sure that scripting permissions are allowed for the Office 365 
global administrator Tile -> Admin -> Admin -> SharePoint -> Settings.
•Run the script from your AD Connect server.#>
cls
#Provision OneDrive/PersonalSite for Users that   need it provisioned
#This runs slowly so run this overnight
Install-Module -Name AzureAD #reboot after installing AzureADConnect
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Import-Module Microsoft.SharePoint.Client

#https://www.microsoft.com/web/handlers/webpi.ashx/getinstaller/WindowsAzurePowershellGet.3f.3f.3fnew.appids
Import-Module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"
#Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\ServiceManagement\Azure\Microsoft.WindowsAzure.Commands.dll"
$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
#Must be SharePoint Administrator URL

#update and store password as necessary
#$logfile2 = 'C:\Users\sp_install\Downloads\sProvisioned.txt';
<#DEV Legacy
$logfile2 = 'Provisioned.txt';
$webUrl = "https://xxxx-admin.sharepoint.com";
$mysitewebUrl = "https://xxxx-my.sharepoint.com";
$username = "admin@xxxx.onmicrosoft.com";#>
#DEV for UNIDEV
Write-Host Split-Path $script:MyInvocation.MyCommand.Path
$path = (Split-Path $script:MyInvocation.MyCommand.Path)
$logfile2 = '$path\Provisioned.txt';
$webUrl = "https://xxxxx-admin.sharepoint.com";
$mysitewebUrl = "https://xxxxxx-my.sharepoint.com";
$username = "xxxxxx@xxxxx.onmicrosoft.com";
$Password = "xxxxxxxxxx"
$mycreds = New-Object -TypeName System.Management.Automation.PSCredential `
    -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)

#Connect to msolservice to query users
Connect-AzureAD -credential $mycreds;
$filter = 'accountEnabled eq true';
#we can add another filter for department Get-AzureADUser -Filter "startswith(department,'Information Systems')"
$licenseduserList = Get-AzureADUser -All $True -Filter $filter | 
    Where { ($_.AssignedLicenses -ne $Null -and $_.AssignedLicenses.Count -gt 0) -and !($_.UserPrincipalName -like "8*" -or $_.UserPrincipalName -like "9*")} | 
    Sort-Object UserPrincipalName
Disconnect-AzureAD
Write-Host "OneDrive Provisioning";
#Connect to SharePoint Online to Provision OneDrive
Connect-SPOService -Url $webUrl -Credential $mycreds
#Connect-SPOnline -Url $webUrl -Credential $mycreds
Write-Host "Connected to site and Provision Search Started: $webUrl" -ForegroundColor Green;
     
#Test view all sites
#Get-SPOSite
 
$licenseduserList | Out-File -filepath "$path\licenseduserList.txt"
     
if ($licenseduserList)
{
         
    $usercount = 1;
    $usersToProvision = @();
    $usersprovisioned = @();
    foreach ($eachuser in $licenseduserList)
    {
 
        #Run OneDrive/PersonalSite Provisioning in batches of 10 
        if ($usercount -gt 10)
        {
            Write-Host "Batch Provisioning OneDrive for users:";
            Write-Host "Users Needing Provision:";
            $usersToProvision;
            Request-SPOPersonalSite -UserEmails $usersToProvision;
            $usersToProvision = @();
            $usercount = 1;
        }
             
        #To enqueue
             
        $onedriveuser = [string]$($eachuser.UserPrincipalName);
        Write-Host $usercount
        #$usersToProvision += $onedriveuser;
        $spouser1 = $null;
        try
        {
            #this checks if there is a mysite for the user - a mysite being theyre onedrive
            #ignore the current user if no error
            $spouser1 = Get-SPOUser -Site $mysitewebUrl -LoginName $onedriveuser
            $usersprovisioned += $onedriveuser;

            #add the MyFiles doclib
            #todo call a function
        }
        catch
        {
            #users not provisioned with onedrive get caught
            #and added to list for later provisioning
            $usersToProvision += $onedriveuser;
            Add-Content $logfile2 $onedriveuser;
            $usercount++;
            #Write-Host $onedriveuser
        }
             
            
          
    }
 
    #Run last batch
    if ($usercount -gt 1)
    {
        Write-Host "Batch Provisioning OneDrive for users:";
        Write-Host "Users Needing Provision:";
        $usersToProvision;
        Request-SPOPersonalSite -UserEmails $usersToProvision;

        #add the MyFiles doclib
        #todo call a function
        $usersToProvision = @();
        $usercount = 1;
    }
}
else 
{
    Write-Host "No Users to Provision";
}
 
Disconnect-SPOService;
 
Write-Host "One Drive Provisioning Completed" ;
 
 
#to Test Provisioning succeeded wait at least a few hours
#Login to Office 365 using an account then hit the url below replacing username as desired
#replace @ symbol and . with underscores in the UserPrincipalName
#https://[ORGANIZATION SITE]-my.sharepoint.com/personal/USERPRINCIPALNAME
