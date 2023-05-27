-----------------------------------------------------------
-- Author: Joctan Porras Esquivel
-- Fecha: 2023/05/25
-- Desc: 
-----------------------------------------------------------


/*
El supuesto es que un programador tenia que hacer un procedimiento que buscara la cantidad de dinero ganada 
en un dia especifico , el programador usó el nivel de isolacion READ COMMITED ya que es el que le venia 
dando resultados hasta ahora, sin embargo le habian comentado que podian darse problemas de phantom
cuano hacian lecuturas ya que se podia hacer cambios a los datos mientras la transaccion esta
corriendo.
Asi que el dijo que una solucion que podia poner es duplicar las soluciones para quedarse con la ultima
sin embargo aun con el READ COMMITED se le filtro el phantom ya que perfectamente el phantom puede
entrar entre una lectura y la otra ya que un select no hace bloqueos.
*/
CREATE PROCEDURE [dbo].[ObtenerSumaVentasPorDia]
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
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED --REPEATABLE READ--
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