-- =====================================================
-- Project: Crime Risk Analysis Mexico
-- Purpose: Create analytical view for automobile theft
-- =====================================================

USE CrimeRiskMexico;
GO

CREATE VIEW vw_riesgo_automotriz AS

SELECT
    clave_entidad,
    entidad,
    clave_municipio,
    municipio,
    anio,
    numero_mes,
    mes,
    fecha,

    SUM(
        CASE
            WHEN modalidad = N'Robo de coche de 4 ruedas Con violencia'
            THEN cantidad_delitos
            ELSE 0
        END
    ) AS robos_con_violencia,

    SUM(
        CASE
            WHEN modalidad = N'Robo de coche de 4 ruedas Sin violencia'
            THEN cantidad_delitos
            ELSE 0
        END
    ) AS robos_sin_violencia,

    SUM(cantidad_delitos) AS robos_totales

FROM vw_delitos_mensuales

WHERE subtipo_delito = N'Robo de vehículo automotor'
  AND modalidad IN (
      N'Robo de coche de 4 ruedas Con violencia',
      N'Robo de coche de 4 ruedas Sin violencia'
  )

GROUP BY
    clave_entidad,
    entidad,
    clave_municipio,
    municipio,
    anio,
    numero_mes,
    mes,
    fecha;
GO

-- =====================================================
-- Data quality validation
-- =====================================================

-- Total rows and date range

SELECT
    COUNT(*) AS total_rows,
    MIN(fecha) AS min_date,
    MAX(fecha) AS max_date
FROM vw_riesgo_automotriz;


-- Validate that total thefts equal
-- violent + non-violent thefts

SELECT COUNT(*) AS inconsistencias
FROM vw_riesgo_automotriz
WHERE robos_totales <>
      robos_con_violencia + robos_sin_violencia;


-- Inspect sample records

SELECT TOP 20 *
FROM vw_riesgo_automotriz
ORDER BY fecha, clave_municipio;