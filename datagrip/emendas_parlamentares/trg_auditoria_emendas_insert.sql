create definer = root@localhost trigger emendas_parlamentares.trg_auditoria_emendas_insert
    after insert
    on emendas_parlamentares.emendas_otimizada
    for each row
BEGIN
    INSERT INTO log_emendas (id_emenda, tipo_operacao, usuario_responsavel, dados_novos)
    VALUES (
        NEW.id_emenda,
        'INSERT',
        USER(),
        CONCAT('codigo_da_emenda: ', NEW.codigo_da_emenda, ', ano_da_emenda: ', NEW.ano_da_emenda,
               ', numero_da_emenda: ', NEW.numero_da_emenda, ', valor_empenhado: ', NEW.valor_empenhado,
               ', valor_pago: ', NEW.valor_pago)
    );
END;

