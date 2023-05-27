DROP VIEW IF EXISTS dbo.vw_SalesInfo
GO
CREATE VIEW dbo.vw_SalesInfo
WITH SCHEMABINDING AS 
SELECT dbo.NewProducts.name, dbo.NewProducts.lotId, 
dbo.SalesXNewProducts.amount, 
dbo.Sales.buyerName, dbo.Sales.buyerLastName, 
dbo.Sales.buyerPhone, dbo.ContacInfo.name nombreVendedor,
dbo.ContacInfo.lastname
FROM dbo.SalesXNewProducts
INNER JOIN dbo.NewProducts ON dbo.NewProducts.newProductId = dbo.SalesXNewProducts.newProductId
INNER JOIN dbo.Sales On dbo.Sales.saleId = dbo.SalesXNewProducts.saleId
INNER JOIN dbo.ContacInfo On dbo.ContacInfo.contacInfoId = dbo.Sales.contacInfoId
GO

GO
ALTER TABLE dbo.SalesXNewProducts
drop column amount

GO

GO
ALTER TABLE dbo.ContacInfo
drop column lastname

GO