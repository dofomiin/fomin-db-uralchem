USE uralchem_db;

CREATE TABLE production_sites (
    site_id INT AUTO_INCREMENT PRIMARY KEY,
    site_code VARCHAR(10) NOT NULL,
    site_name VARCHAR(100) NOT NULL,
    object_type VARCHAR(50) NOT NULL,
    region VARCHAR(100) NOT NULL,
    iso14001 BOOLEAN NOT NULL,

    CONSTRAINT uq_production_sites_code
        UNIQUE (site_code),

    CONSTRAINT uq_production_sites_name
        UNIQUE (site_name)
);

CREATE TABLE indicator_types (
    indicator_type_id INT AUTO_INCREMENT PRIMARY KEY,
    indicator_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    unit_measure VARCHAR(50) NOT NULL,

    CONSTRAINT uq_indicator_types_name
        UNIQUE (indicator_name)
);

CREATE TABLE waste_types (
    waste_type_id INT AUTO_INCREMENT PRIMARY KEY,
    waste_name VARCHAR(150) NOT NULL,
    unit_measure VARCHAR(50) NOT NULL,

    CONSTRAINT uq_waste_types_name
        UNIQUE (waste_name)
);

CREATE TABLE ghg_indicator_types (
    ghg_indicator_type_id INT AUTO_INCREMENT PRIMARY KEY,
    indicator_name VARCHAR(150) NOT NULL,
    unit_measure VARCHAR(50) NOT NULL,

    CONSTRAINT uq_ghg_indicator_types_name
        UNIQUE (indicator_name)
);

CREATE TABLE environmental_values (
    environmental_value_id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT NOT NULL,
    report_year INT NOT NULL,
    indicator_type_id INT NOT NULL,
    indicator_value DECIMAL(15,2) NOT NULL,
    data_source VARCHAR(255) NOT NULL,

    CONSTRAINT uq_environmental_values
        UNIQUE (site_id, report_year, indicator_type_id),

    CONSTRAINT fk_environmental_values_site
        FOREIGN KEY (site_id)
        REFERENCES production_sites(site_id),

    CONSTRAINT fk_environmental_values_indicator
        FOREIGN KEY (indicator_type_id)
        REFERENCES indicator_types(indicator_type_id)
);

CREATE TABLE waste_records (
    waste_record_id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT NOT NULL,
    report_year INT NOT NULL,
    waste_type_id INT NOT NULL,
    generated_volume DECIMAL(15,2) NOT NULL DEFAULT 0,
    accumulated_volume DECIMAL(15,2) NOT NULL DEFAULT 0,
    data_source VARCHAR(255) NOT NULL,

    CONSTRAINT uq_waste_records
        UNIQUE (site_id, report_year, waste_type_id),

    CONSTRAINT fk_waste_records_site
        FOREIGN KEY (site_id)
        REFERENCES production_sites(site_id),

    CONSTRAINT fk_waste_records_waste_type
        FOREIGN KEY (waste_type_id)
        REFERENCES waste_types(waste_type_id)
);

CREATE TABLE waste_movements (
    waste_movement_id INT AUTO_INCREMENT PRIMARY KEY,
    waste_record_id INT NOT NULL,
    handling_method VARCHAR(50) NOT NULL,
    transferred_volume DECIMAL(15,2) NOT NULL DEFAULT 0,

    CONSTRAINT uq_waste_movements
        UNIQUE (waste_record_id, handling_method),

    CONSTRAINT fk_waste_movements_waste_record
        FOREIGN KEY (waste_record_id)
        REFERENCES waste_records(waste_record_id)
);

CREATE TABLE water_records (
    water_record_id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT NOT NULL,
    report_year INT NOT NULL,
    water_intake DECIMAL(15,2) NOT NULL DEFAULT 0,
    water_used DECIMAL(15,2) NOT NULL DEFAULT 0,
    wastewater_volume DECIMAL(15,2) NOT NULL DEFAULT 0,
    data_source VARCHAR(255) NOT NULL,

    CONSTRAINT uq_water_records
        UNIQUE (site_id, report_year),

    CONSTRAINT fk_water_records_site
        FOREIGN KEY (site_id)
        REFERENCES production_sites(site_id)
);

