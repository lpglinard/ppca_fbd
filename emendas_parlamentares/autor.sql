create table if not exists emendas_parlamentares.autor
(
    codigo_do_autor_da_emenda varchar(100) not null
        primary key,
    nome_do_autor_da_emenda   varchar(255) null
);

