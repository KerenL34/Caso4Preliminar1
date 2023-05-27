
-----------------------------------------------------------
-- Author: 
-- Fecha: 
-- Desc: 
-----------------------------------------------------------
USE EsencialVerde
CREATE PROCEDURE [dbo].[SP_ObtenerCountries]

AS
BEGIN

    SET NOCOUNT ON -- no retorne metadatos

    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
    DECLARE @Message VARCHAR(200)
    DECLARE @InicieTransaccion BIT


    SET @InicieTransaccion = 0
    IF @@TRANCOUNT=0 BEGIN
        SET @InicieTransaccion = 1
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED
        BEGIN TRANSACTION
    END

    BEGIN TRY
        SET @CustomError = 2001

        SELECT countryId, name 
		FROM Countries 


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