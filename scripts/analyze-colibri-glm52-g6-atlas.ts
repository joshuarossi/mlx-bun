#!/usr/bin/env bun

import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import {
  buildGlm52Atlas,
  buildGlm52AtlasRun,
  glm52AtlasRunId,
  glm52AtlasWebExperts,
  validateGlm52Atlas,
  validateGlm52AtlasProbeSet,
  type Glm52AtlasRun,
} from "../src/model/glm52-atlas";
import type { Glm52RouteTraceRecord } from "../src/model/glm52-coupling";
import { renderGlm52AtlasHtml } from "./lib/glm52-atlas-html";

function argumentsMap(argv: string[]): Map<string, string> {
  const values = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: analyze-colibri-glm52-g6-atlas.ts --traces DIR " +
        "--output-dir DIR [--probes FILE --min-count N --min-runs N " +
        "--top-k N --strong-threshold 0..1]",
      );
    }
    values.set(key.slice(2), value);
  }
  return values;
}

function required(values: Map<string, string>, key: string): string {
  const value = values.get(key);
  if (!value) throw new Error(`missing --${key}`);
  return resolve(value);
}

function positive(values: Map<string, string>, key: string, fallback: number): number {
  const value = Number(values.get(key) ?? fallback);
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new Error(`--${key} must be a positive integer`);
  return value;
}

function parseTrace(path: string): Glm52RouteTraceRecord[] {
  const text = readFileSync(path, "utf8");
  const records: Glm52RouteTraceRecord[] = [];
  for (const [index, raw] of text.split("\n").entries()) {
    const line = raw.trim();
    if (!line) continue;
    try {
      records.push(JSON.parse(line) as Glm52RouteTraceRecord);
    } catch (error) {
      const detail = error instanceof Error ? error.message : String(error);
      throw new Error(`${path}:${index + 1}: ${detail}`);
    }
  }
  return records;
}

const cli = argumentsMap(Bun.argv.slice(2));
const tracesDir = required(cli, "traces");
const outputDir = required(cli, "output-dir");
const probesPath = resolve(
  cli.get("probes") ??
    "fixtures/colibri-glm52/atlas-probes.json",
);
const minCount = positive(cli, "min-count", 30);
const minRuns = positive(cli, "min-runs", 2);
const topK = positive(cli, "top-k", 200);
const strongThreshold = Number(cli.get("strong-threshold") ?? "0.5");
if (!Number.isFinite(strongThreshold) || strongThreshold < 0 ||
    strongThreshold > 1) {
  throw new Error("--strong-threshold must be in [0, 1]");
}

const probes = validateGlm52AtlasProbeSet(
  JSON.parse(readFileSync(probesPath, "utf8")),
);
const runs: Glm52AtlasRun[] = [];
for (const category of Object.keys(probes.categories).sort()) {
  const prompts = probes.categories[category]!;
  for (let promptIndex = 0; promptIndex < prompts.length; promptIndex++) {
    const id = glm52AtlasRunId(category, promptIndex);
    const path = join(tracesDir, `${category}_${promptIndex}.jsonl`);
    if (!existsSync(path)) throw new Error(`missing GLM Atlas trace ${path}`);
    const records = parseTrace(path);
    if (records.some((record) => record.segment !== id))
      throw new Error(`${path}: expected only segment ${id}`);
    runs.push(buildGlm52AtlasRun(category, promptIndex, records));
  }
}

const analysis = buildGlm52Atlas(probes, runs, {
  minCount,
  minRuns,
  strongThreshold,
});
const validation = validateGlm52Atlas(probes, runs, topK);
const manifestPath = join(dirname(tracesDir), "manifest.json");
const manifest = existsSync(manifestPath)
  ? JSON.parse(readFileSync(manifestPath, "utf8")) as Record<string, unknown>
  : {};
const generatedAt = new Date().toISOString();
const model = typeof manifest.model === "string"
  ? manifest.model
  : "unrecorded";
const provenance = {
  model,
  probesPath,
  probeSource: probes.provenance.source,
  probeSourceCommit: probes.provenance.sourceCommit,
  tracesDir,
  generatedAt,
};
const atlas = {
  ...analysis,
  kind: "glm52-expert-atlas" as const,
  provenance,
  validation,
};
const web = {
  schemaVersion: 1 as const,
  kind: "glm52-expert-atlas-web" as const,
  categories: analysis.categories,
  summary: analysis.summary,
  validation: {
    topK: validation.topK,
    hits: validation.hits,
    trials: validation.trials,
    accuracy: validation.accuracy,
    chance: validation.chance,
    protocol: validation.protocol,
  },
  provenance,
  experts: glm52AtlasWebExperts(analysis),
};
const html = renderGlm52AtlasHtml({
  title: "GLM-5.2 Expert Atlas",
  analysis,
  validation,
  provenance: {
    model,
    probeSource: probes.provenance.source,
    probeSourceCommit: probes.provenance.sourceCommit,
    generatedAt,
  },
});

mkdirSync(outputDir, { recursive: true });
await Promise.all([
  Bun.write(join(outputDir, "atlas.json"), `${JSON.stringify(atlas, null, 2)}\n`),
  Bun.write(join(outputDir, "experts.json"), `${JSON.stringify(web)}\n`),
  Bun.write(join(outputDir, "atlas.html"), html),
]);
console.log(
  `Atlas: ${analysis.summary.expertsKept.toLocaleString()} replicated experts, ` +
  `${analysis.summary.strongSpecialists.toLocaleString()} strong; ` +
  `held-out ${validation.hits}/${validation.trials} ` +
  `(${(validation.accuracy * 100).toFixed(1)}%, chance ` +
  `${(validation.chance * 100).toFixed(1)}%)`,
);
console.log(`wrote ${outputDir}/{atlas.json,experts.json,atlas.html}`);
