DELIMITER %%

DROP FUNCTION IF EXISTS `uralchem_db`.`waste_records_count`
%%

CREATE FUNCTION `uralchem_db`.`waste_records_count`(
    p_min_volume DECIMAL(15,2)
)
RETURNS INTEGER
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*)
    INTO v_count
    FROM waste_records
    WHERE generated_volume >= p_min_volume;

    RETURN v_count;
END%%

DELIMITER ;

SELECT `uralchem_db`.`waste_records_count`(300);

DELIMITER %%

DROP FUNCTION IF EXISTS `uralchem_db`.`water_records_count`%%

CREATE FUNCTION `uralchem_db`.`water_records_count`(
    p_year INT
)
RETURNS INTEGER
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*)
    INTO v_count
    FROM water_records
    WHERE report_year = p_year;

    RETURN v_count;
END%%


DROP FUNCTION IF EXISTS `uralchem_db`.`certified_sites_count`%%

CREATE FUNCTION `uralchem_db`.`certified_sites_count`(
    p_iso14001 BOOLEAN
)
RETURNS INTEGER
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*)
    INTO v_count
    FROM production_sites
    WHERE iso14001 = p_iso14001;

    RETURN v_count;
END%%

DELIMITER ;

SELECT `uralchem_db`.`water_records_count`(2025);

SELECT `uralchem_db`.`certified_sites_count`(1);