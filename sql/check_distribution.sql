\set ON_ERROR_STOP on

SELECT
    count(*) AS total_rows,
    count(*) FILTER (WHERE transfer_type = 'SWIFT') AS swift_rows,
    count(*) FILTER (WHERE route_type = 'CROSS_BORDER') AS cross_border_rows,
    count(*) FILTER (
        WHERE transfer_type = 'SWIFT'
          AND route_type = 'CROSS_BORDER'
    ) AS swift_cross_border_rows
FROM transactions;

SELECT transfer_type, route_type, count(*) AS rows
FROM transactions
GROUP BY transfer_type, route_type
ORDER BY rows DESC;
