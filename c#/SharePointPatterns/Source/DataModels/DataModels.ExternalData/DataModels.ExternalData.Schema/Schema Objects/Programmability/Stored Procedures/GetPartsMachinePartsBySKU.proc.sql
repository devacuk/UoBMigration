﻿-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetPartsMachinePartsBySKU]
	-- Add the parameters for the stored procedure here
	@partSku varchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [SKU],
			[Name],
			[Description]
				
	FROM Parts 
	INNER JOIN MachineParts ON Parts.SKU = MachineParts.PartSKU
	WHERE MachineParts.PartSKU  = @partSku
	
END