create definer = root@localhost trigger emendas_parlamentares.trg_auditoria_emendas_delete
    after delete
    on emendas_parlamentares.emendas_otimizada
    for each row
BEGIN
    INSERT INTO log_emendas (id_emenda, tipo_operacao, usuario_responsavel, dados_anteriores)
    VALUES (
        OLD.id_emenda,
        'DELETE',
        USER(),
        CONCAT('codigo_da_emenda: ', OLD.codigo_da_emenda, ', ano_da_emenda: ', OLD.ano_da_emenda,
               ', numero_da_emenda: ', OLD.numero_da_emenda, ', valor_empenhado: ', OLD.valor_empenhado,
               ', valor_pago: ', OLD.valor_pago)
    );
END;

