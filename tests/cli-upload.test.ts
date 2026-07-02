// CLI upload verb + 2026-07-01 CLI-audit plumbing — all model-free.
//
// Every test spawns `bun src/cli.ts …` and exercises only paths that exit
// BEFORE any model load or network call (usage errors, token resolution,
// registry picks against an isolated empty $HOME). Nothing here uploads,
// downloads, or loads weights.
//
//   - upload: mlx_lm.upload parity verb (--path/--upload-repo) over
//     src/hf-push.ts — arg validation, dir check, token-missing error.
//   - convert --upload-repo: now wired (token checked BEFORE converting).
//   - embed: the no-query path picks a downloaded embedding model and
//     errors helpfully when none exists (never the chat-starter download).
//   - train --sft-scope: value validation, before model resolution.
//   - help routing: generate / gen / train-watch / upload are documented
//     verbs (their --help used to exit 1 "unknown command").
//   - memory: unknown subcommand exits 1; `setup` is a true memory alias.

import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { nativeRuntimeDir } from "../src/native-pack";

const CLI = join(import.meta.dir, "../src/cli.ts");

/** Run the CLI with optional env overrides (undefined = unset the var). */
async function runCli(
  args: string[],
  env?: Record<string, string | undefined>,
): Promise<{ code: number; out: string }> {
  const merged: Record<string, string> = {};
  for (const [k, v] of Object.entries({ ...process.env, ...env }))
    if (v !== undefined) merged[k] = v;
  const p = Bun.spawn(["bun", CLI, ...args], { stdout: "pipe", stderr: "pipe", env: merged });
  const [stdout, stderr, code] = await Promise.all([
    new Response(p.stdout).text(),
    new Response(p.stderr).text(),
    p.exited,
  ]);
  return { code, out: stdout + stderr };
}

/** Isolated empty $HOME: no HF cache, no registry DB, no saved HF token. */
function withTempHome<T>(fn: (home: string) => Promise<T>): Promise<T> {
  const home = mkdtempSync(join(tmpdir(), "cli-upload-home-"));
  return fn(home).finally(() => rmSync(home, { recursive: true, force: true }));
}

// The mlx ffi module dlopens libmlxc at import time (the embed verb imports
// it before the registry pick). With $HOME isolated, resolution can miss the
// per-user cache, so pass the real machine's copy through explicitly.
const LIBMLXC = (() => {
  const dir = nativeRuntimeDir();
  return dir ? join(dir, "libmlxc.dylib") : null;
})();

// ---------------------------------------------------------------- upload verb

describe("upload verb — arg plumbing (model-free, no network)", () => {
  test("overview + help document the verb", async () => {
    const overview = await runCli(["--help"]);
    expect(overview.code).toBe(0);
    expect(overview.out).toContain("upload");
    const help = await runCli(["help", "upload"]);
    expect(help.code).toBe(0);
    expect(help.out).toContain("--upload-repo");
    expect(help.out).toContain("--path");
    expect(help.out).toContain("mlx_lm.upload");
  });

  test("usage error without --upload-repo", async () => {
    const { code, out } = await runCli(["upload", "--path", "/tmp"]);
    expect(code).toBe(1);
    expect(out).toContain("usage: mlx-bun upload");
  });

  test("valueless --upload-repo is a usage error", async () => {
    const { code, out } = await runCli(["upload", "--path", "/tmp", "--upload-repo"]);
    expect(code).toBe(1);
    expect(out).toContain("usage: mlx-bun upload");
  });

  test("missing --path directory exits 1 before any auth/network", async () => {
    const { code, out } = await runCli([
      "upload", "--upload-repo", "org/x", "--path", "/tmp/definitely-not-a-model-dir",
    ]);
    expect(code).toBe(1);
    expect(out).toContain("not a directory");
  });

  test("no HF token → helpful error listing all three sources", async () => {
    await withTempHome(async (home) => {
      const { code, out } = await runCli(
        ["upload", "--upload-repo", "org/x", "--path", home],
        { HOME: home, HF_TOKEN: undefined },
      );
      expect(code).toBe(1);
      expect(out).toContain("no Hugging Face token found");
      expect(out).toContain("hf auth login");
      expect(out).toContain("HF_TOKEN");
    });
  });
});

// -------------------------------------------------- convert --upload-repo wire

