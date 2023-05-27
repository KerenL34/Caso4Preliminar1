-----------------------------------------------------------
-- Author: Joctan Esquivel y Keren Fuentes
-- Fecha: 2023-05-26
-- Desc: 
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[SP_ActualizarPreciosProductos]
	@NombreProducto VARCHAR(64),
	@lote INT,
	@newPrice money

AS
BEGIN

	SET NOCOUNT ON 

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT

	DECLARE @ProductoId INT = (SELECT newProductId FROM NewProducts
							   WHERE lotId = @lote AND @NombreProducto = name)
	


	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION
	END

	BEGIN TRY
		SET @CustomError = 2001

		UPDATE NewProducts
		SET price = @newPrice
		WHERE newProductId = @ProductoId

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
GO