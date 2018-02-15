CREATE PROCEDURE [dbo].[GetSupplierContactsBySupplierID]
	@supplierID int = 0 
AS
	SELECT [ID],
			[SupplierID],
			[FirstName] ,
			[LastName]  ,
			[HomePhone]     ,
			[WorkPhone]     ,
			[MobilePhone]     ,
			[Email],
			[Website]
	FROM SupplierContacts WHERE SupplierID = @supplierID
RETURN 0