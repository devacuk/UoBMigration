CREATE PROCEDURE [dbo].[GetAddressesByContactID]
	@contactID int = 0 
AS
	SELECT 
	 [ID],
	 [ContactID],
	 [Address1],
	 [Address2],
	 [City],
	 [State],
	 [PostalCode],
	 [Country]   
	 FROM ContactAddresses WHERE ContactID = @contactID
RETURN 0