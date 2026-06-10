#!/usr/bin/env bun
// mlx-bun CLI: the appliance interface.
//
//   mlx-bun scan                          index the HF cache
//   mlx-bun ls [--vision] [--max-size 10GB] [query]
//   mlx-bun fit <query> [--ctx 32768] [--skus]
//   mlx-bun serve <query> [--port 8090] [--memory-budget GB]
//   mlx-bun evals                         recent benchmark runs

import { Registry } from "./registry";
import { loadModelConfig } from "./config";
import { fit, skuMatrix, thisMachine } from "./fit";
import { EvalDB } from "./evaldb";

const argv = process.argv.slice(2);
const cmd = argv[0];

const flag = (name: string): boolean => argv.includes(`--${name}`);
const opt = (name: string, dflt: string | null = null): string | null => {
  const i = argv.indexOf(`--${name}`);
  return i > -1 && argv[i + 1] ? argv[i + 1]! : dflt;
};
const positional = (n: number): string | undefined =>
  argv.filter((a, i) => !a.startsWith("--") && (i === 0 || !argv[i - 1]!.startsWith("--"))).slice(1)[n];

const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;

function parseSize(s: string): number {
  const m = /^([\d.]+)\s*(GB|MB|G|M)?$/i.exec(s.trim());
  if (!m) throw new Error(`bad size: ${s}`);
  const mult = /^m/i.test(m[2] ?? "G") ? 2 ** 20 : 2 ** 30;
  return Number(m[1]) * mult;
}

switch (cmd) {
  case "scan": {
    const reg = new Registry();
    const n = await reg.scan();
    console.log(`indexed ${n} model snapshot(s)`);
    break;
  }

  case "ls": {
    const reg = new Registry();
    if ((reg.list().length ?? 0) === 0) await reg.scan();
    const maxSize = opt("max-size");
    const models = reg.list({
      vision: flag("vision") ? true : undefined,
      maxBytes: maxSize ? parseSize(maxSize) : undefined,
      query: positional(0),
    });
    if (models.length === 0) {
      console.log("no models match (try `mlx-bun scan`)");
      break;
    }
    for (const m of models) {
      const caps = [
        m.hasVisionSidecar ? "vision" : null,
        m.hasToolTemplate ? "tools" : null,
        m.hasKvConfig ? "kv-quant" : null,
      ].filter(Boolean).join(",");
      const quant = m.quantBits ? `${m.quantBits}-bit g${m.quantGroupSize}` : "full";
      const params = m.paramCount ? `${(m.paramCount / 1e9).toFixed(1)}B` : "?";
      console.log(
        `${m.repoId.padEnd(48)} ${gb(m.sizeBytes).padStart(9)}  ${params.padStart(6)}  ${quant.padEnd(12)} ${caps}`,
      );
    }
    break;
  }

  case "fit": {
    const query = positional(0);
    if (!query) { console.error("usage: mlx-bun fit <query> [--ctx N] [--skus]"); process.exit(1); }
    const reg = new Registry();
    if (reg.list().length === 0) await reg.scan();
    const m = reg.resolve(query);
    const config = await loadModelConfig(m.path);
    const ctx = Number(opt("ctx", "8192"));
    const r = fit(config, m.sizeBytes, ctx, thisMachine(), undefined, m.expertsBytes);
    console.log(`${m.repoId} @ ${ctx} context on ${thisMachine().name}:`);
    console.log(`  weights   ${gb(r.weightsBytes)}${
      config.text.enableMoeBlock && m.expertsBytes > 0
        ? ` (experts ${gb(m.expertsBytes)}; top ${config.text.topKExperts}/${config.text.numExperts} read per token)`
        : ""
    }`);
    if (m.sidecarBytes > 0)
      console.log(`  (+ vision sidecar ${gb(m.sidecarBytes)}, bf16 — loads only for vision requests)`);
    console.log(`  kv cache  ${gb(r.kvBytes)}`);
    console.log(`  transient ${gb(r.transientBytes)}`);
    console.log(`  total     ${gb(r.totalBytes)} of ${gb(r.usableBytes)} usable → ${r.fits ? "FITS" : "DOES NOT FIT"}`);
    console.log(`  max safe context: ${r.maxSafeContext} tokens`);
    console.log(`  predicted decode: ${r.predictedDecodeTps.toFixed(1)} tok/s`);
    if (flag("skus")) {
      console.log(`\nSKU matrix @ ${ctx} context:`);
      for (const row of skuMatrix(config, m.sizeBytes, ctx, m.expertsBytes)) {
        console.log(
          `  ${`${row.sku} ${row.ramGB}GB`.padEnd(16)} ${row.fits ? "fits" : "  — "}  ` +
          `max ctx ${String(row.maxContext).padStart(7)}  ~${row.decodeTps.toFixed(0)} tok/s`,
        );
      }
    }
    break;
  }

  case "serve": {
    const query = positional(0);
    if (!query) {
      console.error("usage: mlx-bun serve <query> [--port 8090] [--memory-budget GB]");
      process.exit(1);
    }
    const reg = new Registry();
    if (reg.list().length === 0) await reg.scan();
    const m = reg.resolve(query);
    const { createServer, loadContext } = await import("./server");
    const budgetGB = Number(opt("memory-budget", "0"));
    const memoryBudgetBytes = budgetGB > 0 ? budgetGB * 1e9 : undefined;
    console.log(`loading ${m.repoId} ...`);
    const t0 = performance.now();
    const ctx = await loadContext(m.path, m.repoId, { memoryBudgetBytes });
    const server = createServer(ctx, Number(opt("port", "8090")), { memoryBudgetBytes });
    if (memoryBudgetBytes)
      console.log(`memory budget: ${budgetGB} GB (admission control on)`);
    console.log(
      `serving ${m.repoId} at http://localhost:${server.port}/v1 ` +
      `(ready in ${(performance.now() - t0).toFixed(0)} ms)`,
    );
    break;
  }

  case "evals": {
    const db = new EvalDB();
    for (const r of db.recent()) {
      console.log(
        `${new Date(r.ts as number).toISOString()}  ${(r.model_path as string).split("/").at(-1)}  ` +
        `decode ${(r.decode_tps as number).toFixed(1)} tok/s  peak ${gb(r.peak_bytes as number)}  ` +
        `${r.commit_sha ?? ""} ${r.notes ?? ""}`,
      );
    }
    break;
  }

  default:
    console.log("usage: mlx-bun <scan|ls|fit|serve|evals> [...]");
    process.exit(cmd ? 1 : 0);
}
