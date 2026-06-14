// HumanEval — code-generation pass@1. Port of optiq/eval/humaneval.py:
// raw function-completion (or instruct code-block when a chat template
// exists), greedy decode, stop-sequence truncation, then execute the
// assembled program (prompt + completion + test + check(entry)) in a
// macOS sandbox-exec jail (falls back to a plain subprocess) against the
// oracle venv python. A problem passes iff the program exits 0 within the
// timeout.
//
// SECURITY: generated code is UNTRUSTED model output. It is NEVER eval'd
// in-process — each candidate runs as a separate, sandboxed python
// subprocess with a hard wall-clock timeout and a memory cap, in a fresh
// temp dir that is removed afterwards.

import { spawnSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { generateText, loadJsonl, sampleIndices, type TaskModel } from "../runner";

// Oracle venv python — the same interpreter the Python reference uses.
const ORACLE_PYTHON = "/Users/joshrossi/Code/mlx-lm/.venv/bin/python";

interface HumanevalRow {
  task_id: string;
  prompt: string;
  canonical_solution: string;
  test: string;
  entry_point: string;
}

export interface HumanevalResult {
  nPass: number;
  nTotal: number;
  accuracy: number; // pass@1, 0..1
}

// Stop sequences — mirror humaneval.py's _STOP_SEQS exactly.
const STOP_SEQS = ["\nclass ", "\ndef ", "\n#", "\nif __name__", "\nprint(", "\n```"];

/** Last fenced ```python|py? ... ``` block, or null (port of _extract_code_block). */
function extractCodeBlock(text: string): string | null {
  const re = /```(?:python|py)?\n([\s\S]*?)\n```/g;
  let last: string | null = null;
  for (const m of text.matchAll(re)) last = m[1]!;
  return last;
}

/** Escape a string for use as a literal inside a RegExp (re.escape). */
function reEscape(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Strip the `def entry_point(...):` header + docstring, keep just the body
 * (port of _strip_function_def). Falls through if no such def is found.
 */
function stripFunctionDef(body: string, entryPoint: string): string {
  const pat = new RegExp(`def\\s+${reEscape(entryPoint)}\\s*\\([^)]*\\)[^:]*:\\s*\\n`);
  const m = body.match(pat);
  if (!m || m.index === undefined) return body;
  const after = body.slice(m.index + m[0].length);
  // Skip leading blank lines + a possible docstring.
  let rest = after.replace(/^\n+/, "");
  const doc = rest.match(/^\s*(["']{3})([\s\S]*?)\1\s*\n/);
  if (doc) rest = rest.slice(doc[0].length);
  return rest;
}

/**
 * Reduce the model response to a function body suitable for concatenating
 * onto the HumanEval prompt (port of _truncate_completion).
 */
export function truncateCompletion(text: string, entryPoint = ""): string {
  let out = text;
  if (out.includes("</think>")) out = out.split("</think>").slice(1).join("</think>");
  if (out.includes("<channel|>")) out = out.split("<channel|>").slice(1).join("<channel|>");

  // Prefer the last fenced code block (conversational models).
  const block = extractCodeBlock(out);
  if (block !== null) {
    return entryPoint ? stripFunctionDef(block, entryPoint) : block;
  }

  // Legacy / completion-mode path: strip a leading fence, then cut at the
  // first stop sequence.
  out = out.replace(/^\s+/, "");
  if (out.startsWith("```python\n")) out = out.slice("```python\n".length);
  else if (out.startsWith("```\n")) out = out.slice("```\n".length);

  let earliest = out.length;
  for (const stop of STOP_SEQS) {
    const i = out.indexOf(stop);
    if (i !== -1 && i < earliest) earliest = i;
  }
  return out.slice(0, earliest);
}

/** Concatenate prompt + completion + test driver (port of _build_program). */
function buildProgram(prompt: string, completion: string, test: string, entryPoint: string): string {
  return prompt + completion + "\n\n" + test + "\n\n" + `check(${entryPoint})\n`;
}

// sandbox-exec SBPL profile (port of _SBPL_PROFILE): deny network, deny
// most filesystem writes except the temp dir; reads stay open so python
// can find its stdlib.
const SBPL_PROFILE = (tmp: string) => `(version 1)
(deny default)
(allow process-fork)
(allow process-exec)
(allow file-read*)
(allow file-write* (subpath "${tmp}"))
(allow file-write-data
       (literal "/dev/null")
       (literal "/dev/dtracehelper"))
(allow sysctl-read)
(allow mach-lookup)
(allow ipc-posix-shm)
`;

// rlimit + no-socket preamble prepended to the script (port of the
// sandbox-exec preamble). Caps address space / data segment and disables
// raw socket creation so a buggy program can't exhaust RAM or hit the net.
const preamble = (memoryMb: number) => `import resource
try:
    resource.setrlimit(resource.RLIMIT_AS,   (${memoryMb} * 1024 * 1024,) * 2)
except (ValueError, OSError):
    pass
try:
    resource.setrlimit(resource.RLIMIT_DATA, (${memoryMb} * 1024 * 1024,) * 2)
except (ValueError, OSError):
    pass
import socket as _s
_orig_socket = _s.socket
def _no_socket(*a, **k):
    raise OSError("network access disabled in sandbox")
_s.socket = _no_socket
`;

const HAS_SANDBOX_EXEC = (() => {
  try {
    return spawnSync("which", ["sandbox-exec"]).status === 0;
  } catch {
    return false;
  }
})();

interface RunResult { ok: boolean; timedOut: boolean }

/**
 * Run `program` as a python script in a fresh temp dir, sandboxed if
 * sandbox-exec is available (else a plain rlimit-capped subprocess), with
 * a hard wall-clock timeout. Returns whether it exited 0 (pass). The code
 * is NEVER eval'd in-process — always a separate subprocess.
 */
function runProgram(program: string, timeoutSec: number, memoryMb: number): RunResult {
  const sbRoot = mkdtempSync(join(tmpdir(), "mlxbun_he_"));
  try {
    const scriptPath = join(sbRoot, "script.py");
    writeFileSync(scriptPath, preamble(memoryMb) + "\n" + program);

    const env = {
      PATH: "/usr/bin:/bin",
      PYTHONIOENCODING: "utf-8",
      HOME: sbRoot,
      TMPDIR: sbRoot,
      MPLBACKEND: "Agg",
      MPLCONFIGDIR: sbRoot,
      XDG_CACHE_HOME: sbRoot,
      XDG_CONFIG_HOME: sbRoot,
    };

    let argv: string[];
    if (HAS_SANDBOX_EXEC) {
      const profilePath = join(sbRoot, "policy.sb");
      writeFileSync(profilePath, SBPL_PROFILE(sbRoot));
      argv = ["sandbox-exec", "-f", profilePath, ORACLE_PYTHON, "-I", scriptPath];
    } else {
      argv = [ORACLE_PYTHON, "-I", scriptPath];
    }

    const res = spawnSync(argv[0]!, argv.slice(1), {
      cwd: sbRoot,
      env,
      timeout: timeoutSec * 1000, // hard wall-clock kill
      killSignal: "SIGKILL",
      stdio: ["ignore", "ignore", "ignore"],
    });

    // spawnSync sets signal === "SIGKILL" (and status === null) when the
    // timeout fires; ETIMEDOUT shows up in res.error on some platforms.
    const timedOut =
      res.signal === "SIGKILL" ||
      (res.error as NodeJS.ErrnoException | undefined)?.code === "ETIMEDOUT";
    const ok = !timedOut && res.status === 0;
    return { ok, timedOut };
  } finally {
    rmSync(sbRoot, { recursive: true, force: true });
  }
}

export async function evaluateHumaneval(
  tm: TaskModel,
  opts: {
    nSamples?: number;
    maxTokens?: number;
    seed?: number;
    timeoutSec?: number;
    memoryMb?: number;
  } = {},
): Promise<HumanevalResult> {
  const maxTokens = opts.maxTokens ?? 512;
  const timeoutSec = opts.timeoutSec ?? 10;
  const memoryMb = opts.memoryMb ?? 512;
  const rows = loadJsonl<HumanevalRow>("humaneval");
  const idx = sampleIndices(rows.length, opts.nSamples ?? rows.length, opts.seed ?? 42);

  // When a chat template exists, ask the model (instruct-style) for the
  // complete function inside a ```python block — humaneval.py's use_chat
  // path. Otherwise feed the raw signature for completion.
  const useChat = tm.template !== null;

  let nPass = 0;
  for (let k = 0; k < idx.length; k++) {
    const ex = rows[idx[k]!]!;

    let body: string;
    if (useChat) {
      body =
        "Complete the following Python function. Output the " +
        "complete function (header, docstring, body) inside a " +
        "single ```python ... ``` code block. No commentary " +
        "outside the code block.\n\n" +
        "```python\n" + ex.prompt + "```";
    } else {
      body = ex.prompt;
    }

    const raw = await generateText(tm, body, { maxTokens, useChat });
    const completion = truncateCompletion(raw, ex.entry_point);
    const program = buildProgram(ex.prompt, completion, ex.test, ex.entry_point);

    const { ok } = runProgram(program, timeoutSec, memoryMb);
    if (ok) nPass++;

    if ((k + 1) % 5 === 0 || k + 1 === idx.length)
      process.stderr.write(
        `\r  humaneval ${k + 1}/${idx.length}  pass@1=${((nPass / (k + 1)) * 100).toFixed(1)}%`,
      );
  }
  process.stderr.write("\n");
  return { nPass, nTotal: idx.length, accuracy: idx.length ? nPass / idx.length : 0 };
}
