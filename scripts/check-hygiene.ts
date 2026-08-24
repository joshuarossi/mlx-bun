#!/usr/bin/env bun
// Hygiene gate — the "mess can't re-form" guarantee.
//
// Two checks, both must pass:
//
//   1. binaries   — no tracked file may be a binary artifact (or >1 MB of
//                   anything) unless it is on an EXPLICIT, size-capped
//                   allowlist with a recorded rationale. This is the direct
//                   guardrail against a repeat of the goldens episode
//                   (179 MB .git driven by 497 machine-specific .bin blobs
//                   that regenerated on every run). Allowlisted entries are
//                   the exception, not the rule: adding one requires a
//                   justification and a regen path.
//
//   2. docs-map   — every docs/**/*.md must appear (by basename) in the
//                   CLAUDE.md "Doc map" section, so the hand-maintained map
//                   can't silently drift from reality.
//
//   3. root-clean — every TRACKED file at the repo root must be on the
//                   explicit allowlist below. This is a SOFTWARE PROJECT:
//                   dated benchmark dumps, logs, session reports, and any
//                   other work artifacts never get committed at root
//                   (2026-08-18 sweep: six benchmarks-serve-*.md had leaked
//                   past an incomplete gitignore pattern). Raw bench output
//                   goes to reports/ (untracked); curated numbers to
//                   benchmarks/RESULTS.md; built models to ~/models.
//                   See CONTRIBUTING.md.
//
// Usage:
//   bun scripts/check-hygiene.ts            # check all tracked files (CI)
//   bun scripts/check-hygiene.ts --staged   # check only staged files (pre-commit)
//   bun scripts/check-hygiene.ts --binaries # just the binary gate
//   bun scripts/check-hygiene.ts --docs-map # just the docs-map assertion
//   bun scripts/check-hygiene.ts --root     # just the root allowlist
//
// Wire into CI via scripts/test.sh; for pre-commit, run with --staged.

import { readFileSync } from "node:fs";
import { execSync } from "node:child_process";

const ROOT = import.meta.dir + "/..";
const ONE_MB = 1_048_576;

type Mode = "all" | "staged" | "binaries" | "docs-map" | "root";
const args = new Set(process.argv.slice(2));
const mode: Mode = args.has("--staged")
  ? "staged"
  : args.has("--binaries")
    ? "binaries"
    : args.has("--docs-map")
      ? "docs-map"
      : args.has("--root")
        ? "root"
        : "all";

// ---------------------------------------------------------------------------
// 3. Root allowlist — tracked files with no "/" in their path
// ---------------------------------------------------------------------------

const ROOT_ALLOWLIST = new Set([
  ".gitattributes", ".gitignore",
  // Single-context domain vocabulary; required by the repository's domain
  // layout and maintained as source documentation, not generated output.
  "AGENTS.md", "CLAUDE.md", "CONTEXT.md", "CONTRIBUTING.md", "LICENSE",
  "PLAN.md", "README.md", "STATUS.md",
  "THIRD_PARTY_LICENSES.md",
  "benchmark.sh", "bun.lock", "package.json",
  "tsconfig.json", "tsconfig.web.json",
]);

function checkRoot(): string[] {
  const rootFiles = execSync("git ls-files", { cwd: ROOT, encoding: "utf8" })
    .split("\n")
    .map((s) => s.trim())
    .filter((f) => f && !f.includes("/"));
  return rootFiles
    .filter((f) => !ROOT_ALLOWLIST.has(f))
    .map(
      (f) =>
        `  FAIL  ${f} — tracked at root but not on ROOT_ALLOWLIST ` +
        `(work artifacts belong in reports/ or ~/models, never committed at root; ` +
        `genuinely new meta files get an allowlist entry with rationale — CONTRIBUTING.md)`,
    );
}

// ---------------------------------------------------------------------------
// 1. Binary-in-git gate
// ---------------------------------------------------------------------------

