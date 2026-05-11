USE sisgesc;

-- =========================================
-- CENARIO 1: CONSULTA OPERACIONAL
-- =========================================
EXPLAIN
SELECT pk_mensalidade_id, fk_contrato_id, valor, status
FROM tb_mensalidades
WHERE status = 'PENDENTE'
  AND data_vencimento <= '2026-12-31';

SET @idx_mensalidade_existe := (
    SELECT COUNT(*)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'tb_mensalidades'
      AND index_name = 'idx_mensalidades_status_vencimento'
);

SET @sql_idx_mensalidade := IF(
    @idx_mensalidade_existe = 0,
    'CREATE INDEX idx_mensalidades_status_vencimento ON tb_mensalidades (status, data_vencimento)',
    'SELECT ''Indice idx_mensalidades_status_vencimento ja existe'' AS info'
);

PREPARE stmt_idx_mensalidade FROM @sql_idx_mensalidade;
EXECUTE stmt_idx_mensalidade;
DEALLOCATE PREPARE stmt_idx_mensalidade;

EXPLAIN
SELECT pk_mensalidade_id, fk_contrato_id, valor, status
FROM tb_mensalidades
WHERE status = 'PENDENTE'
  AND data_vencimento <= '2026-12-31';

-- =========================================
-- CENARIO 2: CONSULTA ANALITICA
-- =========================================
EXPLAIN
SELECT dt.ano, dt.mes, SUM(f.valor_pago) AS total_pago
FROM fato_financeiro f
JOIN dim_tempo dt ON dt.sk_tempo = f.sk_tempo
GROUP BY dt.ano, dt.mes;

SET @idx_fato_existe := (
    SELECT COUNT(*)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'fato_financeiro'
      AND index_name = 'idx_fato_tempo_valor'
);

SET @sql_idx_fato := IF(
    @idx_fato_existe = 0,
    'CREATE INDEX idx_fato_tempo_valor ON fato_financeiro (sk_tempo, valor_pago)',
    'SELECT ''Indice idx_fato_tempo_valor ja existe'' AS info'
);

PREPARE stmt_idx_fato FROM @sql_idx_fato;
EXECUTE stmt_idx_fato;
DEALLOCATE PREPARE stmt_idx_fato;

EXPLAIN
SELECT dt.ano, dt.mes, SUM(f.valor_pago) AS total_pago
FROM fato_financeiro f
JOIN dim_tempo dt ON dt.sk_tempo = f.sk_tempo
GROUP BY dt.ano, dt.mes;
