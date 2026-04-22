\set ON_ERROR_STOP on

\echo [bootstrap] resetting schema
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

\echo [bootstrap] creating tables
CREATE TABLE transactions (
    id bigint PRIMARY KEY,
    transfer_type text NOT NULL,
    route_type text NOT NULL
);

CREATE TABLE compliance_docs (
    transaction_id bigint NOT NULL,
    notes text NOT NULL,
    padding TEXT
);

\echo [bootstrap] inserting synthetic transactions (:demo_rows rows)
INSERT INTO transactions (id, transfer_type, route_type)
SELECT gs,
       CASE WHEN gs % 10 = 0 THEN 'SWIFT' ELSE 'SEPA' END,
       CASE WHEN gs % 10 = 0 THEN 'CROSS_BORDER' ELSE 'DOMESTIC' END
FROM generate_series(1, :demo_rows) AS gs;

\echo [bootstrap] inserting compliance docs
INSERT INTO compliance_docs (transaction_id, notes, padding)
SELECT tx_id,
       'doc-' || tx_id || '-' || substr(md5(tx_id::text), 1, 12),
       repeat(md5(tx_id::text), 10) -- ~960 байт мусора на каждую строку
FROM (
    SELECT (((gs::bigint * 104729) % :demo_rows::bigint) + 1) AS tx_id
    FROM generate_series(0, :demo_rows - 1) AS gs
) AS shuffled;

\echo [bootstrap] creating indexes after bulk load
CREATE INDEX idx_transactions_type_route
    ON transactions (transfer_type, route_type);

CREATE UNIQUE INDEX idx_compliance_docs_txid
    ON compliance_docs (transaction_id);

ALTER TABLE compliance_docs
    ADD CONSTRAINT fk_compliance_docs_transaction
    FOREIGN KEY (transaction_id)
    REFERENCES transactions (id);

\echo [bootstrap] collecting base statistics
ANALYZE transactions;
ANALYZE compliance_docs;

\echo [bootstrap] done
