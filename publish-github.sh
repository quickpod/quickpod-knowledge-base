#!/usr/bin/env bash
set -euo pipefail

usage() {
	echo "Usage: GITHUB_TOKEN=<token> ./publish-github.sh <owner> <repo-name> [description]"
	echo
	echo "Creates a new public GitHub repository, adds origin, and pushes the current main branch."
}

require_command() {
	if ! command -v "$1" >/dev/null 2>&1; then
		echo "Missing required command: $1" >&2
		exit 1
	fi
}

require_command curl
require_command git
require_command python3

if [[ $# -lt 2 || $# -gt 3 ]]; then
	usage
	exit 1
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
	echo "GITHUB_TOKEN is required" >&2
	exit 1
fi

owner="$1"
repo_name="$2"
description="${3:-QuickPod Assistant public knowledge base}"
repo_api="https://api.github.com/repos/${owner}/${repo_name}"

if [[ ! -d .git ]]; then
	echo "Current directory is not a git repository" >&2
	exit 1
fi

default_branch="$(git branch --show-current)"
if [[ -z "$default_branch" ]]; then
	default_branch="main"
fi

payload="$(python3 - "$repo_name" "$description" <<'PY'
import json
import sys

name = sys.argv[1]
description = sys.argv[2]
print(json.dumps({
    "name": name,
    "description": description,
    "private": False,
    "has_issues": True,
    "has_projects": False,
    "has_wiki": False,
    "auto_init": False,
}))
PY
)"

http_status="$(curl --silent --show-error --output /tmp/quickpod-kb-create-repo.json --write-out '%{http_code}' \
	-X POST \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer ${GITHUB_TOKEN}" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	-d "$payload" \
	"https://api.github.com/user/repos")"

if [[ "$http_status" != "201" && "$http_status" != "422" ]]; then
	echo "GitHub repository creation failed with HTTP ${http_status}" >&2
	cat /tmp/quickpod-kb-create-repo.json >&2
	exit 1
fi

if git remote get-url origin >/dev/null 2>&1; then
	git remote set-url origin "https://github.com/${owner}/${repo_name}.git"
else
	git remote add origin "https://github.com/${owner}/${repo_name}.git"
fi

git add .
if ! git diff --cached --quiet; then
	git commit -m "Initialize QuickPod knowledge base"
fi

git push -u "https://${owner}:${GITHUB_TOKEN}@github.com/${owner}/${repo_name}.git" "$default_branch"

echo "Repository published: https://github.com/${owner}/${repo_name}"