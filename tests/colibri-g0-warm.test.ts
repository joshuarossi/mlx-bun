import { describe, expect, test } from "bun:test";
import { chmodSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { analyzeExistingWarmRun, parseEngineTrace, parseStat, parseTiers, runWarmHarness } from "../scripts/colibri-g0-warm";

const FAKE_ENGINE = String.raw`const END = "\x01\x01END\x01\x01\n";
let buffer = Buffer.alloc(0), expected = null, firstPrompt = null, turn = 0;
process.stdout.write("fake load preamble | MTP ACTIVE (draft=3)\n\x01\x01READY\x01\x01\nSTAT 0 0.00 0.0 1.00\nTIERS 0 75 19125 0.00 1.40\n");
process.stderr.write("fake engine started\n");
function consume() {
  while (true) {
    if (expected !== null) {
      if (buffer.length < expected + 1) return;
      const prompt = buffer.subarray(0, expected);
      if (buffer[expected] !== 10) process.exit(4);
      buffer = buffer.subarray(expected + 1);
      if (firstPrompt === null) firstPrompt = Buffer.from(prompt);
      else if (!firstPrompt.equals(prompt)) process.exit(5);
      expected = null;
      turn++;
      const current = turn;
      const begin = 100 + current;
      process.stderr.write("[G0_TRACE] BEGIN turn=" + current + " mono_s=" + begin.toFixed(9) + "\n");
      setTimeout(() => {
        process.stderr.write("[G0_TRACE] FIRST turn=" + current + " token=7 mono_s=" + (begin + 0.01).toFixed(9) + " ttft_s=0.010000000\n");
        process.stdout.write("reply-" + current + "-");
        setTimeout(() => {
          process.stderr.write("[G0_TRACE] VERIFY turn=" + current + " fw=1 src=2 mtp=1 proposed_raw=2 proposed=1 accepted=1 tokens=2 forward_s=0.004000000 mono_s=" + (begin + 0.014).toFixed(9) + "\n");
          process.stderr.write("[G0_TRACE] END turn=" + current + " produced=2 elapsed_s=0.015000000\n");
          process.stderr.write("[G0_TRACE] TOKENS turn=" + current + " count=2 ids=7,8\n");
          process.stderr.write("[PROF] decode forwards: 1 | latency p50 4.0 ms | p90 4.0 ms | p99 4.0 ms | max 4.0 ms | 2.00 tok/forward\n");
          process.stderr.write("[PROF] expert I/O: 1.250 GB fetched (625.0 MB/token, 83.3 GB/s over the run) | hit 50.0% (2 pin + 3 lru / 5 load) | 2.5 loads/token | 0.8s read service / 0.2s felt wait\n");
          process.stderr.write("[PROF] resident experts: 2 pinned (0.1 GB) + 3 in LRU (0.2 GB, cap 1/layer)\n");
          process.stdout.write("ok" + END + "STAT 2 10.00 50.0 1.20 5 0\n");
        }, 5);
      }, 10);
      continue;
    }
    const nl = buffer.indexOf(10);
    if (nl < 0) return;
    const line = buffer.subarray(0, nl).toString();
    buffer = buffer.subarray(nl + 1);
    if (line === "\x02RESET") {
      process.stdout.write(END + "STAT 0 0.00 0.0 1.10\n");
    } else if (line.startsWith("\x02PROMPT ")) {
      const fields = line.slice(8).split(" ");
      expected = Number(fields[0]);
    } else process.exit(3);
  }
}
process.stdin.on("data", chunk => { buffer = Buffer.concat([buffer, chunk]); consume(); });
process.stdin.on("end", () => { process.stderr.write("fake engine eof\n"); });
`;

describe("bounded Colibri G0 warm harness", () => {
  test("parses protocol status records", () => {
    expect(parseStat("STAT 4 0.42 2.3 7.79 32 1 route_swaps=2")).toEqual({
      completion_tokens: 4,
      tokens_per_second: 0.42,
      cache_hit_percent: 2.3,
      rss_gb: 7.79,
      prompt_tokens: 32,
      length_limited: true,
      extra: { route_swaps: "2" },
    });
    expect(parseTiers("TIERS 0 75 19125 0.00 1.40")).toEqual({
      vram_experts: 0,
      ram_experts: 75,
      disk_experts: 19125,
      vram_gb: 0,
      ram_gb: 1.4,
    });
  });

  test("uses one process for prompt, reset, identical prompt, and EOF", async () => {
    const temp = mkdtempSync(join(tmpdir(), "mlx-bun-colibri-warm-"));
    const binary = join(temp, "fake-glm");
    const out = join(temp, "evidence");
    const prompt = new TextEncoder().encode("line one\nline two 🐦");
    try {
      writeFileSync(binary, `#!${process.execPath}\n${FAKE_ENGINE}`);
      chmodSync(binary, 0o755);
      const result = await runWarmHarness({
        binary,
        model: join(temp, "model-is-never-opened"),
        prompt,
        promptSource: "inline test prompt",
        out,
        mtp: "on",
        maxTokens: 2,
        temperature: 0,
        topP: 1,
        timeoutSeconds: 5,
        cacheCap: 1,
        expertBits: 4,
        denseBits: 4,
        extraEnv: { RAM_GB: "18", DIRECT: "1" },
      });
      expect(result.complete).toBe(true);
      expect(result.protocol_sequence).toEqual([
        "READY", "STAT_READY", "TIERS",
        "PROMPT_1", "END_1", "STAT_1",
        "RESET", "END_RESET", "STAT_RESET",
        "PROMPT_2", "END_2", "STAT_2", "EOF",
      ]);
      expect(result.turns).toHaveLength(2);
      expect(result.ready?.observed_draft).toBe(3);
      expect(result.same_process).toBe(true);
      expect(result.process_pid).toBeGreaterThan(0);
      expect(result.process.launcher_pid).toBeGreaterThan(0);
      expect(result.process.engine_pid).toBeGreaterThan(0);
      expect(result.process.maximum_resident_set_bytes).toBeGreaterThan(0);
      expect(result.process.process_swaps).toBe(0);
      expect(result.process.peak_memory_footprint_bytes).toBeGreaterThan(0);
      expect(result.turns.map((turn) => turn.cache_state)).toEqual(["first-turn-in-process", "warm-explicit-lru"]);
      expect(result.turns.every((turn) => turn.client_ttft_s > 0)).toBe(true);
      expect(result.turns.map((turn) => turn.stat.prompt_tokens)).toEqual([5, 5]);
      expect(result.turns[0]?.engine_trace).toMatchObject({
        engine_prefill_to_first_s: 0.01,
        elapsed_s: 0.015,
        produced: 2,
        token_ids: [7, 8],
        verify_rows: 1,
        mtp_raw_proposals: 2,
        mtp_verified_proposals: 1,
        mtp_accepted: 1,
        mtp_rejected_or_discarded: 1,
        acceptance_length_histogram: { "1": 1 },
        verify_seconds: 0.004,
        forwards: 1,
        tokens_per_forward: 2,
        expert_fetched_gb: 1.25,
        pinned_hits: 2,
        lru_hits: 3,
        resident_pinned_experts: 2,
        resident_lru_experts: 3,
      });
      expect(result.turns[0]?.engine_trace.resident_expert_gb).toBeCloseTo(0.3);
      expect(readFileSync(join(out, "prompt.bin"))).toEqual(Buffer.from(prompt));
      expect(readFileSync(join(out, "stderr.bin"), "utf8")).toContain("fake engine eof");
      const manifest = JSON.parse(readFileSync(join(out, "manifest.json"), "utf8"));
      expect(manifest.env_overrides).toMatchObject({ MTP: "1", TOKENS: "1", SNAP: join(temp, "model-is-never-opened"), SERVE: "1", SERVE_BATCH: "0", DRAFT: "3" });
      expect(manifest.launcher_command.slice(0, 2)).toEqual(["/usr/bin/time", "-l"]);
      expect(manifest.engine_binary).toMatchObject({ path: binary, bytes: readFileSync(binary).byteLength });
      expect(manifest.engine_binary.sha256).toMatch(/^[0-9a-f]{64}$/);
      expect(manifest.prompt).toMatchObject({ bytes: prompt.length, file: "prompt.bin" });
      expect(manifest.analysis).toMatchObject({ stderr: { path: "stderr.bin" }, client_engine_tolerance_s: 0.05 });
      const persisted = JSON.parse(readFileSync(join(out, "result.json"), "utf8"));
      expect(persisted.complete).toBe(true);
      expect(persisted.schema_version).toBe(3);

      const legacy = structuredClone(persisted);
      legacy.schema_version = 2;
      delete legacy.same_process;
      delete legacy.process_pid;
      delete legacy.ready.observed_draft;
      for (const turn of legacy.turns) {
        delete turn.cache_state;
        delete turn.engine_trace;
      }
      const legacyManifest = structuredClone(manifest);
      legacyManifest.schema_version = 1;
      delete legacyManifest.analysis;
      writeFileSync(join(out, "result.json"), `${JSON.stringify(legacy, null, 2)}\n`);
      writeFileSync(join(out, "manifest.json"), `${JSON.stringify(legacyManifest, null, 2)}\n`);
      const reanalyzed = await analyzeExistingWarmRun(out);
      expect(reanalyzed.schema_version).toBe(3);
      expect(reanalyzed.process_pid).toBeNull();
      expect(reanalyzed.turns[1]?.cache_state).toBe("warm-explicit-lru");
      expect(reanalyzed.turns[1]?.engine_trace.mtp_accepted).toBe(1);
      expect(() => parseEngineTrace(
        readFileSync(join(out, "stderr.bin"), "utf8"),
        reanalyzed.turns,
        "off",
      )).toThrow("MTP-off trace turn 1 contains MTP proposal activity");
    } finally {
      rmSync(temp, { recursive: true, force: true });
    }
  });

  test("CLI rejects missing model selection instead of defaulting", () => {
    const result = Bun.spawnSync([
      process.execPath, "scripts/colibri-g0-warm.ts", "--mtp", "off", "--out", "/tmp/unused",
    ], { stdout: "pipe", stderr: "pipe" });
    expect(result.exitCode).not.toBe(0);
    expect(new TextDecoder().decode(result.stderr)).toContain("--binary is required");
  });
});
