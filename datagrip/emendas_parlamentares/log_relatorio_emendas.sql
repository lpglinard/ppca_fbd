create table emendas_parlamentares.log_relatorio_emendas
(
    id_log        int auto_increment
        primary key,
    id_emenda     int                                 not null,
    ano_da_emenda int                                 null,
    autor_emenda  varchar(255)                        null,
    localidade    varchar(255)                        null,
    nivel_risco   enum ('BAIXO', 'MEDIO', 'ALTO')     not null,
    mensagem      text                                null,
    data_analise  timestamp default CURRENT_TIMESTAMP null
);

