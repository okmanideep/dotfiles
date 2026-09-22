---
name: launchdarkly
description: Inspect and manage Hotstar LaunchDarkly projects, environments, feature flags, targeting, rollouts, and segments with `ldcli`. Use when asked to find a flag or change its configuration, especially an environment-specific toggle or rollout.
compatibility: Requires an authenticated `ldcli` with a LaunchDarkly access token.
---

# LaunchDarkly

Use `ldcli` for Hotstar's LaunchDarkly configuration. Do not expose access tokens or SDK keys.

## Discover

Prefer JSON and narrow reads:

```bash
ldcli flags list --project <project> --env <environment> --filter 'query:<term>' --json
ldcli flags get --project <project> --flag <flag-key> --env <environment> --json
ldcli projects list --json
ldcli environments list --project <project> --json
ldcli segments list --project <project> --env <environment> --json
```

Use `ldcli <resource> <command> --help` before an unfamiliar operation. Flag keys, project keys, environment keys, variation IDs, rule IDs, and clause IDs must come from a read; never guess them.

## Changes

State the project, environment, flag, intended variation/rollout, and production impact before changing configuration. For production toggles, targeting, rollouts, destructive operations, or an ambiguous request, obtain explicit confirmation. First use the available dry run, then run the same command without it only after confirmation:

```bash
ldcli flags toggle-on --project <project> --environment <environment> --flag <flag-key> --dry-run
ldcli flags toggle-off --project <project> --environment <environment> --flag <flag-key> --dry-run
```

For targeting changes, fetch the flag first and send a semantic patch with `ldcli flags update --semantic-patch --data '<json>'`. Use `--dry-run true` to preview it. Semantic patches require the environment key when changing environment targeting. Rollout weights are integers from 0 to 100000 and must total 100000.

Re-read the flag after a persisted change and report the resulting state. Never use `--ignore-conflicts` unless the user explicitly asks.
