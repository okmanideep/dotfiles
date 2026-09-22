---
name: mermaid-validation
description: Validate and fix Mermaid diagram syntax using the Maid CLI tool. Provides fast, lightweight validation without browser dependencies.
---

Skill for validating Mermaid diagrams using the Maid CLI tool.

## Overview

This skill provides fast, lightweight validation of Mermaid diagram syntax without requiring a browser or heavy dependencies.

## Prerequisites

- Node.js and npm installed
- Maid CLI: `npm install -g @probelabs/maid` or use via npx

## Commands

### Validate from stdin (recommended)

```bash
cat diagram.mmd | npx -y @probelabs/maid -
```

Or with heredoc:

```bash
npx -y @probelabs/maid - <<EOF
graph TD
    A --> B
EOF
```

### Validate with auto-fix

```bash
cat diagram.mmd | npx -y @probelabs/maid --fix -
```

### Dry-run (preview fixes without writing)

```bash
cat diagram.mmd | npx -y @probelabs/maid --fix --dry-run -
```

### JSON output (for CI/CD)

```bash
cat diagram.mmd | npx -y @probelabs/maid --format json -
```

### Validate a single diagram file (alternative)

```bash
npx -y @probelabs/maid <file.mmd>
```

### Validate all diagrams in a directory

```bash
npx -y @probelabs/maid <directory>/
```

## Validation Features

- Checks for syntax errors in all Mermaid diagram types
- Identifies missing arrows, unbalanced brackets, invalid syntax
- Provides clear, actionable error messages with line numbers
- Auto-fixes common issues (with `--fix` flag)

## Supported Diagram Types

- Flowcharts (graph TD, graph LR, etc.)
- Sequence diagrams
- Class diagrams
- State diagrams
- ER diagrams
- User journey diagrams
- Gantt charts
- Pie charts
- Git graphs
- And more...

## Exit Codes

- `0`: All diagrams are valid
- `1`: Validation errors found
- `2`: System error

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Validate Mermaid Diagrams
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npx -y @probelabs/maid docs/
```

## Why Maid?

- **Lightweight**: ~5MB vs 1.7GB (mermaid-cli with Puppeteer)
- **Fast**: Pure JavaScript, no browser startup time
- **Smart**: Intelligent error messages and auto-fix suggestions
- **CI-friendly**: JSON output, proper exit codes
