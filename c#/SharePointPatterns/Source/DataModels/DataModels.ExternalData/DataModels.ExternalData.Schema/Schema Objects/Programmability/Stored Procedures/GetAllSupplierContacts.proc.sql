CREATE PROCEDURE [dbo].[GetAllSupplierContacts]

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
	
	 FROM SupplierContacts
RETURN 0