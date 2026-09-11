// Model-free replay fixture for the §7.10 offline HTML report
// (scripts/bench/report.ts): schema validation, unit definitions, pairing,
// failure handling and renderer escaping. No weights, server, GPU, Python or
// network.
//
// Fixture provenance (fixtures/bench-report/, both trimmed with
// trimRawForFixture — rules recorded inside each file under `fixture`):
//   serve-schema4-a.json  <- reports/benchmarks-serve-2026-09-08-Joshs-MacBook-Pro.md.json
//                            (Apple M1 Max 32 GB, commit 1ac8f61, Bun 1.4.0);
//                            kept model cpm5 × arms mlx-bun, mlx-lm; 38 requests.
//   serve-schema4-b.json  <- reports/trellis-kv4-mtp-m1-block-0.md.json
//                            (same machine/commit); kept the local packed-trellis
//                            Qwen3.8-27B artifact × mlx-bun-serial with
//                            --draft-model/--kv-quant flags; 19 requests.
// sourceSnapshotStart.files dropped (sha256 + fileCount kept); prompt/response
// text cut to 48 chars; outputEventTimesMs cut to 3 entries. Failure and
// escaping cases below are injected in memory, never written to the fixtures.

import { describe, expect, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { median } from "../../scripts/bench-serve";
import type { NativeBenchSample } from "../../scripts/bench/native";
import {
  buildReportModel, defaultBaseline, escapeHtml, jsonForScript, loadRawReport, machineKey, nativeIdentity, nativeRows,
  pairedLogRatioInterval, pairRows, parseReportArgs, renderHtml, serveRows, trimRawForFixture, validateNativeRaw, validateServeRaw,
  METRIC_KEYS, type LoadedReport, type NativeRawReport, type ServeRawReport,
} from "../../scripts/bench/report";

const ROOT = new URL("../..", import.meta.url).pathname;
const FIXTURE_A = join(ROOT, "fixtures/bench-report/serve-schema4-a.json");
const FIXTURE_B = join(ROOT, "fixtures/bench-report/serve-schema4-b.json");
const REPORT_SCRIPT = join(ROOT, "scripts/bench/report.ts");

const loadA = () => loadRawReport(FIXTURE_A) as Extract<LoadedReport, { kind: "serve" }>;
const loadB = () => loadRawReport(FIXTURE_B) as Extract<LoadedReport, { kind: "serve" }>;
const cloneA = (): ServeRawReport => structuredClone(loadA().report);
// Explicit synthetic identity control. The recorded MiniCPM decode outputs
// differ, and must never become speedup evidence merely by trimming text.
function matchedA(): ServeRawReport {
  const raw = cloneA();
  for (const q of raw.requests.filter(q => q.cell.arm === "mlx-bun" && q.result)) {
    const ref = raw.requests.find(r => r.cell.arm === "mlx-lm" && r.requestSha256 === q.requestSha256 && r.result);
    if (ref?.result) Object.assign(q.result!, {
      text: ref.result.text, textSha256: ref.result.textSha256,
      genTokens: ref.result.genTokens, promptTokens: ref.result.promptTokens, finishReason: ref.result.finishReason,
    });
  }
  return raw;
}
const asLoaded = (report: ServeRawReport, path = "in-memory-a.json"): Extract<LoadedReport, { kind: "serve" }> =>
  ({ kind: "serve", path, sha256: "0".repeat(64), bytes: 0, report });
const row = (rows: ReturnType<typeof serveRows>, arm: string) => rows.find((r) => r.arm === arm)!;

function nativeReport(stack: "mlx-bun" | "mlx-lm", samples: NativeBenchSample[], extra: Partial<NativeRawReport> = {}): NativeRawReport {
  return validateNativeRaw({
    schemaVersion: 1, kind: "native-inference-diagnostic", canonical: false, httpMeasurement: false,
    stack, artifact: "/models/Qwen3.8-27B-rtn4", host: "test-host", chip: "Apple M4 Pro", ramBytes: 24 * 2 ** 30,
    configSha256: "c".repeat(64), promptSha256: "p".repeat(64), variant: "13", samples, complete: true, ...extra,
  }, `synthetic-${stack}`);
}
const sample = (tokens: number[], wallMs: number, extra: Partial<NativeBenchSample> = {}): NativeBenchSample =>
  ({ wallMs, firstTokenMs: wallMs / 4, tokens, finishReason: tokens.length < 64 ? "stop" : "length", peakBytes: 1e9, ...extra });

describe("schema validation", () => {
  test("both fixtures load as serve schema 4 with file provenance", () => {
    for (const path of [FIXTURE_A, FIXTURE_B]) {
      const loaded = loadRawReport(path);
      expect(loaded.kind).toBe("serve");
      expect(loaded.sha256).toHaveLength(64);
      expect(loaded.bytes).toBe(statSync(path).size);
      if (loaded.kind === "serve") {
        expect(loaded.report.schemaVersion).toBe(4);
        expect(loaded.report.fixture?.trimmedFrom).toMatch(/\.md\.json$/);
        expect(loaded.report.sourceSnapshotStart.sha256).toHaveLength(64);
      }
    }
    expect(loadA().report.models.map((m) => m.id)).toEqual(["cpm5"]);
    expect(loadB().report.models[0]!.packedTrellis).toBe(true);
    expect(Object.keys(loadB().report.runtimeEnvironment).length).toBeGreaterThan(0);
  });

  test("wrong schema, missing arrays and unknown kinds throw with the path", () => {
    const a = cloneA();
    expect(() => validateServeRaw({ ...a, schemaVersion: 3 }, "x/three.json")).toThrow(/x\/three\.json.*schemaVersion must be 4/);
    const { results: _drop, ...noResults } = a;
    expect(() => validateServeRaw(noResults, "x/no-results.json")).toThrow(/x\/no-results\.json.*results must be an array/);
    expect(() => validateServeRaw({ ...a, requests: {} }, "x/bad-requests.json")).toThrow(/x\/bad-requests\.json.*requests must be an array/);
    expect(() => validateNativeRaw({ schemaVersion: 1, kind: "something-else" }, "x/native.json")).toThrow(/x\/native\.json.*native-inference-diagnostic/);
    const dir = mkdtempSync(join(tmpdir(), "bench-report-"));
    try {
      const bad = join(dir, "unknown.json");
      Bun.write(bad, JSON.stringify({ schemaVersion: 4 }));
      Bun.spawnSync(["sync"]);
      expect(() => loadRawReport(bad)).toThrow(new RegExp(`${bad.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}.*unrecognized input`));
      const notJson = join(dir, "not.json");
      Bun.write(notJson, "{");
      expect(() => loadRawReport(notJson)).toThrow(/not valid JSON/);
    } finally { rmSync(dir, { recursive: true, force: true }); }
  });

  test("native validator accepts the shape native.ts writes", () => {
    const r = nativeReport("mlx-bun", [sample([1, 2, 3], 100)]);
    expect(r.stack).toBe("mlx-bun");
    expect(() => validateNativeRaw({ ...r, samples: [{ wallMs: "1" }] })).toThrow(/samples\[0\]/);
    expect(() => validateNativeRaw({ ...r, stack: "optiq" })).toThrow(/stack/);
  });
});

describe("unit definitions", () => {
  const loaded = loadA();
  const rows = serveRows(loaded);
  const bun = row(rows, "mlx-bun");
  const raw = loaded.report.results.find((r) => r.cell.arm === "mlx-bun")!;
  const reqs = loaded.report.requests.filter((q) => q.cell.arm === "mlx-bun");

  test("decode is the median SSE-window tok/s, labeled as such", () => {
    expect(bun.metrics.decodeTps.value).toBe(median(raw.decodeTps!));
    expect(bun.metrics.decodeTps.unit).toBe("SSE window tok/s");
    expect(bun.metrics.decodeTps.samples).toEqual(raw.decodeTps!);
    expect(bun.metrics.decodeTps.n).toBe(5);
    expect(bun.metrics.decodeTps.status).toBe("measured");
  });

  test("ctx prefill tok/s recomputes from the raw ctx request; actual-output tok/s = genTokens*1000/wallMs", () => {
    const ctxCold = reqs.find((q) => q.phase === "ctx" && q.index === 0)!.result!;
    expect(bun.metrics.ctxPrefillTps.value).toBeCloseTo(ctxCold.promptTokens * 1000 / ctxCold.ttftMs, 6);
    expect(bun.metrics.ctxPromptTokens.value).toBe(ctxCold.promptTokens);
    const decode = reqs.filter((q) => q.phase === "decode").map((q) => q.result!.genTokens * 1000 / q.result!.wallMs);
    expect(bun.metrics.endToEndTps.value).toBeCloseTo(median(decode), 9);
    expect(bun.metrics.endToEndTps.unit).toContain("genTokens ÷ wall");
    expect(bun.metrics.endToEndTps.unit).not.toContain("SSE");
    const prefill1k = reqs.filter((q) => q.phase === "ttft1k" && q.index < 3).map((q) => q.result!.promptTokens * 1000 / q.result!.ttftMs);
    expect(bun.metrics.prefill1kTps.value).toBeCloseTo(median(prefill1k), 6);
  });

  test("RSS is process RSS from ps, never native peak", () => {
    for (const key of ["idleRssMB", "peakRssMB"] as const) {
      expect(bun.metrics[key].unit).toBe("process RSS MB (ps)");
      expect(bun.metrics[key].label.toLowerCase()).not.toContain("native");
    }
    expect(bun.metrics.peakRssMB.value).toBe(raw.peakRssMB);
  });

  test("every metric key carries a status and a note slot", () => {
    for (const key of METRIC_KEYS) {
      expect(["measured", "recovered", "failed", "not-measured", "unsupported"]).toContain(bun.metrics[key].status);
      expect(typeof bun.metrics[key].note).toBe("string");
    }
  });

  test("machine key parses chip + RAM from the schema-4 machine string; host not recorded", () => {
    expect(machineKey(loaded.report)).toEqual({ chip: "Apple M1 Max", ramGiB: 32, host: "not recorded", key: "Apple M1 Max · 32 GB · host not recorded" });
    const native = nativeReport("mlx-bun", []);
    expect(machineKey(native).key).toBe("Apple M4 Pro · 24 GB · host test-host");
  });
});

describe("paired block uncertainty", () => {
  test("uses independent blocks, with no interval below five or for invalid ratios", () => {
    expect(pairedLogRatioInterval([1.2, 1.2, 1.2, 1.2])).toBeNull();
    expect(pairedLogRatioInterval([1, 1, 0, 1, 1])).toBeNull();
    const constant = pairedLogRatioInterval([1.2, 1.2, 1.2, 1.2, 1.2])!;
    expect(constant.factor).toBeCloseTo(1.2, 12);
    expect(constant.low).toBeCloseTo(1.2, 12);
    expect(constant.high).toBeCloseTo(1.2, 12);
    const mixed = pairedLogRatioInterval([0.8, 0.9, 1, 1, 1 / 0.9, 1 / 0.8])!;
    expect(mixed.factor).toBeCloseTo(1, 12);
    expect(mixed.low).toBeLessThan(1);
    expect(mixed.high).toBeGreaterThan(1);
    expect(pairedLogRatioInterval([0.8, 0.9, 1, 1, 1 / 0.9, 1 / 0.8])).toEqual(mixed);
  });

  test("groups fixed-source seeds and counts duplicate inputs only once", () => {
    const inputs = Array.from({ length: 6 }, (_, i) => {
      const raw = matchedA(); raw.host = "test-host"; raw.workload.seed = `block-${i}`;
      return asLoaded(raw, `block-${i}.json`);
    });
    const model = buildReportModel([...inputs, inputs[0]!], { baseline: "mlx-lm" });
    const group = model.blockSummaries.find(g => g.metric === "decodeWallMs")!;
    expect(group.blocks).toHaveLength(6);
    expect(group.interval?.n).toBe(6);
    expect(renderHtml(model)).toContain("Paired block uncertainty");
    inputs[5]!.report.sourceSnapshotStart.sha256 = "different-source";
    inputs[5]!.report.sourceSnapshotAtSaveSha256 = "different-source";
    const split = buildReportModel(inputs, { baseline: "mlx-lm" }).blockSummaries
      .filter(g => g.metric === "decodeWallMs");
    expect(split.map(g => g.blocks.length).sort()).toEqual([1, 5]);
  });
});

describe("pairing", () => {
  test("an explicit environment value compares variants of the same server arm", () => {
    const a = matchedA(), b = matchedA();
    a.host = b.host = "test-host";
    a.runtimeEnvironment = { MLX_BUN_TRELLIS_VARIANT: "6" };
    b.runtimeEnvironment = { MLX_BUN_TRELLIS_VARIANT: "13" };
    const inputs = [asLoaded(a, "v6.json"), asLoaded(b, "v13.json")];
    const model = buildReportModel(inputs, { baseline: "mlx-bun", baselineEnv: {
      key: "MLX_BUN_TRELLIS_VARIANT", value: "6",
    } });
    const pairs = model.pairsByBaseline["mlx-bun"]!;
    const candidate = pairs.find(p => p.row.source === "v13.json" && p.row.arm === "mlx-bun")!;
    expect(candidate.status).toBe("paired");
    expect(candidate.baseline?.source).toBe("v6.json");
    expect(candidate.ratios.decodeTps.ratio).toBe(1);
    expect(renderHtml(model)).toContain("baseline setting: MLX_BUN_TRELLIS_VARIANT=6");
    expect(renderHtml(model)).toContain("MLX_BUN_TRELLIS_VARIANT=13");
    const machineTable = renderHtml(model).split('class="machines"')[1]!.split("</table>")[0]!;
    expect(machineTable).toContain("MLX_BUN_TRELLIS_VARIANT=6");
    expect(machineTable).toContain("MLX_BUN_TRELLIS_VARIANT=13");
    expect(pairRows(serveRows(inputs[1]!), "mlx-bun", { key: "MLX_BUN_TRELLIS_VARIANT", value: "6" })
      .find(p => p.row.arm === "mlx-bun")!.baseline).toBeNull();
    expect(parseReportArgs(["a.json", "--out", "a.html", "--baseline-env", "MLX_BUN_TRELLIS_VARIANT=6"]).baselineEnv)
      .toEqual({ key: "MLX_BUN_TRELLIS_VARIANT", value: "6" });
    expect(() => parseReportArgs(["a.json", "--out", "a.html", "--baseline-env", "6"]))
      .toThrow("KEY=VALUE");
  });

  test("matched outputs pair with n and both sample arrays; ms metrics invert", () => {
    const rows = serveRows(asLoaded(matchedA()));
    const pairs = pairRows(rows, "mlx-lm");
    const p = pairs.find((x) => x.row.arm === "mlx-bun")!;
    expect(p.status).toBe("paired");
    expect(p.baseline!.arm).toBe("mlx-lm");
    const d = p.ratios.decodeTps;
    expect(d.ratio).toBeCloseTo(row(rows, "mlx-bun").metrics.decodeTps.value! / row(rows, "mlx-lm").metrics.decodeTps.value!, 9);
    expect(d.n).toBe(5);
    expect(d.samplesA).toHaveLength(5);
    expect(d.samplesB).toHaveLength(5);
    const cold = p.ratios.ttftColdMs;
    expect(cold.ratio).toBeCloseTo(row(rows, "mlx-lm").metrics.ttftColdMs.value! / row(rows, "mlx-bun").metrics.ttftColdMs.value!, 9);
    expect(pairs.find((x) => x.row.arm === "mlx-lm")!.status).toBe("self");
    expect(defaultBaseline(rows)).toBe("mlx-lm");
  });

  test("recorded output differences retain timings but suppress speed ratios", () => {
    const p = pairRows(serveRows(loadA()), "mlx-lm").find(p => p.row.arm === "mlx-bun")!;
    expect(p.row.metrics.decodeTps.value).toBeGreaterThan(0);
    expect(p.ratios.decodeTps.ratio).toBeNull();
    expect(p.ratios.decodeTps.note).toContain("output or usage mismatch");
    expect(p.ratios.ttftColdMs.ratio).not.toBeNull();
  });

  test("same chip with unknown hosts or same config at different paths cannot join files", () => {
    const a = matchedA(), b = matchedA();
    a.commands = a.commands.filter(c => c.arm === "mlx-bun");
    b.commands = b.commands.filter(c => c.arm === "mlx-lm");
    const compare = () => pairRows([...serveRows(asLoaded(a, "a.json")), ...serveRows(asLoaded(b, "b.json"))], "mlx-lm")[0]!;
    expect(compare().baseline).toBeNull();
    a.host = b.host = "same-known-host";
    expect(compare().baseline).not.toBeNull();
    a.models[0]!.configSha256 = b.models[0]!.configSha256 = "same-config";
    b.models[0]!.path = "/different-weights";
    expect(compare().baseline).toBeNull();
  });

  test("retry request hashes and unrecorded full outputs cannot earn ratios", () => {
    const raw = matchedA();
    const q = raw.requests.find(q => q.cell.arm === "mlx-bun" && q.phase === "decode")!;
    q.requestSha256 = "different-retry";
    let p = pairRows(serveRows(asLoaded(raw)), "mlx-lm")[0]!;
    expect(p.ratios.decodeTps.ratio).toBeNull();
    expect(p.ratios.decodeTps.note).toContain("request/attempt mismatch");
    const truncated = matchedA();
    delete truncated.requests.find(q => q.cell.arm === "mlx-bun" && q.phase === "decode")!.result!.textSha256;
    p = pairRows(serveRows(asLoaded(truncated)), "mlx-lm")[0]!;
    expect(p.ratios.decodeTps.note).toContain("full output identity not recorded");
  });

  test("different prefix reuse cannot earn a same-work speed ratio", () => {
    const raw = matchedA();
    raw.requests.find(q => q.cell.arm === "mlx-bun" && q.phase === "decode")!.result!.cachedTokens += 1;
    const p = pairRows(serveRows(asLoaded(raw)), "mlx-lm")[0]!;
    expect(p.ratios.decodeTps.ratio).toBeNull();
    expect(p.ratios.decodeTps.note).toContain("cache reuse mismatch");
  });

  test("packed-trellis serial row vs mlx-lm is unsupported with the loader reason", () => {
    const rows = serveRows(loadB());
    const p = pairRows(rows, "mlx-lm")[0]!;
    expect(p.status).toBe("unsupported");
    expect(p.note).toContain("packed trellis has no stock mlx-lm/optiq loader");
    expect(p.ratios.decodeTps.status).toBe("unsupported");
    expect(p.ratios.decodeTps.ratio).toBeNull();
    expect(rows[0]!.configured).toEqual(expect.arrayContaining([expect.stringContaining("--draft-model"), "--kv-quant 4"]));
    expect(rows[0]!.flags.join("\n")).toContain("configured experiment");
    expect(rows[0]!.warnings.join("\n")).toContain("MLX_BUN_TRELLIS_VARIANT=13");
    expect(defaultBaseline(rows)).toBe("mlx-bun-serial");
  });

  test("a different chip prevents pairing; different workload too", () => {
    const a = cloneA();
    const b = cloneA();
    b.machine = b.machine.replace("Apple M1 Max", "Apple M4 Pro").replace("32 GB", "24 GB");
    b.commands = b.commands.filter((c) => c.arm === "mlx-lm");
    b.results = b.results.filter((r) => r.cell.arm === "mlx-lm");
    const aRows = serveRows(asLoaded({ ...a, commands: a.commands.filter((c) => c.arm === "mlx-bun"), results: a.results.filter((r) => r.cell.arm === "mlx-bun") }, "a.json"));
    const bRows = serveRows(asLoaded(b, "b.json"));
    const p = pairRows([...aRows, ...bRows], "mlx-lm").find((x) => x.row.arm === "mlx-bun")!;
    expect(p.status).toBe("no compatible baseline");
    expect(p.note).toContain("same machine and workload");
    const c = cloneA();
    c.workload = { ...c.workload, seed: "other-seed" };
    const cRows = serveRows(asLoaded({ ...c, commands: c.commands.filter((x) => x.arm === "mlx-lm"), results: c.results.filter((r) => r.cell.arm === "mlx-lm") }, "c.json"));
    expect(pairRows([...aRows, ...cRows], "mlx-lm").find((x) => x.row.arm === "mlx-bun")!.status).toBe("no compatible baseline");
    c.workload = { ...a.workload, allowedCpuProcess: "/usr/libexec/audiomxd" };
    const allowedRows = serveRows(asLoaded({ ...c, commands: c.commands.filter((x) => x.arm === "mlx-lm"), results: c.results.filter((r) => r.cell.arm === "mlx-lm") }, "allowed.json"));
    expect(pairRows([...aRows, ...allowedRows], "mlx-lm").find((x) => x.row.arm === "mlx-bun")!.status).toBe("no compatible baseline");
  });

  test("diagnostic rows never serve as baseline and are flagged", () => {
    const a = cloneA();
    a.diagnostic = true;
    const rows = serveRows(asLoaded(a));
    expect(row(rows, "mlx-lm").flags.join("\n")).toContain("DIAGNOSTIC");
    expect(defaultBaseline(rows)).toBeNull();
    const p = pairRows(rows, "mlx-lm").find((x) => x.row.arm === "mlx-bun")!;
    expect(p.status).toBe("no compatible baseline");
  });

  test("commands with command=null become explicit unsupported rows", () => {
    const a = cloneA();
    a.models[0]!.packedTrellis = true;
    a.commands.push({ model: "cpm5", arm: "optiq-mixed", command: null });
    const r = row(serveRows(asLoaded(a)), "optiq-mixed");
    expect(r.status).toBe("unsupported");
    expect(r.note).toContain("packed trellis");
    expect(METRIC_KEYS.every((k) => r.metrics[k].status === "unsupported" && r.metrics[k].value === null)).toBe(true);
  });
});

describe("failure handling", () => {
  test("recovered phase keeps its value with status recovered", () => {
    const a = matchedA();
    const res = a.results.find((r) => r.cell.arm === "mlx-bun")!;
    res.phaseFailures.push({ phase: "decode", error: "TypeError: fetch failed; recovered on retry. Compare only matching attempts and request hashes.", stderrTail: ["boom"] });
    const r = row(serveRows(asLoaded(a)), "mlx-bun");
    expect(r.metrics.decodeTps.status).toBe("recovered");
    expect(r.metrics.decodeTps.value).toBe(median(res.decodeTps!));
    expect(r.metrics.decodeTps.note).toContain("recovered on retry");
    expect(r.status).toBe("measured");
    const p = pairRows(serveRows(asLoaded(a)), "mlx-lm").find((x) => x.row.arm === "mlx-bun")!;
    expect(p.ratios.decodeTps.status).toBe("recovered");
    expect(p.ratios.decodeTps.ratio).not.toBeNull();
  });

  test("partial failed attempts do not enter final request-time medians", () => {
    const a = matchedA();
    const original = serveRows(asLoaded(a))[0]!.metrics.decodeWallMs;
    const partial = structuredClone(a.requests.find(q => q.cell.arm === "mlx-bun" && q.phase === "decode")!);
    partial.result!.wallMs = 1e9;
    for (const q of a.requests.filter(q => q.cell.arm === "mlx-bun" && q.phase === "decode")) q.attempt++;
    a.requests.unshift(partial);
    const value = serveRows(asLoaded(a))[0]!.metrics.decodeWallMs;
    expect(value.value).toBe(original.value);
    expect(value.n).toBe(original.n);
  });

  test("hard ctx failure marks ctx/restart cells failed with the error text; other cells unchanged", () => {
    const a = cloneA();
    const res = a.results.find((r) => r.cell.arm === "mlx-bun")!;
    res.ctx = null; res.restart = null;
    res.phaseFailures.push({ phase: "ctx", error: "TimeoutError: The operation timed out — retry: TimeoutError", stderrTail: ["kernel panic (not really)"] });
    const before = row(serveRows(loadA()), "mlx-bun");
    const r = row(serveRows(asLoaded(a)), "mlx-bun");
    for (const key of ["ctxPrefillTps", "ctxTtftMs", "ctxDecodeTps", "ctxPromptTokens", "ctxRepeatTtftMs"] as const) {
      expect(r.metrics[key].status).toBe("failed");
      expect(r.metrics[key].value).toBeNull();
      expect(r.metrics[key].note).toContain("The operation timed out");
    }
    expect(r.metrics.restartCtxTtftMs.status).toBe("not-measured");
    expect(r.metrics.restartCtxTtftMs.note).toContain("requires a measured ctx leg");
    for (const key of ["decodeTps", "ttftColdMs", "aggTps", "peakRssMB", "readyMs"] as const)
      expect(r.metrics[key]).toEqual(before.metrics[key]);
    const html = renderHtml(buildReportModel([asLoaded(a)]));
    expect(html).toContain("kernel panic (not really)");
    expect(html).toContain("[phase ctx]");
    const p = pairRows(serveRows(asLoaded(a)), "mlx-lm").find((x) => x.row.arm === "mlx-bun")!;
    expect(p.ratios.ctxPrefillTps.ratio).toBeNull();
    expect(p.ratios.ctxPrefillTps.status).toBe("failed");
  });

  test("whole-cell failures with stderr tails and request errors render in the failures section", () => {
    const a = cloneA();
    a.results = a.results.filter((r) => r.cell.arm !== "mlx-lm");
    a.failures.push({ cell: "cpm5/mlx-lm", error: "server exited before ready: code=1", stderrTail: ["ModuleNotFoundError: no module named optiq"] });
    a.requests[3]!.error = "TypeError: SSE error: {\"message\":\"overloaded\"}";
    a.requests[3]!.result = undefined;
    a.requests[3]!.processAtFailure = { pid: 4242, exitCode: null, signal: null };
    const rows = serveRows(asLoaded(a));
    const lm = row(rows, "mlx-lm");
    expect(lm.status).toBe("failed");
    expect(lm.note).toContain("server exited before ready");
    expect(METRIC_KEYS.every((k) => lm.metrics[k].status === "failed" && lm.metrics[k].value === null)).toBe(true);
    const bun = row(rows, "mlx-bun");
    expect(bun.requestErrors).toHaveLength(1);
    expect(bun.flags.join("\n")).toContain("1 request errors retained");
    const html = renderHtml(buildReportModel([asLoaded(a)]));
    expect(html).toContain("ModuleNotFoundError: no module named optiq");
    expect(html).toContain("overloaded");
    expect(html).toContain("pid 4242");
  });

  test("early EOS on a decode sample is flagged beside decode tok/s", () => {
    const a = cloneA();
    const q = a.requests.find((x) => x.cell.arm === "mlx-bun" && x.phase === "decode" && x.index === 2)!;
    q.result!.genTokens = 40; q.result!.finishReason = "stop";
    const r = row(serveRows(asLoaded(a)), "mlx-bun");
    const flags = r.flags.join("\n");
    expect(flags).toContain("EARLY EOS on 1/5 decode samples");
    expect(flags).toContain("genTokens 40 < requested 192");
    expect(flags).toMatch(/finish reasons: .*stop×/);
    expect(row(serveRows(loadA()), "mlx-bun").flags.join("\n")).not.toContain("EARLY EOS");
  });

  test("--skip-context yields not-measured, never failed; incomplete native runs are flagged", () => {
    const a = cloneA();
    a.workload.withContext = false;
    for (const r of a.results) { r.ctx = null; r.restart = null; }
    const r = row(serveRows(asLoaded(a)), "mlx-bun");
    expect(r.metrics.ctxPrefillTps.status).toBe("not-measured");
    expect(r.metrics.ctxPrefillTps.note).toContain("--skip-context");
    expect(r.metrics.restartCtxTtftMs.status).toBe("not-measured");
    expect(r.status).toBe("measured");
    const n = nativeRows([{ report: nativeReport("mlx-bun", [], { complete: false, error: "Error: machine not quiet" }), path: "n.json", sha256: "1".repeat(64) }])[0]!;
    expect(n.complete).toBe(false);
    expect(n.flags.join("\n")).toContain("INCOMPLETE run: Error: machine not quiet");
    expect(n.wallMs).toBeNull();
  });
});

describe("native rows", () => {
  const tokens = Array.from({ length: 64 }, (_, i) => i * 3);
  test("same artifact + prompt across stacks: wall medians and token-ID identity", () => {
    const bun = nativeReport("mlx-bun", [sample(tokens, 900), sample(tokens, 1000), sample(tokens, 1100)]);
    const lm = nativeReport("mlx-lm", [sample(tokens, 1200), sample(tokens, 1300, { peakBytes: 3e9 })]);
    const rows = nativeRows([{ report: bun, path: "bun.json", sha256: "a".repeat(64) }, { report: lm, path: "lm.json", sha256: "b".repeat(64) }]);
    expect(rows[0]!.wallMs).toEqual({ median: 1000, min: 900, max: 1100 });
    expect(rows[1]!.wallMs!.median).toBe(1250);
    expect(rows[1]!.peakBytes).toBe(3e9);
    expect(rows[0]!.identity[0]).toMatchObject({ identical: true, comparedSamples: 2, firstDivergence: null });
    expect(rows[0]!.identity[0]!.against).toContain("mlx-lm");
    expect(rows[0]!.finishReasons).toEqual({ length: 3 });
  });
  test("differing tokens report the first divergent index", () => {
    const other = [...tokens]; other[17] = 999;
    const id = nativeIdentity([sample(tokens, 1), sample(tokens, 1)], [sample(tokens, 1), sample(other, 1)]);
    expect(id).toEqual({ identical: false, comparedSamples: 2, firstDivergence: { sample: 1, index: 17 } });
    expect(nativeIdentity([], [])).toMatchObject({ identical: false, comparedSamples: 0 });
    const lm = nativeReport("mlx-lm", [sample(other, 1)]);
    const bun = nativeReport("mlx-bun", [sample(tokens, 1)]);
    const html = renderHtml(buildReportModel([{ kind: "native", path: "bun.json", sha256: "a".repeat(64), bytes: 1, report: bun }, { kind: "native", path: "lm.json", sha256: "b".repeat(64), bytes: 1, report: lm }]));
    expect(html).toContain("DIVERGES vs mlx-lm");
    expect(html).toContain("index 17");
  });
});

describe("renderer", () => {
  test("every cell has a value or an explicit status; provenance fields present; two machines produce two columns", () => {
    const a = loadA();
    const b = loadB();
    b.report.machine = b.report.machine.replace("Apple M1 Max", "Apple M4 Pro").replace("32 GB", "24 GB");
    const model = buildReportModel([a, b], { title: "fixture render" });
    const html = renderHtml(model);
    expect(model.machines.map((m) => m.key)).toEqual(["Apple M1 Max · 32 GB · host not recorded", "Apple M4 Pro · 24 GB · host not recorded"]);
    expect((html.match(/<th class="machine-col">/g) ?? []).length).toBe(2);
    expect((html.match(/<h3 class="machine"/g) ?? []).length).toBe(2);
    // matrix cells: value or status token, never empty
    const cells = html.match(/<td class="m st-[^"]*" data-metric="[^"]*">(.*?)<\/td>/gs) ?? [];
    expect(cells.length).toBe(3 * METRIC_KEYS.length);
    for (const c of cells) expect(c).toMatch(/<b>[\d.]+<\/b>|st-(failed|not-measured|unsupported|recovered)"/);
    for (const needle of [a.sha256, b.sha256, "1ac8f61", "Bun</th><td>1.4.0", "bench-serve-v2", "pr47-block-0", "enable_thinking=true pinned",
      "MLX_BUN_TRELLIS_VARIANT", a.report.sourceSnapshotStart.sha256, "--draft-model", "packed trellis has no stock mlx-lm/optiq loader",
      "MiniCPM5-1B", "Qwen3.8-27B-q3-trellis-ldlq-k300-packed-interleave2-rd", "SSE window tok/s", "genTokens ÷ wall", "process RSS MB (ps)",
      "parity ✓", "not measured", "Quality versus size", "reference prefill", "server (stock; legacy report)"]) expect(html).toContain(needle);
    expect(html).toContain("<!doctype html>");
    expect(html.match(/<script\b/g)!.length).toBe(1);
    expect(html.match(/<style\b/g)!.length).toBe(1);
    expect(html).not.toMatch(/<script src|<link |url\(http|fetch\(|https?:\/\//);
  });

  test("saved model output and labels are escaped; payload never breaks out of <script>", () => {
    const a = cloneA();
    a.machine = "Apple M1 Max & Co · 32 GB · loadavg { 1 1 1 } · 2026-09-08T00:00:00.000Z";
    a.models[0]!.label = 'Evil" onerror=alert(1) <img src=x>';
    for (const q of a.requests) if (q.result) q.result.text = "<script>alert(1)</script>\u2028</script><script>alert(2)</script>";
    a.results[0]!.parity!.chat.text = "</script><script>alert(3)</script>";
    a.results[0]!.phaseFailures.push({ phase: "agg", error: "<b>bold</b> failure; recovered on retry.", stderrTail: ["<script>alert(4)</script>"] });
    const html = renderHtml(buildReportModel([asLoaded(a)]));
    expect(html).not.toContain("<script>alert");
    expect(html).not.toContain("</script><script>");
    expect(html).toContain("&lt;script&gt;alert(1)&lt;/script&gt;");
    expect(html).toContain("Evil&quot; onerror=alert(1) &lt;img src=x&gt;");
    expect(html).toContain("Apple M1 Max &amp; Co");
    expect(html.match(/<script\b/g)!.length).toBe(1);
    const payload = html.match(/const DATA=(.*);\n/)![1]!;
    expect(payload).not.toContain("<");
    expect(payload).not.toContain("\u2028");
    expect(() => JSON.parse(payload)).not.toThrow();
    expect(jsonForScript({ t: "</script>\u2028\u2029" })).toBe('{"t":"\\u003c/script>\\u2028\\u2029"}');
    expect(escapeHtml(`<a href="x">'&'</a>`)).toBe("&lt;a href=&quot;x&quot;&gt;&#39;&amp;&#39;&lt;/a&gt;");
  });
});

describe("fixtures", () => {
  test("trimRawForFixture is idempotent on both fixtures and the pair stays under 100 KB", () => {
    let total = 0;
    for (const [path, keep] of [[FIXTURE_A, { models: ["cpm5"], arms: ["mlx-bun", "mlx-lm"] }], [FIXTURE_B, { models: ["local"], arms: ["mlx-bun-serial"] }]] as const) {
      const text = readFileSync(path, "utf8");
      total += Buffer.byteLength(text);
      const again = JSON.stringify(trimRawForFixture(JSON.parse(text), { models: [...keep.models], arms: [...keep.arms] })) + "\n";
      expect(again).toBe(text);
      const raw = JSON.parse(text) as ServeRawReport;
      expect(raw.sourceSnapshotStart.files).toEqual([]);
      expect(raw.sourceSnapshotStart.fileCount).toBeGreaterThan(0);
      expect(raw.requests.every((q) => q.request.content.length <= 48 && (!q.result || (q.result.text.length <= 48 && q.result.outputEventTimesMs.length <= 3)))).toBe(true);
      expect(raw.results.every((r) => r.parity!.completion.text.length > 48 || r.parity!.chat.text.length > 48)).toBe(true);
    }
    expect(total).toBeLessThan(100 * 1024);
  });
});

describe("CLI", () => {
  test("argument parsing rejects unknown flags and missing --out", () => {
    expect(() => parseReportArgs(["a.json"])).toThrow(/--out/);
    expect(() => parseReportArgs(["--out", "x.html"])).toThrow(/at least one/);
    expect(() => parseReportArgs(["a.json", "--out", "x.html", "--bogus"])).toThrow(/unknown option --bogus/);
    expect(() => parseReportArgs(["a.json", "--out", "x.html", "--baseline", "python"])).toThrow(/--baseline/);
    expect(parseReportArgs(["a.json", "b.json", "--out", "x.html", "--baseline", "mlx-bun-serial", "--title", "t"]))
      .toEqual({ inputs: ["a.json", "b.json"], out: "x.html", baseline: "mlx-bun-serial", title: "t" });
  });

  test("smoke: renders both fixtures to one file; unknown flag exits non-zero", () => {
    const dir = mkdtempSync(join(tmpdir(), "bench-report-cli-"));
    try {
      const out = join(dir, "report.html");
      // A copied report remains usable on a host with no reference runtime.
      const env = { ...process.env, MLX_BUN_ORACLE_VENV: join(dir, "missing-oracle"),
        MLX_BUN_LIBMLXC: join(dir, "missing-native-library"), HF_HUB_OFFLINE: "1" };
      const ok = Bun.spawnSync([process.execPath, REPORT_SCRIPT, FIXTURE_A, FIXTURE_B, "--out", out], { cwd: ROOT, env, stdout: "pipe", stderr: "pipe" });
      expect(ok.stderr.toString()).toBe("");
      expect(ok.exitCode).toBe(0);
      expect(JSON.parse(ok.stdout.toString())).toMatchObject({ out, inputs: 2, serveRows: 3, nativeRows: 0 });
      expect(existsSync(out)).toBe(true);
      const html = readFileSync(out, "utf8");
      const a = loadA(), b = loadB();
      for (const needle of ["MiniCPM5-1B", "Qwen3.8-27B-q3-trellis-ldlq-k300-packed-interleave2-rd", "packed trellis has no stock mlx-lm/optiq loader", a.sha256, b.sha256])
        expect(html).toContain(needle);
      const bad = Bun.spawnSync([process.execPath, REPORT_SCRIPT, FIXTURE_A, "--out", out, "--nope"], { cwd: ROOT, env, stdout: "pipe", stderr: "pipe" });
      expect(bad.exitCode).not.toBe(0);
      expect(bad.stderr.toString()).toContain("unknown option --nope");
    } finally { rmSync(dir, { recursive: true, force: true }); }
  });
});
