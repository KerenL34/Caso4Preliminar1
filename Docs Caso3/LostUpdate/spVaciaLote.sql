-----------------------------------------------------------
-- Author: Joctan Porras Esquivel y Keren Fuentes Guevara 
-- Fecha: 2023-05-15
-- Desc: Se encarga de sacar de circulacicion los productos de un lote
--       Si por alguna razon de defectos el lote resulta dañado
-----------------------------------------------------------

ALTER PROCEDURE [dbo].[SP_Vacia_lote]
	@lotId int
AS 
BEGIN
    SET NOCOUNT ON 

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT, @CustomError2 INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT


	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION		
	END

	BEGIN TRY
		SET @CustomError = 53001
		SET @CustomError = 53002

		-- put your code here
		IF @lotId IS NOT NULL

		   BEGIN
				
				UPDATE Lots 
				SET Lots.productQuantity = 0
				WHERE Lots.lotId = @lotId
				

			
			END
		ELSE
			BEGIN	
				RAISERROR('%s - Error Number: %i', 
						17, 11, 'Se está intentando insertar un valor NULL en un campo requerido', @CustomError)
			END

		
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