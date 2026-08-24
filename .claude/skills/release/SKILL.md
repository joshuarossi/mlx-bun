---
name: release
description: Cut and publish an mlx-bun release (signed+notarized binary, GitHub release, Homebrew tap, npm). Use for "release vX", "publish", "cut a version".
---

# release

Canonical procedure: docs/reference/distribution.md. Never run this without
Josh's explicit go — it is outward-facing and irreversible on npm.

1. Verify the state FIRST (docs drift; registries don't): `git tag`,
   `npm view mlx-bun version`, `gh release list`, package.json version.
2. Preconditions: clean tree, HEAD == origin/main, `gh auth status`,
   `npm whoami`, one "Developer ID Application" identity, `AC_PROFILE`
   notary profile (`xcrun notarytool history --keychain-profile AC_PROFILE`).
3. Release notes at `docs/planning/release-notes-v<ver>.md` (the publish
   script uses it as the GitHub release body; after publishing, move it to
   docs/archive/planning/).
4. Bump `version` in package.json → `git commit -m "chore: release v<ver>"`
   → `git push origin main`.
5. `PUBLISH=1 ./scripts/release-binary.sh` — builds, signs every Mach-O incl.
   helper executables, notarizes and FAILS on any status other than Accepted,
   then creates the GitHub release, pushes the tap, publishes npm.
6. `git commit -am "chore(dist): mlx-bun <ver>"` (the rewritten formula) and
   push. Record the release in STATUS.md (sha256, notarization result).
7. Verify every channel again (step 1) plus
   `curl -sL <release tarball url> | shasum -a 256` == the tap's sha256.
