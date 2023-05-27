-----------------------------------------------------------
-- Author: Joctan Porras Esquivel y Keren Fuentes Guevara
-- Fecha: 2023/05/25
-- Desc: 
-----------------------------------------------------------
/*
Solución:
Se agregara un if antes de cada actualizacion para validar 
que existan los productos suficientes asi si 
la venta no se puede realizar lo sabremos antes de
realizar los cambios y se hará un rollback en caso
de que no hayan suficientes articulos
*/


CREATE PROCEDURE dbo.SP_AgregarSalePruebaLostUpdateCorregido
	@venta tVenta READONLY,
	@buyerName varchar(64),
	@buyerLastName varchar(64),
	@buyerPhone varchar(15),
	@employeeName varchar(64),
	@employeeLastName varchar(64)
AS 
BEGIN
	
	SET NOCOUNT ON -- no retorne metadatos
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT, @CustomError2 INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT

	-- declaracion de otras variables
	DECLARE @contacInfoId int = (select ContacInfo.contacInfoId FROM ContacInfo
								 WHERE ContacInfo.name = @employeeName AND
								       ContacInfo.lastname = @employeeLastName )
	DECLARE @ventaConId tVentaConId
	INSERT INTO @ventaConId(productId, amount,lotId)
					  SELECT (select newProductId FROM NewProducts
					  WHERE name = productName AND NewProducts.lotId = ventita.lotId ), amount, lotId
					  FROM @venta ventita

	-- Declarar variables necesarias
	DECLARE @variable1 INT
	DECLARE @variable2 INT
	DECLARE @ErrorMessage VARCHAR(200) = 'Se está intentando vender un producto sin existencias -- Producto: '
			
	-- Declarar el cursor
	DECLARE cursor_cantidades CURSOR FOR
	SELECT  amount, lotId
	FROM @ventaConId
	

	-- operaciones de select que no tengan que ser bloqueadas
	-- tratar de hacer todo lo posible antes de q inice la transaccion
	
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
		IF @buyerLastName IS NOT NULL AND @buyerName IS NOT NULL
		   AND @contacInfoId IS NOT NULL
		   BEGIN

		   IF EXISTS(SELECT productQuantity FROM Lots 
		   INNER JOIN @ventaConId ventita ON Lots.lotId = ventita.lotId
		   WHERE (productQuantity-ventita.amount) < 0)
					BEGIN
						SET @ErrorMessage = CONCAT('Se está intentando vender un producto sin existencias -- Producto: ',
											(SELECT STRING_AGG(ventita2.productName + ' -- lote: '+CONVERT(varchar,ventita2.lotId) , ', ') AS ConcatenatedValues
											FROM Lots 
											INNER JOIN @ventaConId ventita ON Lots.lotId = ventita.lotId
											INNER JOIN @venta ventita2 ON Lots.lotId = ventita2.lotId
											WHERE (productQuantity-ventita.amount) < 0))
						RAISERROR('%s - Error Number: %i', 
						17, 17, 
						 @ErrorMessage,
						 @CustomError2)
		   END

		  
				
				WAITFOR DELAY '00:00:10';
				INSERT INTO Sales(buyerName, buyerLastName, buyerPhone,
								  contacInfoId, postime,deleted) VALUES
							(@buyerName,@buyerLastName,@buyerPhone,
							 @contacInfoId, GETDATE(),0)

				INSERT INTO SalesXNewProducts(newProductId, amount, deleted, saleId)
							SELECT productId, amount, 0, SCOPE_IDENTITY() FROM @ventaConId
				OPEN cursor_cantidades

				-- Recuperar el primer registro del cursor
				FETCH NEXT FROM cursor_cantidades INTO @variable1, @variable2

				-- Iniciar el bucle de procesamiento de los registros del cursor
				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- Lógica de procesamiento del registro actual

			IF EXISTS(SELECT productQuantity FROM Lots
		   INNER JOIN @ventaConId ventita ON Lots.lotId = ventita.lotId
		   WHERE (productQuantity-ventita.amount) < 0)
					BEGIN
						SET @ErrorMessage = CONCAT('Se está intentando vender un producto sin existencias -- Producto: ',
											(SELECT STRING_AGG(ventita2.productName + ' -- lote: '+CONVERT(varchar,ventita2.lotId) , ', ') AS ConcatenatedValues
											FROM Lots 
											INNER JOIN @ventaConId ventita ON Lots.lotId = ventita.lotId
											INNER JOIN @venta ventita2 ON Lots.lotId = ventita2.lotId
											WHERE (productQuantity-ventita.amount) < 0))
						RAISERROR('%s - Error Number: %i', 
						17, 17, 
						 @ErrorMessage,
						 @CustomError2)
		   END

					UPDATE Lots
					SET productQuantity = Lots.productQuantity - @variable1
					WHERE Lots.lotId = @variable2
					

					-- Recuperar el siguiente registro del cursor
					FETCH NEXT FROM cursor_cantidades INTO @variable1, @variable2
				END

				-- Cerrar el cursor
				CLOSE cursor_cantidades
				

				
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
