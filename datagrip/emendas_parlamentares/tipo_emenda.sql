create table emendas_parlamentares.tipo_emenda
(
    id_tipo_emenda   int auto_increment
        primary key,
    nome_tipo_emenda varchar(100) not null,
    constraint nome_tipo_emenda
        unique (nome_tipo_emenda)
);

