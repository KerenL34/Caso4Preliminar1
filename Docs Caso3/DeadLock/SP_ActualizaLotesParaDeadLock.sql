
-----------------------------------------------------------
-- Author: Joctan Porras Esquivel y Keren Fuentes Guevara
-- Fecha: 2023/05/25
-- Desc: 
-----------------------------------------------------------
	USE EsencialVerde

	CREATE TYPE TLoteInfo AS TABLE
	(
		lotId INT,
		amount INT
	)

	/*
	En el supuesto de que se ejecuten dos transancciones de forma simultanea
	se produce el problema del deadlock ya que, se recibe un TVP el cual se recorrerá
	mediante un cursor y donde se necesita hacer el update se bloquea el campo
	que se va a actualizar, de modo que si se da un caso como el siguiente
T1
DECLARE @tablita TLoteInfo
INSERT INTO @tablita VALUES
					(1,100),
					(2,300)

T2
DECLARE @tablita TLoteInfo
INSERT INTO @tablita VALUES
					(2,100),
					(1,300)

En este caso al recibir las transacciones T1 y T2 
se requieren actualizar los elementos con indices 1 y 2 
por lo cual en el T1 se hace el bloqueo del recurso con el Id 1
y por su parte en T2 se bloquea el recurso con Id  2.
Luego cuando se necesita en la T1 hacer el bloqueo del recurso con Id 2
este ya esta ocupado por la T2 y lo mismo sucede con T2
asi que entran en deadlock.
	*/
	DROP PROCEDURE IF EXISTS dbo.SP_ActualizarLotes 
	GO
	CREATE PROCEDURE [dbo].[SP_ActualizarLotes]
		@lotes TLoteInfo READONLY
	AS 
	BEGIN
		SET NOCOUNT ON; 
	
		DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
		DECLARE @Message VARCHAR(200)
		DECLARE @InicieTransaccion BIT

		DECLARE @loteNum INT, @cantiNueva INT
		DECLARE cursor_lotes CURSOR FOR
		SELECT * FROM @lotes



		SET @InicieTransaccion = 0
		IF @@TRANCOUNT = 0 BEGIN
			SET @InicieTransaccion = 1
			SET TRANSACTION ISOLATION LEVEL READ COMMITTED
			BEGIN TRANSACTION		
		END
	
		BEGIN TRY
			SET @CustomError = 53001

			OPEN cursor_lotes


			FETCH NEXT FROM cursor_lotes INTO @loteNum, @cantiNueva 


			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				UPDATE Lots
				SET productQuantity = productQuantity + @cantiNueva
				WHERE lotId = @loteNum
				WAITFOR DELAY '00:00:10'
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
	GO
