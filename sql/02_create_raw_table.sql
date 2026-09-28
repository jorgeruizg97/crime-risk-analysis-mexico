-- =====================================================
-- Project: Crime Risk Analysis Mexico
-- Purpose: Create raw SESNSP municipal crime table
-- Source: SESNSP Open Data
-- =====================================================

USE CrimeRiskMexico;
GO

CREATE TABLE raw_delitos_municipales (
    anio INT,
    clave_entidad INT,
    entidad NVARCHAR(100),
    clave_municipio INT,
    municipio NVARCHAR(150),
    bien_juridico NVARCHAR(200),
    tipo_delito NVARCHAR(200),
    subtipo_delito NVARCHAR(200),
    modalidad NVARCHAR(300),

    enero INT,
    febrero INT,
    marzo INT,
    abril INT,
    mayo INT,
    junio INT,
    julio INT,
    agosto INT,
    septiembre INT,
    octubre INT,
    noviembre INT,
    diciembre INT
);
GO

-- =====================================================
-- Load raw CSV
--
-- FORMAT = 'CSV' and FIELDQUOTE = '"' are required
-- because some text fields contain commas inside quotes.
-- CODEPAGE = '1252' preserves Spanish characters.
-- =====================================================

BULK INSERT raw_delitos_municipales
FROM 'C:\Users\jorge\OneDrive\Escritorio\crime-risk-analysis-mexico\data\raw\Municipal-Delitos-2015-2025_ago2026.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '1252',
    TABLOCK
);
GO

-- =====================================================
-- Basic validation
-- =====================================================

SELECT COUNT(*) AS total_rows
FROM raw_delitos_municipales;

SELECT
    MIN(anio) AS min_year,
    MAX(anio) AS max_year,
    COUNT(DISTINCT entidad) AS total_entities
FROM raw_delitos_municipales;