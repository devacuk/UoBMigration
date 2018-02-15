CREATE PROCEDURE [dbo].[GetPartSuppliersByPart]
	@partSku varchar(255)
AS
	SELECT Suppliers.Name, Parts.SKU FROM PartSuppliers 
	INNER JOIN Suppliers ON PartSuppliers.SupplierId = Suppliers.ID 
	INNER JOIN Parts ON PartSuppliers.PartSKU = Parts.SKU
	WHERE PartSuppliers.PartSKU = @partSku
	ORDER BY Suppliers.Name
RETURN 0