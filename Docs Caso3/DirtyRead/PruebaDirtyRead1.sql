DECLARE @ventita tVenta

INSERT INTO @ventita(productName, amount,lotId) VALUES
					('Cuaderno',15,1),
					('Cuaderno',0,1),
					('Cuaderno',4,1)

exec dbo.SP_AgregarSalePruebaDirtyRead @ventita,'Miguel','Ternera','1234-5964', 'José','Martínez'
SELECT * FROM Sales