interface AllowEntry {
  /** gitignore-style glob matched against the repo-relative path. */
  glob: string;
  /** Max bytes; a matching file over this FAILs. */
  maxBytes: number;
  why: string;
}

// The explicit allowlist. Every entry is a deliberate, documented exception
// to the "no binaries in git" rule. To add one: justify why it can't be
// untracked (e.g. no bit-exact regen, or CI-load-bearing + tiny) and confirm
// it is NOT a churning machine-specific artifact — those belong under a
// regen script + gitignore, like goldens/**.bin.
const ALLOW: AllowEntry[] = [
  // fixtures/adapters/*/adapters.safetensors: UNTRACKED 2026-07-02 (the last
  // multi-MB binaries in the index). Bytes are pinned by sha256 in
  // scripts/fetch-test-fixtures.sh (sources: the test-fixtures-v1 release /
  // either dev laptop / git history until the Phase-C rewrite); the gated
  // LoRA test skips cleanly when the files are absent. Plan B2 is CLOSED.
  {
    glob: "tests/fixtures/qwen-delta-golden.json",
    maxBytes: 1_200_000,
    why: "Text JSON golden (bf16-quantized reference kernel output). Model-free CI load-bearer (tests/qwen-delta.test.ts, no model load). Regenerated by scripts/gen-qwen-delta-golden.py.",
  },
  {
    glob: "tests/fixtures/**/*.bin",
    maxBytes: 16_384,
    why: "Model-free universal-rope bit-exact oracle fixtures (4–8 KB each). CI load-bearer; tests/universal-rope.test.ts skips cleanly if absent. Regenerated by scripts/gen-universal-rope-fixtures.py.",
  },
  {
    glob: "lab/**/lib*.dylib",
    maxBytes: 102_400,
    why: "Compiled C dylibs for the bun-ffi-f64 upstream-bug repro (lab/repro/). Rebuilt from tracked .c sources; tiny (≤36 KB).",
  },
];

const BINARY_EXT = /\.(bin|safetensors|dylib|gguf|metallib)$/i;

// Minimal glob → RegExp: supports *, **, and literal segments.
function globToRe(glob: string): RegExp {
  // Anchor and escape, then translate *, **  (handle **/ and /** and /**/).
  let re = "";
  let i = 0;
  while (i < glob.length) {
    const c = glob[i]!;
    if (c === "*") {
      if (glob[i + 1] === "*") {
        // **
        i += 2;
        // consume a following slash — **/ means "any number of dirs"
        if (glob[i] === "/") {
          i += 1;
          re += "(?:.*/)?";
        } else {
          re += ".*";
        }
      } else {
        i += 1;
        re += "[^/]*";
      }
    } else if (".+?^${}()|[]\\".includes(c)) {
      re += "\\" + c;
      i += 1;
    } else {
      re += c;
      i += 1;
    }
  }
  return new RegExp("^" + re + "$");
}

const ALLOW_RE = ALLOW.map((a) => ({ ...a, re: globToRe(a.glob) }));

function allowMatch(path: string): AllowEntry | null {
  return ALLOW_RE.find((a) => a.re.test(path)) ?? null;
}

function listFiles(): string[] {
  const cmd =
    mode === "staged"
      ? "git diff --cached --name-only --diff-filter=A"
      : "git ls-files";
  return execSync(cmd, { cwd: ROOT, encoding: "utf8" })
    .split("\n")
    .map((s) => s.trim())
    .filter(Boolean);
}

function fileBytes(path: string): number {
  // Use git-cat-file for accuracy against the index/HEAD (avoids stat on
  // possibly-deleted working-tree files during --staged).
  try {
    const out = execSync(`git cat-file -s :${path}`, {
      cwd: ROOT,
      encoding: "utf8",
    });
    return parseInt(out.trim(), 10);
  } catch {
    // Not in index (e.g. working-tree-only); fall back to fs.
    try {
      return readFileSync(`${ROOT}/${path}`).length;
    } catch {
      return 0;
    }
  }
}

