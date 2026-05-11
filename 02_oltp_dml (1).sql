USE sisgesc;

-- CARGA DE DADOS IDEMPOTENTE - SISGESC
-- Este script carrega os dados iniciais de forma idempotente
-- utilizando ON DUPLICATE KEY UPDATE.
-- MODULO ACADEMICO

INSERT INTO tb_cursos (pk_curso_id, nome_curso, carga_horaria_total)
VALUES
  (1, 'Analise e Desenvolvimento de Sistemas', 2000),
  (2, 'Administracao', 3000),
  (3, 'Pedagogia', 3200)
ON DUPLICATE KEY UPDATE
  nome_curso = VALUES(nome_curso),
  carga_horaria_total = VALUES(carga_horaria_total);

INSERT INTO tb_disciplinas (pk_disciplina_id, nome_disciplina, carga_horaria, fk_curso_id)
VALUES
  (1, 'Banco de Dados', 80, 1),
  (2, 'Programacao Web', 80, 1),
  (3, 'Gestao Financeira', 60, 2),
  (4, 'Metodologia Cientifica', 40, 3),
  (5, 'Didatica', 60, 3)
ON DUPLICATE KEY UPDATE
  nome_disciplina = VALUES(nome_disciplina),
  carga_horaria = VALUES(carga_horaria),
  fk_curso_id = VALUES(fk_curso_id);

INSERT INTO tb_turmas (pk_turma_id, nome_turma, fk_disciplina_id, semestre)
VALUES
  (1, 'BD-2026A', 1, '2026.1'),
  (2, 'WEB-2026A', 2, '2026.1'),
  (3, 'GF-2026A', 3, '2026.1'),
  (4, 'MET-2026A', 4, '2026.1'),
  (5, 'DID-2026A', 5, '2026.1')
ON DUPLICATE KEY UPDATE
  nome_turma = VALUES(nome_turma),
  fk_disciplina_id = VALUES(fk_disciplina_id),
  semestre = VALUES(semestre);

INSERT INTO tb_alunos (pk_aluno_id, nome, sobrenome, cpf, data_nascimento, status_aluno)
VALUES
  (1, 'Lucas', 'Oliveira', '11111111111', '2002-03-10', 'ATIVO'),
  (2, 'Mariana', 'Souza', '22222222222', '2001-06-21', 'ATIVO'),
  (3, 'Pedro', 'Silva', '33333333333', '2000-11-04', 'INATIVO'),
  (4, 'Aline', 'Ferreira', '44444444444', '2003-02-15', 'ATIVO'),
  (5, 'Rafaela', 'Santos', '55555555555', '2002-08-30', 'ATIVO'),
  (6, 'Joao', 'Mendes', '66666666666', '2001-12-12', 'TRANCADO')
ON DUPLICATE KEY UPDATE
  nome = VALUES(nome),
  sobrenome = VALUES(sobrenome),
  cpf = VALUES(cpf),
  data_nascimento = VALUES(data_nascimento),
  status_aluno = VALUES(status_aluno);

INSERT INTO tb_matriculas (fk_aluno_id, fk_turma_id, data_matricula, status_matricula)
VALUES
  (1, 1, '2026-01-15', 'ATIVA'),
  (1, 2, '2026-01-15', 'ATIVA'),
  (2, 1, '2026-01-18', 'ATIVA'),
  (3, 3, '2025-02-10', 'CONCLUIDA'),
  (4, 4, '2026-01-20', 'ATIVA'),
  (5, 5, '2026-01-22', 'ATIVA'),
  (6, 2, '2026-01-25', 'CANCELADA')
ON DUPLICATE KEY UPDATE
  data_matricula = VALUES(data_matricula),
  status_matricula = VALUES(status_matricula);

INSERT INTO tb_notas (fk_aluno_id, fk_turma_id, tipo_avaliacao, nota)
VALUES
  (1, 1, 'AV1', 8.50),
  (1, 1, 'AV2', 7.80),
  (1, 2, 'AV1', 9.10),
  (2, 1, 'AV1', 6.90),
  (2, 1, 'AV2', 7.20),
  (3, 3, 'FINAL', 8.00),
  (4, 4, 'AV1', 7.50),
  (5, 5, 'AV1', 9.30)
ON DUPLICATE KEY UPDATE
  nota = VALUES(nota);

INSERT INTO tb_faltas (fk_aluno_id, fk_turma_id, quantidade_faltas)
VALUES
  (1, 1, 2),
  (1, 2, 1),
  (2, 1, 4),
  (3, 3, 3),
  (4, 4, 0),
  (5, 5, 1),
  (6, 2, 5)
ON DUPLICATE KEY UPDATE
  quantidade_faltas = VALUES(quantidade_faltas);

-- MODULO RH (RECURSOS HUMANOS)

INSERT INTO tb_funcionarios (pk_funcionario_id, nome, sobrenome, cpf, cargo, data_admissao)
VALUES
  (1, 'Ana', 'Souza', '77777777777', 'Professor', '2020-02-10'),
  (2, 'Bruno', 'Lima', '88888888888', 'Professor', '2019-03-01'),
  (3, 'Carla', 'Mendes', '99999999999', 'Professor', '2021-08-16'),
  (4, 'Diego', 'Santos', '10101010101', 'Coordenador', '2018-01-05'),
  (5, 'Elisa', 'Rocha', '12121212121', 'Analista Financeiro', '2022-04-11')
