SELECT 'Executando 00_reset.sql - reset do ambiente' AS etapa;
SOURCE 00_reset.sql;

SELECT 'Executando 01_oltp_ddl.sql - criacao da estrutura OLTP' AS etapa;
SOURCE 01_oltp_ddl.sql;

SELECT 'Prova idempotencia - antes da primeira carga' AS etapa;
DROP TEMPORARY TABLE IF EXISTS tmp_contagem_antes_carga;
CREATE TEMPORARY TABLE tmp_contagem_antes_carga (
  modulo VARCHAR(20) NOT NULL,
  tabela VARCHAR(64) NOT NULL,
  total_registros INT NOT NULL,
  PRIMARY KEY (tabela)
);
INSERT INTO tmp_contagem_antes_carga (modulo, tabela, total_registros)
SELECT 'ACADEMICO', 'tb_cursos', COUNT(*) FROM tb_cursos
UNION ALL SELECT 'ACADEMICO', 'tb_disciplinas', COUNT(*) FROM tb_disciplinas
UNION ALL SELECT 'ACADEMICO', 'tb_turmas', COUNT(*) FROM tb_turmas
UNION ALL SELECT 'ACADEMICO', 'tb_alunos', COUNT(*) FROM tb_alunos
UNION ALL SELECT 'ACADEMICO', 'tb_matriculas', COUNT(*) FROM tb_matriculas
UNION ALL SELECT 'ACADEMICO', 'tb_notas', COUNT(*) FROM tb_notas
UNION ALL SELECT 'ACADEMICO', 'tb_faltas', COUNT(*) FROM tb_faltas
UNION ALL SELECT 'RH', 'tb_funcionarios', COUNT(*) FROM tb_funcionarios
UNION ALL SELECT 'RH', 'tb_professores', COUNT(*) FROM tb_professores
UNION ALL SELECT 'RH', 'tb_professor_especialidades', COUNT(*) FROM tb_professor_especialidades
UNION ALL SELECT 'RH', 'tb_vinculos_professor_disciplina', COUNT(*) FROM tb_vinculos_professor_disciplina
UNION ALL SELECT 'RH', 'tb_folha_pagamento', COUNT(*) FROM tb_folha_pagamento
UNION ALL SELECT 'FINANCEIRO', 'tb_contratos_educacionais', COUNT(*) FROM tb_contratos_educacionais
UNION ALL SELECT 'FINANCEIRO', 'tb_mensalidades', COUNT(*) FROM tb_mensalidades
UNION ALL SELECT 'FINANCEIRO', 'tb_pagamentos', COUNT(*) FROM tb_pagamentos;
SELECT 'ANTES_1A_CARGA' AS etapa, modulo, tabela, total_registros
FROM tmp_contagem_antes_carga
ORDER BY FIELD(modulo, 'ACADEMICO', 'RH', 'FINANCEIRO'), tabela;

SELECT 'Executando 02_oltp_dml.sql - carga de dados OLTP (1a execucao)' AS etapa;
SOURCE 02_oltp_dml.sql;

SELECT 'Prova idempotencia - apos primeira carga' AS etapa;
DROP TEMPORARY TABLE IF EXISTS tmp_contagem_primeira_carga;
CREATE TEMPORARY TABLE tmp_contagem_primeira_carga (
  modulo VARCHAR(20) NOT NULL,
  tabela VARCHAR(64) NOT NULL,
  total_registros INT NOT NULL,
  PRIMARY KEY (tabela)
);
INSERT INTO tmp_contagem_primeira_carga (modulo, tabela, total_registros)
SELECT 'ACADEMICO', 'tb_cursos', COUNT(*) FROM tb_cursos
UNION ALL SELECT 'ACADEMICO', 'tb_disciplinas', COUNT(*) FROM tb_disciplinas
UNION ALL SELECT 'ACADEMICO', 'tb_turmas', COUNT(*) FROM tb_turmas
UNION ALL SELECT 'ACADEMICO', 'tb_alunos', COUNT(*) FROM tb_alunos
UNION ALL SELECT 'ACADEMICO', 'tb_matriculas', COUNT(*) FROM tb_matriculas
UNION ALL SELECT 'ACADEMICO', 'tb_notas', COUNT(*) FROM tb_notas
UNION ALL SELECT 'ACADEMICO', 'tb_faltas', COUNT(*) FROM tb_faltas
UNION ALL SELECT 'RH', 'tb_funcionarios', COUNT(*) FROM tb_funcionarios
UNION ALL SELECT 'RH', 'tb_professores', COUNT(*) FROM tb_professores
UNION ALL SELECT 'RH', 'tb_professor_especialidades', COUNT(*) FROM tb_professor_especialidades
UNION ALL SELECT 'RH', 'tb_vinculos_professor_disciplina', COUNT(*) FROM tb_vinculos_professor_disciplina
UNION ALL SELECT 'RH', 'tb_folha_pagamento', COUNT(*) FROM tb_folha_pagamento
UNION ALL SELECT 'FINANCEIRO', 'tb_contratos_educacionais', COUNT(*) FROM tb_contratos_educacionais
UNION ALL SELECT 'FINANCEIRO', 'tb_mensalidades', COUNT(*) FROM tb_mensalidades
UNION ALL SELECT 'FINANCEIRO', 'tb_pagamentos', COUNT(*) FROM tb_pagamentos;
SELECT 'APOS_1A_CARGA' AS etapa, modulo, tabela, total_registros
FROM tmp_contagem_primeira_carga
ORDER BY FIELD(modulo, 'ACADEMICO', 'RH', 'FINANCEIRO'), tabela;