CREATE TABLE water_quality_values (
    water_quality_value_id INT AUTO_INCREMENT PRIMARY KEY,
    water_record_id INT NOT NULL,
    indicator_type_id INT NOT NULL,
    indicator_value DECIMAL(15,2) NOT NULL,

    CONSTRAINT uq_water_quality_values
        UNIQUE (water_record_id, indicator_type_id),

    CONSTRAINT fk_water_quality_water_record
        FOREIGN KEY (water_record_id)
        REFERENCES water_records(water_record_id),

    CONSTRAINT fk_water_quality_indicator
        FOREIGN KEY (indicator_type_id)
        REFERENCES indicator_types(indicator_type_id)
);

CREATE TABLE climate_site_values (
    climate_site_value_id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT NOT NULL,
    report_year INT NOT NULL,
    ghg_indicator_type_id INT NOT NULL,
    indicator_value DECIMAL(15,2) NOT NULL,
    calculation_source VARCHAR(255) NOT NULL,

    CONSTRAINT uq_climate_site_values
        UNIQUE (site_id, report_year, ghg_indicator_type_id),

    CONSTRAINT fk_climate_site_site
        FOREIGN KEY (site_id)
        REFERENCES production_sites(site_id),

    CONSTRAINT fk_climate_site_ghg_type
        FOREIGN KEY (ghg_indicator_type_id)
        REFERENCES ghg_indicator_types(ghg_indicator_type_id)
);

CREATE TABLE climate_company_values (
    climate_company_value_id INT AUTO_INCREMENT PRIMARY KEY,
    report_year INT NOT NULL,
    ghg_indicator_type_id INT NOT NULL,
    indicator_value DECIMAL(15,2) NOT NULL,
    calculation_source VARCHAR(255) NOT NULL,

    CONSTRAINT uq_climate_company_values
        UNIQUE (report_year, ghg_indicator_type_id),

    CONSTRAINT fk_climate_company_ghg_type
        FOREIGN KEY (ghg_indicator_type_id)
        REFERENCES ghg_indicator_types(ghg_indicator_type_id)
);
USE uralchem_db;

SHOW TABLES;

ALTER TABLE environmental_values
MODIFY data_source VARCHAR(500) NOT NULL;

INSERT INTO production_sites
(site_code, site_name, object_type, region, iso14001)
VALUES
('PL-001', 'Azot', 'Branch', 'Perm Region, Berezniki', 1),
('PL-002', 'PMU', 'Branch', 'Perm Region, Perm', 1),
('PL-003', 'KCKK', 'Branch', 'Kirov Region, Kirovo-Chepetsk', 1),
('PL-004', 'VMU', 'Branch', 'Moscow Region, Voskresensk', 1),
('PL-005', 'GEO NPK', 'Enterprise', 'Kaliningrad Region, Chernyakhovsk', 1);

INSERT INTO indicator_types
(indicator_name, category, unit_measure)
VALUES
('Air pollutant emissions', 'Atmospheric air', 't'),
('Water intake', 'Water resources', 'thousand m3'),
('Water use', 'Water resources', 'thousand m3'),
('Wastewater volume', 'Water resources', 'thousand m3'),
('Energy consumption', 'Energy efficiency', 'MWh');

INSERT INTO waste_types
(waste_name, unit_measure)
VALUES
('Production waste class IV', 't'),
('Production waste class V', 't'),
('Waste sent for recycling', 't');

INSERT INTO ghg_indicator_types
(indicator_name, unit_measure)
VALUES
('Scope 1', 't CO2e'),
('Scope 2', 't CO2e'),
('Total GHG emissions', 't CO2e');

INSERT INTO environmental_values
(site_id, report_year, indicator_type_id, indicator_value, data_source)
VALUES
(1, 2025, 1, 1250.00, 'Environmental monitoring report'),
(2, 2025, 1, 980.00, 'Environmental monitoring report'),
(1, 2025, 5, 45000.00, 'Energy consumption report');

