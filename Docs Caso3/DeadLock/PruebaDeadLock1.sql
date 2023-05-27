USE EsencialVerde
DECLARE @tablita TLoteInfo
INSERT INTO @tablita VALUES
					(1,100),
					(2,300)

exec dbo.SP_ActualizarLotes @tablita

select * from Lots
