create table emendas_parlamentares.regiao
(
    id_regiao   int auto_increment
        primary key,
    nome_regiao varchar(100) not null,
    constraint nome_regiao
        unique (nome_regiao)
);

