---
name: jira
description: Search, inspect, create, and update Jira issues, epics, sprints, boards, and releases with `jira`. Use whenever the user asks about Jira tickets, JQL, issue status, assignment, comments, or creating a ticket.
compatibility: Requires a configured and authenticated `jira` CLI.
---

# Jira

Use `jira` to work with Jira. Read operations are safe; creating, editing, assigning, commenting, linking, transitioning, logging work, and deleting modify Jira.

## Discover

Use project-scoped queries where possible and machine-readable output for analysis:

```bash
jira issue view <ISSUE-KEY> --raw
jira issue list -p <PROJECT> --jql '<JQL>' --raw
jira issue list -p <PROJECT> --plain --columns key,summary,status,assignee
jira project list
jira board list -p <PROJECT>
```

Use `jira <command> <subcommand> --help` before an unfamiliar operation. Do not invent project keys, issue types, workflow states, custom-field names, or link types.

## Create a concise ticket

Determine the project, issue type, and a specific imperative summary. Write a compact description with only relevant sections, for example:

```text
Problem
<current behavior or need>

Acceptance criteria
- <observable result>
```

If a required value or the desired scope is unclear, ask before creating. Otherwise create non-interactively and return the resulting key and URL:

```bash
jira issue create -p <PROJECT> -t <TYPE> -s '<summary>' -b '<description>' --no-input
```

Use `--parent <ISSUE-KEY>` for a sub-task or epic relationship only when the requested relationship is clear. Include labels, components, priority, versions, assignee, or custom fields only when the user provides them or they are necessary and verified.

## Updates

Confirm the target issue and intended change before edits, transitions, assignment, comments, links, worklogs, or deletion. Use the focused command and then re-read the issue:

```bash
jira issue edit <ISSUE-KEY> -s '<summary>' -b '<description>' --no-input
jira issue assign <ISSUE-KEY> '<email-or-exact-name>'
jira issue move <ISSUE-KEY> '<STATE>' --comment '<reason>'
jira issue comment add <ISSUE-KEY> '<comment>' --no-input
```

Never delete an issue or make a state-changing action from an ambiguous request.

### Images in descriptions

- Preserve existing ADF when editing; plain-text/Markdown `--body` edits can remove image nodes. Upload images as Jira attachments, then embed them with Jira’s editor or valid ADF `mediaSingle`/`media` nodes. Don’t use Markdown image syntax or attachment-content URLs as embeds. Re-read the issue to verify rendering.
- Official references: [ADF structure](https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/), [mediaSingle node](https://developer.atlassian.com/cloud/jira/platform/apis/document/nodes/mediaSingle/), [media node](https://developer.atlassian.com/cloud/jira/platform/apis/document/nodes/media/), [upload issue attachment API](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-attachments/#api-rest-api-3-issue-issueidorkey-attachments-post).
