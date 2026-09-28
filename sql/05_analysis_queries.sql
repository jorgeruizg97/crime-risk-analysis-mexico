-- =====================================================
-- Project: Crime Risk Analysis Mexico
-- Purpose: Exploratory and analytical SQL queries
-- =====================================================

USE CrimeRiskMexico;
GO

-- =====================================================
-- 1. Historical monthly average of registered crimes
--    by municipality
-- =====================================================

WITH delitos_mensuales AS (
    SELECT
        clave_entidad,
        entidad,
        clave_municipio,
        municipio,
        fecha,
        SUM(cantidad_delitos) AS total_delitos_mes
    FROM vw_delitos_mensuales
    GROUP BY
        clave_entidad,
        entidad,
        clave_municipio,
        municipio,
        fecha
)

SELECT
    clave_entidad,
    entidad,
    clave_municipio,
    municipio,
    AVG(CAST(total_delitos_mes AS DECIMAL(18,2))) AS promedio_mensual
FROM delitos_mensuales
GROUP BY
    clave_entidad,
    entidad,
    clave_municipio,
    municipio
ORDER BY promedio_mensual DESC;

-- =====================================================
-- 2. Most frequently registered crime type
--    by municipality
-- =====================================================

WITH delitos_por_tipo AS (
    SELECT
        clave_entidad,
        entidad,
        clave_municipio,
        municipio,
        tipo_delito,
        SUM(cantidad_delitos) AS total_delitos
    FROM vw_delitos_mensuales
    GROUP BY
        clave_entidad,
        entidad,
        clave_municipio,
        municipio,
        tipo_delito
),

ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY clave_entidad, clave_municipio
            ORDER BY total_delitos DESC
        ) AS posicion
    FROM delitos_por_tipo
)

SELECT
    entidad,
    municipio,
    tipo_delito,
    total_delitos
FROM ranking
WHERE posicion = 1
ORDER BY total_delitos DESC;

-- =====================================================
-- 3. Average registered crimes by season
-- =====================================================

WITH delitos_por_mes AS (
    SELECT
        fecha,

        CASE
            WHEN numero_mes IN (12, 1, 2) THEN 'Invierno'
            WHEN numero_mes IN (3, 4, 5) THEN 'Primavera'
            WHEN numero_mes IN (6, 7, 8) THEN 'Verano'
            WHEN numero_mes IN (9, 10, 11) THEN 'Otono'
        END AS estacion,

        SUM(cantidad_delitos) AS total_delitos

    FROM vw_delitos_mensuales

    GROUP BY
        fecha,
        numero_mes
)

SELECT
    estacion,
    AVG(CAST(total_delitos AS DECIMAL(18,2))) AS promedio_mensual_delitos
FROM delitos_por_mes
GROUP BY estacion
ORDER BY promedio_mensual_delitos DESC;

-- =====================================================
-- 4. Monthly crime analysis by type in Mexico City
-- =====================================================

SELECT
    fecha,
    tipo_delito,
    SUM(cantidad_delitos) AS total_delitos
FROM vw_delitos_mensuales
WHERE entidad = N'Ciudad de México'
GROUP BY
    fecha,
    tipo_delito
ORDER BY
    fecha,
    total_delitos DESC;

    -- =====================================================
-- 5. Annual automobile theft evolution and YoY change
-- =====================================================

WITH robos_anuales AS (
    SELECT
        clave_entidad,
        entidad,
        clave_municipio,
        municipio,
        anio,
        SUM(robos_totales) AS robos_totales
    FROM vw_riesgo_automotriz
    GROUP BY
        clave_entidad,
        entidad,
        clave_municipio,
        municipio,
        anio
),

comparacion AS (
    SELECT
        *,
        LAG(robos_totales) OVER (
            PARTITION BY clave_entidad, clave_municipio
            ORDER BY anio
        ) AS robos_anio_anterior
    FROM robos_anuales
)

SELECT
    entidad,
    municipio,
    anio,
    robos_totales,
    robos_anio_anterior,

    robos_totales - robos_anio_anterior AS cambio_absoluto,

    CAST(
        100.0 * (robos_totales - robos_anio_anterior)
        / NULLIF(robos_anio_anterior, 0)
        AS DECIMAL(10,2)
    ) AS variacion_yoy_pct

FROM comparacion
ORDER BY
    clave_entidad,
    clave_municipio,
    anio;