INSERT INTO waste_records
(site_id, report_year, waste_type_id,
 generated_volume, accumulated_volume, data_source)
VALUES
(1, 2025, 1, 520.00, 35.00, 'Waste movement log'),
(2, 2025, 2, 310.00, 20.00, 'Waste movement log');

INSERT INTO waste_movements
(waste_record_id, handling_method, transferred_volume)
VALUES
(1, 'Recycling', 400.00),
(1, 'Disposal', 85.00),
(2, 'Recycling', 250.00);

INSERT INTO water_records
(site_id, report_year, water_intake,
 water_used, wastewater_volume, data_source)
VALUES
(1, 2025, 1500.00, 1300.00, 900.00, 'Water use report'),
(2, 2025, 1200.00, 1050.00, 700.00, 'Water use report');

INSERT INTO water_quality_values
(water_record_id, indicator_type_id, indicator_value)
VALUES
(1, 4, 900.00),
(2, 4, 700.00);

INSERT INTO climate_site_values
(site_id, report_year, ghg_indicator_type_id,
 indicator_value, calculation_source)
VALUES
(1, 2025, 1, 250000.00, 'GHG calculation'),
(2, 2025, 1, 210000.00, 'GHG calculation'),
(1, 2025, 2, 95000.00, 'GHG calculation'),
(2, 2025, 2, 82000.00, 'GHG calculation');

INSERT INTO climate_company_values
(report_year, ghg_indicator_type_id,
 indicator_value, calculation_source)
VALUES
(2025, 1, 900000.00, 'Consolidated GHG calculation'),
(2025, 2, 300000.00, 'Consolidated GHG calculation'),
(2025, 3, 1200000.00, 'Consolidated GHG calculation');

UPDATE environmental_values
SET indicator_value = 1280.00
WHERE environmental_value_id = 1;

INSERT INTO indicator_types
(indicator_name, category, unit_measure)
VALUES
('Temporary indicator', 'Test', 'unit');

DELETE FROM indicator_types
WHERE indicator_name = 'Temporary indicator';

CREATE USER 'ecologist_user'@'localhost'
IDENTIFIED BY 'Eco_2026!Lab5';

CREATE USER 'esg_user'@'localhost'
IDENTIFIED BY 'ESG_2026!Lab5';

CREATE USER 'manager_user'@'localhost'
IDENTIFIED BY 'Manager_2026!Lab5';

GRANT SELECT, INSERT, UPDATE
ON uralchem_db.*
TO 'ecologist_user'@'localhost';

GRANT SELECT
ON uralchem_db.*
TO 'esg_user'@'localhost';

GRANT INSERT, UPDATE
ON uralchem_db.climate_site_values
TO 'esg_user'@'localhost';

GRANT INSERT, UPDATE
ON uralchem_db.climate_company_values
TO 'esg_user'@'localhost';

GRANT SELECT
ON uralchem_db.*
TO 'manager_user'@'localhost';

DESCRIBE production_sites;

DESCRIBE indicator_types;

DESCRIBE waste_types;

DESCRIBE ghg_indicator_types;

DESCRIBE environmental_values;

DESCRIBE waste_records;

DESCRIBE waste_movements;

DESCRIBE water_records;

DESCRIBE water_quality_values;

DESCRIBE climate_site_values;

DESCRIBE climate_company_values;
USE uralchem_db;

SELECT
    ps.site_name,
    ev.report_year,
    it.indicator_name,
    ev.indicator_value,
    it.unit_measure
FROM production_sites ps, environmental_values ev, indicator_types it
WHERE ps.site_id = ev.site_id
  AND it.indicator_type_id = ev.indicator_type_id
  AND ev.report_year = 2025
ORDER BY ev.indicator_value DESC;

SELECT
    ps.site_name,
    wr.report_year,
    wt.waste_name,
    wr.generated_volume,
    wr.accumulated_volume,
    wt.unit_measure
