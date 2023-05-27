USE EsencialVerde
SELECT *
FROM sys.objects
WHERE type = 'P'


DECLARE @Instrucciones NVARCHAR(max) = ''
SELECT @Instrucciones = @Instrucciones + 'EXEC sp_recompile ' + QUOTENAME(name) + ';' + CHAR(13) + CHAR(10)
FROM sys.objects
WHERE type = 'P';
EXECUTE sp_executesql @Instrucciones
PRINT @Instrucciones
SELECT object_id AS StoredProcedureName,
       last_execution_time AS LastExecutionTime
FROM sys.dm_exec_procedure_stats
WHERE object_id = 1666104976;



SELECT *
FROM sys.objects
WHERE type = 'P'
    AND name = 'SP_AgregarSale'

SELECT name AS StoredProcedureName,
       create_date AS LastCompilationTime
FROM sys.objects
WHERE type = 'P'
    AND name = 'SP_AgregarSale'

SELECT *
FROM sys.dm_exec_procedure_stats
WHERE object_id = 1666104976;

