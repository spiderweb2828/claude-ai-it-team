# it-team

A Claude Code plugin that gives you a six-agent IT team wired to GitHub and Jira through MCP.

| Agent | Role |
|---|---|
| `scrum-master` | Creates Jira Epics and user stories |
| `developer-1` | Creates feature branches, builds stories once started, records sub-tasks, opens PRs |
| `developer-2` | Watches Jira for new bugs and fixes them with regression tests, opens PRs |
| `tester-1` | Functional QA against Jira acceptance criteria, files bugs |
| `tester-2` | Regression, edge cases and test automation, files bugs |
| `reviewer-merger` | Code review and the only agent allowed to merge to `main` |

## Flow

1. **scrum-master** creates the Epic and stories in Jira.
2. **developer-1** creates a feature branch for each story, adds its link to the Jira story, and copies the tech spec template to the epic's first story branch.
3. **You** fill in the tech spec on that branch and ask developer-1 to start.
4. **developer-1** reviews the spec and builds the story. Once coding is complete, it creates Jira sub-tasks based on the spec, marks them Done, and opens a PR.
5. **tester-1 and tester-2** test the PR.
6. **reviewer-merger** reviews, merges and closes the ticket.

**developer-2** separately watches Jira for new bugs and fixes them.

## Gates

- **developer-1** will not code until `docs/features/<EPIC-KEY>/tech-specs.md` passes its review: overview, design and out-of-scope sections, no placeholders, and no undecided questions that affect the build. Otherwise it comments "Blocked" on the Jira ticket and stops.
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
7. Turn on branch protection for `main` and require passing CI. Only require a review if reviewer-merger uses a different GitHub account from the developers, because GitHub does not let an account approve its own PR.
8. Create the GitHub labels once per repo: `../claude-ai-it-team/scripts/create-github-labels.sh your-org/your-repo` (needs the `gh` CLI). Jira creates labels automatically the first time an agent adds one.

## Usage

Run these inside Claude Code, from your project repo.

1. Create the stories. After you confirm the draft, developer-1 creates a feature branch for each one, adds its link to the Jira story, and copies the tech spec template to the first story's branch:

   > Use scrum-master to create an Epic and user stories for password reset by email

   For a story created directly in Jira, ask for its branch yourself:

   > Use developer-1 to create the branch for PROJ-123

2. Check out the branch with the template, fill in `docs/features/<EPIC-KEY>/tech-specs.md`, and push it to that branch. It reaches `main` when that story's PR merges.

3. Start the work. Testing, review and merge follow on their own:

   > Use developer-1 to start PROJ-100

To watch for bugs, keep one Claude Code session open with this running:

> /loop 15m Use developer-2 to check for new bugs

Watching stops when that session closes.

Jira status names (In Progress, Ready for QA, In QA, Ready for Review, Done) are assumed. Edit the agent files if your workflow uses different names.
