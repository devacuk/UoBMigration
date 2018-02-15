CREATE PROCEDURE [dbo].[GetPartSuppliersBySupplier]
	@SupplierId int
AS
	SELECT Suppliers.Name, Parts.SKU FROM PartSuppliers 
	INNER JOIN Suppliers ON PartSuppliers.SupplierId = Suppliers.ID 
	INNER JOIN Parts ON PartSuppliers.PartSKU = Parts.SKU
	WHERE PartSuppliers.SupplierId = @SupplierId 
	ORDER BY Suppliers.Name
RETURN 0