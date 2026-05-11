USE sisgesc;

-- =========================================
-- ETL OLTP -> OLAP (PROCESSO FINANCEIRO)
-- FASES: EXTRACT, TRANSFORM, LOAD e VALIDACAO
-- =========================================
SET @etl_inicio := NOW();

INSERT INTO etl_auditoria_financeiro (
    processo,
    data_inicio,
    status_execucao,
    observacao
)
VALUES (
    'etl_financeiro_pagamentos',
    @etl_inicio,
    'INICIADO',
    'Carga idempotente do modelo estrela financeiro'
);

SET @etl_execucao_id := LAST_INSERT_ID();

-- =========================================
-- FASE 1 - EXTRACT
-- Extraimos o conjunto transacional base de pagamentos.
-- =========================================
DROP TEMPORARY TABLE IF EXISTS stg_pagamentos_financeiro;
CREATE TEMPORARY TABLE stg_pagamentos_financeiro AS
SELECT
    p.pk_pagamento_id AS nk_pagamento_id,
    p.data_pagamento,
    p.valor_pago,
    c.fk_aluno_id AS nk_aluno_id,
    ac.fk_curso_id AS nk_curso_id
FROM tb_pagamentos p
JOIN tb_mensalidades m ON m.pk_mensalidade_id = p.fk_mensalidade_id
JOIN tb_contratos_educacionais c ON c.pk_contrato_id = m.fk_contrato_id
JOIN (
    SELECT
        mt.fk_aluno_id,
        MIN(d.fk_curso_id) AS fk_curso_id
    FROM tb_matriculas mt
    JOIN tb_turmas t ON t.pk_turma_id = mt.fk_turma_id
    JOIN tb_disciplinas d ON d.pk_disciplina_id = t.fk_disciplina_id
    GROUP BY mt.fk_aluno_id
) ac ON ac.fk_aluno_id = c.fk_aluno_id
WHERE p.data_pagamento IS NOT NULL;

SELECT COUNT(*) INTO @qtd_registros_staging
FROM stg_pagamentos_financeiro;