FROM waste_records wr
JOIN production_sites ps
    ON wr.site_id = ps.site_id
JOIN waste_types wt
    ON wr.waste_type_id = wt.waste_type_id
ORDER BY ps.site_name;

SELECT
    ps.site_name,
    csv.report_year,
    git.indicator_name,
    csv.indicator_value,
    git.unit_measure
FROM climate_site_values csv
JOIN production_sites ps
    ON csv.site_id = ps.site_id
JOIN ghg_indicator_types git
    ON csv.ghg_indicator_type_id = git.ghg_indicator_type_id
ORDER BY csv.indicator_value DESC;

SELECT
    SUM(generated_volume) AS total_generated_waste
FROM waste_records;

SELECT
    AVG(indicator_value) AS average_environmental_value
FROM environmental_values;

SELECT
    COUNT(*) AS number_of_environmental_records
FROM environmental_values;

SELECT
    MAX(water_intake) AS maximum_water_intake
FROM water_records;

SELECT
    MIN(water_intake) AS minimum_water_intake
FROM water_records;

SELECT
    ps.site_name,
    SUM(wr.generated_volume) AS total_generated_waste
FROM waste_records wr
JOIN production_sites ps
    ON wr.site_id = ps.site_id
GROUP BY ps.site_id, ps.site_name
ORDER BY total_generated_waste DESC;

SELECT
    ps.site_name,
    SUM(wr.generated_volume) AS total_generated_waste
FROM waste_records wr
JOIN production_sites ps
    ON wr.site_id = ps.site_id
GROUP BY ps.site_id, ps.site_name
HAVING SUM(wr.generated_volume) > 300
ORDER BY total_generated_waste DESC;

SELECT
    report_year,
    AVG(indicator_value) AS average_climate_value
FROM climate_site_values
GROUP BY report_year
ORDER BY report_year;

SELECT
    git.indicator_name,
    AVG(csv.indicator_value) AS average_value
FROM climate_site_values csv
JOIN ghg_indicator_types git
    ON csv.ghg_indicator_type_id = git.ghg_indicator_type_id
GROUP BY git.ghg_indicator_type_id, git.indicator_name
HAVING AVG(csv.indicator_value) > 100000
ORDER BY average_value DESC;

SELECT
    ps.site_name,
    COUNT(ev.environmental_value_id) AS records_count
FROM production_sites ps
LEFT JOIN environmental_values ev
    ON ps.site_id = ev.site_id
GROUP BY ps.site_id, ps.site_name
ORDER BY records_count DESC;

SELECT
    ps.site_name,
    SUM(csv.indicator_value) AS total_ghg_emissions
FROM climate_site_values csv
JOIN production_sites ps
    ON csv.site_id = ps.site_id
GROUP BY ps.site_id, ps.site_name
ORDER BY total_ghg_emissions DESC;

SELECT
    ps.site_name,
    wr.report_year,
    wr.water_intake,
    wr.water_used,
    wr.wastewater_volume
FROM water_records wr
JOIN production_sites ps
    ON wr.site_id = ps.site_id
WHERE wr.report_year = 2025
ORDER BY wr.water_intake DESC;

