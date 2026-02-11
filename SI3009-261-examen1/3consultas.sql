-- consulta 1: operativa

SELECT tx_id, amount, status
FROM transactions
WHERE user_id = 4321
ORDER BY tx_date DESC
LIMIT 20;

-- consulta 2: analítica

SELECT country, SUM(amount)
FROM transactions t
JOIN users u ON t.user_id = u.user_id
WHERE tx_date >= '2024-01-01'
GROUP BY country;

-- consulta 3: históricos

SELECT *
FROM audit_log
WHERE created_at BETWEEN '2023-01-01' AND '2023-12-31';