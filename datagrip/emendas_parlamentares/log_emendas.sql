create table emendas_parlamentares.log_emendas
(
    id_log              int auto_increment
        primary key,
    id_emenda           int                                 not null,
    tipo_operacao       enum ('INSERT', 'UPDATE', 'DELETE') not null,
    usuario_responsavel varchar(100)                        not null,
    data_operacao       timestamp default CURRENT_TIMESTAMP null,
    dados_anteriores    text                                null,
    dados_novos         text                                null
);

