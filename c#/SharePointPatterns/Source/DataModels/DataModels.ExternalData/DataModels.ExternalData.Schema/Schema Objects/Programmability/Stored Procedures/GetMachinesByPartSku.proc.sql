-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE GetMachinesByPartSku
	-- Add the parameters for the stored procedure here
	@partSku varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Machines.[ID],
		   Machines.[Name], 
		   Machines.[ModelNumber],
		   Machines.[ManufacturerId],
		   Machines.[CategoryId]    

	 FROM Parts 
	INNER JOIN MachineParts ON Parts.SKU = MachineParts.PartSKU 
	INNER JOIN Machines ON MachineParts.MachineId = Machines.ID 
	WHERE Parts.SKU = @partSku;
END