Use EsencialVerde
DECLARE @tablita tLoteInfo
INSERT INTO @tablita VALUES
					(1,100)
					

exec dbo.SP_ActualizarLotesParaDirtyReadCorregido @tablita

select * from Lots