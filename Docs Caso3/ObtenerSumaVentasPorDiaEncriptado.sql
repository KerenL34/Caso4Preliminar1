USE [EsencialVerde]
GO
/****** Object:  StoredProcedure [dbo].[ObtenerSumaVentasPorDia]    Script Date: 26/05/2023 03:12:36 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ObtenerSumaVentasPorDia]
    @FechaVenta DATE
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    DECLARE @SumaVentas DECIMAL(18, 2);

    SET @SumaVentas = (SELECT SUM(SXN.amount*NP.price)
    FROM SalesXNewProducts SXN
	INNER JOIN Sales ON Sales.saleId = SXN.saleId
	INNER JOIN NewProducts NP ON NP.newProductId = SXN.newProductId
    WHERE @FechaVenta = CONVERT(date,Sales.postime))

    COMMIT;

    SELECT @SumaVentas AS SumaVentas;
END
