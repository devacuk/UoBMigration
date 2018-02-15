#Must be SharePoint Administrator URL  runas admin
#this works, may take a few minutes to provision
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


#example create a personal site (if licensned
Request-SPOPersonalSite -UserEmails "D.xxxxxx@xxxxxxx.ac.uk";
Request-SPOPersonalSite -UserEmails "J.M.xxxxxx@xxxxxxx.ac.uk";
Request-SPOPersonalSite -UserEmails "F.M.xxxxxx@xxxxxx.ac.uk";


#example two, grant secondary admin


$thisPath = Split-Path -Parent $PSCommandPath 
Import-Csv $thisPath\..\usermapping\UsersToMigrate.csv -Delimiter "|" | ForEach-Object {
    #$username = $_.username
    $o365login = $_.o365login
    $department = $_.department
    $o365urlpart = $_.o365urlpart

    $sitename = "https://xxxxxx-my.sharepoint.com/personal/$o365urlpart"
    try
    {
        $temp1 = Set-SPOUser -Site $sitename -LoginName $username -IsSiteCollectionAdmin $true
        Write-Output "Updated Secondary Admins for:" $sitename
    }
    catch [System.Exception]
    {
        Write-Output  $Error[0].Exception
    }

}