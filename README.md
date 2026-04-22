# PostgreSQL MCV Demo

Minimal reproduction for the article scenario.

## Run

```bash
./scripts/reset.sh
./scripts/bootstrap.sh 10000000
./scripts/run_demo.sh
```

The wrapper runs:

1. `sql/1_explain_before.sql`
2. `sql/2_fix.sql`
3. `sql/3_explain_after.sql`

Artifacts:

- `results/01_before_mcv.txt`
- `results/02_after_mcv.txt`
- `results/summary.txt`

## What To Compare

- before `MCV`: `rows=` on filtered `transactions` should be materially below `actual rows=`
- before `MCV`: the plan may prefer `Nested Loop`
- after `MCV`: the estimate on `transactions` should jump toward the real cardinality
- after `MCV`: the plan may switch to `Hash Join`

If you want to verify the generated distribution before running the plans:

```bash
./scripts/psql.sh -f sql/check_distribution.sql
```
