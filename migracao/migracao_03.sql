-- 1. Criar a tabela de estados (UF)
CREATE TABLE estado (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    sigla_uf VARCHAR(2) UNIQUE NOT NULL,
    nome_estado VARCHAR(100) NOT NULL
);

-- 2. Criar a tabela de cidades
CREATE TABLE cidade (
    id_cidade INT AUTO_INCREMENT PRIMARY KEY,
    nome_cidade VARCHAR(255) NOT NULL,
    id_estado INT,
    UNIQUE (nome_cidade, id_estado),
    FOREIGN KEY (id_estado) REFERENCES estado (id_estado)
);

-- 3. Criar a tabela de regiões
CREATE TABLE regiao (
    id_regiao INT AUTO_INCREMENT PRIMARY KEY,
    nome_regiao VARCHAR(100) UNIQUE NOT NULL
);

-- 4. Criar a tabela de abrangências especiais
CREATE TABLE abrangencia_especial (
    id_abrangencia INT AUTO_INCREMENT PRIMARY KEY,
    nome_abrangencia VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO estado (sigla_uf, nome_estado)
VALUES
('AC', 'Acre'),
('AL', 'Alagoas'),
('AP', 'Amapá'),
('AM', 'Amazonas'),
('BA', 'Bahia'),
('CE', 'Ceará'),
('DF', 'Distrito Federal'),
('ES', 'Espírito Santo'),
('GO', 'Goiás'),
('MA', 'Maranhão'),
('MT', 'Mato Grosso'),
('MS', 'Mato Grosso do Sul'),
('MG', 'Minas Gerais'),
('PA', 'Pará'),
('PB', 'Paraíba'),
('PR', 'Paraná'),
('PE', 'Pernambuco'),
('PI', 'Piauí'),
('RJ', 'Rio de Janeiro'),
('RN', 'Rio Grande do Norte'),
('RS', 'Rio Grande do Sul'),
('RO', 'Rondônia'),
('RR', 'Roraima'),
('SC', 'Santa Catarina'),
('SP', 'São Paulo'),
('SE', 'Sergipe'),
('TO', 'Tocantins');

INSERT INTO cidade (nome_cidade, id_estado)
SELECT DISTINCT
    SUBSTRING_INDEX(localidade_do_gasto, ' - ', 1) AS nome_cidade,
    (SELECT id_estado FROM estado WHERE sigla_uf = SUBSTRING_INDEX(localidade_do_gasto, ' - ', -1)) AS id_estado
FROM emendas_parlamentares.emendas_otimizada
WHERE localidade_do_gasto LIKE '% - %';

INSERT INTO regiao (nome_regiao)
VALUES ('Norte'), ('Nordeste'), ('Centro-Oeste'), ('Sudeste'), ('Sul');

INSERT INTO abrangencia_especial (nome_abrangencia)
VALUES ('Nacional', 'MÚLTIPLO', 'Exterior');

ALTER TABLE emendas_parlamentares.emendas_otimizada
    ADD COLUMN id_cidade INT NULL,
    ADD COLUMN id_estado INT NULL,
    ADD COLUMN id_regiao INT NULL,
    ADD COLUMN id_abrangencia INT NULL,
    ADD CONSTRAINT fk_cidade FOREIGN KEY (id_cidade) REFERENCES cidade (id_cidade),
    ADD CONSTRAINT fk_estado FOREIGN KEY (id_estado) REFERENCES estado (id_estado),
    ADD CONSTRAINT fk_regiao FOREIGN KEY (id_regiao) REFERENCES regiao (id_regiao),
    ADD CONSTRAINT fk_abrangencia FOREIGN KEY (id_abrangencia) REFERENCES abrangencia_especial (id_abrangencia);

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


ALTER TABLE emendas_parlamentares.emendas_otimizada
    DROP COLUMN localidade_do_gasto;