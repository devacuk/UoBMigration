#Must be SharePoint Administrator URL  runas admin
#this works, may take a few minutes to provision
cls
$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")

$webUrl = "https://xxxxxxx@xxxxxxx-admin.sharepoint.com";
$mysitewebUrl = "https://xxxxxx@xxxxxx-my.sharepoint.com";
$username = "xxxxxx@xxxxxx.onmicrosoft.com";
$Password = "xxxxxxxxxx"
$cred = New-Object -TypeName System.Management.Automation.PSCredential `
    -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
Connect-SPOService -Url $webUrl -Credential $cred


#example create a personal site (if licensned
#Request-SPOPersonalSite -UserEmails "T.xxxx@xxx.xxxxxx.ac.uk";
#Request-SPOPersonalSite -UserEmails "c.xxxxxx@xxx.xxxxxx.ac.uk";

#example two, grant secondary admin



$sitename = "https://xxxxxxxxx-my.sharepoint.com/personal/xxxxxxx"
try
{
    $temp1 = Set-SPOUser -Site $sitename -LoginName $username -IsSiteCollectionAdmin $true
    Write-Output "Updated Secondary Admins for:" $sitename
}
catch [System.Exception]
{
    Write-Output  $Error[0].Exception

}
