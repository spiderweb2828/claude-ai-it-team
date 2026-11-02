# Project context for the it-team agents

Copy this file to the root of your project repo as `CLAUDE.md` and fill it in.
All six agents read it at the start of every session.

## Project
- Name: <project name>
- GitHub repo: <org>/<repo>
- Default branch: main
- Jira site: https://<your-site>.atlassian.net
- Jira project key: <PROJ>

## Jira workflow status names
(Change these if your board uses different names.)
- In Progress
- Ready for QA
- In QA
- Ready for Review
- Done
- Blocked (optional)

## Tech specs
- Location: `docs/features/<EPIC-KEY>/tech-specs.md`
- Template: `docs/features/_template/tech-specs.md`
- developer-1 copies the template to this location on the first story's feature branch. Fill it in on that branch, not on `main`. It reaches `main` when that story's PR merges.

## Team flow
When you are running the it-team agents, hand off in this order without waiting to be asked:
- After `scrum-master` creates stories, run `developer-1` to create their feature branches and link them on the stories. Then stop, and tell the human which branch has the spec template, to fill it in there, and to ask `developer-1` to start.
- After `developer-1` opens a PR, run `tester-1` and `tester-2` on it.
- If QA passes, run `reviewer-merger`.
- If QA fails or the reviewer requests changes, run `developer-1` to fix it, then repeat from QA. After three rounds on the same story, stop and ask the human.
- If any agent reports it is blocked, stop and tell the human why.

## Commands
- Install dependencies: `<e.g. npm ci>`
- Run app locally: `<e.g. npm run dev>`
- Unit tests: `<e.g. npm test>`
- Full test suite: `<e.g. npm run test:all>`
- Coverage: `<e.g. npm run coverage>`
- Lint: `<e.g. npm run lint>`

## Conventions
- Language / framework: <e.g. TypeScript, React, Node 22>
- Code style: <e.g. Prettier + ESLint config in repo>
- Test location: <e.g. tests next to source as *.test.ts>
- Files the agents must never touch: <e.g. infra/, .github/workflows/, migrations/ without approval>

## High-risk areas (reviewer-merger asks a human before merging)
- <e.g. auth/, payments/, database migrations, infra/>
