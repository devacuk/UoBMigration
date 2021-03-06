 #deploy this code to SharePoint 2010 WFE, it wont run on the migration server
 #Add SharePoint PowerShell SnapIn if not already added 

 <#  
    .SYNOPSIS
    populates table of active mysites on SharePoint 2010 on prem
    .DESCRIPTION
    you need to supply these parameters, examples in quote
    -dataSource "BS-DB-PRO04\MSSQLSERVERLG" `
    -database "SPMigration" `
    -mySiteUrl "https://mydepartment.dev.brighton.ac.uk" `
    -domain "UNIVERSITY"
    .EXAMPLE
    .\mysitesreportfinal.ps1 -dataSource "BS-DB-PRO04\MSSQLSERVERLG" `
    -database "SPMigration" `
    -mySiteUrl "https://mydepartment.dev.brighton.ac.uk" `
    -domain "UNIVERSITY"
    .NOTES
    Author : Tristian O'Brien - t.obrien2@brighton.ac.uk
    Version:        1.0
    Creation Date:  8/2/2018
    Change Date: n/a
    Purpose/Change: n/a
    .LINK
    https://itwiki.brighton.ac.uk/migration

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
$site = Get-SPSite $mySiteUrl 

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


$rootSite = Get-SPSite -webapplication $mySiteHostUrl -limit all  
Invoke-sql -dataSource $dataSource -database $database -sqlCommand "TRUNCATE TABLE mysites"

foreach($subSite in $rootSite){   
    $username =  $subSite.RootWeb.ServerRelativeUrl.Replace("/user/","")
    $SiteUrl = $subSite.RootWeb.ServerRelativeUrl #url     
    $SiteName = $subSite.RootWeb.Title.replace("'","''") #user
    $sharepointdatabase = $subSite.ContentDatabase.Name #CDB
    $SiteSize = $subSite.Usage.Storage/1MB
    $SiteCDate = $subSite.RootWeb.Created
    $SiteMDate = $subSite.RootWeb.LastItemModifiedDate       
    Write-Output "$username, $SiteUrl, $SiteName, $database, $SiteSize, $SiteCDate, $SiteMDate"      
    echo "$username, $SiteUrl, $SiteName, $database, $SiteSize, $SiteCDate, $SiteMDate" >> mysites.csv 
    ##if (-not ([string]::IsNullOrEmpty($migrated)))
    ##{
        Invoke-sql -dataSource $dataSource -database $database -sqlCommand `
        "INSERT `
        INTO mysites ([username],[siteURL],[siteName],[database],[siteSize],[siteCDate],[siteMDate]) `
        VALUES('$username','$SiteUrl','$siteName','$sharepointdatabase','$siteSize','$siteCDate','$siteMDate');"                  
    ##}    
    #Invoke-sql -dataSource "BS-DB-PRO04\MSSQLSERVERLG" -database "SPMigration" -sqlCommand "INSERT INTO datemigrated ([uid]) VALUES('$accountName')"        
    $subSite.Dispose() 
} 

$site.Dispose()


