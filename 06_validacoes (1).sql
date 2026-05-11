USE sisgesc;

-- =========================================
-- CONTAGENS BASE
-- =========================================
SELECT 'OLTP_tb_alunos' AS metrica, COUNT(*) AS total FROM tb_alunos
UNION ALL
SELECT 'OLTP_tb_matriculas', COUNT(*) FROM tb_matriculas
UNION ALL
SELECT 'OLTP_tb_contratos_educacionais', COUNT(*) FROM tb_contratos_educacionais
UNION ALL
SELECT 'OLTP_tb_mensalidades', COUNT(*) FROM tb_mensalidades
UNION ALL
SELECT 'OLTP_tb_pagamentos', COUNT(*) FROM tb_pagamentos
UNION ALL
SELECT 'OLAP_dim_tempo', COUNT(*) FROM dim_tempo
UNION ALL
SELECT 'OLAP_dim_aluno', COUNT(*) FROM dim_aluno
UNION ALL
SELECT 'OLAP_dim_curso', COUNT(*) FROM dim_curso
UNION ALL
SELECT 'OLAP_dim_unidade', COUNT(*) FROM dim_unidade
UNION ALL
SELECT 'OLAP_fato_financeiro', COUNT(*) FROM fato_financeiro;

-- =========================================
-- VALIDACAO CRITICA: SUM(OLTP) = SUM(OLAP)
-- =========================================
SELECT
    COALESCE((SELECT SUM(valor_pago) FROM tb_pagamentos), 0) AS soma_oltp,
    COALESCE((SELECT SUM(valor_pago) FROM fato_financeiro), 0) AS soma_olap,
    CASE
        WHEN COALESCE((SELECT SUM(valor_pago) FROM tb_pagamentos), 0)
           = COALESCE((SELECT SUM(valor_pago) FROM fato_financeiro), 0)
        THEN 'OK'
        ELSE 'DIVERGENTE'
    END AS validacao_soma;

-- =========================================
-- CONSULTA ANALITICA EXEMPLO
-- =========================================
SELECT
    dt.ano,
    dt.nome_mes,
    SUM(f.valor_pago) AS faturamento
FROM fato_financeiro f
JOIN dim_tempo dt ON dt.sk_tempo = f.sk_tempo
GROUP BY dt.ano, dt.mes, dt.nome_mes
ORDER BY dt.ano, dt.mes;
