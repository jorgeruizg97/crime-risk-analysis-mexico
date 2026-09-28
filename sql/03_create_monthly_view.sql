
-- =====================================================
-- Project: Crime Risk Analysis Mexico
-- Purpose: Transform monthly columns into rows
-- =====================================================

USE CrimeRiskMexico;
GO

CREATE VIEW vw_delitos_mensuales AS

SELECT
    d.anio,
    d.clave_entidad,
    d.entidad,
    d.clave_municipio,
    d.municipio,
    d.bien_juridico,
    d.tipo_delito,
    d.subtipo_delito,
    d.modalidad,

    DATEFROMPARTS(
        d.anio,
        m.numero_mes,
        1
    ) AS fecha,

    m.numero_mes,
    m.mes,

    CASE
        WHEN m.cantidad_delitos < 0 THEN NULL
        ELSE m.cantidad_delitos
    END AS cantidad_delitos

FROM raw_delitos_municipales AS d

CROSS APPLY (
    VALUES
        ('enero', 1, d.enero),
        ('febrero', 2, d.febrero),
        ('marzo', 3, d.marzo),
        ('abril', 4, d.abril),
        ('mayo', 5, d.mayo),
        ('junio', 6, d.junio),
        ('julio', 7, d.julio),
        ('agosto', 8, d.agosto),
        ('septiembre', 9, d.septiembre),
        ('octubre', 10, d.octubre),
        ('noviembre', 11, d.noviembre),
        ('diciembre', 12, d.diciembre)
) AS m(
    mes,
    numero_mes,
    cantidad_delitos
);
GO


-- =====================================================
-- Data quality validation
-- =====================================================

-- Check for remaining negative values

SELECT COUNT(*) AS valores_negativos
FROM vw_delitos_mensuales
WHERE cantidad_delitos < 0;


-- Count NULL values

SELECT COUNT(*) AS valores_nulos
FROM vw_delitos_mensuales
WHERE cantidad_delitos IS NULL;


-- Inspect transformed records

SELECT TOP 20 *
FROM vw_delitos_mensuales
ORDER BY anio, clave_municipio, fecha;
