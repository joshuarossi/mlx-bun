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
//                   docs/reference/benchmarks.md; built models to ~/models.
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

import { existsSync, readdirSync, readFileSync } from "node:fs";
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
  "AGENTS.md", "CLAUDE.md", "CONTRIBUTING.md", "LICENSE",
  "PLAN.md", "README.md", "STATUS.md",
  "THIRD_PARTY_LICENSES.md",
  "scripts/bench-serve.ts all", "bun.lock", "package.json",
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
    why: "Text JSON golden (bf16-quantized reference kernel output). Model-free CI load-bearer (tests/qwen-delta.test.ts, no model load). Regenerated by scripts/oracle/gen-qwen-delta-golden.py.",
  },
  {
    glob: "tests/fixtures/**/*.bin",
    maxBytes: 16_384,
    why: "Model-free universal-rope bit-exact oracle fixtures (4–8 KB each). CI load-bearer; tests/universal-rope.test.ts skips cleanly if absent. Regenerated by scripts/oracle/gen-universal-rope-fixtures.py.",
  },
  {
    glob: "fixtures/audio/*.wav",
    maxBytes: 131_072,
    why: "Tiny audio inputs for the model-free audio preprocessor tests (≤100 KB each).",
  },
  {
    glob: "tests/fixtures/grad-*.png",
    maxBytes: 262_144,
    why: "Vision preprocessor fixtures (gradient images); model-free CI load-bearers.",
  },
  {
    glob: "tests/fixtures/grad-*.heic",
    maxBytes: 65_536,
    why: "HEIC fixture for the Bun.Image native codec path; model-free CI load-bearer.",
  },
  {
    glob: "tests/fixtures/qwen38-clip.mov",
    maxBytes: 65_536,
    why: "10 KB clip driving the video frame-extraction tests.",
  },
  {
    glob: "tests/fixtures/qwen38-clip-frames/*.png",
    maxBytes: 131_072,
    why: "Frames extracted from qwen38-clip.mov by the AVFoundation sidecar; pinned so the video preprocessor test is model-free and sidecar-free in CI. Regenerate with mlx-bun-frame-extract.",
  },
];

const BINARY_EXT = /\.(bin|safetensors|dylib|gguf|metallib|wav|png|heic|mov|webp|jpg|jpeg|npz)$/i;

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

/** Content sniff: a NUL byte in the first 8 KB means Mach-O/ELF/blob, whatever
 *  the extension says (the 2026-08 sweep found an extension-less Mach-O under
 *  lab/spikes that the extension regex never saw). */
const TEXT_EXT = /\.(ts|tsx|js|mjs|cjs|json|md|mdx|py|sh|c|cpp|h|m|mm|swift|metal|rb|yml|yaml|toml|txt|html|css|svg|astro|plist|patch|jsonl|csv|webmanifest)$/i;
function looksBinary(path: string): boolean {
  if (TEXT_EXT.test(path)) return false; // source text may legitimately embed \0
  try {
    const buf = execSync(`git cat-file -p :${path}`, { cwd: ROOT, maxBuffer: 1 << 24 });
    return buf.subarray(0, 8192).includes(0);
  } catch {
    try { return readFileSync(`${ROOT}/${path}`).subarray(0, 8192).includes(0); }
    catch { return false; }
  }
}