SELECT 'Executando 02_oltp_dml.sql - segunda carga de dados' AS etapa;
SOURCE 02_oltp_dml.sql;

SELECT 'Prova idempotencia - teste de duplicatas apos segunda carga' AS etapa;
DROP TEMPORARY TABLE IF EXISTS tmp_contagem_segunda_carga;
CREATE TEMPORARY TABLE tmp_contagem_segunda_carga (
  modulo VARCHAR(20) NOT NULL,
  tabela VARCHAR(64) NOT NULL,
  total_registros INT NOT NULL,
  PRIMARY KEY (tabela)
);
INSERT INTO tmp_contagem_segunda_carga (modulo, tabela, total_registros)
SELECT 'ACADEMICO', 'tb_cursos', COUNT(*) FROM tb_cursos
UNION ALL SELECT 'ACADEMICO', 'tb_disciplinas', COUNT(*) FROM tb_disciplinas
UNION ALL SELECT 'ACADEMICO', 'tb_turmas', COUNT(*) FROM tb_turmas
UNION ALL SELECT 'ACADEMICO', 'tb_alunos', COUNT(*) FROM tb_alunos
UNION ALL SELECT 'ACADEMICO', 'tb_matriculas', COUNT(*) FROM tb_matriculas
UNION ALL SELECT 'ACADEMICO', 'tb_notas', COUNT(*) FROM tb_notas
UNION ALL SELECT 'ACADEMICO', 'tb_faltas', COUNT(*) FROM tb_faltas
UNION ALL SELECT 'RH', 'tb_funcionarios', COUNT(*) FROM tb_funcionarios
UNION ALL SELECT 'RH', 'tb_professores', COUNT(*) FROM tb_professores
UNION ALL SELECT 'RH', 'tb_professor_especialidades', COUNT(*) FROM tb_professor_especialidades
UNION ALL SELECT 'RH', 'tb_vinculos_professor_disciplina', COUNT(*) FROM tb_vinculos_professor_disciplina
UNION ALL SELECT 'RH', 'tb_folha_pagamento', COUNT(*) FROM tb_folha_pagamento
UNION ALL SELECT 'FINANCEIRO', 'tb_contratos_educacionais', COUNT(*) FROM tb_contratos_educacionais
UNION ALL SELECT 'FINANCEIRO', 'tb_mensalidades', COUNT(*) FROM tb_mensalidades
UNION ALL SELECT 'FINANCEIRO', 'tb_pagamentos', COUNT(*) FROM tb_pagamentos;
SELECT
  'TESTE_DUPLICIDADE' AS etapa,
  s.modulo,
  s.tabela,
  p.total_registros AS total_apos_1a_carga,
  s.total_registros AS total_apos_2a_carga,
  (s.total_registros - p.total_registros) AS delta,
  CASE
    WHEN s.total_registros = p.total_registros THEN 'NAO'
    ELSE 'SIM'
  END AS status_duplicata
FROM tmp_contagem_segunda_carga s
INNER JOIN tmp_contagem_primeira_carga p ON p.tabela = s.tabela
ORDER BY FIELD(s.modulo, 'ACADEMICO', 'RH', 'FINANCEIRO'), s.tabela;

SELECT 'Executando 03_oltp_queries.sql - consultas e transacoes OLTP' AS etapa;
SOURCE 03_oltp_queries.sql;

SELECT 'Executando 04_olap_ddl.sql - criacao da estrutura OLAP' AS etapa;
SOURCE 04_olap_ddl.sql;

SELECT 'Executando 05_etl.sql - processo ETL OLTP para OLAP' AS etapa;
SOURCE 05_etl.sql;

SELECT 'Executando 06_validacoes.sql - validacoes de consistencia' AS etapa;
SOURCE 06_validacoes.sql;

SELECT 'Executando 07_performance.sql - indices e explain' AS etapa;
SOURCE 07_performance.sql;

SELECT 'Execucao do run_all.sql concluida' AS etapa;
