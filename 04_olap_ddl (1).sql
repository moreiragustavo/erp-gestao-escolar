USE sisgesc;

-- =========================================
-- MODELO ESTRELA (OLAP) - PROCESSO FINANCEIRO
-- =========================================
-- Processo de negocio modelado:
--   Recebimento de pagamentos de mensalidades.
--
-- Granularidade da fato_financeiro (regra de 1 linha):
--   1 linha = 1 pagamento efetivado (tb_pagamentos.pk_pagamento_id),
--   associado a 1 aluno, 1 curso, 1 unidade e 1 data de pagamento.
--
-- Padrao de chaves no DW:
--   SK_* = Surrogate Key (inteiro sequencial interno do DW).
--   NK_* = Natural Key (chave de negocio oriunda do OLTP).

CREATE TABLE IF NOT EXISTS dim_tempo (
    sk_tempo INT PRIMARY KEY AUTO_INCREMENT,
    data_calendario DATE NOT NULL UNIQUE,
    dia TINYINT NOT NULL,
    mes TINYINT NOT NULL,
    nome_mes VARCHAR(20) NOT NULL,
    trimestre TINYINT NOT NULL,
    ano SMALLINT NOT NULL
);


CREATE TABLE IF NOT EXISTS dim_aluno (
    sk_aluno INT PRIMARY KEY AUTO_INCREMENT,
    nk_aluno_id INT NOT NULL UNIQUE,
    nome_completo VARCHAR(140) NOT NULL,
    status_aluno ENUM('ATIVO', 'INATIVO', 'TRANCADO') NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_curso (
    sk_curso INT PRIMARY KEY AUTO_INCREMENT,
    nk_curso_id INT NOT NULL UNIQUE,
    nome_curso VARCHAR(100) NOT NULL,
    carga_horaria_total INT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_professor (
    sk_professor INT PRIMARY KEY AUTO_INCREMENT,
    nk_professor_id INT NOT NULL UNIQUE,
    nome_completo VARCHAR(140) NOT NULL,
    nivel_academico ENUM('GRADUACAO', 'ESPECIALIZACAO', 'MESTRADO', 'DOUTORADO') NOT NULL,
    carga_horaria_semanal INT NOT NULL,
    situacao_professor ENUM('ATIVO', 'AFASTADO', 'INATIVO') NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_unidade (
    sk_unidade INT PRIMARY KEY AUTO_INCREMENT,
    nk_unidade_codigo VARCHAR(20) NOT NULL UNIQUE,
    nome_unidade VARCHAR(100) NOT NULL,
    cidade VARCHAR(60) NOT NULL,
    uf CHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS fato_financeiro (
    sk_fato BIGINT PRIMARY KEY AUTO_INCREMENT,
    sk_tempo INT NOT NULL,
    sk_aluno INT NOT NULL,
    sk_curso INT NOT NULL,
    sk_unidade INT NOT NULL,
    nk_pagamento_id INT NOT NULL UNIQUE,
    valor_pago DECIMAL(10, 2) NOT NULL,
    qtd_pagamentos INT NOT NULL DEFAULT 1,
    FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo),
    FOREIGN KEY (sk_aluno) REFERENCES dim_aluno(sk_aluno),
    FOREIGN KEY (sk_curso) REFERENCES dim_curso(sk_curso),
    FOREIGN KEY (sk_unidade) REFERENCES dim_unidade(sk_unidade)
);

CREATE INDEX idx_fato_financeiro_tempo ON fato_financeiro (sk_tempo);
CREATE INDEX idx_fato_financeiro_aluno ON fato_financeiro (sk_aluno);
CREATE INDEX idx_fato_financeiro_curso ON fato_financeiro (sk_curso);
CREATE INDEX idx_fato_financeiro_unidade ON fato_financeiro (sk_unidade);

-- Tabela de auditoria do ETL financeiro.
CREATE TABLE IF NOT EXISTS etl_auditoria_financeiro (
    pk_execucao_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    processo VARCHAR(80) NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME,
    status_execucao ENUM('INICIADO', 'SUCESSO', 'ERRO') NOT NULL,
    qtd_registros_staging INT NOT NULL DEFAULT 0,
    qtd_dim_tempo INT NOT NULL DEFAULT 0,
    qtd_dim_aluno INT NOT NULL DEFAULT 0,
    qtd_dim_curso INT NOT NULL DEFAULT 0,
    qtd_dim_unidade INT NOT NULL DEFAULT 0,
    qtd_dim_professor INT NOT NULL DEFAULT 0,
    qtd_fato_financeiro INT NOT NULL DEFAULT 0,
    soma_oltp DECIMAL(14, 2) NOT NULL DEFAULT 0,
    soma_olap DECIMAL(14, 2) NOT NULL DEFAULT 0,
    validacao_soma ENUM('OK', 'DIVERGENTE') NOT NULL DEFAULT 'DIVERGENTE',
    observacao VARCHAR(255)
);
