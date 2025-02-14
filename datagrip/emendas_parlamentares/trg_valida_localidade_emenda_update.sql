create definer = root@localhost trigger emendas_parlamentares.trg_valida_localidade_emenda_update
    before update
    on emendas_parlamentares.emendas_otimizada
    for each row
BEGIN
    IF NEW.id_cidade IS NULL
       AND NEW.id_estado IS NULL
       AND NEW.id_regiao IS NULL
       AND NEW.id_abrangencia IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: A emenda deve ter pelo menos uma localidade definida (cidade, estado, região ou abrangência especial).';
    END IF;
END;

