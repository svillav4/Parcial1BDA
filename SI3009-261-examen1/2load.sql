SET synchronous_commit = off;
SET work_mem = '64MB';
SET maintenance_work_mem = '1GB';

-- Genera 400,000 usuarios

INSERT INTO users (user_id, email, country, created_at)
SELECT
  gs AS user_id,
  'user' || gs || '@fintechpay.com' AS email,
  (ARRAY['CO','MX','AR','CL','PE','BR','US','ES','EC','PA'])[1 + (random()*9)::int] AS country,
  now() - (random() * interval '5 years') AS created_at
FROM generate_series(1, 400000) AS gs;

ANALYZE users;

-- Genera 6,000,000 de transacciones en bloques

DO $$
DECLARE
  chunk_size BIGINT := 200000;      -- 200K por bloque
  total_rows BIGINT := 6000000;     -- 6M total
  start_id   BIGINT := 1;
  end_id     BIGINT;
BEGIN
  WHILE start_id <= total_rows LOOP
    end_id := LEAST(start_id + chunk_size - 1, total_rows);

    RAISE NOTICE 'Inserting transactions: % .. %', start_id, end_id;

    INSERT INTO transactions (tx_id, user_id, amount, status, tx_date)
    SELECT
      gs AS tx_id,
      1 + (random() * 399999)::bigint AS user_id,  -- 1..2,000,000
      round((random() * 5000 + 1)::numeric, 2) AS amount,

      CASE
        WHEN random() < 0.75 THEN 'APPROVED'
        WHEN random() < 0.90 THEN 'PENDING'
        WHEN random() < 0.98 THEN 'REJECTED'
        ELSE 'CHARGEBACK'
      END AS status,
      now() - (random() * interval '3 years') AS tx_date
    FROM generate_series(start_id, end_id) AS gs;

    start_id := end_id + 1;
  END LOOP;
END $$;

ANALYZE transactions;

-- Genera 24,000,000 de registros de auditoría

DO $$
DECLARE
  chunk_size BIGINT := 400000;      -- 400K por bloque
  total_rows BIGINT := 24000000;    -- 24M total
  start_id   BIGINT := 1;
  end_id     BIGINT;
BEGIN
  WHILE start_id <= total_rows LOOP
    end_id := LEAST(start_id + chunk_size - 1, total_rows);

    RAISE NOTICE 'Inserting audit_log: % .. %', start_id, end_id;

    INSERT INTO audit_log (id, tx_id, event, created_at)
    SELECT
      gs AS id,
      1 + (random() * 5999999)::bigint AS tx_id,  -- 1..30,000,000
      (ARRAY[
        'TX_CREATED',
        'RISK_CHECK',
        '3DS_CHALLENGE',
        'PAYMENT_AUTH',
        'PAYMENT_CAPTURE',
        'SETTLEMENT',
        'REFUND',
        'DISPUTE_OPENED',
        'DISPUTE_CLOSED',
        'TX_UPDATED'
      ])[1 + (random()*9)::int] AS event,
      now() - (random() * interval '3 years') AS created_at
    FROM generate_series(start_id, end_id) AS gs;

    start_id := end_id + 1;
  END LOOP;
END $$;

ANALYZE audit_log;