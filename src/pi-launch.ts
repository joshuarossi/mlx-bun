// mlx-bun pi — launch the user's installed pi against the local server
// (Phase 16 P2, docs/pi-builtin-investigation.md).
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
  const cli = realpathSync(pi.binPath); // resolve the shim to cli.js
  const argv = [
    process.execPath, cli,
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

/** Spawn pi with inherited stdio; returns its exit code. */
export async function launchPi(invocation: PiInvocation): Promise<number> {
  try {
    const child = Bun.spawn(invocation.argv, {
      stdin: "inherit", stdout: "inherit", stderr: "inherit",
    });
    return await child.exited;
  } finally {
    rmSync(invocation.cleanupDir, { recursive: true, force: true });
  }
}
