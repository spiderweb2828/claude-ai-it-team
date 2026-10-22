# it-team

A Claude Code plugin that gives you a five-agent IT team wired to GitHub and Jira through MCP.

| Agent | Role |
|---|---|
| `developer-1` | Builds features from Jira stories, opens PRs |
| `developer-2` | Fixes bugs and tech debt with regression tests, opens PRs |
| `tester-1` | Functional QA against Jira acceptance criteria, files bugs |
| `tester-2` | Regression, edge cases and test automation, files bugs |
| `reviewer-merger` | Code review and the only agent allowed to merge to `main` |

## Flow

Jira ticket → developer (branch + PR) → **Ready for QA** → tester-1 + tester-2 → **Ready for Review** → reviewer-merger (review, squash merge, close ticket) → **Done**

## Gates

- **developer-1** will not code until `docs/features/<EPIC-KEY>/tech-specs.md` exists in the repo with an overview, design and out-of-scope section. Otherwise it comments "Blocked" on the Jira ticket and stops.
- **tester-1** will not test until the Jira user story has specific, checkable acceptance criteria. Otherwise it comments "Blocked" on the story and stops.

## Labels and traceability

Every agent marks its work so you can see what AI did.

| Where | Marker |
|---|---|
| Jira issues | `ai-agent` + `agent-<name>` labels, plus stage labels below |
| Jira comments | start with `🤖 [AI Agent: <name>]` |
| Jira bugs filed by testers | `ai-agent`, `agent-tester-N`, `ai-found-bug`, `qa-functional` / `qa-regression` |
| Git commits | trailers `Jira: KEY`, `Agent: <name>`, `Co-Authored-By: Claude <noreply@anthropic.com>` |
| Merge commit | above trailers from all squashed commits + `Reviewed-by-agent` and `Merged-by-agent: reviewer-merger` |
| GitHub PRs | `ai-agent`, `agent:<name>`, `type:*`, stage labels; comments start with `🤖 [AI Agent: <name>]` |

**Jira stage labels:** `ai-blocked-no-tech-spec`, `ai-blocked-cannot-reproduce`, `ai-blocked-no-acceptance-criteria`, `ai-dev-in-progress`, `ai-dev-done`, `ai-qa-in-progress`, `ai-qa-passed`, `ai-qa-failed`, `ai-regression-passed`, `ai-regression-failed`, `ai-tests-added`, `ai-changes-requested`, `ai-reviewed`, `ai-merged`.

**GitHub stage labels:** `ready-for-qa`, `qa-passed`, `qa-failed`, `regression-passed`, `regression-failed`, `tests-added`, `changes-requested`, `approved`, `merged-by-ai`.

Useful searches:
- Jira JQL: `labels = ai-agent ORDER BY updated DESC`, or `labels = ai-merged AND updated >= -7d`
- GitHub PRs: `is:pr label:ai-agent`, or `is:pr label:merged-by-ai`
- Git: `git log --grep="Agent: developer-1"`, or `git log --grep="Merged-by-agent"`

## Setup

1. Create a GitHub personal access token (fine-grained, limited to your repo; contents, pull requests, issues) and export it:
   `export GITHUB_PAT=ghp_...`
2. Start Claude Code with the plugin: `claude --plugin-dir ./it-team-plugin`
3. Run `/mcp`, pick `atlassian`, choose **Authenticate**, and sign in to your Atlassian site.
4. Run `/agents` to confirm the five agents are loaded.
5. Turn on branch protection for `main` (required review + passing CI).
6. Create the GitHub labels once per repo: `./scripts/create-github-labels.sh your-org/your-repo` (needs the `gh` CLI). Jira creates labels automatically the first time an agent adds one.

## Usage

> Use developer-1 to implement PROJ-123

> Use tester-1 and tester-2 to QA PROJ-123

> Use reviewer-merger to review and merge the PR for PROJ-123

Jira status names (In Progress, Ready for QA, In QA, Ready for Review, Done) are assumed. Edit the agent files if your workflow uses different names.