function checkBinaries(): string[] {
  const files = listFiles();
  const fails: string[] = [];
  for (const f of files) {
    const isBinary = BINARY_EXT.test(f);
    let size: number;
    try {
      size = fileBytes(f);
    } catch {
      continue; // vanished; not our concern here
    }
    const isLarge = size > ONE_MB;
    if (!isBinary && !isLarge) continue;

    const entry = allowMatch(f);
    if (!entry) {
      fails.push(
        `  FAIL  ${f} (${(size / ONE_MB).toFixed(2)} MB${isBinary ? ", binary ext" : ""}) — NOT on the allowlist. If it's a regenerable artifact, untrack + gitignore + add a regen script (see goldens/README.md policy). Otherwise add a justified entry to ALLOW in scripts/check-hygiene.ts.`,
      );
    } else if (size > entry.maxBytes) {
      fails.push(
        `  FAIL  ${f} (${size} B) — allowlisted (${entry.glob}, cap ${entry.maxBytes} B) but EXCEEDS the cap. ${entry.why}`,
      );
    }
  }
  return fails;
}

// ---------------------------------------------------------------------------
// 2. docs-map coverage assertion
// ---------------------------------------------------------------------------

function checkDocsMap(): string[] {
  const claude = readFileSync(`${ROOT}/CLAUDE.md`, "utf8");
  // Isolate the Doc map section (from "**Doc map:**" up to the next "**" header).
  const start = claude.indexOf("**Doc map:**");
  if (start < 0) return ["  FAIL  CLAUDE.md has no '**Doc map:**' section."];
  const rest = claude.slice(start);
  const nextHdr = rest.indexOf("\n**", 1);
  const mapSection = nextHdr > 0 ? rest.slice(0, nextHdr) : rest;

  // Enumerate every tracked docs/**/*.md (exclude docs/archive/ frozen HTML
  // neighbors and dotfiles; .md only).
  const docs = execSync("git ls-files 'docs/*.md' 'docs/**/*.md'", {
    cwd: ROOT,
    encoding: "utf8",
  })
    .split("\n")
    .map((s) => s.trim())
    .filter(Boolean);

  const missing: string[] = [];
  for (const f of docs) {
    const base = f.replace(/.*\//, "").replace(/\.md$/, "");
    if (!mapSection.includes(base)) missing.push(f);
  }
  // Spurious: files in the map that no longer exist (best-effort, warn only).
  return missing.map(
    (f) =>
      `  FAIL  ${f} — not mentioned in CLAUDE.md Doc map (by basename). Add it to the relevant docs/{reference,design,investigations,planning}/ bullet.`,
  );
}

// ---------------------------------------------------------------------------
// run
// ---------------------------------------------------------------------------

let exit = 0;
const runBin = mode === "all" || mode === "staged" || mode === "binaries";
const runMap = mode === "all" || mode === "docs-map";

if (runBin) {
  const fails = checkBinaries();
  console.log(`== hygiene: binaries (${mode}) ==`);
  if (fails.length) {
    fails.forEach((l) => console.log(l));
    console.log(`  ${fails.length} binary/huge-file violation(s).`);
    exit = 1;
  } else {
    console.log("  OK — every binary/large tracked file is allowlisted + in-cap.");
  }
}
if (runMap) {
  const fails = checkDocsMap();
  console.log(`== hygiene: docs-map coverage ==`);
  if (fails.length) {
    fails.forEach((l) => console.log(l));
    console.log(`  ${fails.length} doc(s) missing from the map.`);
    exit = 1;
  } else {
    console.log("  OK — every docs/**/*.md appears in the CLAUDE.md Doc map.");
  }
}
if (mode === "all" || mode === "root") {
  const fails = checkRoot();
  console.log(`== hygiene: root allowlist ==`);
  if (fails.length) {
    fails.forEach((l) => console.log(l));
    console.log(`  ${fails.length} unexpected tracked root file(s).`);
    exit = 1;
  } else {
    console.log("  OK — every tracked root file is on the allowlist.");
  }
}
process.exit(exit);
