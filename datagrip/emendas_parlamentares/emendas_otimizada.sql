create table emendas_parlamentares.emendas_otimizada
(
    id_emenda                       int auto_increment
        primary key,
    codigo_da_emenda                varchar(255)                null,
    ano_da_emenda                   int                         not null,
    numero_da_emenda                varchar(50)                 null,
    id_funcao                       varchar(50)                 not null,
    id_subfuncao                    varchar(50)                 not null,
    valor_empenhado                 decimal(15, 2) default 0.00 null,
    valor_liquidado                 decimal(15, 2) default 0.00 null,
    valor_pago                      decimal(15, 2) default 0.00 null,
    valor_restos_a_pagar_inscritos  decimal(15, 2) default 0.00 null,
    valor_restos_a_pagar_cancelados decimal(15, 2) default 0.00 null,
    valor_restos_a_pagar_pagos      decimal(15, 2) default 0.00 null,
    id_cidade                       int                         null,
    id_estado                       int                         null,
    id_regiao                       int                         null,
    id_abrangencia                  int                         null,
    id_tipo_emenda                  int                         null,
    id_autor                        int                         null,
    constraint fk_abrangencia
        foreign key (id_abrangencia) references emendas_parlamentares.abrangencia_especial (id_abrangencia)
            on update cascade,
    constraint fk_autor_emenda
        foreign key (id_autor) references emendas_parlamentares.autor (codigo_do_autor_da_emenda)
            on update cascade,
    constraint fk_cidade
        foreign key (id_cidade) references emendas_parlamentares.cidade (id_cidade)
            on update cascade,
    constraint fk_estado
        foreign key (id_estado) references emendas_parlamentares.estado (id_estado)
            on update cascade,
    constraint fk_funcao
        foreign key (id_funcao) references emendas_parlamentares.funcao (codigo_funcao)
            on update cascade,
    constraint fk_regiao
        foreign key (id_regiao) references emendas_parlamentares.regiao (id_regiao)
            on update cascade,
    constraint fk_subfuncao
        foreign key (id_subfuncao) references emendas_parlamentares.subfuncao (codigo_subfuncao)
            on update cascade,
    constraint fk_tipo_emenda
        foreign key (id_tipo_emenda) references emendas_parlamentares.tipo_emenda (id_tipo_emenda)
);

