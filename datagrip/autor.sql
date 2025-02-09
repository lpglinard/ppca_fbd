create table if not exists emendas_parlamentares.autor
(
    nome_do_autor_da_emenda   varchar(255) null,
    codigo_do_autor_da_emenda int          not null
        primary key
);

