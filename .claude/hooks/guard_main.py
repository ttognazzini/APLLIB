#!/usr/bin/env python3
"""Claude Code PreToolUse guard: block git commit/push directly on `main`.

Copied from the arrowhead-winch-system repo so sessions whose shell working
directory sits inside this project can still resolve the hook (the winch
repo's settings reference it by relative path). Same rule applies here:
changes go through feature branches, not main.

Reads the tool call as JSON on stdin. If it's a `git commit` / `git push` AND
the current branch is `main`, it exits 2 (which blocks the tool and shows the
message to Claude). In every other case it exits 0 and stays out of the way.
It also fails *open* — if anything is unexpected (no git, can't parse), it
allows the command rather than getting in the way.
"""
import json
import re
import subprocess
import sys

# A git command that commits or pushes. `[^&|;]*?` keeps it within a single
# command segment so a later `&& git push` in a chain is still seen.
_WRITE_ACTION = re.compile(r"\bgit\b[^&|;]*?\b(commit|push)\b")


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        sys.exit(0)  # can't parse the hook input -> don't interfere

    command = (payload.get("tool_input") or {}).get("command", "")
    if not command:
        sys.exit(0)

    match = _WRITE_ACTION.search(command)
    if not match:
        sys.exit(0)  # not a commit/push -> allow

    # What branch are we on?
    try:
        branch = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=5,
        ).stdout.strip()
    except Exception:
        sys.exit(0)  # can't determine branch -> don't interfere

    if branch != "main":
        sys.exit(0)  # on a feature branch -> allow

    action = match.group(1)  # "commit" or "push"
    print(
        f"BLOCKED: attempted to git {action} while on 'main'.\n"
        "\n"
        "This project requires every change to go through a feature branch + PR.\n"
        "Do this instead:\n"
        "\n"
        "    git switch -c feature/<short-description>\n"
        "    # re-run your commit, then: git push -u origin <branch>\n"
        "    # and open a PR with: gh pr create --fill\n"
        "\n"
        "If a direct change to main is genuinely required (e.g. an admin hotfix),\n"
        "run the git command yourself in a terminal outside Claude Code.",
        file=sys.stderr,
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
