-----------------------------------------------------------
-- Author: Joctan Porras Esquivel y Keren Fuentes Guevara
-- Fecha: 2023/05/25
-- Desc: 
-----------------------------------------------------------
/*
 correccion dirtyRead:
La solucion para este estado de DIRTYREAD es
cambiar el uso de Cursores por una actualizacion 
usando el tvp, realizar el read committed para evitar que lea valores erroneos

*/
GO
CREATE PROCEDURE [dbo].[SP_ActualizarLotesParaDirtyReadCorregido]
	@lotes TLoteInfo READONLY
AS 
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	DECLARE @CantiActual INT -- Variable creada debido


	SET @InicieTransaccion = 0
	IF @@TRANCOUNT = 0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 53001

			
			UPDATE L
			SET L.productQuantity = UL.amount+L.productQuantity
			FROM Lots L
			INNER JOIN @lotes UL ON L.lotId = UL.lotId;
		

		IF @InicieTransaccion = 1 BEGIN
			COMMIT
		END
	END TRY
	BEGIN CATCH
		SET @ErrorNumber = ERROR_NUMBER()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		SET @Message = ERROR_MESSAGE()
		
		IF @InicieTransaccion = 1 BEGIN
			ROLLBACK
		END
		RAISERROR('%s - Error Number: %i', 
			@ErrorSeverity, @ErrorState, @Message, @CustomError)
	END CATCH	
END
RETURN 0
GO
