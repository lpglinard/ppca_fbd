-- 1. Criar a tabela funcao
CREATE TABLE funcao (
    codigo_funcao VARCHAR(50) PRIMARY KEY,
    nome_funcao VARCHAR(255) NOT NULL
);

-- 2. Migrar os dados de funcoes únicos para a tabela funcao
INSERT INTO funcao (codigo_funcao, nome_funcao)
SELECT DISTINCT codigo_funcao, nome_funcao
FROM emendas_parlamentares.emendas_otimizada;

-- 3. Criar a tabela subfuncao
CREATE TABLE subfuncao (
    codigo_subfuncao VARCHAR(50) PRIMARY KEY,
    nome_subfuncao VARCHAR(255) NOT NULL
);

-- 4. Migrar os dados de subfuncoes únicos para a tabela subfuncao
INSERT INTO subfuncao (codigo_subfuncao, nome_subfuncao)
SELECT DISTINCT codigo_subfuncao, nome_subfuncao
FROM emendas_parlamentares.emendas_otimizada;

-- 5. Criar a tabela autor
CREATE TABLE autor (
    codigo_do_autor_da_emenda VARCHAR(100) PRIMARY KEY,
    nome_do_autor_da_emenda VARCHAR(255) NOT NULL
);

-- 6. Migrar os dados de autores únicos para a tabela autor
INSERT INTO autor (codigo_do_autor_da_emenda, nome_do_autor_da_emenda)
SELECT codigo_do_autor_da_emenda, MIN(nome_do_autor_da_emenda) AS nome_do_autor_da_emenda
FROM emendas_parlamentares.emendas_otimizada
GROUP BY codigo_do_autor_da_emenda;

-- 7. Alterar a tabela emendas_otimizada para adicionar as chaves estrangeiras
ALTER TABLE emendas_parlamentares.emendas_otimizada
    -- Remover colunas redundantes (se necessário)
    DROP COLUMN nome_funcao,
    DROP COLUMN nome_subfuncao,
    DROP COLUMN nome_do_autor_da_emenda;

-- 8. Adicionar as chaves estrangeiras para relacionar com as tabelas normalizadas
ALTER TABLE emendas_otimizada
    ADD CONSTRAINT fk_funcao FOREIGN KEY (codigo_funcao) REFERENCES funcao (codigo_funcao),
    ADD CONSTRAINT fk_subfuncao FOREIGN KEY (codigo_subfuncao) REFERENCES subfuncao (codigo_subfuncao),
    ADD CONSTRAINT fk_autor FOREIGN KEY (codigo_do_autor_da_emenda) REFERENCES autor (codigo_do_autor_da_emenda);