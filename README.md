# it-team

A Claude Code plugin that gives you a six-agent IT team wired to GitHub and Jira through MCP.

| Agent | Role |
|---|---|
| `scrum-master` | Creates Jira Epics and user stories with testable acceptance criteria |
| `developer-1` | Builds features from Jira stories, opens PRs |
| `developer-2` | Fixes bugs and tech debt with regression tests, opens PRs |
| `tester-1` | Functional QA against Jira acceptance criteria, files bugs |
| `tester-2` | Regression, edge cases and test automation, files bugs |
| `reviewer-merger` | Code review and the only agent allowed to merge to `main` |

## Flow

scrum-master creates Epic and stories → developer-1 picks up each story automatically → blocked until the tech spec lands → human pushes tech spec to `main` → developer-1 reviews it and builds (branch + PR per story) → **Ready for QA** → tester-1 + tester-2 → **Ready for Review** → reviewer-merger (review, squash merge, close ticket) → **Done**

Bugs and maintenance tickets start with `developer-2`, run by hand.

## Gates

- **developer-1** will not code until `docs/features/<EPIC-KEY>/tech-specs.md` passes its review: `Status: Approved`, with overview, stories in scope, design and out-of-scope sections, no placeholders, and no undecided questions that affect the build. Otherwise it comments "Blocked" on the Jira epic and its stories, and stops.
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

1. Clone the plugin next to your project: `git clone https://github.com/spiderweb2828/claude-ai-it-team.git`
2. Create a GitHub personal access token (fine-grained, limited to your repo; contents, pull requests, issues) and export it:
   `export GITHUB_PAT=ghp_...`
3. In your project repo, copy `templates/CLAUDE.md` to the repo root as `CLAUDE.md` and fill it in. Copy `templates/tech-specs.md` to `docs/features/_template/tech-specs.md`.
4. From your project repo, start Claude Code with the plugin: `claude --plugin-dir ../claude-ai-it-team`
5. Run `/mcp`, pick `atlassian`, choose **Authenticate**, and sign in to your Atlassian site.
6. Run `/agents` to confirm the six agents are loaded.
7. Turn on branch protection for `main` (required review + passing CI).
8. Create the GitHub labels once per repo: `../claude-ai-it-team/scripts/create-github-labels.sh your-org/your-repo` (needs the `gh` CLI). Jira creates labels automatically the first time an agent adds one.

## Automatic pickup

Set this up once per project repo so developer-1 starts when a story is created or a spec lands on `main`:

1. Copy `templates/developer-1-pickup.yml` to `.github/workflows/developer-1-pickup.yml` and push it to `main`.
2. Add these GitHub Actions secrets:
   - `ANTHROPIC_API_KEY`
   - `IT_TEAM_GITHUB_PAT`: needs contents, pull requests and issues on the project repo, plus read access to this plugin repo if it is private.
   - `ATLASSIAN_API_KEY`: a service account API key. An Atlassian org admin must enable API token authentication for the MCP server, because browser sign-in cannot run in CI.
3. Add your project's build and test commands to `--allowedTools` in the workflow. Anything not listed is denied.
4. Create a Jira Automation rule so new stories reach GitHub. In your Jira project, go to **Project settings → Automation → Create rule**:
   - **Trigger:** Issue created
   - **Condition:** Issue fields condition, Issue Type equals Story
   - **Action:** Send web request
     - URL: `https://api.github.com/repos/<org>/<repo>/dispatches`
     - Method: `POST`
     - Headers: `Authorization: Bearer <token>` and `Accept: application/vnd.github+json`. Use a fine-grained token with **Contents: write** on the project repo, and mark the header as hidden.
     - Web request body: Custom data
       ```json
       {"event_type": "jira-story-created", "client_payload": {"story_key": "{{issue.key}}"}}
       ```

**When a story is created,** developer-1 checks the tech spec for its epic. With no approved spec yet, it comments "Blocked" on the story and stops. Stories created by hand trigger this too, not just the ones from scrum-master. Each story gets its own run, so a batch of stories starts several runs at once.

**When a spec is pushed,** developer-1 reviews it and builds every waiting story it lists. The run starts on a push to `main` that adds or changes `docs/features/<EPIC-KEY>/tech-specs.md`. It does not start for changes to `_template`, for commits with an `Agent:` trailer, or for specs that only exist on another branch. A spec with `Status: Draft` starts a run, but the review blocks it. To re-run an epic, use **Run workflow** on the Actions tab.

## Usage

Run these inside Claude Code, from your project repo.

1. Create the backlog, then confirm the draft when scrum-master shows it:

   > Use scrum-master to create an Epic and user stories for password reset by email

2. Write `docs/features/<EPIC-KEY>/tech-specs.md`, list the new story keys under "Stories in scope", set `Status: Approved`, and push it to `main`. developer-1 then builds the stories and opens PRs.

3. Run QA and review on each PR:

   > Use tester-1 and tester-2 to QA PROJ-123

   > Use reviewer-merger to review and merge the PR for PROJ-123

To run an agent by hand instead of waiting for the automation:

> Use developer-1 to implement PROJ-123

Jira status names (In Progress, Ready for QA, In QA, Ready for Review, Done) are assumed. Edit the agent files if your workflow uses different names.