INSERT INTO environmental_values
(site_id, report_year, indicator_type_id, indicator_value, data_source)
VALUES
(1, 2023, 1, 1380.00, 'Environmental monitoring report'),
(1, 2024, 1, 1320.00, 'Environmental monitoring report'),
(2, 2023, 1, 1080.00, 'Environmental monitoring report'),
(2, 2024, 1, 1020.00, 'Environmental monitoring report'),
(3, 2023, 1, 890.00, 'Environmental monitoring report'),
(3, 2024, 1, 850.00, 'Environmental monitoring report'),
(3, 2025, 1, 810.00, 'Environmental monitoring report'),
(4, 2023, 1, 760.00, 'Environmental monitoring report'),
(4, 2024, 1, 720.00, 'Environmental monitoring report'),
(4, 2025, 1, 690.00, 'Environmental monitoring report'),
(5, 2023, 1, 640.00, 'Environmental monitoring report'),
(5, 2024, 1, 610.00, 'Environmental monitoring report'),
(5, 2025, 1, 580.00, 'Environmental monitoring report'),
(1, 2023, 5, 42000.00, 'Energy consumption report'),
(1, 2024, 5, 43500.00, 'Energy consumption report'),
(2, 2023, 5, 38000.00, 'Energy consumption report'),
(2, 2024, 5, 39500.00, 'Energy consumption report'),
(2, 2025, 5, 41000.00, 'Energy consumption report'),
(3, 2023, 5, 33000.00, 'Energy consumption report'),
(3, 2024, 5, 34000.00, 'Energy consumption report'),
(3, 2025, 5, 35000.00, 'Energy consumption report'),
(4, 2023, 5, 27000.00, 'Energy consumption report'),
(4, 2024, 5, 28000.00, 'Energy consumption report'),
(4, 2025, 5, 29000.00, 'Energy consumption report'),
(5, 2023, 5, 21000.00, 'Energy consumption report'),
(5, 2024, 5, 22000.00, 'Energy consumption report'),
(5, 2025, 5, 23000.00, 'Energy consumption report');

INSERT INTO water_records
(site_id, report_year, water_intake, water_used, wastewater_volume, data_source)
VALUES
(1, 2023, 1650.00, 1410.00, 980.00, 'Water use report'),
(1, 2024, 1580.00, 1360.00, 940.00, 'Water use report'),
(2, 2023, 1320.00, 1130.00, 760.00, 'Water use report'),
(2, 2024, 1260.00, 1090.00, 730.00, 'Water use report'),
(3, 2023, 1100.00, 950.00, 640.00, 'Water use report'),
(3, 2024, 1050.00, 920.00, 610.00, 'Water use report'),
(3, 2025, 1010.00, 890.00, 590.00, 'Water use report'),
(4, 2023, 900.00, 780.00, 520.00, 'Water use report'),
(4, 2024, 860.00, 750.00, 500.00, 'Water use report'),
(4, 2025, 830.00, 720.00, 480.00, 'Water use report'),
(5, 2023, 720.00, 620.00, 410.00, 'Water use report'),
(5, 2024, 690.00, 600.00, 390.00, 'Water use report'),
(5, 2025, 660.00, 580.00, 370.00, 'Water use report');

INSERT INTO waste_records
(site_id, report_year, waste_type_id, generated_volume, accumulated_volume, data_source)
VALUES
(1, 2023, 1, 590.00, 42.00, 'Waste movement log'),
(1, 2024, 1, 555.00, 39.00, 'Waste movement log'),
(2, 2023, 2, 350.00, 28.00, 'Waste movement log'),
(2, 2024, 2, 330.00, 24.00, 'Waste movement log'),
(3, 2023, 1, 440.00, 31.00, 'Waste movement log'),
(3, 2024, 1, 415.00, 27.00, 'Waste movement log'),
(3, 2025, 1, 390.00, 25.00, 'Waste movement log'),
(4, 2023, 2, 280.00, 21.00, 'Waste movement log'),
(4, 2024, 2, 265.00, 19.00, 'Waste movement log'),
(4, 2025, 2, 250.00, 17.00, 'Waste movement log'),
(5, 2023, 3, 200.00, 15.00, 'Waste movement log'),
(5, 2024, 3, 215.00, 13.00, 'Waste movement log'),
(5, 2025, 3, 230.00, 12.00, 'Waste movement log');

