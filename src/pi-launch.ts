// mlx-bun pi — launch the user's installed pi against the local server
// (Phase 16 P2, docs/investigations/pi-builtin-investigation.md).
//
// Session-scoped wiring, no global config writes: a temp extension file
// registers the provider for this run only (-e <file>), the default
// model is the server's, and Ctrl+P cycling is scoped to local models
// via `--models "mlx-bun/*"` so the user can SELECT among everything
// the server offers (and /model still reaches their other providers).
// All unrecognized argv passes through to pi verbatim — and user flags
// are appended after ours, so an explicit --model/--models wins.
//
// pi's bin shim is `#!/usr/bin/env node` and pi-tui needs node >= 22.19
// (/v-flag regexes); a stale system node crashes it. We therefore spawn
// pi's cli.js under the Bun that is running us (process.execPath) —
// the same runtime upstream compiles their release binary with.

import { mkdtempSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  detectPi, fetchServerModels, renderPiExtension,
  PI_PROVIDER_ID, type PiDetection, type ServerModel,
} from "./harness-pi";

/** GET /v1/models with a short timeout; null when no server is up. */
export async function probeServer(baseUrl: string, timeoutMs = 1500): Promise<ServerModel[] | null> {
  const models = await fetchServerModels(baseUrl, timeoutMs);
  return models.length > 0 ? models : null;
}

export interface PiInvocation {
  argv: string[];
  /** Temp dir holding the session-scoped extension; caller removes it. */
  cleanupDir: string;
}

/** Build the full pi argv: session extension + provider/model defaults +
 *  scoped cycling, with user passthrough LAST so it overrides ours. */
export function buildPiInvocation(
  pi: PiDetection,
  baseUrl: string,
  models: ServerModel[],
  passthrough: string[],
): PiInvocation {
  if (!pi.found || !pi.binPath) throw new Error("pi not found");
  const cleanupDir = mkdtempSync(join(tmpdir(), "mlx-bun-pi-"));
  const extPath = join(cleanupDir, "mlx-bun-provider.ts");
  writeFileSync(extPath, renderPiExtension(baseUrl, models));
  const cli = realpathSync(pi.binPath); // resolve the shim
  // Interpreter resolution. A JS install (bun/npm shim -> cli.js) needs
  // a runtime: bun, or ourselves when we ARE bun (`bun run`). Inside
  // the COMPILED mlx-bun binary process.execPath is mlx-bun itself —
  // it cannot execute a JS file (the original "friend had to install
  // bun" bug). pi's standalone install (pi.dev/install.sh) is its own
  // compiled binary and runs directly.
  let runner: string[];
  if (!cli.endsWith(".js")) {
    runner = [cli]; // compiled pi binary
  } else {
    const selfIsBun = process.execPath.endsWith("/bun");
    const bun = selfIsBun ? process.execPath : Bun.which("bun");
    if (!bun) throw new Error(
      "pi is installed as a JS package, which needs the bun runtime — either\n" +
      "install standalone pi (curl -fsSL https://pi.dev/install.sh | sh)\n" +
      "or install bun (https://bun.sh)",
    );
    runner = [bun, cli];
  }
  const argv = [
    ...runner,
    "-e", extPath,
    "--provider", PI_PROVIDER_ID,
    "--model", models[0]!.id,
    // Exact ids, not "mlx-bun/*": the provider registers via an async
    // extension factory, and the glob is resolved before that happens
    // (observed: "No models match pattern" warning with the glob).
    "--models", models.map((m) => m.id).join(","),
    ...passthrough,
  ];
  return { argv, cleanupDir };
}

/** Spawn pi with inherited stdio; returns its exit code.
 *  SIGINT is ignored in the parent while pi runs: Ctrl+C reaches the
 *  whole foreground process group, and pi treats the first press as
 *  "clear input" / double-press as exit — the parent (and any server
 *  it carries) must not die on the first press. */
export async function launchPi(invocation: PiInvocation): Promise<number> {
  const ignoreSigint = () => {};
  process.on("SIGINT", ignoreSigint);
  try {
    const child = Bun.spawn(invocation.argv, {
      stdin: "inherit", stdout: "inherit", stderr: "inherit",
    });
    return await child.exited;
  } finally {
    process.off("SIGINT", ignoreSigint);
    rmSync(invocation.cleanupDir, { recursive: true, force: true });
  }
}
