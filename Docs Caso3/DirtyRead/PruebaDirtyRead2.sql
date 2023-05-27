DECLARE @tablita tLoteInfo
INSERT INTO @tablita VALUES
					(1,100)
					

exec dbo.SP_ActualizarLotesParaDirtyRead @tablita

select * from Lots