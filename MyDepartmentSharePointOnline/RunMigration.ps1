<#
.SYNOPSIS
    orchestration of the powershell cmdlets
#>

& "$PSScriptRoot\ProvisionIA.ps1"
& "$PSScriptRoot\AddSecondaryAdminToMySites.ps1"
& "$PSScriptRoot\MigrateUsersMysitesToOneDrives.ps1"