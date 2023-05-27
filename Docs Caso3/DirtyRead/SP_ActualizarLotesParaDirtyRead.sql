-----------------------------------------------------------
-- Author: Joctan Porras Esquivel y Keren Fuentes Guevara
-- Fecha: 2023/05/25
-- Desc: 
-----------------------------------------------------------

/*
En el caso de este SP el error es hacer el READ UNCOMMITTED el va a leer un valor
que no se ha comiteado en la otra transaccion 
Se podria hacer más eficiente usando una operacion de update con un tvp 
*/
GO
CREATE PROCEDURE [dbo].[SP_ActualizarLotesParaDirtyRead]
	@lotes TLoteInfo READONLY
AS 
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	DECLARE @CantiActual INT -- Variable creada debido


	DECLARE @loteNum INT, @cantiNueva INT
	DECLARE cursor_lotes CURSOR FOR
	SELECT * FROM @lotes



	SET @InicieTransaccion = 0
	IF @@TRANCOUNT = 0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 53001

		OPEN cursor_lotes


		FETCH NEXT FROM cursor_lotes INTO @loteNum, @cantiNueva 


		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @CantiActual = (Select productQuantity FROM Lots 
								WHERE lotId = @loteNum)
			PRINT @CantiActual 
			UPDATE Lots
			SET productQuantity = @CantiActual + @cantiNueva
			WHERE lotId = @loteNum
			
			FETCH NEXT FROM cursor_lotes INTO @loteNum,@cantiNueva
		END

		CLOSE cursor_lotes

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
