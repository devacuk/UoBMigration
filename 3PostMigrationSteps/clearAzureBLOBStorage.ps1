clear 
$StorageAccountName = "[storage account name]" 
$StorageAccountKey = "[put your key here]"
$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$ContainerName = "bbb"
$container = Get-AzureStorageContainer -Name $ContainerName -Context $ctx
foreach($item in $container) {
    Write-Host $item
}

#delete all containers in a given storage
$containers = Get-AzureStorageContainer -Context $ctx
foreach($item in $containers) {
    Remove-AzureStorageContainer -Name $item.Name -Context $ctx -Force
    Write-Host $item.Name
}

#or delete all blobs in a given container
Get-AzureStorageBlob -Container $ContainerName -blob * -Context $ctx | ForEach-Object {
    Remove-AzureStorageBlob -Blob $_.Name -Container $ContainerName -Context $ctx
    Write-Host "deleted "$_.Name
   
}
Write-Host "end"