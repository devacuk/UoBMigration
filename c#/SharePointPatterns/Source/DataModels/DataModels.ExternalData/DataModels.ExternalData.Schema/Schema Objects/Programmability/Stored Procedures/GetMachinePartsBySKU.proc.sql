-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetMachinePartsBySKU]
	-- Add the parameters for the stored procedure here
	@partSku varchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [MachineId],
		   [PartSKU]
 	FROM MachineParts WHERE MachineParts.PartSKU  = @partSku
	
END