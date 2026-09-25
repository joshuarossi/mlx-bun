import { Registry } from "@mlx-bun/hub/registry";
import { fit, skuMatrix, thisMachine, type FitKvScheme } from "@mlx-bun/hub/fit";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { resolveKvScheme } from "@mlx-bun/inference/state/kv-scheme";
import { isGlm52Config } from "@mlx-bun/inference/models/support";
import {
  GLM52_G5_DEFAULT_MAX_GENERATION_TOKENS,
  GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES, planGlm52MemoryForArtifact,
} from "@mlx-bun/inference/artifacts/glm52/memory";
import type { Command, CommandArgs } from "./args";

const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;
function parseSize(s: string): number {
  const match = /^(\d+(?:\.\d+)?)\s*(GB|MB|G|M)?$/i.exec(s.trim());
  if (!match) throw new Error(`bad size: ${s}`);
  return Number(match[1]) * (/^m/i.test(match[2] ?? "G") ? 2 ** 20 : 2 ** 30);
}

/** CLI policy and presentation only; the hub owns scanning, downloading, and GC. */
export async function runHub(cmd: Command, args: CommandArgs): Promise<void> {
  const flag = (name: string) => args.values[name] === true;
  const opt = (name: string, fallback: string | null = null): string | null => {
    const value = args.values[name];
    return typeof value === "string" ? value : fallback;
  };
  const positional = (index: number) => args.positionals[index];
  if (cmd === "fit") {
    const ctx = opt("ctx");
    if (ctx !== null && (!Number.isSafeInteger(Number(ctx)) || Number(ctx) <= 0))
      throw new Error("--ctx must be a positive integer");
  }
  const reg = new Registry();
  try {
    switch (cmd) {
      case "get": {
        let repoId = positional(0);
        if (!repoId) {
          throw new Error("usage: mlx-bun get <org/repo | substring> [--revision main]");
        }
        if (!repoId.includes("/")) {
          // No org/name — treat it as a registry query over already-downloaded
          // repos (re-get/refresh, e.g. `mlx-bun get 12B` after an upstream push).
          try {
            const regQ = reg;
            if (regQ.list().length === 0) await regQ.scan();
            repoId = regQ.resolve(repoId).repoId;
          } catch (e) {
            throw new Error(`${(e as Error).message}\nusage: mlx-bun get <org/repo> [--revision main] — or a substring of a downloaded repo (try \`mlx-bun ls ${repoId}\`)`);
          }
        }
        const { downloadModel } = await import("@mlx-bun/hub/download");
        const { step, style } = await import("./terminal");
        const { join: joinPath, basename } = await import("node:path");
        const { readdirSync, existsSync } = await import("node:fs");
        const { DEFAULT_HUB, planRepoGc } = await import("@mlx-bun/hub/registry");
        const repoDir = joinPath(DEFAULT_HUB, `models--${repoId.replaceAll("/", "--")}`);
        const priorSnapshots = existsSync(joinPath(repoDir, "snapshots"))
          ? readdirSync(joinPath(repoDir, "snapshots"))
          : [];
        const s = step(`downloading ${repoId}`);
        let snap: string;
        try {
        snap = await downloadModel(repoId, {
          revision: opt("revision", "main")!,
          onProgress: (file, received, total) => {
            const pct = total ? Math.floor((received / total) * 100) : 0;
            s.update(`${style.bold(repoId)} ${style.dim(`· ${file} · ${gb(received)} / ${gb(total)} (${pct}%)`)}`);
          },
        });
        } catch (error) { s.fail("download failed"); throw error; }
        s.done(`${style.bold(repoId)} ${style.dim("downloaded · verified")}`);
        const sScan = step("updating registry");

        try { await reg.scan(); }
        catch (error) { sScan.fail("registry update failed"); throw error; }
        sScan.done(`registry updated ${style.dim(`· ${snap}`)}`);
        // Upstream pushed a new revision → this get created a NEW snapshots/<sha>
        // dir; the old one stays on disk (that's how ~25 GB of dead blobs pile
        // up). Say so, with what `gc` would get back.
        if (priorSnapshots.length > 0 && !priorSnapshots.includes(basename(snap))) {
          const plan = planRepoGc(repoDir);
          const note = plan.skippedSnapshots.length > 0
            ? " (a previous snapshot has files this revision lacks — gc will warn; --force to prune it)"
            : "";
          console.log(style.dim(
            `  previous revision kept on disk — \`mlx-bun gc\` reclaims ~${gb(plan.reclaimBytes)}${note}`,
          ));
        }
        break;
      }

      case "scan": {
        const { step } = await import("./terminal");
        const s = step("scanning the Hugging Face cache");

        try {
          const n = await reg.scan();
          s.done(`indexed ${n} model snapshot(s)`);
        } catch (error) { s.fail("scan failed"); throw error; }
        break;
      }

      case "ls": {

        if ((reg.list().length ?? 0) === 0) await reg.scan();
        const maxSize = opt("max-size");
        const allRevisions = flag("all-revisions");
        const lsFilter = {
          vision: flag("vision") ? true : undefined,
          maxBytes: maxSize ? parseSize(maxSize) : undefined,
          query: positional(0),
        };
        // One row per repo by default: the HF cache keeps a snapshots/<commit>
        // dir per downloaded revision, and re-getting after an upstream push
        // strands the old one — those are duplicates, not separate models.
        // --all-revisions shows the per-snapshot truth (canonical marked *).
        const models = allRevisions ? reg.list(lsFilter) : reg.listCanonical(lsFilter);
        if (models.length === 0) {
          console.log("no models match (try `mlx-bun scan`)");
          break;
        }
        const { visionCapable } = await import("@mlx-bun/hub/registry");
        const { supportTier } = await import("@mlx-bun/inference/models/support");
        const canonicalPaths = new Set(reg.listCanonical(lsFilter).map((m) => m.path));
        const capabilities = (m: (typeof models)[number]) => {
          const tier = supportTier(m.modelType, m.repoId);
          return [
            tier ? `supported (${tier})` : `unsupported (${m.modelType})`,
            visionCapable(m) ? "vision" : null,
            m.hasToolTemplate ? "tools" : null,
            m.hasKvConfig ? "kv-quant" : null,
          ].filter(Boolean).join(" · ");
        };
        const { table, style, h1 } = await import("./terminal");
        h1("library");
        console.log();
        table(
          [
            { header: "model", paint: (c) => style.bold(c) },
            ...(allRevisions ? [{ header: "revision" }] : []),
            { header: "size", align: "right" as const },
            { header: "params", align: "right" as const },
            { header: "quant" },
            { header: "license", paint: (c: string) => style.dim(c) },
            { header: "capabilities", paint: (c: string) => style.dim(c) },
          ],
          models.map((m) => [
            m.repoId,
            ...(allRevisions
              ? [`${(m.path.split("/snapshots/")[1] ?? "").slice(0, 12)}${canonicalPaths.has(m.path) ? " *" : ""}`]
              : []),
            gb(m.sizeBytes),
            m.paramCount ? `${(m.paramCount / 1e9).toFixed(1)}B` : "?",
            m.quantBits ? `${m.quantBits}-bit g${m.quantGroupSize}` : "full",
            m.license ?? "?",
            capabilities(m),
          ]),
        );
        console.log();
        if (allRevisions) {
          console.log(style.dim(
            `  ${models.length} snapshot(s) · * = canonical (refs/main) · superseded snapshots: \`mlx-bun gc\``,
          ));
        } else {
          console.log(style.dim(`  ${models.length} model(s) · mlx-bun fit <query> for a memory assessment`));
        }
        break;
      }

      case "gc": {
        const { planGc, executeGc, DEFAULT_HUB } = await import("@mlx-bun/hub/registry");
        const { table, style, h1 } = await import("./terminal");
        const force = flag("force");
        const plans = planGc(DEFAULT_HUB, { force }).filter(
          (p) => p.pruneSnapshots.length || p.skippedSnapshots.length || p.deadBlobs.length,
        );
        h1("gc — superseded snapshots + dead blobs");
        console.log();
        if (plans.length === 0) {
          console.log("  nothing to reclaim — every snapshot is referenced by refs/*");
          break;
        }
        table(
          [
            { header: "repo", paint: (c) => style.bold(c) },
            { header: "keep", align: "right" },
            { header: "prune", align: "right" },
            { header: "skip", align: "right" },
            { header: "reclaims", align: "right" },
          ],
          plans.map((p) => [
            p.repoId,
            String(p.keepSnapshots.length),
            String(p.pruneSnapshots.length),
            String(p.skippedSnapshots.length),
            gb(p.reclaimBytes),
          ]),
        );
        console.log();
        for (const p of plans) {
          for (const s of p.skippedSnapshots) {
            const rev = (s.path.split("/snapshots/")[1] ?? s.path).slice(0, 12);
            console.log(style.accent(
              `  WARNING ${p.repoId}@${rev}: superseded snapshot has files the canonical revision lacks — skipped.`,
            ));
            console.log(style.dim(`    only copy of: ${s.extraFiles.join(", ")}`));
            console.log(style.dim("    deleting it loses those files — rerun with --force if that's intended."));
          }
        }
        const totalReclaim = plans.reduce((a, p) => a + p.reclaimBytes, 0);
        const totalSnaps = plans.reduce((a, p) => a + p.pruneSnapshots.length, 0);
        const totalBlobs = plans.reduce((a, p) => a + p.deadBlobs.length, 0);
        console.log(
          `  total: ${totalSnaps} snapshot(s), ${totalBlobs} blob(s), ${style.bold(gb(totalReclaim))}`,
        );
        if (flag("dry-run") || !flag("yes")) {
          console.log(style.dim("  nothing deleted — rerun with --yes to delete (destructive)."));
          break;
        }
        const res = executeGc(plans);
        console.log(
          `  deleted ${res.snapshots} snapshot(s) + ${res.blobs} blob(s) — reclaimed ${style.bold(gb(res.reclaimedBytes))}`,
        );

        await reg.scan(); // reap deleted snapshots from the registry
        break;
      }

      case "fit": {
        const query = positional(0);
        if (!query) throw new Error("usage: mlx-bun fit <query> [--ctx N] [--kv-quant 4|8|config] [--skus]");

        if (reg.list().length === 0) await reg.scan();
        const m = reg.resolve(query);
        const config = await loadModelConfig(m.path);
        const { box, table, style, h1, gradient } = await import("./terminal");
        const glm = isGlm52Config(config);
        const ctx = Number(opt("ctx", glm ? "4096" : "8192"));
        if (glm) {
          const machine = thisMachine();
          let plan;
          try {
            plan = await planGlm52MemoryForArtifact(m.path, {
              machineBytes: machine.ramBytes,
              processLimitBytes: Math.min(
                GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES,
                machine.ramBytes,
              ),
              contextTokens: ctx,
              maxGenerationTokens: Math.min(
                ctx,
                GLM52_G5_DEFAULT_MAX_GENERATION_TOKENS,
              ),
              batchSize: 1,
              enableMtp: true,
            });
          } catch (error) {
            console.error(
              `GLM-5.2 resource plan refused: ` +
              `${error instanceof Error ? error.message : String(error)}`,
            );
            process.exitCode = 1;
            break;
          }
          const gib = (bytes: number): string => `${(bytes / 2 ** 30).toFixed(2)} GiB`;
          const li = plan.lineItems;
          const kvBytes = li.targetKvBytes + li.mtpKvBytes;
          const otherBytes = plan.plannedProcessBytes - li.residentWeightsBytes -
            li.mainExpertSlabBytes - li.mtpExpertSlabBytes - kvBytes;
          h1("will it fit?");
          console.log(`  ${style.bold(m.repoId)} ${style.dim(`@ ${ctx.toLocaleString()} context · streamed GLM plan`)}`);
          console.log();
          box([
            `artifact on disk  ${gib(m.sizeBytes).padStart(10)} ${style.dim("(streamed, not resident)")}`,
            `resident weights  ${gib(li.residentWeightsBytes).padStart(10)}`,
            `main expert slab  ${gib(li.mainExpertSlabBytes).padStart(10)}`,
            `MTP expert slab   ${gib(li.mtpExpertSlabBytes).padStart(10)}`,
            `target + MTP KV   ${gib(kvBytes).padStart(10)}`,
            `runtime reserves  ${gib(otherBytes).padStart(10)}`,
            `process plan      ${gib(plan.plannedProcessBytes).padStart(10)} ${style.dim(`of ${gib(plan.processLimitBytes)}`)}  ${style.green(style.bold("FITS"))}`,
            `macOS headroom    ${gib(plan.machineHeadroomBytes).padStart(10)}`,
            "",
            `max safe context  ${style.bold(plan.contextTokens.toLocaleString())} tokens`,
            `max generation    ${style.bold(plan.maxGenerationTokens.toLocaleString())} tokens`,
          ]);
          if (flag("skus")) {
            console.log(style.dim(
              "  GLM-5.2's direct-container preset is validated on the M1 Max 32 GB; " +
              "the generic resident-weight SKU projection does not apply.",
            ));
          }
          console.log();
          break;
        }
        // --kv-quant mirrors serve: bill the quantized cache's true bytes so
        // the reported window matches what serving with the same flag admits.
        const kvQuantOpt = opt("kv-quant");
        let fitKvScheme: FitKvScheme | undefined;
        if (kvQuantOpt === "4" || kvQuantOpt === "8") {
          fitKvScheme = resolveKvScheme({ override: Number(kvQuantOpt) }).fitOptions;
        } else if (kvQuantOpt === "config") {
          if (!config.kvQuant?.length) {
            throw new Error(`${m.repoId} ships no per-layer kv-quant config — use --kv-quant 4|8`);
          }
          fitKvScheme = resolveKvScheme({
            override: "config",
            config: config.kvQuant,
            missingConfig: "error",
          }).fitOptions;
        } else if (kvQuantOpt != null && kvQuantOpt !== "off") {
          throw new Error(`--kv-quant ${kvQuantOpt}: expected 4, 8, config, or off`);
        }
        const r = fit(config, m.sizeBytes, ctx, thisMachine(), undefined, m.expertsBytes, undefined, fitKvScheme);
        h1("will it fit?");
        const kvNote = fitKvScheme
          ? style.dim(` · kv-quant ${fitKvScheme.kvBits ? `${fitKvScheme.kvBits}-bit` : "config"}`)
          : "";
        console.log(`  ${style.bold(m.repoId)} ${style.dim(`@ ${ctx.toLocaleString()} context · this machine`)}${kvNote}`);
        console.log();
        const expertsNote = config.text.enableMoeBlock && m.expertsBytes > 0
          ? style.dim(`  (experts ${gb(m.expertsBytes)}; top ${config.text.topKExperts}/${config.text.numExperts} read per token)`)
          : "";
        box([
          `weights    ${gb(r.weightsBytes).padStart(9)}${expertsNote}`,
          ...(m.sidecarBytes > 0
            ? [style.dim(`  + vision sidecar ${gb(m.sidecarBytes)} (bf16, loads only for vision)`)] : []),
          `kv cache   ${gb(r.kvBytes).padStart(9)}`,
          `transient  ${gb(r.transientBytes).padStart(9)}`,
          `total      ${gb(r.totalBytes).padStart(9)} ${style.dim(`of ${gb(r.usableBytes)} usable`)}  ${r.fits ? style.green(style.bold("FITS")) : style.bold("DOES NOT FIT")}`,
          "",
          `max safe context   ${style.bold(r.maxSafeContext.toLocaleString())} tokens`,
          `predicted decode   ${gradient(`${r.predictedDecodeTps.toFixed(1)} tok/s`)}`,
        ]);
        if (flag("skus")) {
          h1("apple silicon matrix");
          console.log();
          table(
            [
              { header: "chip" }, { header: "ram", align: "right" },
              { header: "fits", paint: (c) => (c.includes("fits") ? style.green(c) : style.dim(c)) },
              { header: "max context", align: "right" }, { header: "decode", align: "right" },
            ],
            skuMatrix(config, m.sizeBytes, ctx, m.expertsBytes, fitKvScheme).map((row) => [
              row.sku, `${row.ramGB} GB`, row.fits ? "fits" : "—",
              row.fits ? row.maxContext.toLocaleString() : "—",
              row.fits ? `~${row.decodeTps.toFixed(0)} tok/s` : "—",
            ]),
          );
        }
        console.log();
        break;
      }

    }
  } finally { reg.close(); }
}