-- =========================================
-- FASE 2 - TRANSFORM
-- Padronizamos atributos de tempo para carga da dim_tempo.
-- =========================================
DROP TEMPORARY TABLE IF EXISTS stg_tempo_financeiro;
CREATE TEMPORARY TABLE stg_tempo_financeiro AS
SELECT DISTINCT
    sp.data_pagamento AS data_calendario,
    DAY(sp.data_pagamento) AS dia,
    MONTH(sp.data_pagamento) AS mes,
    ELT(MONTH(sp.data_pagamento), 'Janeiro', 'Fevereiro', 'Marco', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro') AS nome_mes,
    QUARTER(sp.data_pagamento) AS trimestre,
    YEAR(sp.data_pagamento) AS ano
FROM stg_pagamentos_financeiro sp;

-- =========================================
-- FASE 3 - LOAD (DIMENSOES)
-- =========================================
INSERT INTO dim_unidade (nk_unidade_codigo, nome_unidade, cidade, uf)
VALUES ('MATRIZ-001', 'Unidade Matriz', 'Sao Paulo', 'SP')
ON DUPLICATE KEY UPDATE
    nome_unidade = VALUES(nome_unidade),
    cidade = VALUES(cidade),
    uf = VALUES(uf);

INSERT INTO dim_tempo (data_calendario, dia, mes, nome_mes, trimestre, ano)
SELECT
    st.data_calendario,
    st.dia,
    st.mes,
    st.nome_mes,
    st.trimestre,
    st.ano
FROM stg_tempo_financeiro st
ON DUPLICATE KEY UPDATE
    dia = VALUES(dia),
    mes = VALUES(mes),
    nome_mes = VALUES(nome_mes),
    trimestre = VALUES(trimestre),
    ano = VALUES(ano);

INSERT INTO dim_aluno (nk_aluno_id, nome_completo, status_aluno)
SELECT
    a.pk_aluno_id,
    CONCAT(a.nome, ' ', a.sobrenome) AS nome_completo,
    a.status_aluno
FROM tb_alunos a
ON DUPLICATE KEY UPDATE
    nome_completo = VALUES(nome_completo),
    status_aluno = VALUES(status_aluno);

INSERT INTO dim_curso (nk_curso_id, nome_curso, carga_horaria_total)
SELECT
    c.pk_curso_id,
    c.nome_curso,
    c.carga_horaria_total
FROM tb_cursos c
ON DUPLICATE KEY UPDATE
    nome_curso = VALUES(nome_curso),
    carga_horaria_total = VALUES(carga_horaria_total);

INSERT INTO dim_professor (
    nk_professor_id,
    nome_completo,
    nivel_academico,
    carga_horaria_semanal,
    situacao_professor
)
SELECT
    p.pk_professor_id,
    CONCAT(f.nome, ' ', f.sobrenome) AS nome_completo,
    p.nivel_academico,
    p.carga_horaria_semanal,
    p.situacao_professor
FROM tb_professores p
JOIN tb_funcionarios f ON f.pk_funcionario_id = p.pk_professor_id
ON DUPLICATE KEY UPDATE
    nome_completo = VALUES(nome_completo),
    nivel_academico = VALUES(nivel_academico),
    carga_horaria_semanal = VALUES(carga_horaria_semanal),
    situacao_professor = VALUES(situacao_professor);

-- =========================================
-- FASE 4 - LOAD (FATO)
-- A fato guarda SKs + metricas, sem atributos descritivos.
-- =========================================
INSERT INTO fato_financeiro (
    sk_tempo,
    sk_aluno,
    sk_curso,
    sk_unidade,
    nk_pagamento_id,
    valor_pago,
    qtd_pagamentos
)
SELECT
    dt.sk_tempo,
    da.sk_aluno,
    dc.sk_curso,
    du.sk_unidade,
    sp.nk_pagamento_id,
    sp.valor_pago,
    1 AS qtd_pagamentos
FROM stg_pagamentos_financeiro sp
JOIN dim_tempo dt ON dt.data_calendario = sp.data_pagamento
JOIN dim_aluno da ON da.nk_aluno_id = sp.nk_aluno_id
JOIN dim_curso dc ON dc.nk_curso_id = sp.nk_curso_id
JOIN dim_unidade du ON du.nk_unidade_codigo = 'MATRIZ-001'
ON DUPLICATE KEY UPDATE
    sk_tempo = VALUES(sk_tempo),
    sk_aluno = VALUES(sk_aluno),
    sk_curso = VALUES(sk_curso),
    sk_unidade = VALUES(sk_unidade),
    valor_pago = VALUES(valor_pago),
    qtd_pagamentos = VALUES(qtd_pagamentos);

-- =========================================
-- FASE 5 - VALIDACAO POS-CARGA
-- =========================================
SELECT COUNT(*) INTO @qtd_dim_tempo FROM dim_tempo;
SELECT COUNT(*) INTO @qtd_dim_aluno FROM dim_aluno;
SELECT COUNT(*) INTO @qtd_dim_curso FROM dim_curso;
SELECT COUNT(*) INTO @qtd_dim_unidade FROM dim_unidade;
SELECT COUNT(*) INTO @qtd_dim_professor FROM dim_professor;
SELECT COUNT(*) INTO @qtd_fato_financeiro FROM fato_financeiro;

SELECT COALESCE(SUM(valor_pago), 0) INTO @soma_oltp
FROM tb_pagamentos;

SELECT COALESCE(SUM(valor_pago), 0) INTO @soma_olap
FROM fato_financeiro;

SET @validacao_soma := IF(@soma_oltp = @soma_olap, 'OK', 'DIVERGENTE');
SET @status_execucao := IF(@validacao_soma = 'OK', 'SUCESSO', 'ERRO');

UPDATE etl_auditoria_financeiro
SET
    data_fim = NOW(),
    status_execucao = @status_execucao,
    qtd_registros_staging = @qtd_registros_staging,
    qtd_dim_tempo = @qtd_dim_tempo,
    qtd_dim_aluno = @qtd_dim_aluno,
    qtd_dim_curso = @qtd_dim_curso,
    qtd_dim_unidade = @qtd_dim_unidade,
    qtd_dim_professor = @qtd_dim_professor,
    qtd_fato_financeiro = @qtd_fato_financeiro,
    soma_oltp = @soma_oltp,
    soma_olap = @soma_olap,
    validacao_soma = @validacao_soma
WHERE pk_execucao_id = @etl_execucao_id;

SELECT
    pk_execucao_id,
    processo,
    data_inicio,
    data_fim,
    status_execucao,
    qtd_registros_staging,
    qtd_dim_tempo,
    qtd_dim_aluno,
    qtd_dim_curso,
    qtd_dim_unidade,
    qtd_dim_professor,
    qtd_fato_financeiro,
    soma_oltp,
    soma_olap,
    validacao_soma
FROM etl_auditoria_financeiro
WHERE pk_execucao_id = @etl_execucao_id;
