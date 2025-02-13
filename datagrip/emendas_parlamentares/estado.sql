create table emendas_parlamentares.estado
(
    id_estado   int auto_increment
        primary key,
    sigla_uf    varchar(2)   not null,
    nome_estado varchar(100) not null,
    id_regiao   int          not null,
    constraint sigla_uf
        unique (sigla_uf),
    constraint fk_estado_regiao
        foreign key (id_regiao) references emendas_parlamentares.regiao (id_regiao)
            on update cascade
);

