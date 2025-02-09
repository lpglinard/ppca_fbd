DELIMITER //
CREATE TRIGGER valida_localidade_emenda
BEFORE INSERT ON emendas_otimizada
FOR EACH ROW
BEGIN
    IF (NEW.id_cidade IS NULL AND NEW.id_estado IS NULL
        AND NEW.id_regiao IS NULL AND NEW.id_abrangencia IS NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uma emenda deve ter uma localidade definida (cidade, estado, região ou abrangência especial).';
    END IF;
END;
//
DELIMITER ;