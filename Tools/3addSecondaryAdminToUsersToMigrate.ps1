#Must be SharePoint Administrator URL  runas admin
#this works, may take a few minutes to provision
cls
$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")

$webUrl = "https://xxxxxx@xxxxxxx-admin.sharepoint.com";
$mysitewebUrl = "https://xxxxxxx@xxxxxx-my.sharepoint.com";
$username = "xxxxxx@xxxxxx.onmicrosoft.com";
$Password = "xxxxxxxxxx"
$cred = New-Object -TypeName System.Management.Automation.PSCredential `
    -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
Connect-SPOService -Url $webUrl -Credential $cred



Request-SPOPersonalSite -UserEmails "D.xxxxxxx@xxxxxxx.ac.uk";
Request-SPOPersonalSite -UserEmails "J.M.xxxxxx@xxxxxx.ac.uk";



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
        Request-SPOPersonalSite -UserEmails "F.M.xxxxxx@xxxxxx.ac.uk";
        Write-Output "Updated Secondary Admins for:" $sitename
    }
    catch [System.Exception]
    {
        Write-Output  $Error[0].Exception
    }

}