create table if not exists emendas_parlamentares.emendas_otimizada
(
    id_emenda                       int auto_increment
        primary key,
    codigo_da_emenda                varchar(255)                null,
    ano_da_emenda                   int                         not null,
    tipo_de_emenda                  varchar(100)                not null,
    codigo_do_autor_da_emenda       varchar(100)                null,
    numero_da_emenda                varchar(50)                 null,
    localidade_do_gasto             varchar(255)                null,
    codigo_funcao                   varchar(50)                 null,
    codigo_subfuncao                varchar(50)                 null,
    valor_empenhado                 decimal(15, 2) default 0.00 null,
    valor_liquidado                 decimal(15, 2) default 0.00 null,
    valor_pago                      decimal(15, 2) default 0.00 null,
    valor_restos_a_pagar_inscritos  decimal(15, 2) default 0.00 null,
    valor_restos_a_pagar_cancelados decimal(15, 2) default 0.00 null,
    valor_restos_a_pagar_pagos      decimal(15, 2) default 0.00 null,
    constraint fk_autor
        foreign key (codigo_do_autor_da_emenda) references emendas_parlamentares.autor (codigo_do_autor_da_emenda),
    constraint fk_funcao
        foreign key (codigo_funcao) references emendas_parlamentares.funcao (codigo_funcao),
    constraint fk_subfuncao
        foreign key (codigo_subfuncao) references emendas_parlamentares.subfuncao (codigo_subfuncao)
);

