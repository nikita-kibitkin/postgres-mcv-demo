# Benchmark Notes


## Deterministic Data

The dataset uses `generate_series` plus modular arithmetic, not `random()`.

That guarantees:

- exact selectivity
- exact correlation
- reproducible row counts

## Shuffled Inner Table

`compliance_docs` is inserted in a deterministic shuffled order instead of ascending `transaction_id`.

That avoids an unrealistically friendly locality pattern for the inner index probes.

## Session Knobs

The explain scripts set:

```sql
SET max_parallel_workers_per_gather = 0;
SET enable_mergejoin = off;
SET jit = off;
SET random_page_cost = 1.1;
SET work_mem = '128MB';
```

These settings are there only to make the article-shaped plan easier to surface on local hardware.

## macOS Caveat

Docker standardizes packaging, not performance physics.

On macOS, Docker Desktop runs containers inside a lightweight Linux VM rather than directly on the host kernel. Docker documents this explicitly, and it also notes that databases perform better in named volumes inside that Linux VM. Sources:

- [Docker Desktop on Mac runs containers in a lightweight Linux VM](https://docs.docker.com/desktop/setup/install/mac-permission-requirements/)
- [Docker Desktop settings: databases perform better in named volumes inside the Linux VM](https://docs.docker.com/desktop/settings-and-maintenance/settings/)

So macOS Docker runs are useful for local diagnostics, but Linux on production-like hardware is a better source of canonical latency measurements.