describe("convert --upload-repo — wired to hf-push (model-free)", () => {
  test("token is required BEFORE any conversion work", async () => {
    await withTempHome(async (home) => {
      const { code, out } = await runCli(
        ["convert", "--hf-path", "x", "-q", "--upload-repo", "org/x"],
        { HOME: home, HF_TOKEN: undefined },
      );
      expect(code).toBe(1);
      expect(out).toContain("--upload-repo needs a Hugging Face WRITE token");
    });
  });

  test("accepted with a token: falls through to normal convert validation", async () => {
    await withTempHome(async (home) => {
      // Fake token passes the presence check; the run then dies on the
      // ordinary "-q or --target-bpw" gate — proving --upload-repo is no
      // longer blanket-rejected and no network is touched.
      const { code, out } = await runCli(
        ["convert", "--hf-path", "x", "--upload-repo", "org/x"],
        { HOME: home, HF_TOKEN: "hf_fake_token_for_arg_test" },
      );
      expect(code).toBe(1);
      expect(out).toContain("pass -q or --target-bpw");
      expect(out).not.toContain("--upload-repo: not supported");
    });
  });

  test("help no longer lists --upload-repo as unsupported", async () => {
    const { code, out } = await runCli(["help", "convert"]);
    expect(code).toBe(0);
    expect(out).toContain("--upload-repo");
    expect(out).not.toContain("--upload-repo (not supported");
  });
});

// ------------------------------------------------------------ embed auto-pick

describe.skipIf(LIBMLXC === null)("embed — no-query auto-pick (model-free)", () => {
  test("no embedding model downloaded → helpful `get` suggestion, no starter download", async () => {
    await withTempHome(async (home) => {
      const { code, out } = await runCli(
        ["embed", "--text", "hello"],
        { HOME: home, MLX_BUN_LIBMLXC: LIBMLXC! },
      );
      expect(code).toBe(1);
      expect(out).toContain("no embedding model downloaded");
      expect(out).toContain("mlx-bun get mlx-community/Qwen3-Embedding");
      // The old behavior downloaded the chat starter first, then failed.
      expect(out).not.toContain("downloading starter model");
      expect(out).not.toContain("is not an embedding model");
    });
  });
});

// ------------------------------------------------------------ train --sft-scope

describe("train --sft-scope — value validation (model-free)", () => {
  test("junk value exits 1 before model resolution", async () => {
    await withTempHome(async (home) => {
      await Bun.write(join(home, "train.jsonl"), '{"prompt":"p","chosen":"c","rejected":"r"}\n');
      const { code, out } = await runCli(
        ["train", "some-model", "--data", home, "--sft-scope", "junk"],
        { HOME: home },
      );
      expect(code).toBe(1);
      expect(out).toContain("--sft-scope must be full | response");
    });
  });

  test("help train documents --sft-scope and the audit's four flags", async () => {
    const { code, out } = await runCli(["help", "train"]);
    expect(code).toBe(0);
    for (const f of ["--sft-scope", "--grad-accum", "--grad-clip", "--seed", "--val-size"])
      expect(out).toContain(f);
  });
});

// ------------------------------------------------------- help routing (audit)

describe("cli-audit help routing", () => {
  test("generate / gen / train-watch have help (used to exit 1 'unknown command')", async () => {
    for (const [verb, marker] of [
      ["generate", "--raw"],
      ["gen", "--raw"],
      ["train-watch", "metrics.jsonl"],
    ] as const) {
      const { code, out } = await runCli(["help", verb]);
      expect(code).toBe(0);
      expect(out).toContain(marker);
      expect(out).not.toContain("unknown command");
    }
    const dashHelp = await runCli(["generate", "--help"]);
    expect(dashHelp.code).toBe(0);
  });

  test("overview lists generate + train-watch", async () => {
    const { out } = await runCli(["--help"]);
    expect(out).toContain("generate");
    expect(out).toContain("train-watch");
  });

  test("fit help matches the code default (8192)", async () => {
    const { out } = await runCli(["help", "fit"]);
    expect(out).toContain("8192");
    expect(out).not.toContain("32768");
  });

  test("serve help documents the parity tiers", async () => {
    const { out } = await runCli(["help", "serve"]);
    for (const t of ["--l1", "--l2", "--l3"]) expect(out).toContain(t);
  });
});

// --------------------------------------------------------- memory exit codes

describe("memory / setup dispatch (audit #11)", () => {
  test("unknown memory subcommand exits 1 (was exit 0)", async () => {
    const { code, out } = await runCli(["memory", "definitely-not-a-subcommand"]);
    expect(code).toBe(1);
    expect(out).toContain("unknown: mlx-bun memory");
  });

  test("`setup` dispatches into the memory handler (not a help dead-end)", async () => {
    await withTempHome(async (home) => {
      const { code, out } = await runCli(["setup"], { HOME: home });
      // Same handler as `mlx-bun memory` → default `status` subcommand.
      expect(code).toBe(0);
      expect(out).toContain("no memory wiki yet");
      expect(out).toContain("mlx-bun memory init");
    });
  });
});
