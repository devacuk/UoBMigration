
dont use this need to run the new one based upon the mapping file ..\Tools\2provisionOneDrivesBasedUponMappingFile.ps1 then ..\Tools\3addSecondaryAdminToUsersToMigrate.ps1  
when they are refactored, we'll move those files as pre reqs to the process

#need to run this on SharePoint 2010 WFE
#needed as some users such xxxxxx, xxxxxx and xxxxxx had not mysite, the OOB mysite host is not working properly on UNIDEV.. make sure for unidev, you dont run this on haldus but azha otherwise you will be working on pre prod and not see the changes on unidev
#PowerShell Script - Create All Users Personel Sites - SharePoint 2010 #The scripts is distributet "as-is." Use it on your own risk. 
#Add SharePoint PowerShell SnapIn if not already added 
if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

[Reflection.Assembly]::LoadWithPartialName("Microsoft.Office.Server")

#UNIDEV settings
$mysiteHostUrl = "http://xxxxxx.xxx.xxxxxx.ac.uk"
$personalSiteGlobalAdmin = "UNIDEV\xxxxxx"
$personalSiteGlobalAdminNot ="---"
$personalSiteGlobalAdminDisplayName = "SharePoint Admin Development"
$mysite = Get-SPSite $mysiteHostUrl
$domain = "UNIDEV"

$context = [Microsoft.Office.Server.ServerContext]::GetContext($mysite)
$upm =  New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($context)

$AllProfiles = $upm.GetEnumerator()

foreach($profile in $AllProfiles)
{

    $DisplayName = $profile.DisplayName
    $AccountName = $profile[[Microsoft.Office.Server.UserProfiles.PropertyConstants]::AccountName].Value
    Write-Host "$displayname $AccountName"
   #Add your restrictions for users.        
   if($Accountname -like "$UNIDEV*")
   {
      if($profile.PersonalSite -eq $Null)
      {
           write-host "Creating personel site for ", $AccountName
           $profile.CreatePersonalSite()
           #Adding an extra admin for personel sites                $pweb = $profile.PersonalSite.OpenWeb()
           $pweb.AllUsers.Add($personalSiteGlobalAdmin,$personalSiteGlobalAdminNot,$personalSiteGlobalAdminDisplayName,$null);
           $padm= $pweb.AllUsers[$personalSiteGlobalAdmin];
           $padm.IsSiteAdmin = $true;
           $padm.Update();
           $pweb.Dispose();
           write-host "Personal Site Admin has assigned"
      }
      else
      {
           write-host $AccountName ," has already personel site"
      }
   }
}
$mysite.Dispose();