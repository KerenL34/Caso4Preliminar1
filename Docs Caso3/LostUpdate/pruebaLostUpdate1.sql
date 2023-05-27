DECLARE @ventita tVenta

INSERT INTO @ventita(productName, amount,lotId) VALUES
					('Cuaderno',15,1),
					('Cuaderno',2,1),
					('Cuaderno',4,1)

exec dbo.SP_AgregarSalePruebaLostUpdate @ventita,'Miguel','Ternera','1234-5964', 'José','Martínez'

UPDATE Lots
SET productQuantity = 50000
WHERE lotId = 1

select * from Lots