function checkBinaries(): string[] {
  const files = listFiles();
  const fails: string[] = [];
  for (const f of files) {
    const isBinary = BINARY_EXT.test(f) || looksBinary(f);
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
// 4. root-untracked artifacts — dated bench dumps at root are work products
//    whether or not git sees them (2026-08 sweep: six untracked
//    benchmarks-serve-*.md sat at root for a week). Move them to reports/.
// ---------------------------------------------------------------------------

function checkRootArtifacts(): string[] {
  return readdirSync(ROOT)
    .filter((f) => /^(benchmarks?|bench)-.*\.(md|json|html)$/.test(f))
    .map((f) => `  FAIL  ${f} — dated benchmark artifact at repo root (untracked or not). Move it to reports/ (gitignored) or distil into docs/reference/benchmarks.md.`);
}

// ---------------------------------------------------------------------------
// 5. docs/archive is .md only — raw run data, logs, and generated HTML are
//    recoverable from git history, never tracked (CONTRIBUTING rule 1).
// ---------------------------------------------------------------------------

function checkArchiveMdOnly(): string[] {
  return listFiles()
    .filter((f) => f.startsWith("docs/archive/") && !f.endsWith(".md"))
    .map((f) => `  FAIL  ${f} — docs/archive/ holds authored write-ups (.md) only; raw artifacts live in git history.`);
}

// ---------------------------------------------------------------------------
// 6. scripts/ root allowlist — production tooling only. A new top-level
//    script needs an entry here; research one-offs write their finding into
//    a doc and are deleted (scripts/experiments/ was removed 2026-08-23).
// ---------------------------------------------------------------------------

const SCRIPTS_ROOT_ALLOWLIST = new Set([
  // build + distribution
  "build-binary.sh", "build-native-pack.sh", "build-frame-extract.sh",
  "build-expert-io.sh", "build-web.ts", "release-binary.sh",
  "publish-release.sh", "verify-binary-pi.ts", "verify-colibri-g0-artifact.ts",
  // gates + hygiene
  "test.sh", "check-hygiene.ts", "fetch-test-fixtures.sh", "clean.ts",
  "history-rewrite.sh",
  // codegen + fixtures + goldens
  "gen-model.ts", "regen.ts", "gen-colibri-glm52-fixtures.ts",
  "gen-colibri-expert-file.ts", "gen-curve-terrain.ts",
  // measurement
  "bench-serve.ts", "bench-h2h.ts", "bench-matrix.ts", "bench-levers.ts",
  "bench-serving-load.ts", "bench-prompt-response.ts", "bench-orpo.ts",
  "render-p2r-html.ts", "summarize-p2r-waterfall.ts",
  // quality + parity + training checks
  "eval.ts", "run-ifeval.ts", "parity-check.ts", "op-parity-check.ts",
  "train-orpo.ts", "curate-ultrafeedback.ts", "inspect-model.ts",
  // dispatchers' job families live in subdirs: regen/ dspark/ bench/
  "dspark.ts",
]);

function checkScriptsRoot(): string[] {
  return listFiles()
    .filter((f) => /^scripts\/[^/]+\.(ts|sh|py|mjs)$/.test(f))
    .map((f) => f.slice("scripts/".length))
    .filter((f) => !SCRIPTS_ROOT_ALLOWLIST.has(f))
    .map((f) => `  FAIL  scripts/${f} — not on SCRIPTS_ROOT_ALLOWLIST. Production tooling gets an entry (scripts/check-hygiene.ts); research one-offs record their finding in a doc and are deleted.`);
}

// ---------------------------------------------------------------------------
// 7. script-path validity — every scripts/<path> mentioned in the live docs
//    must exist (four dead paths survived the 2026-08 audit because nothing
//    checked them). Frozen docs/archive/ is exempt by design.
// ---------------------------------------------------------------------------

function checkScriptPaths(): string[] {
  const liveDocs = ["README.md", "CLAUDE.md", "CONTRIBUTING.md", "PLAN.md", "STATUS.md",
    ...listFiles().filter((f) => /^docs\/(reference|design|planning)\/.*\.md$/.test(f))];
  const fails: string[] = [];
  const seen = new Set<string>();
  for (const doc of liveDocs) {
    let text: string;
    try { text = readFileSync(`${ROOT}/${doc}`, "utf8"); } catch { continue; }
    for (const m of text.matchAll(/scripts\/[A-Za-z0-9_./-]+?\.(?:ts|py|sh|mjs)\b/g)) {
      const p = m[0];
      if (p.includes("<") || p.includes("*")) continue;
      const key = `${doc}:${p}`;
      if (seen.has(key)) continue;
      seen.add(key);
      if (!existsSync(`${ROOT}/${p}`))
        fails.push(`  FAIL  ${doc} references ${p} — path does not exist (deleted/moved script; fix the doc or note "(deleted; git history)").`);
    }
  }
  return fails;
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
  console.log("== hygiene: root artifacts / archive md-only / scripts root / script paths ==");
  const more = [...checkRootArtifacts(), ...checkArchiveMdOnly(), ...checkScriptsRoot(), ...checkScriptPaths()];
  if (more.length) { for (const m of more) console.log(m); exit = 1; }
  else console.log("  OK — no root artifacts, archive is .md-only, scripts root allowlisted, doc script paths resolve.");
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
