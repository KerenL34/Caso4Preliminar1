USE EsencialVerde
DECLARE @tablita tLoteInfo
INSERT INTO @tablita VALUES
					(2,100),
					(1,300)

exec dbo.SP_ActualizarLotesDeadlockCorregido @tablita

select * from Lots