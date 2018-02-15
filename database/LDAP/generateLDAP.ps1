<#  
    .SYNOPSIS
    script to generate the LDAP table needs to run on migration server
    .DESCRIPTION
    as it needs powershell > 2 wont run on a SharePoint 2010 WFE    
    you need to supply these parameters, examples in quotes    
    -Server "SP-MIG-xxxx\MSSQLSERVERLG" `
    -Database  "SPMigration" `
    -uid "university\xxxxxx" `
    -pwd "xxxxxx" `
    -force $false `
    -setCredential $false `
    -truncate $true `
    -LDAPPassword "Delguc6g" 
    .EXAMPLE
    .\generateLDAP.ps1 -Server "SP-MIG-DEV01\xxxxxx" `
    -Database  "SPMigration" `
    -uid "university\xxxxxx" `
    -pwd "xxxxxxxxxx" `
    -force $false `
    -setCredential $false `
    -truncate $true `
    -LDAPPassword "xxxxxxxx" `
    -filter "(&(|(uobusertype=w*)(uobusertype=sr)))"
    .NOTES
    Author : Tristian O'Brien - t.xxxxxxx@xxxxxxxx.ac.uk
    Version:        1.0
    Creation Date:  8/2/2018
    Change Date: n/a
    Purpose/Change: n/a
    .LINK
    https://itwiki.xxxxxxxx.ac.uk/migration

#>



[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$Server,
    [Parameter(Mandatory=$True)]
    [string]$Database, 
    [Parameter(Mandatory=$True)]
    [string]$uid, 
    [Parameter(Mandatory=$True)]
    [string]$pwd, 
    [Parameter(Mandatory=$True)]
    [bool]$force, 
    [Parameter(Mandatory=$True)]
    [bool]$setCredential,
    [Parameter(Mandatory=$True)]
    [bool]$truncate,
    [Parameter(Mandatory=$True)]
    [string]$LDAPPassword,
    [Parameter(Mandatory=$True)]
    [string]$filter,
    [Parameter(Mandatory=$True)]
    [string]$ldap_server,
    [Parameter(Mandatory=$True)]
    [string]$domain,
    [Parameter(Mandatory=$True)]
    [string]$dc,
    [Parameter(Mandatory=$True)]
    [string]$ldap_people_ou
       
)
Import-Module dbatools #for invoke-sqlcmd for example
Clear-Host

if ($setCredential -eq $True) {
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $uid, $(convertto-securestring $pwd -asplaintext -force)
}
###not needed   $srv =  Connect-DbaInstance -SqlInstance $Server -Database $Database -Credential $cred 
# If no argument was supplied, set DebugPreference to "SilentlyContinue"
cd C:\migration\Tools

$domain_fq = (Get-WmiObject Win32_ComputerSystem).domain
Write-Host "Running on a production DC in $domain_fq"

function LDAPUsersToDatabase () {
    
    $ldap_user_dn="$ldap_people_ou"
    $ldap_server_and_user_url = "LDAP://$ldap_server/$ldap_user_dn"
    $ldap_bind_user="uid=spldap,$ldap_people_ou"
    $ldap_bind_password=$LDAPPassword
    $ldap_auth = [System.DirectoryServices.AuthenticationTypes]::FastBind

    Write-Host "Searching for user '$username' on $ldap_server"
    $ldap_entry = New-Object System.DirectoryServices.DirectoryEntry($ldap_server_and_user_url,$ldap_bind_user,$ldap_bind_password,$ldap_auth)
    if (!$ldap_entry.Exists) {
        Write-Host "Could not find user '$username' in LDAP directory"
    }

    else {
        Write-Host "Found user '$username' in LDAP directory"        
        $ds = New-Object system.DirectoryServices.DirectorySearcher($de,$filter,$null)
        $ds = New-Object system.DirectoryServices.DirectorySearcher($ldap_entry,$filter,$null)
        $ds.PageSize = '10'
        $query = $ds.FindAll()
        $count = 1
        #echo "row`tdn`tuid`tcn`tinitials`tsn`tuobdeptdescription`tuobfacultydescription`ttitle`tmail`ttelephoneNumber`tuobusertypedescription`tuobpersonaltitle`tgivenname`troom`tbuildingname`tsiteName`ttownName`tpostalCode`tbuildingCode`tdeptCode`tstaffType`tstaffCategory`tuserType`tuobDateLeft" >> results.csv     
        foreach ($objResult in $query){
            $objItem = $objResult.Properties   
            [string]$dn = $objItem.dn
            [string]$uid = $objItem.uid
            [string]$cn = $objItem.cn
            [string]$initials = $objItem.initials
            [string]$sn = $objItem.sn
            [string]$uobdeptdescription = $objItem.uobdeptdescription
            [string]$uobfacultydescription = $objItem.uobfacultydescription
            [string]$title = $objItem.title
            [string]$mail = $objItem.mail
            [string]$telephoneNumber = $objItem.telephonenumber
            [string]$uobusertypedescription = $objItem.uobusertypedescription
            [string]$uobpersonaltitle = $objItem.uobpersonaltitle
            [string]$givenname = $objItem.givenname
            #these properties are available to authenticated bind
            [string]$room = $objItem.uobRoom
            [string]$buildingname = $objItem.uobbuildingname
            [string]$siteName = $objItem.uobsitename
            [string]$townName = $objItem.uobtownname
            [string]$postalCode = $objItem.uobpostalcode
            [string]$buildingCode = $objItem.uobbuildingcode
            [string]$deptCode = $objItem.uobdeptcode
            [string]$staffType = $objItem.uobstafftype
            [string]$staffCategory = $objItem.uobstaffcategory
            [string]$userType = $objItem.uobusertype    
            [string]$uobDateLeft = $objResult.Properties.uobdateleft        
            Write-Host "$count $dn $uid $cn "
            Write-Host "$uobdeptdescription $uobfacultydescription"
            Write-Host "$uobusertypedescription"
            Write-Host "$uobpersonaltitle $givenname $uobDateLeft"

            $Obj = [PSCustomObject] @{                    
                    dn='not found'
                    uid=$uid
                    cn=$cn
                    initials=$initials    
                    sn=$sn
                    department=$uobdeptdescription
                    faculty=$uobfacultydescription
                    title=$title
                    mail=$mail
                    telehone=$telephoneNumber
                    uobusertypedescription=$uobusertypedescription
                    uobpersonaltitle=$uobpersonaltitle
                    givenname=$givenname
                    room=$room
                    buildingname=$buildingname
                    siteName=$siteName
                    townname=$townName
                    postalcode=$postalCode
                    buildingcode=$buildingCode
                    deptcode=$deptCode
                    stafftype=$staffType
                    staffCategory=$staffCategory
                    usertype=$userType
                    uobDateLeft=$uobDateLeft    
            }
            
            ##todo need a switch around here to force if the table isnt setup already create a parameter
            if ($setCredential -eq $true) {      

     
                if ($force -eq $true) {             
                    Write-SqlTableData -serverInstance $Server -database $Database -TableName "LDAPData" -SchemaName dbo -InputData $obj -force -Credential $cred 
                    $force = $false
                } else {
                    if ($truncate -eq $true) {
                        Invoke-Sqlcmd -Query "TRUNCATE TABLE LDAPData" -ServerInstance $Server -database $Database -Credential $cred 
                        $truncate = $false
                    } 
                    Write-SqlTableData -serverInstance $Server -database $Database -TableName "LDAPData" -SchemaName dbo -InputData $obj -PassThru -Credential $cred
                }                
            } else {

                if ($force -eq $true) {             
                    Write-SqlTableData -serverInstance $Server -database $Database -TableName "LDAPData" -SchemaName dbo -InputData $obj -force  
                    $force = $false
                } else {
                    if ($truncate -eq $true) {
                        Invoke-Sqlcmd -Query "TRUNCATE TABLE LDAPData" -ServerInstance $Server -database $Database   
                        $truncate = $false
                    } 
                    
                    try {
                        Write-SqlTableData -serverInstance $Server -database $Database -TableName "LDAPData" -SchemaName dbo -InputData $obj -PassThru 
                    } catch {


                        if ($_.FullyQualifiedErrorId -eq "CommandNotFoundException") {
                            Write-Host "Install SQL Server PowerShell module" -BackgroundColor Red -ForegroundColor Yellow
                            Write-Host "https://docs.microsoft.com/en-gb/sql/powershell/download-sql-server-ps-module"
                            break
                        } else {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            write-host "error" -ForegroundColor red
                        }




                    }







                }
            }
            
            $count++
        }
      
    }

    return $ldap_entry
}

LDAPUsersToDatabase



