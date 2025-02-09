create table if not exists emendas_parlamentares.abrangencia_especial
(
    id_abrangencia   int auto_increment
        primary key,
    nome_abrangencia varchar(100) not null,
    constraint nome_abrangencia
        unique (nome_abrangencia)
);

