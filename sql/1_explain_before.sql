\set ON_ERROR_STOP on

DROP STATISTICS IF EXISTS tx_correlation;
ANALYZE transactions;

SET max_parallel_workers_per_gather = 0;
SET enable_mergejoin = off;
SET jit = off;
SET random_page_cost = 1.1;
SET work_mem = '128MB';

EXPLAIN (ANALYZE, BUFFERS, SETTINGS)
SELECT t.id, d.notes
FROM transactions AS t
JOIN compliance_docs AS d
  ON d.transaction_id = t.id
WHERE t.transfer_type = 'SWIFT'
  AND t.route_type = 'CROSS_BORDER';