ON DUPLICATE KEY UPDATE
  nome = VALUES(nome),
  sobrenome = VALUES(sobrenome),
  cpf = VALUES(cpf),
  cargo = VALUES(cargo),
  data_admissao = VALUES(data_admissao);

INSERT INTO tb_professores (pk_professor_id, nivel_academico, carga_horaria_semanal, situacao_professor)
VALUES
  (1, 'MESTRADO', 20, 'ATIVO'),
  (2, 'DOUTORADO', 24, 'ATIVO'),
  (3, 'ESPECIALIZACAO', 16, 'ATIVO')
ON DUPLICATE KEY UPDATE
  nivel_academico = VALUES(nivel_academico),
  carga_horaria_semanal = VALUES(carga_horaria_semanal),
  situacao_professor = VALUES(situacao_professor);

INSERT INTO tb_professor_especialidades (fk_professor_id, especialidade)
VALUES
  (1, 'Banco de Dados'),
  (1, 'Engenharia de Software'),
  (2, 'Gestao Financeira'),
  (3, 'Didatica')
ON DUPLICATE KEY UPDATE
  especialidade = VALUES(especialidade);

INSERT INTO tb_vinculos_professor_disciplina (fk_professor_id, fk_disciplina_id)
VALUES
  (1, 1),
  (1, 2),
  (2, 3),
  (3, 4),
  (3, 5)
ON DUPLICATE KEY UPDATE
  fk_disciplina_id = VALUES(fk_disciplina_id);

INSERT INTO tb_folha_pagamento (
  fk_funcionario_id,
  mes_referencia,
  salario_base,
  descontos,
  salario_liquido,
  data_pagamento,
  status
)
VALUES
  (1, '2026-04-01', 6500.00, 500.00, 6000.00, '2026-04-30', 'PAGO'),
  (2, '2026-04-01', 7000.00, 700.00, 6300.00, '2026-04-30', 'PAGO'),
  (3, '2026-04-01', 5000.00, 350.00, 4650.00, '2026-04-30', 'PAGO'),
  (4, '2026-04-01', 8000.00, 900.00, 7100.00, '2026-04-30', 'PAGO'),
  (5, '2026-04-01', 4200.00, 250.00, 3950.00, '2026-04-30', 'PAGO')
ON DUPLICATE KEY UPDATE
  salario_base = VALUES(salario_base),
  descontos = VALUES(descontos),
  salario_liquido = VALUES(salario_liquido),
  data_pagamento = VALUES(data_pagamento),
  status = VALUES(status);

-- MODULO FINANCEIRO

INSERT INTO tb_contratos_educacionais (pk_contrato_id, fk_aluno_id, data_inicio, data_fim, valor_total, status)
VALUES
  (1, 1, '2026-01-10', '2026-12-10', 7200.00, 'ATIVO'),
  (2, 2, '2026-01-12', '2026-12-12', 7200.00, 'ATIVO'),
  (3, 3, '2025-01-10', '2025-12-10', 3600.00, 'ENCERRADO'),
  (4, 4, '2026-01-15', NULL, 3600.00, 'CANCELADO'),
  (5, 5, '2026-01-20', '2026-12-20', 4800.00, 'ATIVO'),
  (6, 6, '2026-01-25', '2026-12-25', 6000.00, 'ATIVO')
ON DUPLICATE KEY UPDATE
  fk_aluno_id = VALUES(fk_aluno_id),
  data_inicio = VALUES(data_inicio),
  data_fim = VALUES(data_fim),
  valor_total = VALUES(valor_total),
  status = VALUES(status);

INSERT INTO tb_mensalidades (pk_mensalidade_id, fk_contrato_id, data_vencimento, valor, status)
VALUES
  (1, 1, '2026-02-10', 600.00, 'PAGO'),
  (2, 1, '2026-03-10', 600.00, 'PENDENTE'),
  (3, 2, '2026-02-10', 600.00, 'PAGO'),
  (4, 2, '2026-03-10', 600.00, 'ATRASADO'),
  (5, 3, '2025-11-10', 600.00, 'ATRASADO'),
  (6, 5, '2026-02-15', 400.00, 'PAGO'),
  (7, 6, '2026-02-20', 500.00, 'PAGO'),
  (8, 6, '2026-03-20', 500.00, 'PENDENTE')
ON DUPLICATE KEY UPDATE
  fk_contrato_id = VALUES(fk_contrato_id),
  data_vencimento = VALUES(data_vencimento),
  valor = VALUES(valor),
  status = VALUES(status);

INSERT INTO tb_pagamentos (pk_pagamento_id, fk_mensalidade_id, data_pagamento, valor_pago)
VALUES
  (1, 1, '2026-02-09', 600.00),
  (2, 3, '2026-02-08', 600.00),
  (3, 6, '2026-02-14', 400.00),
  (4, 7, '2026-02-19', 500.00)
ON DUPLICATE KEY UPDATE
  fk_mensalidade_id = VALUES(fk_mensalidade_id),
  data_pagamento = VALUES(data_pagamento),
  valor_pago = VALUES(valor_pago);

