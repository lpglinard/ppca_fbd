create table emendas_parlamentares.cidade
(
    id_cidade   int auto_increment
        primary key,
    nome_cidade varchar(255) not null,
    id_estado   int          null,
    constraint nome_cidade
        unique (nome_cidade, id_estado),
    constraint cidade_ibfk_1
        foreign key (id_estado) references emendas_parlamentares.estado (id_estado)
);

create index id_estado
    on emendas_parlamentares.cidade (id_estado);

