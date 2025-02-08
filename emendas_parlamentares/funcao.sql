create table if not exists emendas_parlamentares.funcao
(
    codigo_funcao varchar(50)  not null
        primary key,
    nome_funcao   varchar(255) null
);

