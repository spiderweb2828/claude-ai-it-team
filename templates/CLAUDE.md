# Project context for the it-team agents

Copy this file to the root of your project repo as `CLAUDE.md` and fill it in.
All five agents read it at the start of every session.

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
