create table emendas_parlamentares.cidade
(
    id_cidade   int auto_increment
        primary key,
    nome_cidade varchar(255) not null,
    id_estado   int          null,
    constraint nome_cidade
        unique (nome_cidade, id_estado),
    constraint fk_cidade_estado
        foreign key (id_estado) references emendas_parlamentares.estado (id_estado)
            on update cascade
);

create index id_estado
    on emendas_parlamentares.cidade (id_estado);

