\set ON_ERROR_STOP on

DROP STATISTICS IF EXISTS tx_correlation;

CREATE STATISTICS tx_correlation (mcv)
ON transfer_type, route_type
FROM transactions;

ANALYZE transactions;
