#deploy this code to SharePoint 2010 WFE, it wont run on the migration server
#and schedule as the the other reports that report on production use
<#  
    .SYNOPSIS
    populates table of users who have successfully been migrated
    .DESCRIPTION
    you need to supply these parameters, examples in quote
    -dataSource "BS-DB-PRO04\xxxxxx" `
    -database "SPMigration" `
    -mySiteUrl "https://mydepartment.dev.xxxxx.ac.uk" `
    -domain "UNIVERSITY"
    .EXAMPLE
    .\UsersMigratedReportFinal.ps1 -dataSource "BS-DB-PRO04\MSSQLSERVERLG" `
    -database "SPMigration" `
    -mySiteUrl "https://mydepartment.dev.xxxxx.ac.uk" `
    -domain "UNIVERSITY"
    .NOTES
    Author : Tristian O'Brien - t.obrien2@xxxxx.ac.uk
    Version:        1.0
    Creation Date:  8/2/2018
    Change Date: n/a
    Purpose/Change: n/a
    .LINK
    https://itwiki.xxxxx.ac.uk/migration

#>
  
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$dataSource,
    [Parameter(Mandatory=$True)]
    [string]$database, 
    [Parameter(Mandatory=$True)]
    [string]$mySiteUrl, 
    [Parameter(Mandatory=$True)]
    [string]$domain    
)
if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) { 
    Add-PSSnapin "Microsoft.SharePoint.PowerShell" 
} 

.\SP2010Dependencies\Invoke-SQL.ps1

cd C:\Migration\Tools
# region Include required files
#
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\SP2010Dependencies\Invoke-SQL.ps1")
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}
#endregion
clear-host    

$site = Get-SPSite $mySiteUrl 
$ServiceContext = Get-SPServiceContext $site 

#Get UserProfileManager from the My Site Host Site context 
$ProfileManager = new-object Microsoft.Office.Server.UserProfiles.UserProfileManager($ServiceContext)    
$AllProfiles = $ProfileManager.GetEnumerator()  

Invoke-sql -dataSource $datasource -database $database -sqlCommand "TRUNCATE TABLE datemigrated"

while ($AllProfiles.MoveNext()) {
    $userProfile = $AllProfiles.Current
    $accountName = $userProfile[[Microsoft.Office.Server.UserProfiles.PropertyConstants]::AccountName].Value
    $accountName = $accountName -ireplace "$domain\\", ""
    $displayName = $userProfile.DisplayName
    $phone = $userProfile["WorkPhone"]
    $migrated = $userProfile["uob-migrated"]
    write-host "Profile for account $AccountName, $displayName, $phone, $migrated"
    echo "$AccountName, $displayName, $phone, $migrated" >> migrated.csv 
        
    if (-not ([string]::IsNullOrEmpty($migrated)))
    {
        Invoke-sql -dataSource $datasource -database $database -sqlCommand "INSERT INTO datemigrated ([uid],[dateMigrated]) VALUES('$accountName','$migrated');"                  
    }    
    #Invoke-sql -dataSource "BS-DB-PRO04\MSSQLSERVERLG" -database "SPMigration" -sqlCommand "INSERT INTO datemigrated ([uid]) VALUES('$accountName')"    
    

}


<#
echo "DisplayName,AccountName,migrated" >> migrated.csv 
foreach($profile in $AllProfiles)  
{  
    $DisplayName = $profile.DisplayName  
    $AccountName = $profile[[Microsoft.Office.Server.UserProfiles.PropertyConstants]::AccountName].Value  
    $migrated = $profile.Properties.GetPropertyByName("uob-migrated").Value
    $profile = $ProfileManager.GetUserProfile($AccountName)
    
    if ($AccountName -eq 'university\lp79') {
        write-host 'check this'
    }

    #Here goes writing Logic to your SharePoint List + Check if account already existing in the SharePoint list then ignore writing.......
    write-host "Profile for account ", $AccountName , $migrated
    echo "$DisplayName,$AccountName,$migrated" >> migrated.csv 

}  
write-host "Finished." #>
$site.Dispose()


