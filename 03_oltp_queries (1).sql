
USE sisgesc;

-- =========================================
-- CONSULTAS OLTP (SELECT SIMPLES COM FILTRO)
-- =========================================
-- ========================
-- Alunos com status ATIVO
-- ========================
SELECT pk_aluno_id, nome, sobrenome, status_aluno
FROM tb_alunos
WHERE status_aluno = 'ATIVO'
ORDER BY pk_aluno_id;

-- =============================
-- Professores com situação ATIVO
-- =============================
SELECT p.pk_professor_id, f.nome, f.sobrenome, p.nivel_academico, p.situacao_professor
FROM tb_professores p
JOIN tb_funcionarios f ON f.pk_funcionario_id = p.pk_professor_id
WHERE p.situacao_professor = 'ATIVO'
ORDER BY p.pk_professor_id;

-- ====================================
-- Mensalidades PENDENTES ou ATRASADAS
-- ====================================
SELECT m.pk_mensalidade_id, c.fk_aluno_id, m.data_vencimento, m.valor, m.status
FROM tb_mensalidades m
JOIN tb_contratos_educacionais c ON c.pk_contrato_id = m.fk_contrato_id
WHERE m.status IN ('PENDENTE', 'ATRASADO')
ORDER BY m.pk_mensalidade_id;

-- =========================================
-- SUBSELECT (AGREGACAO)
-- Alunos com total pago >= 1000
-- =========================================
SELECT
    a.pk_aluno_id,
    CONCAT(a.nome, ' ', a.sobrenome) AS nome_aluno
FROM tb_alunos a
WHERE a.pk_aluno_id IN (
    SELECT c.fk_aluno_id
    FROM tb_contratos_educacionais c
    JOIN tb_mensalidades m ON m.fk_contrato_id = c.pk_contrato_id
    JOIN tb_pagamentos p ON p.fk_mensalidade_id = m.pk_mensalidade_id
    GROUP BY c.fk_aluno_id
    HAVING SUM(p.valor_pago) >= 1000
)
ORDER BY a.pk_aluno_id;

-- =========================================
-- CENARIO 1: ROLLBACK
-- =========================================
START TRANSACTION;
INSERT INTO tb_mensalidades (pk_mensalidade_id, fk_contrato_id, data_vencimento, valor, status)
VALUES (9001, 1, '2026-12-10', 650.00, 'PENDENTE');
ROLLBACK;

SELECT COUNT(*) AS rollback_registro_deve_ser_zero
FROM tb_mensalidades
WHERE pk_mensalidade_id = 9001;

-- =========================================
-- CENARIO 2: COMMIT
-- =========================================
START TRANSACTION;
INSERT INTO tb_mensalidades (pk_mensalidade_id, fk_contrato_id, data_vencimento, valor, status)
VALUES (9002, 1, '2026-12-20', 700.00, 'PENDENTE')
ON DUPLICATE KEY UPDATE
    fk_contrato_id = VALUES(fk_contrato_id),
    data_vencimento = VALUES(data_vencimento),
    valor = VALUES(valor),
    status = VALUES(status);
COMMIT;

SELECT pk_mensalidade_id, fk_contrato_id, valor, status
FROM tb_mensalidades
WHERE pk_mensalidade_id = 9002;

-- =========================================
-- CENARIO ADICIONAL: MULTIPLAS OPERACOES + ROLLBACK
-- =========================================
START TRANSACTION;
INSERT INTO tb_pagamentos (pk_pagamento_id, fk_mensalidade_id, data_pagamento, valor_pago)
VALUES (9901, 9002, CURDATE(), 700.00);

UPDATE tb_mensalidades
SET status = 'PAGO'
WHERE pk_mensalidade_id = 9002;
ROLLBACK;

SELECT status AS status_apos_rollback
FROM tb_mensalidades
WHERE pk_mensalidade_id = 9002;

SELECT COUNT(*) AS pagamento_apos_rollback_deve_ser_zero
FROM tb_pagamentos
WHERE pk_pagamento_id = 9901;
