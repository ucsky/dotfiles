# Security Policy

This is a personal dotfiles repository. It is maintained on a best-effort
basis, but security reports are taken seriously because people may copy or
run these scripts on their own machines.

## Supported versions

Only the latest commit on `master` is supported. There are no release
branches; fixes land on `master`.

## Reporting a vulnerability

**Please do not open a public issue or pull request for a security problem.**

Report it privately through GitHub:

1. Go to the [Security tab](https://github.com/ucsky/dotfiles/security) of
   this repository.
2. Click **Report a vulnerability**.
3. Describe the issue, the affected file(s), how to reproduce it, and the
   impact you expect.

If you accidentally find a **committed secret** (token, key, password), report
it the same way and do not use it.

## What is in scope

- Install / uninstall scripts (`make/`, `Makefile`, `hooks/`) doing something
  unsafe: running unverified downloads, destructive operations, privilege
  escalation, unsafe `eval`, insecure file permissions.
- Shell configuration (`configs/`) that could execute untrusted input
  (e.g. unsafe `.env` loading, command injection in prompts or aliases).
- Utilities in `scripts/` with injection or path-traversal issues.
- Secrets or personal data committed to the repository.
- GitHub Actions workflows that could be abused (excessive token permissions,
  script injection from PR titles/branches, untrusted `pull_request_target`).
- Vulnerable pinned dependencies (`requirements.txt`, GitHub Actions).

Out of scope: issues that require an attacker to already control your user
account or your shell, and purely stylistic configuration choices.

## What to expect

- Acknowledgement within **7 days**.
- A fix or a decision (accepted / declined, with reasons) as soon as
  reasonably possible; critical issues are prioritized.
- Credit in the fix commit or advisory if you want it.
