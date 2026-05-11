USE sisgesc;

-- =========================================
-- MODULO ACADEMICO
-- =========================================
CREATE TABLE tb_alunos (
    pk_aluno_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    sobrenome VARCHAR(60) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    status_aluno ENUM('ATIVO', 'INATIVO', 'TRANCADO') NOT NULL,
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
    FOREIGN KEY (fk_curso_id) REFERENCES tb_cursos (pk_curso_id)
);

CREATE TABLE tb_turmas (
    pk_turma_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_turma VARCHAR(50) NOT NULL,
    fk_disciplina_id INT,
    semestre VARCHAR(10),
    FOREIGN KEY (fk_disciplina_id) REFERENCES tb_disciplinas (pk_disciplina_id)
);

CREATE TABLE tb_matriculas (
    fk_aluno_id INT,
    fk_turma_id INT,
    data_matricula DATE NOT NULL,
    status_matricula ENUM('ATIVA', 'CANCELADA', 'CONCLUIDA'),
    PRIMARY KEY (fk_aluno_id, fk_turma_id),
    FOREIGN KEY (fk_aluno_id) REFERENCES tb_alunos (pk_aluno_id),
    FOREIGN KEY (fk_turma_id) REFERENCES tb_turmas (pk_turma_id)
);

CREATE TABLE tb_notas (
    fk_aluno_id INT,
    fk_turma_id INT,
    tipo_avaliacao ENUM('AV1', 'AV2', 'AV3', 'FINAL'),
    nota DECIMAL(4, 2) CHECK (nota BETWEEN 0 AND 10),
    PRIMARY KEY (fk_aluno_id, fk_turma_id, tipo_avaliacao),
    FOREIGN KEY (fk_aluno_id, fk_turma_id) REFERENCES tb_matriculas (fk_aluno_id, fk_turma_id)
);

CREATE TABLE tb_faltas (
    fk_aluno_id INT,
    fk_turma_id INT,
    quantidade_faltas INT DEFAULT 0,
    PRIMARY KEY (fk_aluno_id, fk_turma_id),
    FOREIGN KEY (fk_aluno_id, fk_turma_id) REFERENCES tb_matriculas (fk_aluno_id, fk_turma_id)
);

-- =========================================
-- MODULO RH
-- =========================================
CREATE TABLE tb_funcionarios (
    pk_funcionario_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    sobrenome VARCHAR(60) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    cargo VARCHAR(50),
    data_admissao DATE
);

CREATE TABLE tb_professores (
    pk_professor_id INT PRIMARY KEY,
    nivel_academico ENUM('GRADUACAO', 'ESPECIALIZACAO', 'MESTRADO', 'DOUTORADO') NOT NULL,
    carga_horaria_semanal INT NOT NULL,
    situacao_professor ENUM('ATIVO', 'AFASTADO', 'INATIVO') NOT NULL,
    FOREIGN KEY (pk_professor_id) REFERENCES tb_funcionarios (pk_funcionario_id)
);

CREATE TABLE tb_professor_especialidades (
    fk_professor_id INT NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    PRIMARY KEY (fk_professor_id, especialidade),
    FOREIGN KEY (fk_professor_id) REFERENCES tb_professores (pk_professor_id)
);

CREATE TABLE tb_vinculos_professor_disciplina (
    fk_professor_id INT,
    fk_disciplina_id INT,
    PRIMARY KEY (fk_professor_id, fk_disciplina_id),
    FOREIGN KEY (fk_professor_id) REFERENCES tb_professores (pk_professor_id),
    FOREIGN KEY (fk_disciplina_id) REFERENCES tb_disciplinas (pk_disciplina_id)
);

CREATE TABLE tb_folha_pagamento (
    pk_folha_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_funcionario_id INT NOT NULL,
    mes_referencia DATE NOT NULL,
    salario_base DECIMAL(10, 2) NOT NULL,
    descontos DECIMAL(10, 2) DEFAULT 0,
    salario_liquido DECIMAL(10, 2) NOT NULL,
    data_pagamento DATE,
    status ENUM('PENDENTE', 'PAGO') DEFAULT 'PENDENTE',
    UNIQUE (fk_funcionario_id, mes_referencia),
    FOREIGN KEY (fk_funcionario_id) REFERENCES tb_funcionarios (pk_funcionario_id)
);

-- =========================================
-- MODULO FINANCEIRO
-- =========================================
CREATE TABLE tb_contratos_educacionais (
    pk_contrato_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_aluno_id INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    valor_total DECIMAL(10, 2) NOT NULL,
    status ENUM('ATIVO', 'ENCERRADO', 'CANCELADO'),
    FOREIGN KEY (fk_aluno_id) REFERENCES tb_alunos (pk_aluno_id)
);

CREATE TABLE tb_mensalidades (
    pk_mensalidade_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_contrato_id INT,
    data_vencimento DATE NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    status ENUM('PENDENTE', 'PAGO', 'ATRASADO') DEFAULT 'PENDENTE',
    FOREIGN KEY (fk_contrato_id) REFERENCES tb_contratos_educacionais (pk_contrato_id)
);

CREATE TABLE tb_pagamentos (
    pk_pagamento_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_mensalidade_id INT UNIQUE,
    data_pagamento DATE,
    valor_pago DECIMAL(10, 2),
    FOREIGN KEY (fk_mensalidade_id) REFERENCES tb_mensalidades (pk_mensalidade_id)
);

DELIMITER //
CREATE TRIGGER trg_valida_contrato_ativo
BEFORE INSERT ON tb_pagamentos
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT c.status
    INTO v_status
    FROM tb_mensalidades m
    JOIN tb_contratos_educacionais c ON m.fk_contrato_id = c.pk_contrato_id
    WHERE m.pk_mensalidade_id = NEW.fk_mensalidade_id;

    IF v_status != 'ATIVO' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pagamento negado: contrato nao esta ativo.';
    END IF;
END//
DELIMITER ;

-- =========================================
-- INDICES INICIAIS DE PERFORMANCE
-- =========================================
CREATE INDEX idx_matriculas_aluno ON tb_matriculas (fk_aluno_id);
CREATE INDEX idx_contratos_aluno ON tb_contratos_educacionais (fk_aluno_id);
CREATE INDEX idx_mensalidades_cont ON tb_mensalidades (fk_contrato_id);
CREATE INDEX idx_notas_aluno ON tb_notas (fk_aluno_id);
