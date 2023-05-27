use EsencialVerde

CREATE TABLE #TempLog (
    LogID INT IDENTITY(1,1),
    LogMessage VARCHAR(MAX)
) 

-- Insertar los registros de la tabla "binnacle" en la tabla temporal
INSERT INTO #TempLog (LogMessage)
SELECT *
FROM EsencialVerde.dbo.binnacle b

-- Insertar los registros de la tabla temporal en la tabla "binnacle" en la base de datos gemela a través del Linked Server
INSERT INTO LINKEDSERVER.EsencialVerde.dbo.binnacle (description)
SELECT LogMessage
FROM #TempLog;

-- Eliminar los registros transferidos de la tabla "binnacle" en la base de datos "EsencialVerde"
DELETE FROM EsencialVerde.dbo.binnacle
WHERE binnacleId IN (
    SELECT LogID
    FROM #TempLog
);

-- Eliminar la tabla temporal
DROP TABLE #TempLog;

