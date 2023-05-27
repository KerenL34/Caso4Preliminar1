-----------------------------------------------------------
-- Author: Joctan Porras Esquivel
-- Fecha: 2023/05/25
-- Desc: 
-----------------------------------------------------------


/*
La solucion para el phantom es utilizar un REPEATABLE READ ya que este no permite que las filas
leídas por una transacción están bloqueadas para que otras 
transacciones no puedan modificarlas hasta que se complete la transacción actual.
*/
CREATE PROCEDURE [dbo].[ObtenerSumaVentasPorDiaCorregido ]
    @FechaVenta DATE
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	
	DECLARE @SumaVentas DECIMAL(18, 2);
	DECLARE @Precio Money
	

	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
		BEGIN TRANSACTION
	END

	BEGIN TRY
		SET @CustomError = 53001


		SET @SumaVentas = (SELECT SUM(SXN.amount*NP.price)
		FROM SalesXNewProducts SXN
		INNER JOIN Sales ON Sales.saleId = SXN.saleId
		INNER JOIN NewProducts NP ON NP.newProductId = SXN.newProductId
		WHERE @FechaVenta = CONVERT(date,Sales.postime))

		set @Precio = (SELECT price From NewProducts
						WHERE newProductId = 1)
		PRINT @Precio


		PRINT 'PRIMER VALOR ==> ' + CONVERT(varchar,@SumaVentas)
		WAITFOR DELAY '00:00:05'

		SET @SumaVentas = (SELECT SUM(SXN.amount*NP.price)
		FROM SalesXNewProducts SXN
		INNER JOIN Sales ON Sales.saleId = SXN.saleId
		INNER JOIN NewProducts NP ON NP.newProductId = SXN.newProductId
		WHERE @FechaVenta = CONVERT(date,Sales.postime))

		set @Precio = (SELECT price From NewProducts
						WHERE newProductId = 1)
		PRINT @Precio
		PRINT 'SEGUNDO VALOR ==> ' + CONVERT(varchar,@SumaVentas)

		SELECT @SumaVentas AS SumaVentas;

		IF @InicieTransaccion=1 BEGIN
			COMMIT
		END
	END TRY
	BEGIN CATCH
		SET @ErrorNumber = ERROR_NUMBER()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		SET @Message = ERROR_MESSAGE()

		IF @InicieTransaccion=1 BEGIN
			ROLLBACK
		END
		RAISERROR('%s - Error Number: %i',
			@ErrorSeverity, @ErrorState, @Message, @CustomError)
	END CATCH
END
RETURN 0