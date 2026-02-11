-- consulta operativa
CREATE INDEX IF NOT EXISTS operativa
ON transactions (user_id, tx_date DESC);

SELECT tx_id, amount, status
FROM transactions
WHERE user_id = 4321
ORDER BY tx_date DESC
LIMIT 20;


-- Consulta analítica
CREATE INDEX IF NOT EXISTS analitica
ON transactions (tx_date, user_id);

SELECT country, SUM(amount)
FROM transactions t
JOIN users u ON t.user_id = u.user_id
WHERE tx_date >= '2024-01-01'
GROUP BY country;


-- Consulta históricos
CREATE INDEX IF NOT EXISTS historica
ON audit_log (created_at);

SELECT *
FROM audit_log
WHERE created_at BETWEEN '2023-01-01' AND '2023-12-31';

