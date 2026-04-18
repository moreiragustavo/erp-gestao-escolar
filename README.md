# erp-gestao-escolar

-- =========================
-- CRIAÇÃO DO BANCO
-- =========================
CREATE DATABASE sisgesc;
USE sisgesc;

-- =========================
-- MÓDULO ACADÊMICO
-- =========================

CREATE TABLE tb_alunos (
    pk_aluno_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_aluno VARCHAR(120) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    status_aluno VARCHAR(20) NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tb_cursos (
    pk_curso_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_curso VARCHAR(100) NOT NULL,
    carga_horaria_total INT NOT NULL
);

CREATE TABLE tb_disciplinas (
    pk_disciplina_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_disciplina VARCHAR(100) NOT NULL,
    carga_horaria INT NOT NULL,
    fk_curso_id INT,
    FOREIGN KEY (fk_curso_id) REFERENCES tb_cursos(pk_curso_id)
);

CREATE TABLE tb_turmas (
    pk_turma_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_turma VARCHAR(50) NOT NULL,
    fk_disciplina_id INT,
    semestre VARCHAR(10),
    FOREIGN KEY (fk_disciplina_id) REFERENCES tb_disciplinas(pk_disciplina_id)
);

CREATE TABLE tb_matriculas (
    fk_aluno_id INT,
    fk_turma_id INT,
    data_matricula DATE NOT NULL,
    status_matricula VARCHAR(20),
    PRIMARY KEY (fk_aluno_id, fk_turma_id),
    FOREIGN KEY (fk_aluno_id) REFERENCES tb_alunos(pk_aluno_id),
    FOREIGN KEY (fk_turma_id) REFERENCES tb_turmas(pk_turma_id)
);

CREATE TABLE tb_notas (
    pk_nota_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_aluno_id INT,
    fk_turma_id INT,
    nota DECIMAL(4,2) CHECK (nota BETWEEN 0 AND 10),
    FOREIGN KEY (fk_aluno_id, fk_turma_id)
        REFERENCES tb_matriculas(fk_aluno_id, fk_turma_id)
);

CREATE TABLE tb_faltas (
    fk_aluno_id INT,
    fk_turma_id INT,
    quantidade_faltas INT DEFAULT 0,
    PRIMARY KEY (fk_aluno_id, fk_turma_id),
    FOREIGN KEY (fk_aluno_id, fk_turma_id)
        REFERENCES tb_matriculas(fk_aluno_id, fk_turma_id)
);

-- =========================
-- MÓDULO RH
-- =========================

CREATE TABLE tb_funcionarios (
    pk_funcionario_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_funcionario VARCHAR(120) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    cargo VARCHAR(50),
    data_admissao DATE
);

CREATE TABLE tb_professores (
    pk_professor_id INT PRIMARY KEY,
    especialidade VARCHAR(100),
    FOREIGN KEY (pk_professor_id) REFERENCES tb_funcionarios(pk_funcionario_id)
);

-- 🔥 PK COMPOSTA (Professor x Disciplina)
CREATE TABLE tb_vinculos_professor_disciplina (
    fk_professor_id INT,
    fk_disciplina_id INT,
    PRIMARY KEY (fk_professor_id, fk_disciplina_id),
    FOREIGN KEY (fk_professor_id) REFERENCES tb_professores(pk_professor_id),
    FOREIGN KEY (fk_disciplina_id) REFERENCES tb_disciplinas(pk_disciplina_id)
);

-- =========================
-- MÓDULO FINANCEIRO
-- =========================

CREATE TABLE tb_contratos_educacionais (
    pk_contrato_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_aluno_id INT,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    valor_total DECIMAL(10,2),
    FOREIGN KEY (fk_aluno_id) REFERENCES tb_alunos(pk_aluno_id)
);

CREATE TABLE tb_mensalidades (
    pk_mensalidade_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_contrato_id INT,
    data_vencimento DATE NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDENTE',
    dias_atraso INT DEFAULT 0,
    FOREIGN KEY (fk_contrato_id) REFERENCES tb_contratos_educacionais(pk_contrato_id)
);

CREATE TABLE tb_pagamentos (
    pk_pagamento_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_mensalidade_id INT,
    data_pagamento DATE,
    valor_pago DECIMAL(10,2),
    FOREIGN KEY (fk_mensalidade_id) REFERENCES tb_mensalidades(pk_mensalidade_id)
);
