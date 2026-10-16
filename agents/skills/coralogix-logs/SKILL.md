---
name: coralogix-logs
description: |
  Use when the user wants to investigate or answer a question using Coralogix logs,
  including searching for errors, filtering by severity or field, investigating an
  incident, or querying log data with the `cx` CLI.
metadata:
  version: "0.1.0"
---

# Coralogix logs

Use the Coralogix `cx` CLI to search and analyze logs with DataPrime.

## Before querying

- Read `references/dataprime-reference.md` for DataPrime syntax and `references/logs-querying.md` for log query workflows, field discovery, and query examples.
- Use `cx schema` to check the available commands and flags when unsure.
- Use `cx search-fields "<description>" --dataset logs` to discover a field by meaning. If you know a value but not its field, use `cx search-fields "<value>" -s value --dataset logs`.
- Check relevant dashboards or query patterns when that would help answer the question; do not broaden an investigation into other telemetry types unless logs do not contain the needed evidence.

## Querying

- Query logs with `cx logs` or `cx dataprime query`, following the CLI schema and the references above.
- Use `--output toon` when processing command results programmatically.
- Queries are read-only and can be run freely; use `--read-only` for safe exploration where supported.
- Set an API deadline with `--http-timeout <SECONDS>` or `CX_HTTP_TIMEOUT=<SECONDS>` for slow or broad queries.
- If a query returns no useful results, refine the time range, filters, or discovered field names before concluding the data is absent.

## After running cx

Check the command output for an update notice. In toon output, inspect the final JSON line for `_meta.update`; `cx schema` includes it at the top level. In text output, check stdout and stderr for a `[cx update]` or `cx X is available` notice. If present, finish the user's request and then mention both the binary upgrade command and skills refresh command from the notice once at the end. Do not repeat the notice later in the same session.

