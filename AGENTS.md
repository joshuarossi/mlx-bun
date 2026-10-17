# Agent entry

Read [README](README.md), [ARCHITECTURE](ARCHITECTURE.md), the owning package's
README, then its code. Read [CONTRIBUTING](CONTRIBUTING.md) before changing
behavior or packaging. [PLAN](PLAN.md) holds open refactor work; history is Git.

## Policies

- Avoid Python whenever possible, including scripts and verification tooling;
  prefer Bun/TypeScript or suitable non-Python tools.
- Josh approves new documentation files and migration scope. Implementation and
  test files needed for the approved refactor are authorized. Do not carry material
  over just because it exists on main. YAGNI and KISS govern the rebuild.
- Create reviewable PRs targeting `main`; do not merge them without Josh's
  instruction.
- Preserve numerical behavior during migration. Optimization is separate work;
  follow the evidence requirements in CONTRIBUTING.
- Never use the GPU while training is active. Check before numerical runs.
  Ask before starting persistent servers or multi-GB downloads.
- Do not release or publish packages without Josh's instruction.

## Releases

An explicit instruction to release authorizes the release work; do not ask Josh
to repeat it. Use the existing workflow instead of inventing a new one:

1. Read the app's [release instructions](apps/mlx-bun/README.md#release-preparation),
   `scripts/release-binary.sh`, and `scripts/publish-release.sh` first. These scripts
   own building, signing, notarization, GitHub assets, Homebrew, and npm publication.
2. Use the version Josh requested. Update public package versions, the lockfile,
   README, website, and release notes together. Describe beta status and known
   upgrade changes accurately; an older registry version is not the release target.
3. Fetch `origin/main` and rebase the release branch before final verification.
   Resolve conflicts, install with the frozen lockfile, and run the root README's
   applicable checks and required CI. Keep the release PR reviewable. After it is
   merged, build from a clean checkout at the latest `origin/main`; rebuild if that
   source revision changes. Never bypass the publisher's Git or artifact checks.
4. Run `./scripts/release-binary.sh <version>` using the Mac's existing signing
   identity and notarization profile. It defaults to `AC_PROFILE`, with
   `NOTARY_PROFILE` as the supported override. Use configured npm authentication.
   In a separate worktree, compare `npm config get userconfig` with the original
   checkout; reuse its configured path through `NPM_CONFIG_USERCONFIG` if needed.
   Do not export, copy, dump, or search for private keys or credential contents.
   If a script fails, report its exact failing stage and relevant error; do not
   infer that credentials need recreating from an unrelated or transient failure.
5. Verify Apple acceptance and real native-library loading from the relocated
   signed bundle, following the app's release acceptance requirements. Publish
   with `RELEASE_NOTES=/path/to/reviewed-notes ./scripts/publish-release.sh <version>`
   against that same preparation. `BUILD_DIR` and `OUT_DIR` must match when overridden.
6. Verify the GitHub release/assets, Homebrew formula, and public npm versions.
   Only then deploy the website with the [manual Pages workflow](apps/website/README.md),
   using the published latest release tag. Verify the live docs and installer before
   reporting the release complete. Report partial publication precisely if a channel fails.

## Ownership and verification

Architecture owns dependency direction and documentation policy. Package
READMEs own local setup; the root README owns workspace verification commands.
Keep the executable boundary gate authoritative for mechanical import rules.
Read the implementation before changing it.

Do not add status ledgers, session summaries, or memory files. Report progress
in the conversation and PR; remove completed work from PLAN.
