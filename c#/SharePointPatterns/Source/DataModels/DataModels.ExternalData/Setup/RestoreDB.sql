USE [master]
GO

RESTORE DATABASE [PartsManagement]
FROM DISK = '$(restorepath)\PartsManagement_Large.bak'
GO