INSERT INTO climate_site_values
(site_id, report_year, ghg_indicator_type_id, indicator_value, calculation_source)
VALUES
(1, 2023, 1, 275000.00, 'GHG calculation'),
(1, 2024, 1, 262000.00, 'GHG calculation'),
(1, 2023, 2, 105000.00, 'GHG calculation'),
(1, 2024, 2, 100000.00, 'GHG calculation'),
(2, 2023, 1, 232000.00, 'GHG calculation'),
(2, 2024, 1, 221000.00, 'GHG calculation'),
(2, 2023, 2, 91000.00, 'GHG calculation'),
(2, 2024, 2, 87000.00, 'GHG calculation'),
(3, 2023, 1, 195000.00, 'GHG calculation'),
(3, 2024, 1, 185000.00, 'GHG calculation'),
(3, 2025, 1, 177000.00, 'GHG calculation'),
(4, 2023, 1, 155000.00, 'GHG calculation'),
(4, 2024, 1, 148000.00, 'GHG calculation'),
(4, 2025, 1, 141000.00, 'GHG calculation'),
(5, 2023, 1, 118000.00, 'GHG calculation'),
(5, 2024, 1, 112000.00, 'GHG calculation'),
(5, 2025, 1, 107000.00, 'GHG calculation');

SELECT environmental_value_id, site_id, indicator_value
FROM environmental_values
WHERE indicator_value > (
    SELECT AVG(indicator_value)
    FROM environmental_values
);

SELECT site_id, site_name
FROM production_sites
WHERE site_id IN (
    SELECT site_id 
FROM environmental_values 
WHERE report_year = 2025
AND indicator_value > 800 
);

SELECT site_id,site_name 
FROM production_sites
WHERE site_id IN (
 SELECT site_id
 FROM waste_records
 WHERE report_year = 2024 
 AND generated_volume > 300
);

SELECT site_name 
FROM production_sites
WHERE site_id IN (
    SELECT site_id
   FROM water_records
   WHERE water_intake > 800
   AND report_year = 2025
);

SELECT site_id, indicator_value
FROM climate_site_values 
WHERE indicator_value > ALL (
SELECT indicator_value
FROM climate_site_values
WHERE site_id = 5
); 

SELECT site_id, indicator_value
FROM climate_site_values 
WHERE indicator_value > ALL (
SELECT indicator_value
FROM climate_site_values
WHERE site_id = 4
);

SELECT site_id, generated_volume
FROM waste_records
WHERE generated_volume < ALL ( 
SELECT generated_volume
FROM waste_records
WHERE report_year = 2023
);

SELECT site_name AS 'площадка', 
(
    SELECT AVG(indicator_value)
    FROM environmental_values ev
    WHERE ev.site_id = ps.site_id
) AS 'среднее значение'
FROM production_sites ps;

SELECT site_id, generated_volume,
IF (generated_volume > 400, 'высокий', 'нормальный') AS waste_level
FROM waste_records; 

SELECT site_id, generated_volume, 
CASE WHEN generated_volume > 500 THEN 'высокий'
WHEN generated_volume BETWEEN 300 AND 500 THEN 'средний'
ELSE 'низкий'
END AS waste_level
FROM waste_records;

CREATE VIEW environmental_report AS
SELECT site_name, report_year, indicator_name, indicator_value
FROM environmental_values ev
JOIN production_sites ps ON ev.site_id = ps.site_id
JOIN indicator_types it ON ev.indicator_type_id = it.indicator_type_id;

SELECT * 
FROM environmental_report;

WITH water_summary AS (
    SELECT
        site_id,
        AVG(water_intake) AS avg_water_intake
    FROM water_records
    GROUP BY site_id
)
SELECT *
FROM water_summary
WHERE avg_water_intake > 1000;

EXPLAIN
SELECT site_id, report_year, indicator_value
FROM environmental_values
WHERE report_year = 2025; 

CREATE INDEX idx_environmental_report_year
ON environmental_values(report_year);

START TRANSACTION;

UPDATE waste_records
SET accumulated_volume = accumulated_volume - 10
WHERE waste_record_id = 1;

UPDATE waste_movements
SET transferred_volume = transferred_volume + 10
WHERE waste_record_id = 1
  AND handling_method = 'Recycling';

COMMIT;

SET @year = 2024;

PREPARE stmt FROM
'SELECT site_id, report_year, water_intake
 FROM water_records
 WHERE report_year = ?';

EXECUTE stmt USING @year;

DEALLOCATE PREPARE stmt;