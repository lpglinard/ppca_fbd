create
    definer = root@localhost procedure emendas_parlamentares.sp_analisar_emendas_transparencia(IN p_ano_da_emenda int, IN p_id_autor int)
BEGIN
    -- Declaração de variáveis
    DECLARE v_id_emenda INT;
    DECLARE v_ano_da_emenda INT;
    DECLARE v_nome_autor VARCHAR(255);
    DECLARE v_localidade VARCHAR(255);
    DECLARE v_valor_empenhado DECIMAL(15, 2);
    DECLARE v_valor_liquidado DECIMAL(15, 2);
    DECLARE v_valor_pago DECIMAL(15, 2);
    DECLARE v_restos_a_pagar DECIMAL(15, 2);
    DECLARE v_nivel_risco ENUM('BAIXO', 'MEDIO', 'ALTO');
    DECLARE v_mensagem TEXT;
    DECLARE done INT DEFAULT 0;

    -- Cursor para iterar as emendas
    DECLARE cur_emendas CURSOR FOR
        SELECT eo.id_emenda, eo.ano_da_emenda, a.nome_do_autor_da_emenda,
               CASE
                   WHEN eo.id_cidade IS NOT NULL THEN CONCAT(c.nome_cidade, ' - ', est.sigla_uf)
                   WHEN eo.id_estado IS NOT NULL THEN est.nome_estado
                   WHEN eo.id_regiao IS NOT NULL THEN r.nome_regiao
                   WHEN eo.id_abrangencia IS NOT NULL THEN ae.nome_abrangencia
                   ELSE 'Localidade indefinida'
               END AS localidade,
               eo.valor_empenhado, eo.valor_liquidado, eo.valor_pago, eo.valor_restos_a_pagar_inscritos
        FROM emendas_otimizada eo
        LEFT JOIN autor a ON eo.id_autor = a.codigo_do_autor_da_emenda
        LEFT JOIN cidade c ON eo.id_cidade = c.id_cidade
        LEFT JOIN estado est ON c.id_estado = est.id_estado
        LEFT JOIN regiao r ON eo.id_regiao = r.id_regiao
        LEFT JOIN abrangencia_especial ae ON eo.id_abrangencia = ae.id_abrangencia
        WHERE eo.ano_da_emenda = p_ano_da_emenda AND eo.id_autor = p_id_autor;

    -- Controlador de término do loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Primeiro, apagar os registros anteriores do log
    DELETE FROM log_relatorio_emendas;

    -- Abrir o cursor
    OPEN cur_emendas;

    read_loop: LOOP
        -- Ler os dados do cursor
        FETCH cur_emendas INTO v_id_emenda, v_ano_da_emenda, v_nome_autor, v_localidade,
                             v_valor_empenhado, v_valor_liquidado, v_valor_pago, v_restos_a_pagar;

        -- Verificar se o loop deve terminar
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Classificação do nível de risco com base na lógica ajustada
        IF v_valor_pago > v_valor_liquidado THEN
            SET v_nivel_risco = 'ALTO';
            SET v_mensagem = CONCAT('Valor pago (', v_valor_pago, ') superior ao valor liquidado (', v_valor_liquidado, '). Verificar possível irregularidade.');
        ELSEIF v_restos_a_pagar > (v_valor_empenhado * 0.5) THEN
            SET v_nivel_risco = 'MEDIO';
            SET v_mensagem = CONCAT('Restos a pagar elevados: ', v_restos_a_pagar, ' (> 50% do valor empenhado).');
        ELSE
            SET v_nivel_risco = 'BAIXO';
            SET v_mensagem = 'Emenda dentro dos parâmetros normais.';
        END IF;

        -- Inserir o registro no log
        INSERT INTO log_relatorio_emendas (
            id_emenda, ano_da_emenda, autor_emenda, localidade, nivel_risco, mensagem
        )
        VALUES (
            v_id_emenda, v_ano_da_emenda, v_nome_autor, v_localidade, v_nivel_risco, v_mensagem
        );
    END LOOP;

    -- Fechar o cursor
    CLOSE cur_emendas;
END;

