create table if not exists emendas_parlamentares.estado
(
    id_estado   int auto_increment
        primary key,
    sigla_uf    varchar(2)   not null,
    nome_estado varchar(100) not null,
    constraint sigla_uf
        unique (sigla_uf)
);

