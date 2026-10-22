#!/usr/bin/env bash
# Creates (or updates) the GitHub labels the it-team agents use.
# Usage: ./scripts/create-github-labels.sh owner/repo
# Requires the GitHub CLI (gh) logged in with access to the repo.
set -euo pipefail

REPO="${1:?Usage: $0 owner/repo}"

label() { gh label create "$1" --repo "$REPO" --color "$2" --description "$3" --force; }

# Who worked on it
label "ai-agent"               "7057ff" "Work done by an AI agent"
label "agent:developer-1"      "1d76db" "AI agent developer-1 (features)"
label "agent:developer-2"      "0e8a8a" "AI agent developer-2 (bugs/maintenance)"
label "agent:tester-1"         "0e8a16" "AI agent tester-1 (functional QA)"
label "agent:tester-2"         "fbca04" "AI agent tester-2 (regression/automation)"
label "agent:reviewer-merger"  "5319e7" "AI agent reviewer-merger"

# Type
label "type:feature"           "a2eeef" "New feature"
label "type:bugfix"            "d73a4a" "Bug fix"
label "type:chore"             "cfd3d7" "Maintenance / tech debt"

# Stage
label "ready-for-qa"           "c5def5" "Waiting for QA"
label "qa-passed"              "0e8a16" "Functional QA passed"
label "qa-failed"              "b60205" "Functional QA failed"
label "regression-passed"      "0e8a16" "Regression checks passed"
label "regression-failed"      "b60205" "Regression checks failed"
label "tests-added"            "bfdadc" "Tester added automated tests"
label "changes-requested"      "e99695" "Reviewer requested changes"
label "approved"               "0e8a16" "Reviewer approved"
label "merged-by-ai"           "5319e7" "Merged by AI agent reviewer-merger"

echo "Labels ready in $REPO"
