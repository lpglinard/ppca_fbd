INSERT INTO `emendas_otimizada` (
    codigo_da_emenda, ano_da_emenda, tipo_de_emenda,
    codigo_do_autor_da_emenda, nome_do_autor_da_emenda, numero_da_emenda,
    localidade_do_gasto, codigo_funcao, nome_funcao, codigo_subfuncao, nome_subfuncao,
    valor_empenhado, valor_liquidado, valor_pago,
    valor_restos_a_pagar_inscritos, valor_restos_a_pagar_cancelados, valor_restos_a_pagar_pagos
)
SELECT
    codigo_da_emenda,
    ano_da_emenda,
    tipo_de_emenda,
    codigo_do_autor_da_emenda,
    nome_do_autor_da_emenda,
    numero_da_emenda,
    localidade_do_gasto,
    codigo_funcao,
    nome_funcao,
    codigo_subfuncao,
    nome_subfuncao,
    -- Conversão dos valores numéricos de texto para formato numérico adequado
    CAST(REPLACE(valor_empenhado, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_liquidado, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_pago, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_restos_a_pagar_inscritos, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_restos_a_pagar_cancelados, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_restos_a_pagar_pagos, ',', '.') AS DECIMAL(15, 2))
FROM `emendas`;