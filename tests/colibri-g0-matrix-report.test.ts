import { afterEach, describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, unlinkSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { buildMatrixReport, renderMatrixMarkdown } from "../scripts/colibri-g0-matrix-report";

const PREFIX = "warm-final-v4";
const WARM_ANALYZER = join(import.meta.dir, "..", "scripts", "colibri-g0-warm.ts");
const temporary: string[] = [];

afterEach(() => {
  while (temporary.length) rmSync(temporary.pop()!, { recursive: true, force: true });
});

function sha256(value: Uint8Array | string): string {
  return createHash("sha256").update(value).digest("hex");
}

function writeJson(path: string, value: unknown): void {
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`);
}

function vmStat(offset: number): string {
  return [
    "Mach Virtual Memory Statistics: (page size of 16384 bytes)",
    `Pages stored in compressor: ${100 + offset}.`,
    `Pages occupied by compressor: ${50 + offset}.`,
    `Decompressions: ${1000 + offset}.`,
    `Compressions: ${2000 + offset}.`,
    `Swapins: ${3 + offset}.`,
    `Swapouts: ${4 + offset}.`,
    "",
  ].join("\n");
}

interface Fixture {
  root: string;
  run(mode: "off" | "on", repeat: number): string;
}

function makeFixture(): Fixture {
  const temp = mkdtempSync(join(tmpdir(), "mlx-bun-g0-matrix-"));
  temporary.push(temp);
  const root = join(temp, "evidence");
  const binary = join(temp, "glm");
  const model = join(temp, "snapshots", "0123456789abcdef0123456789abcdef01234567");
  mkdirSync(root, { recursive: true });
  mkdirSync(model, { recursive: true });
  writeFileSync(binary, "synthetic exact binary\n");
  const binaryBytes = readFileSync(binary);
  const prompt = Buffer.from("identical synthetic prompt");
  const response = Buffer.from("identical deterministic response");
  const stderr = Buffer.from("bounded synthetic stderr\n");
  const tokenIds = Array.from({ length: 64 }, (_, index) => index + 1);

  for (const mode of ["off", "on"] as const) {
    for (let repeat = 1; repeat <= 3; repeat++) {
      const name = `${PREFIX}-mtp-${mode}-r${repeat}`;
      const directory = join(root, name);
      mkdirSync(directory);
      writeFileSync(join(directory, "prompt.bin"), prompt);
      writeFileSync(join(directory, "stdout.bin"), "bounded synthetic stdout\n");
      writeFileSync(join(directory, "stderr.bin"), stderr);
      writeFileSync(join(directory, "turn-1.response.bin"), response);
      writeFileSync(join(directory, "turn-2.response.bin"), response);
      writeFileSync(`${directory}.stats`, "3 0 1\n");
      const env = {
        AUTOPIN: "0", CACHE_ROUTE: "0", CAP_RAISE: "0", COLI_G0_TRACE: "1", COLI_METAL: "1",
        COLI_MMAP: "0", CTX: "128", DIRECT: "1", DISK_SPLIT: "1", EXPERT_BUDGET: "0",
        KVSAVE: "0", NGEN: "64", OMP_DYNAMIC: "FALSE", OMP_NUM_THREADS: "10", PILOT: "0",
        PILOT_REAL: "0", PILOT_TWO: "0", PIPE: "1", PIPE_WORKERS: "6", PROF: "1",
        RAM_GB: "18", REPIN: "0", SEED: "1", SERVE: "1", SERVE_BATCH: "0", SPEC_PIN: "1",
        TEMP: "0",
        STATS: `${directory}.stats`, MTP: mode === "on" ? "1" : "0", TOKENS: "1", SNAP: model,
        DRAFT: mode === "on" ? "3" : "0",
      };
      writeJson(join(directory, "manifest.json"), {
        schema_version: 3,
        capture_kind: "colibri_glm52_same_process_warm_manifest",
        engine_command: [binary, "1", "4", "4"],
        launcher_command: ["/usr/bin/time", "-l", binary, "1", "4", "4"],
        engine_binary: { path: binary, bytes: binaryBytes.byteLength, sha256: sha256(binaryBytes) },
        env_overrides: env,
        inherited_environment: true,
        mtp: mode,
        prompt: { file: "prompt.bin", bytes: prompt.byteLength, sha256: sha256(prompt), source: "prompt.bin" },
        request: { max_tokens: 64, temperature: 0, top_p: 1 },
        timeout_seconds: 1800,
        protocol: "single process: READY+STAT+TIERS, PROMPT+END+STAT, RESET+END+STAT, identical PROMPT+END+STAT, EOF",
        analysis: {
          analyzer: { path: WARM_ANALYZER, sha256: sha256(readFileSync(WARM_ANALYZER)) },
          stderr: { path: "stderr.bin", sha256: sha256(stderr) },
          ttft_boundary: "synthetic",
          client_engine_tolerance_s: 0.05,
        },
      });
      const enginePid = 10_000 + (mode === "on" ? 100 : 0) + repeat;
      const turns = [1, 2].map((turn) => {
        const engineTtft = 10 + repeat / 10 + turn / 100 + (mode === "on" ? 1 : 0);
        const clientTtft = engineTtft + 0.001;
        const on = mode === "on";
        return {
          cache_state: turn === 1 ? "first-turn-in-process" : "warm-explicit-lru",
          client_ttft_s: clientTtft,
          response_bytes: response.byteLength,
          response_sha256: sha256(response),
          response_file: `turn-${turn}.response.bin`,
          stat: {
            completion_tokens: 64,
            tokens_per_second: on ? 0.3 + repeat / 100 : 0.4 + repeat / 100,
            cache_hit_percent: on ? 1.1 : 2.0,
            rss_gb: 9.4,
            prompt_tokens: 32,
            length_limited: true,
            extra: {},
          },
          engine_trace: {
            engine_prefill_to_first_s: engineTtft,
            elapsed_s: (on ? 220 : 170) + repeat + turn / 10,
            produced: 64,
            token_ids: tokenIds,
            verify_rows: on ? 30 : 63,
            mtp_raw_proposals: on ? 90 : 0,
            mtp_verified_proposals: on ? 87 : 0,
            mtp_accepted: on ? 34 : 0,
            mtp_rejected_or_discarded: on ? 56 : 0,
            mtp_rejection_events: on ? 24 : 0,
            acceptance_length_histogram: on ? { "0": 10, "1": 10, "2": 5, "3": 5 } : {},
            verify_seconds: on ? 190 : 0,
            forwards: on ? 30 : 63,
            tokens_per_forward: on ? 2.13 : 1.02,
            expert_fetched_gb: (on ? 1120 : 830) + repeat,
            expert_read_service_seconds: 700,
            expert_wait_seconds: 100,
            pinned_hits: 0,
            lru_hits: 100,
            expert_load_misses: 44_000,
            resident_pinned_experts: 0,
            resident_lru_experts: 76,
            resident_expert_gb: 1.4,
            client_minus_engine_ttft_s: clientTtft - engineTtft,
          },
        };
      });
      writeJson(join(directory, "result.json"), {
        schema_version: 3,
        capture_kind: "colibri_glm52_same_process_warm_pair",
        complete: true,
        error: null,
        timed_out: false,
        process: {
          exit_code: 0,
          signal_code: null,
          launcher_pid: enginePid - 1,
          engine_pid: enginePid,
          maximum_resident_set_bytes: 10_000_000_000 + repeat,
          process_swaps: 0,
          peak_memory_footprint_bytes: (mode === "on" ? 17_000_000_000 : 13_000_000_000) + repeat,
        },
        same_process: true,
        process_pid: enginePid,
        protocol_sequence: [
          "READY", "STAT_READY", "TIERS", "PROMPT_1", "END_1", "STAT_1",
          "RESET", "END_RESET", "STAT_RESET", "PROMPT_2", "END_2", "STAT_2", "EOF",
        ],
        ready: { preamble_bytes: 100, observed_draft: mode === "on" ? 3 : 0, stat: {}, tiers: {} },
        turns,
        reset_stat: {},
        identical_prompt_frames: true,
        artifacts: { manifest: "manifest.json", stdout: "stdout.bin", stderr: "stderr.bin", prompt: "prompt.bin" },
      });

      writeFileSync(`${directory}.memory-pressure.pre.txt`, "The system has 34359738368 (2097152 pages with a page size of 16384).\nSystem-wide memory free percentage: 80%\n");
      writeFileSync(`${directory}.memory-pressure.post.txt`, "The system has 34359738368 (2097152 pages with a page size of 16384).\nSystem-wide memory free percentage: 79%\n");
      writeFileSync(`${directory}.vm-stat.pre.txt`, vmStat(0));
      writeFileSync(`${directory}.vm-stat.post.txt`, vmStat(10 + repeat));
      writeFileSync(`${directory}.swap.pre.txt`, "vm.swapusage: total = 1024.00M  used = 0.00M  free = 1024.00M  (encrypted)\n");
      writeFileSync(`${directory}.swap.post.txt`, "vm.swapusage: total = 1024.00M  used = 0.25M  free = 1023.75M  (encrypted)\n");
    }
  }
  return { root, run: (mode, repeat) => join(root, `${PREFIX}-mtp-${mode}-r${repeat}`) };
}

describe("Colibri G0 warm matrix reporter", () => {
  test("validates six exact pairs and deterministically aggregates metrics and hashes", () => {
    const fixture = makeFixture();
    const first = buildMatrixReport({ root: fixture.root, prefix: PREFIX });
    const second = buildMatrixReport({ root: fixture.root, prefix: PREFIX });
    expect(first).toEqual(second);
    expect(first).toMatchObject({
      schema_version: 1,
      capture_kind: "colibri_glm52_g0_warm_matrix",
      matrix: { repeats_per_mode: 3, turns_per_process: 2, total_processes: 6 },
      provenance: { model_revision: "0123456789abcdef0123456789abcdef01234567" },
    });
    const modes = first.modes as any;
    expect(modes.off.runs).toHaveLength(3);
    expect(modes.on.runs).toHaveLength(3);
    expect(modes.off.summary.turns[0].elapsed_s).toEqual({ min: 171.1, median: 172.1, max: 173.1 });
    expect(modes.on.summary.turns[0].mtp_accepted).toEqual({ min: 34, median: 34, max: 34 });
    expect(modes.on.summary.turns[0].client_minus_engine_ttft_s.median).toBeCloseTo(0.001, 12);
    expect(modes.off.summary.process.process_swaps).toEqual({ min: 0, median: 0, max: 0 });
    expect(modes.on.summary.system_deltas.swap_used_mib).toEqual({ min: 0.25, median: 0.25, max: 0.25 });
    expect(modes.on.runs[0].source_files.sidecar_swap_post_txt.sha256).toMatch(/^[0-9a-f]{64}$/);
    const markdown = renderMatrixMarkdown(first);
    expect(markdown).toContain("Client-engine delta");
    expect(markdown).toContain("Load misses");
    expect(markdown).toContain("Process swaps");
    expect(markdown).toContain("Every source manifest");
  });

  test("fails closed on an incomplete matrix", () => {
    const fixture = makeFixture();
    rmSync(fixture.run("on", 3), { recursive: true });
    expect(() => buildMatrixReport({ root: fixture.root, prefix: PREFIX })).toThrow("missing run directory");
  });

  test("fails closed on schema drift, setting drift, corrupted responses, and missing sidecars", () => {
    for (const mutation of ["schema", "setting", "response", "sidecar"] as const) {
      const fixture = makeFixture();
      const directory = fixture.run("off", 2);
      if (mutation === "schema" || mutation === "setting") {
        const path = join(directory, "manifest.json");
        const manifest = JSON.parse(readFileSync(path, "utf8"));
        if (mutation === "schema") manifest.schema_version = 2;
        else manifest.env_overrides.RAM_GB = "19";
        writeJson(path, manifest);
      } else if (mutation === "response") {
        writeFileSync(join(directory, "turn-2.response.bin"), "corrupted");
      } else {
        unlinkSync(`${directory}.swap.post.txt`);
      }
      expect(() => buildMatrixReport({ root: fixture.root, prefix: PREFIX })).toThrow("Colibri G0 matrix validation failed");
    }
  });

  test("fails closed when all six cells drift uniformly from the G0 contract", () => {
    const fixture = makeFixture();
    for (const mode of ["off", "on"] as const) {
      for (let repeat = 1; repeat <= 3; repeat++) {
        const path = join(fixture.run(mode, repeat), "manifest.json");
        const manifest = JSON.parse(readFileSync(path, "utf8"));
        manifest.env_overrides.RAM_GB = "19";
        writeJson(path, manifest);
      }
    }
    expect(() => buildMatrixReport({ root: fixture.root, prefix: PREFIX })).toThrow("exact G0 environment");
  });

  test("fails closed when the declared or observed TTFT bound drifts", () => {
    for (const mutation of ["declared", "observed"] as const) {
      const fixture = makeFixture();
      const directory = fixture.run("off", 1);
      if (mutation === "declared") {
        const path = join(directory, "manifest.json");
        const manifest = JSON.parse(readFileSync(path, "utf8"));
        manifest.analysis.client_engine_tolerance_s = 1;
        writeJson(path, manifest);
      } else {
        const path = join(directory, "result.json");
        const result = JSON.parse(readFileSync(path, "utf8"));
        result.turns[0].client_ttft_s = result.turns[0].engine_trace.engine_prefill_to_first_s + 0.051;
        result.turns[0].engine_trace.client_minus_engine_ttft_s = 0.051;
        writeJson(path, result);
      }
      expect(() => buildMatrixReport({ root: fixture.root, prefix: PREFIX })).toThrow("TTFT");
    }
  });

  test("fails closed when engine identity or MTP accounting is inconsistent", () => {
    for (const mutation of ["pid", "mtp"] as const) {
      const fixture = makeFixture();
      const directory = fixture.run("on", 2);
      const path = join(directory, "result.json");
      const result = JSON.parse(readFileSync(path, "utf8"));
      if (mutation === "pid") result.process_pid++;
      else result.turns[0].engine_trace.mtp_rejected_or_discarded--;
      writeJson(path, result);
      expect(() => buildMatrixReport({ root: fixture.root, prefix: PREFIX })).toThrow("Colibri G0 matrix validation failed");
    }
  });
});
