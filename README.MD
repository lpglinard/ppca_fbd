# Introdução
A transparência no uso de recursos públicos é fundamental para a boa governança e o controle social.
No Brasil, as emendas parlamentares são um dos mecanismos pelos quais deputados e senadores destinam recursos do orçamento federal para ações e projetos específicos, abrangendo áreas como saúde, educação e infraestrutura.
No entanto, o acompanhamento da aplicação dessas verbas ainda enfrenta desafios, como falta de padronização na prestação de contas, dificuldades de rastreamento e inconsistências nos dados divulgados.

O objetivo deste trabalho é desenvolver um modelo de banco de dados relacional que represente de forma eficiente e 
estruturada as informações sobre emendas parlamentares, conforme os dados disponibilizados pelo Portal da Transparência 
do Governo Federal (https://portaldatransparencia.gov.br).
Para isso, utilizamos a base pública de Emendas Parlamentares (https://portaldatransparencia.gov.br/download-de-dados/emendas-parlamentares) 
e seguimos a estrutura descrita no Dicionário de Dados Oficial (https://portaldatransparencia.gov.br/pagina-interna/603482-dicionario-de-dados-emendas-parlamentares).

A modelagem proposta busca corrigir possíveis limitações na estrutura original dos dados, garantindo maior consistência,
integridade referencial e eficiência para consultas e análises futuras. Para isso, o banco de dados foi projetado seguindo 
os princípios da normalização, contemplando chaves primárias e estrangeiras bem definidas para evitar redundância e
garantir a integridade das informações.

# Modelo de dados Relacional.
A modelagem foi baseada nos princípios de normalização para evitar redundâncias e inconsistências, e as tabelas foram 
projetadas de forma a representar as entidades e relacionamentos presentes nos dados disponibilizados pelo Portal da 
Transparência do Governo Federal.

## Estrutura Geral do Modelo
O modelo é composto por diversas tabelas, organizadas em diferentes categorias:
- Tabelas principais: Contêm os dados essenciais sobre as emendas parlamentares.
- Tabelas auxiliares: Normalizam informações como autores das emendas, funções orçamentárias e localidades.
- Tabelas de auditoria: Registram operações no banco de dados, garantindo rastreabilidade.

A seguir, apresentamos uma visão geral das principais tabelas do modelo:

## Principais Tabelas do Modelo

### Tabela `emendas_otimizada`
```SQL
CREATE TABLE IF NOT EXISTS emendas_otimizada (
    id_emenda                       INT AUTO_INCREMENT PRIMARY KEY,
    codigo_da_emenda                VARCHAR(255) NULL,
    ano_da_emenda                   INT NOT NULL,
    numero_da_emenda                VARCHAR(50) NULL,
    id_funcao                       VARCHAR(50) NOT NULL,
    id_subfuncao                    VARCHAR(50) NOT NULL,
    valor_empenhado                 DECIMAL(15,2) DEFAULT 0.00 NULL,
    valor_liquidado                 DECIMAL(15,2) DEFAULT 0.00 NULL,
    valor_pago                      DECIMAL(15,2) DEFAULT 0.00 NULL,
    valor_restos_a_pagar_inscritos  DECIMAL(15,2) DEFAULT 0.00 NULL,
    valor_restos_a_pagar_cancelados DECIMAL(15,2) DEFAULT 0.00 NULL,
    valor_restos_a_pagar_pagos      DECIMAL(15,2) DEFAULT 0.00 NULL,
    id_cidade                       INT NULL,
    id_estado                       INT NULL,
    id_regiao                       INT NULL,
    id_abrangencia                  INT NULL,
    id_tipo_emenda                  INT NULL,
    id_autor                        INT NULL,
    CONSTRAINT fk_abrangencia FOREIGN KEY (id_abrangencia) REFERENCES abrangencia_especial (id_abrangencia) ON UPDATE CASCADE,
    CONSTRAINT fk_autor_emenda FOREIGN KEY (id_autor) REFERENCES autor (codigo_do_autor_da_emenda) ON UPDATE CASCADE,
    CONSTRAINT fk_cidade FOREIGN KEY (id_cidade) REFERENCES cidade (id_cidade) ON UPDATE CASCADE,
    CONSTRAINT fk_estado FOREIGN KEY (id_estado) REFERENCES estado (id_estado) ON UPDATE CASCADE,
    CONSTRAINT fk_funcao FOREIGN KEY (id_funcao) REFERENCES funcao (codigo_funcao) ON UPDATE CASCADE,
    CONSTRAINT fk_regiao FOREIGN KEY (id_regiao) REFERENCES regiao (id_regiao) ON UPDATE CASCADE,
    CONSTRAINT fk_subfuncao FOREIGN KEY (id_subfuncao) REFERENCES subfuncao (codigo_subfuncao) ON UPDATE CASCADE,
    CONSTRAINT fk_tipo_emenda FOREIGN KEY (id_tipo_emenda) REFERENCES tipo_emenda (id_tipo_emenda) ON UPDATE CASCADE
);
```

### Tabela `autor`
Armazena os dados dos parlamentares responsáveis pelas emendas.

```SQL
CREATE TABLE IF NOT EXISTS autor (
    codigo_do_autor_da_emenda INT NOT NULL PRIMARY KEY,
    nome_do_autor_da_emenda VARCHAR(255) NULL
);
```
A escolha de um código numérico para o autor foi feita para otimizar consultas e evitar inconsistências nos dados.

### Tabelas `regiao`, `estado` e `cidade`
Estas tabelas organizam as informações geográficas associadas às emendas.

```SQL
CREATE TABLE IF NOT EXISTS regiao (
    id_regiao INT AUTO_INCREMENT PRIMARY KEY,
    nome_regiao VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS estado (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    sigla_uf VARCHAR(2) NOT NULL UNIQUE,
    nome_estado VARCHAR(100) NOT NULL,
    id_regiao INT NOT NULL,
    CONSTRAINT fk_estado_regiao FOREIGN KEY (id_regiao) REFERENCES regiao (id_regiao) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cidade (
    id_cidade INT AUTO_INCREMENT PRIMARY KEY,
    nome_cidade VARCHAR(255) NOT NULL,
    id_estado INT NULL,
    CONSTRAINT fk_cidade_estado FOREIGN KEY (id_estado) REFERENCES estado (id_estado) ON UPDATE CASCADE
);
```
A hierarquia **Região -> Estado -> Cidade** permite consultas flexíveis por diferentes níveis de abrangência territorial.

### Tabela `log_emendas` (Auditoria de Alterações)
Armazena um histórico de todas as operações realizadas na tabela `emendas_otimizada`.

```SQL
CREATE TABLE IF NOT EXISTS log_emendas (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_emenda INT NOT NULL,
    tipo_operacao ENUM ('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    usuario_responsavel VARCHAR(100) NOT NULL,
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP NULL,
    dados_anteriores TEXT NULL,
    dados_novos TEXT NULL
);
```
Esta tabela permite rastrear quem alterou os dados e quando, aumentando a transparência e a segurança do banco.

## Relacionamentos e Integridade Referencial

A tabela `emendas_otimizada` é a principal do modelo, representando as emendas parlamentares.  
Cada emenda está relacionada a diversas entidades, garantindo que os dados sejam organizados de forma normalizada  
e que consultas possam ser realizadas com eficiência.

Além disso, foram incluídas cláusulas `CASCADE` em algumas chaves estrangeiras para manter a integridade referencial e  
atualizar automaticamente os registros associados quando há alterações nas tabelas relacionadas.

A seguir, detalhamos todos os relacionamentos da tabela `emendas_otimizada` com suas respectivas tabelas auxiliares.

---

### Relacionamento com `autor`
- **Objetivo**: Identificar o parlamentar responsável pela emenda.
- **Chave estrangeira**: `id_autor`
- **Relacionamento**: Uma emenda pertence a um único autor, mas um autor pode ter múltiplas emendas.
- **Integridade referencial**: Caso um `autor` tenha seu código atualizado, a alteração será propagada automaticamente.

```SQL
CONSTRAINT fk_autor_emenda 
FOREIGN KEY (id_autor) REFERENCES autor (codigo_do_autor_da_emenda)
ON UPDATE CASCADE
```

---

### Relacionamento com `funcao`
- **Objetivo**: Associar a emenda a uma função orçamentária específica.
- **Chave estrangeira**: `id_funcao`
- **Relacionamento**: Uma emenda deve pertencer a uma única função, mas uma função pode estar associada a diversas emendas.
- **Integridade referencial**: Caso uma função seja atualizada, a alteração será propagada automaticamente.

```SQL
CONSTRAINT fk_funcao 
FOREIGN KEY (id_funcao) REFERENCES funcao (codigo_funcao)
ON UPDATE CASCADE
```

---

### Relacionamento com `subfuncao`
- **Objetivo**: Associar a emenda a uma subfunção orçamentária específica.
- **Chave estrangeira**: `id_subfuncao`
- **Relacionamento**: Cada emenda está vinculada a uma subfunção, enquanto uma subfunção pode estar presente em várias emendas.
- **Integridade referencial**: Caso uma subfunção seja modificada, a alteração será propagada automaticamente.

```SQL
CONSTRAINT fk_subfuncao 
FOREIGN KEY (id_subfuncao) REFERENCES subfuncao (codigo_subfuncao)
ON UPDATE CASCADE
```

---

### Relacionamento com `tipo_emenda`
- **Objetivo**: Classificar a emenda conforme sua categoria.
- **Chave estrangeira**: `id_tipo_emenda`
- **Relacionamento**: Cada emenda tem um único tipo, enquanto um tipo pode estar associado a diversas emendas.
- **Integridade referencial**: Atualizações no tipo de emenda são propagadas automaticamente.

```SQL
CONSTRAINT fk_tipo_emenda 
FOREIGN KEY (id_tipo_emenda) REFERENCES tipo_emenda (id_tipo_emenda)
ON UPDATE CASCADE
```

---

### Relacionamento com `regiao`
- **Objetivo**: Permitir a análise das emendas por região geográfica.
- **Chave estrangeira**: `id_regiao`
- **Relacionamento**: Cada emenda pode ser vinculada a uma região, e uma região pode conter diversas emendas.
- **Integridade referencial**: Atualizações no ID da região serão automaticamente refletidas.

```SQL
CONSTRAINT fk_regiao 
FOREIGN KEY (id_regiao) REFERENCES regiao (id_regiao)
ON UPDATE CASCADE
```

---

### Relacionamento com `estado`
- **Objetivo**: Associar a emenda a um estado específico.
- **Chave estrangeira**: `id_estado`
- **Relacionamento**: Uma emenda pode estar vinculada a um estado, e um estado pode conter várias emendas.
- **Integridade referencial**: Alterações nos estados são propagadas automaticamente.

```SQL
CONSTRAINT fk_estado 
FOREIGN KEY (id_estado) REFERENCES estado (id_estado)
ON UPDATE CASCADE
```

---

### Relacionamento com `cidade`
- **Objetivo**: Relacionar a emenda a uma cidade específica.
- **Chave estrangeira**: `id_cidade`
- **Relacionamento**: Uma emenda pode estar associada a uma cidade, e uma cidade pode conter múltiplas emendas.
- **Integridade referencial**: Caso um município tenha seu ID atualizado, a alteração será refletida automaticamente.

```SQL
CONSTRAINT fk_cidade 
FOREIGN KEY (id_cidade) REFERENCES cidade (id_cidade)
ON UPDATE CASCADE
```

---

### Relacionamento com `abrangencia_especial`
- **Objetivo**: Associar a emenda a um nível especial de abrangência.
- **Chave estrangeira**: `id_abrangencia`
- **Relacionamento**: Uma emenda pode estar vinculada a um nível de abrangência específico.
- **Integridade referencial**: Modificações no ID da abrangência são refletidas automaticamente.

```SQL
CONSTRAINT fk_abrangencia 
FOREIGN KEY (id_abrangencia) REFERENCES abrangencia_especial (id_abrangencia)
ON UPDATE CASCADE
```

---

### Relacionamento com `log_emendas` (Auditoria)
- **Objetivo**: Rastrear alterações realizadas na tabela `emendas_otimizada`.
- **Chave estrangeira**: `id_emenda`
- **Relacionamento**: O log armazena eventos associados a cada emenda, registrando quem fez a alteração e os dados antes e depois da operação.
- **Integridade referencial**: Caso uma emenda seja removida, a entrada no log é preservada, mas a referência fica `NULL`.

```SQL
CONSTRAINT fk_log_emenda 
FOREIGN KEY (id_emenda) REFERENCES emendas_otimizada (id_emenda)
ON DELETE SET NULL
```

---

### Relacionamento com `log_relatorio_emendas` (Análises de Transparência)
- **Objetivo**: Armazenar registros de análise sobre o nível de risco das emendas.
- **Chave estrangeira**: `id_emenda`
- **Relacionamento**: O log de transparência armazena o histórico de análises de risco de cada emenda.
- **Integridade referencial**: Caso uma emenda seja removida, as referências nos registros de análise são mantidas com `NULL`.

```SQL
CONSTRAINT fk_log_relatorio_emenda 
FOREIGN KEY (id_emenda) REFERENCES emendas_otimizada (id_emenda)
ON DELETE SET NULL
```

---

## Considerações sobre `CASCADE`
O uso de `ON UPDATE CASCADE` garante que, se um ID de uma entidade for alterado, todas as tabelas que fazem referência a essa entidade também sejam atualizadas automaticamente.  
Isso evita problemas de integridade, como referências quebradas, tornando o modelo mais robusto.

Entretanto, optamos por **não usar `ON DELETE CASCADE`**, pois uma exclusão em cascata poderia remover registros importantes.  
Em vez disso, em tabelas como `log_emendas` e `log_relatorio_emendas`, usamos `ON DELETE SET NULL` para preservar um histórico de operações,  
mantendo a transparência e rastreabilidade das informações.

---

# DDL 
```SQL
create table abrangencia_especial
(
    id_abrangencia   int auto_increment
        primary key,
    nome_abrangencia varchar(100) not null,
    constraint nome_abrangencia
        unique (nome_abrangencia)
);

create table autor
(
    nome_do_autor_da_emenda   varchar(255) null,
    codigo_do_autor_da_emenda int          not null
        primary key
);

create table emendas_orignal
(
    codigo_da_emenda                text null,
    ano_da_emenda                   int  null,
    tipo_de_emenda                  text null,
    codigo_do_autor_da_emenda       text null,
    nome_do_autor_da_emenda         text null,
    numero_da_emenda                text null,
    localidade_do_gasto             text null,
    codigo_funcao                   text null,
    nome_funcao                     text null,
    codigo_subfuncao                text null,
    nome_subfuncao                  text null,
    valor_empenhado                 text null,
    valor_liquidado                 text null,
    valor_pago                      text null,
    valor_restos_a_pagar_inscritos  text null,
    valor_restos_a_pagar_cancelados text null,
    valor_restos_a_pagar_pagos      text null
);

create table funcao
(
    codigo_funcao varchar(50)  not null
        primary key,
    nome_funcao   varchar(255) null
);

create table log_emendas
(
    id_log              int auto_increment
        primary key,
    id_emenda           int                                 not null,
    tipo_operacao       enum ('INSERT', 'UPDATE', 'DELETE') not null,
    usuario_responsavel varchar(100)                        not null,
    data_operacao       timestamp default CURRENT_TIMESTAMP null,
    dados_anteriores    text                                null,
    dados_novos         text                                null
);

create table log_relatorio_emendas
(
    id_log        int auto_increment
        primary key,
    id_emenda     int                                 not null,
    ano_da_emenda int                                 null,
    autor_emenda  varchar(255)                        null,
    localidade    varchar(255)                        null,
    nivel_risco   enum ('BAIXO', 'MEDIO', 'ALTO')     not null,
    mensagem      text                                null,
    data_analise  timestamp default CURRENT_TIMESTAMP null
);

create table regiao
(
    id_regiao   int auto_increment
        primary key,
    nome_regiao varchar(100) not null,
    constraint nome_regiao
        unique (nome_regiao)
);

create table estado
(
    id_estado   int auto_increment
        primary key,
    sigla_uf    varchar(2)   not null,
    nome_estado varchar(100) not null,
    id_regiao   int          not null,
    constraint sigla_uf
        unique (sigla_uf),
    constraint fk_estado_regiao
        foreign key (id_regiao) references regiao (id_regiao)
            on update cascade
);

create table cidade
(
    id_cidade   int auto_increment
        primary key,
    nome_cidade varchar(255) not null,
    id_estado   int          null,
    constraint nome_cidade
        unique (nome_cidade, id_estado),
    constraint fk_cidade_estado
        foreign key (id_estado) references estado (id_estado)
            on update cascade
);

create index id_estado
    on cidade (id_estado);

create table subfuncao
(
    codigo_subfuncao varchar(50)  not null
        primary key,
    nome_subfuncao   varchar(255) null
);

create table tipo_emenda
(
    id_tipo_emenda   int auto_increment
        primary key,
    nome_tipo_emenda varchar(100) not null,
    constraint nome_tipo_emenda
        unique (nome_tipo_emenda)
);

create table emendas_otimizada
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
        foreign key (id_abrangencia) references abrangencia_especial (id_abrangencia)
            on update cascade,
    constraint fk_autor_emenda
        foreign key (id_autor) references autor (codigo_do_autor_da_emenda)
            on update cascade,
    constraint fk_cidade
        foreign key (id_cidade) references cidade (id_cidade)
            on update cascade,
    constraint fk_estado
        foreign key (id_estado) references estado (id_estado)
            on update cascade,
    constraint fk_funcao
        foreign key (id_funcao) references funcao (codigo_funcao)
            on update cascade,
    constraint fk_regiao
        foreign key (id_regiao) references regiao (id_regiao)
            on update cascade,
    constraint fk_subfuncao
        foreign key (id_subfuncao) references subfuncao (codigo_subfuncao)
            on update cascade,
    constraint fk_tipo_emenda
        foreign key (id_tipo_emenda) references tipo_emenda (id_tipo_emenda)
);

create definer = root@localhost trigger trg_auditoria_emendas_delete
    after delete
    on emendas_otimizada
    for each row
BEGIN
    INSERT INTO log_emendas (id_emenda, tipo_operacao, usuario_responsavel, dados_anteriores)
    VALUES (
        OLD.id_emenda,
        'DELETE',
        USER(),
        CONCAT('codigo_da_emenda: ', OLD.codigo_da_emenda, ', ano_da_emenda: ', OLD.ano_da_emenda,
               ', numero_da_emenda: ', OLD.numero_da_emenda, ', valor_empenhado: ', OLD.valor_empenhado,
               ', valor_pago: ', OLD.valor_pago)
    );
END;

create definer = root@localhost trigger trg_auditoria_emendas_insert
    after insert
    on emendas_otimizada
    for each row
BEGIN
    INSERT INTO log_emendas (id_emenda, tipo_operacao, usuario_responsavel, dados_novos)
    VALUES (
        NEW.id_emenda,
        'INSERT',
        USER(),
        CONCAT('codigo_da_emenda: ', NEW.codigo_da_emenda, ', ano_da_emenda: ', NEW.ano_da_emenda,
               ', numero_da_emenda: ', NEW.numero_da_emenda, ', valor_empenhado: ', NEW.valor_empenhado,
               ', valor_pago: ', NEW.valor_pago)
    );
END;

create definer = root@localhost trigger trg_auditoria_emendas_update
    after update
    on emendas_otimizada
    for each row
BEGIN
    INSERT INTO log_emendas (id_emenda, tipo_operacao, usuario_responsavel, dados_anteriores, dados_novos)
    VALUES (
        OLD.id_emenda,
        'UPDATE',
        USER(),
        CONCAT('codigo_da_emenda: ', OLD.codigo_da_emenda, ', ano_da_emenda: ', OLD.ano_da_emenda,
               ', numero_da_emenda: ', OLD.numero_da_emenda, ', valor_empenhado: ', OLD.valor_empenhado,
               ', valor_pago: ', OLD.valor_pago),
        CONCAT('codigo_da_emenda: ', NEW.codigo_da_emenda, ', ano_da_emenda: ', NEW.ano_da_emenda,
               ', numero_da_emenda: ', NEW.numero_da_emenda, ', valor_empenhado: ', NEW.valor_empenhado,
               ', valor_pago: ', NEW.valor_pago)
    );
END;

create definer = root@localhost view vw_localidade_emenda as
select `eo`.`id_emenda`                       AS `id_emenda`,
       (case
            when (`eo`.`id_cidade` is not null) then concat(`c`.`nome_cidade`, ' - ',
                                                            coalesce(`est`.`sigla_uf`, 'UF Desconhecida'))
            when (`eo`.`id_estado` is not null) then `est`.`nome_estado`
            when (`eo`.`id_regiao` is not null) then `r`.`nome_regiao`
            when (`eo`.`id_abrangencia` is not null) then `ae`.`nome_abrangencia`
            else 'Localidade indefinida' end) AS `localidade`,
       `eo`.`ano_da_emenda`                   AS `ano_da_emenda`,
       `f`.`nome_funcao`                      AS `nome_funcao`,
       `s`.`nome_subfuncao`                   AS `nome_subfuncao`,
       coalesce(`eo`.`valor_empenhado`, 0.00) AS `valor_empenhado`,
       coalesce(`eo`.`valor_pago`, 0.00)      AS `valor_pago`
from ((((((`emendas_parlamentares`.`emendas_otimizada` `eo` left join `emendas_parlamentares`.`cidade` `c`
           on ((`eo`.`id_cidade` = `c`.`id_cidade`))) left join `emendas_parlamentares`.`estado` `est`
          on ((`c`.`id_estado` = `est`.`id_estado`))) left join `emendas_parlamentares`.`regiao` `r`
         on ((`eo`.`id_regiao` = `r`.`id_regiao`))) left join `emendas_parlamentares`.`abrangencia_especial` `ae`
        on ((`eo`.`id_abrangencia` = `ae`.`id_abrangencia`))) left join `emendas_parlamentares`.`funcao` `f`
       on ((`eo`.`id_funcao` = `f`.`codigo_funcao`))) left join `emendas_parlamentares`.`subfuncao` `s`
      on ((`eo`.`id_subfuncao` = `s`.`codigo_subfuncao`)));

create
    definer = root@localhost procedure sp_analisar_emendas_transparencia(IN p_ano_da_emenda int, IN p_id_autor int)
BEGIN
    -- Declaração de variáveis
    DECLARE v_id_emenda INT;
    DECLARE v_ano_da_emenda INT;
    DECLARE v_nome_autor VARCHAR(255);
    DECLARE v_localidade VARCHAR(255);
    DECLARE v_valor_empenhado DECIMAL(15, 2);
    DECLARE v_valor_liquidado DECIMAL(15, 2);
    DECLARE v_valor_pago DECIMAL(15, 2);
    DECLARE v_restos_a_pagar DECIMAL(15, 2);
    DECLARE v_nivel_risco ENUM('BAIXO', 'MEDIO', 'ALTO');
    DECLARE v_mensagem TEXT;
    DECLARE done INT DEFAULT 0;

    -- Cursor para iterar as emendas
    DECLARE cur_emendas CURSOR FOR
        SELECT eo.id_emenda, eo.ano_da_emenda, a.nome_do_autor_da_emenda,
               CASE
                   WHEN eo.id_cidade IS NOT NULL THEN CONCAT(c.nome_cidade, ' - ', est.sigla_uf)
                   WHEN eo.id_estado IS NOT NULL THEN est.nome_estado
                   WHEN eo.id_regiao IS NOT NULL THEN r.nome_regiao
                   WHEN eo.id_abrangencia IS NOT NULL THEN ae.nome_abrangencia
                   ELSE 'Localidade indefinida'
               END AS localidade,
               eo.valor_empenhado, eo.valor_liquidado, eo.valor_pago, eo.valor_restos_a_pagar_inscritos
        FROM emendas_otimizada eo
        LEFT JOIN autor a ON eo.id_autor = a.codigo_do_autor_da_emenda
        LEFT JOIN cidade c ON eo.id_cidade = c.id_cidade
        LEFT JOIN estado est ON c.id_estado = est.id_estado
        LEFT JOIN regiao r ON eo.id_regiao = r.id_regiao
        LEFT JOIN abrangencia_especial ae ON eo.id_abrangencia = ae.id_abrangencia
        WHERE eo.ano_da_emenda = p_ano_da_emenda AND eo.id_autor = p_id_autor;

    -- Controlador de término do loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Primeiro, apagar os registros anteriores do log
    DELETE FROM log_relatorio_emendas;

    -- Abrir o cursor
    OPEN cur_emendas;

    read_loop: LOOP
        -- Ler os dados do cursor
        FETCH cur_emendas INTO v_id_emenda, v_ano_da_emenda, v_nome_autor, v_localidade,
                             v_valor_empenhado, v_valor_liquidado, v_valor_pago, v_restos_a_pagar;

        -- Verificar se o loop deve terminar
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Classificação do nível de risco com base na lógica ajustada
        IF v_valor_pago > v_valor_liquidado THEN
            SET v_nivel_risco = 'ALTO';
            SET v_mensagem = CONCAT('Valor pago (', v_valor_pago, ') superior ao valor liquidado (', v_valor_liquidado, '). Verificar possível irregularidade.');
        ELSEIF v_restos_a_pagar > (v_valor_empenhado * 0.5) THEN
            SET v_nivel_risco = 'MEDIO';
            SET v_mensagem = CONCAT('Restos a pagar elevados: ', v_restos_a_pagar, ' (> 50% do valor empenhado).');
        ELSE
            SET v_nivel_risco = 'BAIXO';
            SET v_mensagem = 'Emenda dentro dos parâmetros normais.';
        END IF;

        -- Inserir o registro no log
        INSERT INTO log_relatorio_emendas (
            id_emenda, ano_da_emenda, autor_emenda, localidade, nivel_risco, mensagem
        )
        VALUES (
            v_id_emenda, v_ano_da_emenda, v_nome_autor, v_localidade, v_nivel_risco, v_mensagem
        );
    END LOOP;

    -- Fechar o cursor
    CLOSE cur_emendas;
END;
```

# Processo de ETL (Extract, Transform, Load)

## Introdução ao Processo de ETL

O processo de ETL (Extract, Transform, Load) foi aplicado para importar os dados da tabela `emendas` (dados brutos) para a tabela `emendas_otimizada` (dados normalizados e estruturados de forma relacional). Esse processo envolveu a extração dos dados originais, a transformação de valores e a carga dos dados na estrutura otimizada.

A seguir, detalhamos a primeira execução de SQL utilizada para realizar essa migração.

## Extração dos Dados

Os dados foram extraídos da tabela `emendas`, que continha os valores originais importados do Portal da Transparência. Essa tabela armazenava informações textuais, o que exigia um processo de conversão para garantir que os dados fossem corretamente armazenados no formato adequado.

## Transformação dos Dados

Durante a transformação, foi necessário converter alguns valores para os tipos de dados corretos. A principal modificação foi a conversão dos valores numéricos, originalmente armazenados como texto, para tipos `DECIMAL(15,2)`, garantindo que fossem compatíveis com a modelagem do banco de dados.

Outra transformação importante foi a substituição da vírgula (`','`) pelo ponto (`'.'`) nos valores monetários, assegurando que fossem interpretados corretamente pelo MySQL.

## Carga dos Dados

A carga dos dados foi realizada com a seguinte instrução SQL:

```SQL
INSERT INTO `emendas_otimizada` (
    codigo_da_emenda, ano_da_emenda, tipo_de_emenda,
    codigo_do_autor_da_emenda, nome_do_autor_da_emenda, numero_da_emenda,
    localidade_do_gasto, codigo_funcao, nome_funcao, codigo_subfuncao, nome_subfuncao,
    valor_empenhado, valor_liquidado, valor_pago,
    valor_restos_a_pagar_inscritos, valor_restos_a_pagar_cancelados, valor_restos_a_pagar_pagos
)
SELECT
    codigo_da_emenda,
    ano_da_emenda,
    tipo_de_emenda,
    codigo_do_autor_da_emenda,
    nome_do_autor_da_emenda,
    numero_da_emenda,
    localidade_do_gasto,
    codigo_funcao,
    nome_funcao,
    codigo_subfuncao,
    nome_subfuncao,
    -- Conversão dos valores numéricos de texto para formato numérico adequado
    CAST(REPLACE(valor_empenhado, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_liquidado, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_pago, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_restos_a_pagar_inscritos, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_restos_a_pagar_cancelados, ',', '.') AS DECIMAL(15, 2)),
    CAST(REPLACE(valor_restos_a_pagar_pagos, ',', '.') AS DECIMAL(15, 2))
FROM `emendas`;
```

# Segunda Fase do Processo de ETL

## Introdução à Segunda Fase

Nesta etapa do processo de ETL, o foco foi a normalização de dados referentes às funções, subfunções e autores das emendas parlamentares. Essa etapa foi necessária para eliminar redundâncias na tabela `emendas_otimizada`, garantindo a integridade referencial e melhorando a eficiência das consultas.

A seguir, detalhamos os comandos executados e suas respectivas justificativas.

## Criação e Migração de Dados para Tabelas Normalizadas

### **1. Criação da Tabela `funcao`**
A tabela `funcao` foi criada para armazenar as funções relacionadas às emendas.

```SQL
CREATE TABLE funcao (
    codigo_funcao VARCHAR(50) PRIMARY KEY,
    nome_funcao VARCHAR(255) NOT NULL
);
```

Em seguida, os dados foram migrados para essa nova estrutura, eliminando duplicatas.

```SQL
INSERT INTO funcao (codigo_funcao, nome_funcao)
SELECT DISTINCT codigo_funcao, nome_funcao
FROM emendas_parlamentares.emendas_otimizada;
```
### **2. Criação da Tabela `subfuncao`**

A subfuncao foi criada para armazenar as subfunções das emendas, garantindo que cada subfunção tenha um identificador único.

```SQL
CREATE TABLE subfuncao (
    codigo_subfuncao VARCHAR(50) PRIMARY KEY,
    nome_subfuncao VARCHAR(255) NOT NULL
);
```

Os dados foram migrados da seguinte forma:

```SQL
INSERT INTO subfuncao (codigo_subfuncao, nome_subfuncao)
SELECT DISTINCT codigo_subfuncao, nome_subfuncao
FROM emendas_parlamentares.emendas_otimizada;
```

### **3. Criação da Tabela `autor`**

A tabela autor foi criada para armazenar as informações dos parlamentares responsáveis pelas emendas.

```SQL
CREATE TABLE autor (
    codigo_do_autor_da_emenda VARCHAR(100) PRIMARY KEY,
    nome_do_autor_da_emenda VARCHAR(255) NOT NULL
);
```

Os dados foram migrados agrupando os nomes dos autores para evitar inconsistências:

```SQL
INSERT INTO autor (codigo_do_autor_da_emenda, nome_do_autor_da_emenda)
SELECT codigo_do_autor_da_emenda, MIN(nome_do_autor_da_emenda) AS nome_do_autor_da_emenda
FROM emendas_parlamentares.emendas_otimizada
GROUP BY codigo_do_autor_da_emenda;
```

Essa abordagem assegura que, caso existam variações no nome do autor para um mesmo código, apenas um nome seja mantido.


### **4. Criação da Tabela `emendas_otimizada`**

Após a normalização, as colunas redundantes foram removidas da tabela emendas_otimizada, pois os dados agora estão armazenados de forma relacional nas tabelas específicas.

```SQL
ALTER TABLE emendas_parlamentares.emendas_otimizada
    DROP COLUMN nome_funcao,
    DROP COLUMN nome_subfuncao,
    DROP COLUMN nome_do_autor_da_emenda;
```

# Terceira Fase do Processo de ETL

## Objetivo

Nesta fase, o foco foi a normalização dos dados geográficos presentes na tabela `emendas_otimizada`. Para isso, criamos tabelas específicas para **estados (UFs), cidades, regiões e abrangências especiais**, garantindo maior integridade referencial e eficiência nas consultas.

---

## **Criação das Tabelas de Localização**

### **1. Criando Estruturas para Estados, Cidades e Regiões**
Para organizar corretamente as informações geográficas, criamos as seguintes tabelas:

```SQL
CREATE TABLE estado (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    sigla_uf VARCHAR(2) UNIQUE NOT NULL,
    nome_estado VARCHAR(100) NOT NULL
);

CREATE TABLE cidade (
    id_cidade INT AUTO_INCREMENT PRIMARY KEY,
    nome_cidade VARCHAR(255) NOT NULL,
    id_estado INT,
    UNIQUE (nome_cidade, id_estado),
    FOREIGN KEY (id_estado) REFERENCES estado (id_estado)
);

CREATE TABLE regiao (
    id_regiao INT AUTO_INCREMENT PRIMARY KEY,
    nome_regiao VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE abrangencia_especial (
    id_abrangencia INT AUTO_INCREMENT PRIMARY KEY,
    nome_abrangencia VARCHAR(100) UNIQUE NOT NULL
);

```

Carga de Dados Geográficos

### **2. Inserção de Estados e Regiões**

Populamos a tabela estado com os dados das 27 unidades federativas brasileiras.

```SQL
INSERT INTO estado (sigla_uf, nome_estado)
VALUES
('AC', 'Acre'), ('AL', 'Alagoas'), ('AP', 'Amapá'), ('AM', 'Amazonas'),
('BA', 'Bahia'), ('CE', 'Ceará'), ('DF', 'Distrito Federal'), ('ES', 'Espírito Santo'),
('GO', 'Goiás'), ('MA', 'Maranhão'), ('MT', 'Mato Grosso'), ('MS', 'Mato Grosso do Sul'),
('MG', 'Minas Gerais'), ('PA', 'Pará'), ('PB', 'Paraíba'), ('PR', 'Paraná'),
('PE', 'Pernambuco'), ('PI', 'Piauí'), ('RJ', 'Rio de Janeiro'), ('RN', 'Rio Grande do Norte'),
('RS', 'Rio Grande do Sul'), ('RO', 'Rondônia'), ('RR', 'Roraima'), ('SC', 'Santa Catarina'),
('SP', 'São Paulo'), ('SE', 'Sergipe'), ('TO', 'Tocantins');
```

Também adicionamos as cinco grandes regiões do Brasil na tabela regiao:


```sql
INSERT INTO regiao (nome_regiao)
VALUES ('Norte'), ('Nordeste'), ('Centro-Oeste'), ('Sudeste'), ('Sul');
```
### **3. Extração e Normalização das Cidades**
A partir dos dados da tabela emendas_otimizada, extraímos nomes de cidades e seus respectivos estados, evitando duplicações:
```SQL
INSERT INTO cidade (nome_cidade, id_estado)
SELECT DISTINCT
    SUBSTRING_INDEX(localidade_do_gasto, ' - ', 1) AS nome_cidade,
    (SELECT id_estado FROM estado WHERE sigla_uf = SUBSTRING_INDEX(localidade_do_gasto, ' - ', -1)) AS id_estado
FROM emendas_parlamentares.emendas_otimizada
WHERE localidade_do_gasto LIKE '% - %';
```

Além disso, adicionamos valores especiais na tabela abrangencia_especial:

```SQL
INSERT INTO abrangencia_especial (nome_abrangencia)
VALUES ('Nacional', 'MÚLTIPLO', 'Exterior');
```

### **4. Atualização da Tabela emendas_otimizada**

Agora que os dados estão organizados nas novas tabelas, adicionamos colunas para armazenar referências normalizadas:

```SQL
ALTER TABLE emendas_parlamentares.emendas_otimizada
    ADD COLUMN id_cidade INT NULL,
    ADD COLUMN id_estado INT NULL,
    ADD COLUMN id_regiao INT NULL,
    ADD COLUMN id_abrangencia INT NULL,
    ADD CONSTRAINT fk_cidade FOREIGN KEY (id_cidade) REFERENCES cidade (id_cidade),
    ADD CONSTRAINT fk_estado FOREIGN KEY (id_estado) REFERENCES estado (id_estado),
    ADD CONSTRAINT fk_regiao FOREIGN KEY (id_regiao) REFERENCES regiao (id_regiao),
    ADD CONSTRAINT fk_abrangencia FOREIGN KEY (id_abrangencia) REFERENCES abrangencia_especial (id_abrangencia);
```

Em seguida, realizamos as atualizações para preencher os identificadores normalizados:

```SQL
UPDATE emendas_parlamentares.emendas_otimizada eo
JOIN cidade c ON c.nome_cidade = SUBSTRING_INDEX(eo.localidade_do_gasto, ' - ', 1)
AND c.id_estado = (SELECT id_estado FROM estado WHERE sigla_uf = SUBSTRING_INDEX(eo.localidade_do_gasto, ' - ', -1))
SET eo.id_cidade = c.id_cidade;

UPDATE emendas_parlamentares.emendas_otimizada eo
JOIN estado e ON eo.localidade_do_gasto LIKE CONCAT(e.nome_estado, ' (UF)')
SET eo.id_estado = e.id_estado;

UPDATE emendas_parlamentares.emendas_otimizada eo
JOIN regiao r ON eo.localidade_do_gasto = r.nome_regiao
SET eo.id_regiao = r.id_regiao;

UPDATE emendas_parlamentares.emendas_otimizada eo
JOIN abrangencia_especial a ON eo.localidade_do_gasto = a.nome_abrangencia
SET eo.id_abrangencia = a.id_abrangencia;
```

Por fim, removemos a coluna localidade_do_gasto, pois seus dados foram completamente migrados para as tabelas normalizadas:

```SQL
ALTER TABLE emendas_parlamentares.emendas_otimizada
    DROP COLUMN localidade_do_gasto;
```

# **Triggers Criados no Modelo de Dados**

## **Objetivo**
Os **triggers** desempenham um papel fundamental no controle da integridade dos dados e na auditoria das operações realizadas no banco de dados. No modelo desenvolvido, criamos **triggers para rastrear alterações na tabela `emendas_otimizada`**, registrando as operações **INSERT, UPDATE e DELETE** na tabela de log `log_emendas`.

---

## **Trigger para Auditoria de Exclusões (`DELETE`)**
### **Objetivo**
Este trigger entra em ação **após a exclusão (`DELETE`) de uma emenda**. Ele registra os dados da emenda removida na tabela `log_emendas`, garantindo que não haja perda completa da informação.

```SQL
CREATE DEFINER = root@localhost TRIGGER trg_auditoria_emendas_delete
    AFTER DELETE
    ON emendas_otimizada
    FOR EACH ROW
BEGIN
    INSERT INTO log_emendas (id_emenda, tipo_operacao, usuario_responsavel, dados_anteriores)
    VALUES (
        OLD.id_emenda,
        'DELETE',
        USER(),
        CONCAT('codigo_da_emenda: ', OLD.codigo_da_emenda, ', ano_da_emenda: ', OLD.ano_da_emenda,
               ', numero_da_emenda: ', OLD.numero_da_emenda, ', valor_empenhado: ', OLD.valor_empenhado,
               ', valor_pago: ', OLD.valor_pago)
    );
END;
```

## **Trigger para Auditoria de Inserções (`INSERT`)**
### **Objetivo**
Este trigger registra automaticamente todas as novas emendas inseridas na tabela emendas_otimizada, garantindo um histórico completo das operações.

```SQL
CREATE DEFINER = root@localhost TRIGGER trg_auditoria_emendas_insert
    AFTER INSERT
    ON emendas_otimizada
    FOR EACH ROW
BEGIN
    INSERT INTO log_emendas (id_emenda, tipo_operacao, usuario_responsavel, dados_novos)
    VALUES (
        NEW.id_emenda,
        'INSERT',
        USER(),
        CONCAT('codigo_da_emenda: ', NEW.codigo_da_emenda, ', ano_da_emenda: ', NEW.ano_da_emenda,
               ', numero_da_emenda: ', NEW.numero_da_emenda, ', valor_empenhado: ', NEW.valor_empenhado,
               ', valor_pago: ', NEW.valor_pago)
    );
END;
```

## **Trigger para Auditoria de Atualizações (`UPDATE`)**
### **Objetivo**
O trigger de UPDATE rastreia modificações feitas nas emendas, salvando tanto os dados anteriores quanto os dados atualizados.

```SQL
CREATE DEFINER = root@localhost TRIGGER trg_auditoria_emendas_update
    AFTER UPDATE
    ON emendas_otimizada
    FOR EACH ROW
BEGIN
    INSERT INTO log_emendas (id_emenda, tipo_operacao, usuario_responsavel, dados_anteriores, dados_novos)
    VALUES (
        OLD.id_emenda,
        'UPDATE',
        USER(),
        CONCAT('codigo_da_emenda: ', OLD.codigo_da_emenda, ', ano_da_emenda: ', OLD.ano_da_emenda,
               ', numero_da_emenda: ', OLD.numero_da_emenda, ', valor_empenhado: ', OLD.valor_empenhado,
               ', valor_pago: ', OLD.valor_pago),
        CONCAT('codigo_da_emenda: ', NEW.codigo_da_emenda, ', ano_da_emenda: ', NEW.ano_da_emenda,
               ', numero_da_emenda: ', NEW.numero_da_emenda, ', valor_empenhado: ', NEW.valor_empenhado,
               ', valor_pago: ', NEW.valor_pago)
    );
END;
```

## **Trigger para Integridade de localização**
### **Objetivo**
Criamos dois trigger adicionais que impedem a inserção ou atualização de uma emenda na tabela emendas_otimizada caso 
nenhuma localidade (cidade, estado, região ou abrangência especial) seja informada.

```SQL
CREATE TRIGGER trg_valida_localidade_emenda
BEFORE INSERT ON emendas_otimizada
FOR EACH ROW
BEGIN
    IF NEW.id_cidade IS NULL 
       AND NEW.id_estado IS NULL 
       AND NEW.id_regiao IS NULL 
       AND NEW.id_abrangencia IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: A emenda deve ter pelo menos uma localidade definida (cidade, estado, região ou abrangência especial).';
    END IF;
END;

CREATE TRIGGER trg_valida_localidade_emenda_update
BEFORE UPDATE ON emendas_otimizada
FOR EACH ROW
BEGIN
    IF NEW.id_cidade IS NULL 
       AND NEW.id_estado IS NULL 
       AND NEW.id_regiao IS NULL 
       AND NEW.id_abrangencia IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: A emenda deve ter pelo menos uma localidade definida (cidade, estado, região ou abrangência especial).';
    END IF;
END;
```
1. Trigger trg_valida_localidade_emenda (INSERT)
- Antes de uma nova emenda ser inserida, ele verifica se todas as colunas de localidade (id_cidade, id_estado, id_regiao, id_abrangencia) estão nulas.
- Se todas estiverem nulas, um erro é lançado e a inserção é cancelada.

2. Trigger trg_valida_localidade_emenda_update (UPDATE)
- Antes de uma emenda ser atualizada, ele executa a mesma validação.
- Se a atualização remover todas as informações de localidade, um erro é lançado e a atualização é rejeitada.

---

# **Visão de Localidade das Emendas**
A view vw_localidade_emenda foi criada para facilitar consultas sobre as emendas, exibindo de forma clara a localidade
associada a cada uma delas, sem precisar realizar múltiplos JOINs diretamente nas consultas.

```SQL
CREATE OR REPLACE VIEW vw_localidade_emenda AS
SELECT 
    eo.id_emenda AS id_emenda,
    CASE
        WHEN eo.id_cidade IS NOT NULL THEN 
            CONCAT(c.nome_cidade, ' - ', COALESCE(est.sigla_uf, 'UF Desconhecida'))
        WHEN eo.id_estado IS NOT NULL THEN 
            est.nome_estado
        WHEN eo.id_regiao IS NOT NULL THEN 
            r.nome_regiao
        WHEN eo.id_abrangencia IS NOT NULL THEN 
            ae.nome_abrangencia
        ELSE 
            'Localidade indefinida'
    END AS localidade,
    eo.ano_da_emenda,
    f.nome_funcao,
    s.nome_subfuncao,
    COALESCE(eo.valor_empenhado, 0.00) AS valor_empenhado,
    COALESCE(eo.valor_pago, 0.00) AS valor_pago
FROM emendas_otimizada eo
LEFT JOIN cidade c ON eo.id_cidade = c.id_cidade
LEFT JOIN estado est ON c.id_estado = est.id_estado
LEFT JOIN regiao r ON eo.id_regiao = r.id_regiao
LEFT JOIN abrangencia_especial ae ON eo.id_abrangencia = ae.id_abrangencia
LEFT JOIN funcao f ON eo.id_funcao = f.codigo_funcao
LEFT JOIN subfuncao s ON eo.id_subfuncao = s.codigo_subfuncao;
```

## Objetivo da View
- Criar uma representação mais acessível das emendas com as respectivas informações de localidade.
- Evitar que consultas manuais precisem repetir múltiplos JOINs, simplificando análises e relatórios.
- Normalizar a apresentação dos dados ao fornecer a localidade em uma única coluna formatada.


## Como a Localidade é Determinada?

A prioridade da localidade é definida na seguinte ordem:
1. Cidade (concatenando nome_cidade e sigla_uf do estado correspondente)
2. Estado (nome completo do estado)
3. Região (caso apenas a região esteja informada)
4. Abrangência Especial (casos como “Nacional”, “Múltiplo” ou “Exterior”)
5. Caso nenhuma das informações esteja presente, exibe “Localidade indefinida”

Essa hierarquia garante que sempre haja um campo descritivo da localidade da emenda.


## Benefícios da View

- Facilita consultas: Os dados já vêm organizados sem a necessidade de JOINs manuais.
- Padroniza a saída: As informações de localidade seguem uma hierarquia bem definida.
- Melhora a legibilidade: Permite visualizar rapidamente onde cada emenda está sendo aplicada.
- Reduz esforço computacional: Evita múltiplos JOINs em consultas frequentes.

---

# **Procedimento Armazenado para Análise de Emendas**
A procedure sp_analisar_emendas_transparencia tem o objetivo de avaliar a transparência das emendas parlamentares, 
classificando cada emenda de acordo com o nível de risco financeiro e registrando as análises em um log específico.

```SQL
CREATE PROCEDURE sp_analisar_emendas_transparencia(IN p_ano_da_emenda INT, IN p_id_autor INT)
BEGIN
    -- Declaração de variáveis
    DECLARE v_id_emenda INT;
    DECLARE v_ano_da_emenda INT;
    DECLARE v_nome_autor VARCHAR(255);
    DECLARE v_localidade VARCHAR(255);
    DECLARE v_valor_empenhado DECIMAL(15, 2);
    DECLARE v_valor_liquidado DECIMAL(15, 2);
    DECLARE v_valor_pago DECIMAL(15, 2);
    DECLARE v_restos_a_pagar DECIMAL(15, 2);
    DECLARE v_nivel_risco ENUM('BAIXO', 'MEDIO', 'ALTO');
    DECLARE v_mensagem TEXT;
    DECLARE done INT DEFAULT 0;

    -- Cursor para iterar as emendas
    DECLARE cur_emendas CURSOR FOR
        SELECT eo.id_emenda, eo.ano_da_emenda, a.nome_do_autor_da_emenda,
               CASE
                   WHEN eo.id_cidade IS NOT NULL THEN CONCAT(c.nome_cidade, ' - ', est.sigla_uf)
                   WHEN eo.id_estado IS NOT NULL THEN est.nome_estado
                   WHEN eo.id_regiao IS NOT NULL THEN r.nome_regiao
                   WHEN eo.id_abrangencia IS NOT NULL THEN ae.nome_abrangencia
                   ELSE 'Localidade indefinida'
               END AS localidade,
               eo.valor_empenhado, eo.valor_liquidado, eo.valor_pago, eo.valor_restos_a_pagar_inscritos
        FROM emendas_otimizada eo
        LEFT JOIN autor a ON eo.id_autor = a.codigo_do_autor_da_emenda
        LEFT JOIN cidade c ON eo.id_cidade = c.id_cidade
        LEFT JOIN estado est ON c.id_estado = est.id_estado
        LEFT JOIN regiao r ON eo.id_regiao = r.id_regiao
        LEFT JOIN abrangencia_especial ae ON eo.id_abrangencia = ae.id_abrangencia
        WHERE eo.ano_da_emenda = p_ano_da_emenda AND eo.id_autor = p_id_autor;

    -- Controlador de término do loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Primeiro, apagar os registros anteriores do log para reanálise
    DELETE FROM log_relatorio_emendas;

    -- Abrir o cursor
    OPEN cur_emendas;

    read_loop: LOOP
        -- Ler os dados do cursor
        FETCH cur_emendas INTO v_id_emenda, v_ano_da_emenda, v_nome_autor, v_localidade,
                             v_valor_empenhado, v_valor_liquidado, v_valor_pago, v_restos_a_pagar;

        -- Verificar se o loop deve terminar
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Classificação do nível de risco com base na lógica ajustada
        IF v_valor_pago > v_valor_liquidado THEN
            SET v_nivel_risco = 'ALTO';
            SET v_mensagem = CONCAT('Valor pago (', v_valor_pago, ') superior ao valor liquidado (', v_valor_liquidado, '). Verificar possível irregularidade.');
        ELSEIF v_restos_a_pagar > (v_valor_empenhado * 0.5) THEN
            SET v_nivel_risco = 'MEDIO';
            SET v_mensagem = CONCAT('Restos a pagar elevados: ', v_restos_a_pagar, ' (> 50% do valor empenhado).');
        ELSE
            SET v_nivel_risco = 'BAIXO';
            SET v_mensagem = 'Emenda dentro dos parâmetros normais.';
        END IF;

        -- Inserir o registro no log
        INSERT INTO log_relatorio_emendas (
            id_emenda, ano_da_emenda, autor_emenda, localidade, nivel_risco, mensagem
        )
        VALUES (
            v_id_emenda, v_ano_da_emenda, v_nome_autor, v_localidade, v_nivel_risco, v_mensagem
        );
    END LOOP;

    -- Fechar o cursor
    CLOSE cur_emendas;
END;
```

## Critérios de Classificação de Risco

A análise considera três níveis de risco baseados em inconsistências nos valores financeiros:
1. Risco ALTO
- O valor pago (valor_pago) é maior que o valor liquidado (valor_liquidado).
- Pode indicar um pagamento irregular antes da liquidação correta.
- Exemplo de mensagem:

`Valor pago (200,000.00) superior ao valor liquidado (150,000.00). Verificar possível irregularidade.`

2. Risco MÉDIO
- O valor de restos a pagar (valor_restos_a_pagar_inscritos) ultrapassa 50% do valor empenhado (valor_empenhado).
- Isso pode indicar que a emenda está demorando para ser executada.
- Exemplo de mensagem:
`Restos a pagar elevados: 300,000.00 (> 50% do valor empenhado).`

3. Risco BAIXO
- Todos os valores estão dentro dos padrões esperados, sem indícios de inconsistência.
- Exemplo de mensagem:
`Emenda dentro dos parâmetros normais.`

### Benefícios da Procedure

- Automatização da auditoria: A análise de risco é feita de forma padronizada e automática.
- Rastreamento de inconsistências: Possíveis problemas financeiros são registrados para futuras investigações.
- Facilidade de monitoramento: O banco de dados mantém um histórico das análises no log de transparência.
- Redução de fraudes e erros: Ajuda a detectar pagamentos irregulares e valores inconsistentes.

A execução da procedure é simples e pode ser feita para analisar as emendas de um determinado parlamentar em um ano específico:

`CALL sp_analisar_emendas_transparencia(2023, 101);`

Explicação:
- 2023 → Ano das emendas que devem ser analisadas.
- 101 → ID do autor cujas emendas serão auditadas.

Após a execução, a tabela log_relatorio_emendas será atualizada com os resultados da auditoria.

---
# Exemplos de consultas
## Consulta 1 - 
```SQL
SELECT 
    eo.ano_da_emenda,
    SUM(eo.valor_empenhado) AS total_empenhado,
    SUM(eo.valor_pago) AS total_pago,
    SUM(eo.valor_empenhado - eo.valor_pago) AS total_nao_pago
FROM emendas_otimizada eo
GROUP BY eo.ano_da_emenda
ORDER BY eo.ano_da_emenda DESC;
```
| ano\_da\_emenda | total\_empenhado | total\_pago | total\_nao\_pago |
| :--- | :--- | :--- | :--- |
| 2024 | 45599169440.81 | 31471329508.74 | 14127839932.07 |
| 2023 | 41629677470.73 | 22921183876.05 | 18708493594.68 |
| 2022 | 25575641587.24 | 17077711874.52 | 8497929712.72 |
| 2021 | 42613294997.35 | 16770232313.24 | 25843062684.11 |
| 2020 | 40361933760.50 | 19205037671.13 | 21156896089.37 |
| 2019 | 14318234969.64 | 6099376135.03 | 8218858834.61 |
| 2018 | 12467480479.18 | 5807810268.92 | 6659670210.26 |
| 2017 | 23153005372.45 | 10564854563.34 | 12588150809.11 |
| 2016 | 30489988421.85 | 19804964808.03 | 10685023613.82 |
| 2015 | 3516461496.89 | 25864983.41 | 3490596513.48 |
| 2014 | 6162372099.08 | 140289522.84 | 6022082576.24 |

## Consulta 2 - Valores das Emendas Parlamentares agrupadas por Autor
```SQL
SELECT 
    a.nome_do_autor_da_emenda AS autor,
    SUM(eo.valor_empenhado) AS total_empenhado,
    SUM(eo.valor_liquidado) AS total_liquidado,
    SUM(eo.valor_pago) AS total_pago
FROM emendas_otimizada eo
JOIN autor a ON eo.id_autor = a.codigo_do_autor_da_emenda
GROUP BY a.nome_do_autor_da_emenda
ORDER BY total_pago DESC
LIMIT 16;
```

