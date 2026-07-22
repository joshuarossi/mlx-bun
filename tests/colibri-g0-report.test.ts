import { describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { tmpdir } from "node:os";
import {
  analyzeCell,
  parseColibriLog,
  parseMemoryPressure,
  parseSwapUsedMb,
  parseVmStat,
  renderMarkdown,
} from "../scripts/colibri-g0-report";

const ROOT = resolve(import.meta.dir, "..");
const LOG = `[METAL] mode: batched routed experts on GPU (unified-memory zero-copy)
[MTP] active: native speculative decoding (draft=3)
[RAM_GB=18.0] cap=1 ok (projected peak 16.8 GB)
[PROF] config: RAM_GB=18.0 CTX=128 | expert cache cap 1/layer (up to 1.5 GB) | pinned 0 (0.0 GB) | DRAFT=3 PIPE=1 DIRECT=1 MMAP=0 IDOT=1 DSA=off PILOT=0 CACHE_ROUTE=0
loaded in 2.76s | resident dense: 9912.75 MB | layers=78 experts=256 | MTP ACTIVE (draft=3)
prompt: 32 tokens | generating up to 64 (EOS stop=154820) | n-gram draft=3
METAL: blocchi GPU 234 | fallback CPU 0 | expert su GPU 7505 | setup 0.09s gpu-wall 3.67s
[TOKENS] 64 generated: ${Array.from({ length: 64 }, (_, index) => index).join(" ")}
---
prefill 32 tokens in 31.47s | decode 64 tokens in 194.21s (0.33 tok/s) | expert hit rate 1.3% (pin 0.0% + lru 1.3%) | RSS 7.79 GB
experts loaded/token: 1112.4 (per-layer 14.83 across 75; baseline topk=8) | TOPK=0 TOPP=0.00
speculation: 2.13 tokens/forward (30 forwards per 64 tokens) | MTP acceptance 38% (34/90)
disk-load split: draft 750 + absorb 401 + verify/main 51030 misses | MTP-layer 1151 loads 43.49 GB | main-layers 51030 loads 965.36 GB (MTP 4.3% of bytes)
[PROF] expert I/O: 983.671 GB fetched (15369.9 MB/token, 5.06 GB/s over the run) | hit 1.3% (0 pin + 664 lru / 51030 load) | 1112.4 loads/token | 833.3s read service / 144.5s felt wait
[PROF] resident experts: 0 pinned (0.0 GB) + 76 in LRU (1.4 GB, cap 1/layer)
METAL: blocchi GPU 3355 | fallback CPU 0 | expert su GPU 59308 | setup 0.72s gpu-wall 24.93s
      228.98 real       111.50 user       132.14 sys
          8359444480  maximum resident set size
                   0  swaps
         16981702576  peak memory footprint
`;

const MEMORY_PRE = `The system has 34359738368 (2097152 pages with a page size of 16384).
Pages free: 777339
Swapins: 0
Swapouts: 0
Pages used by compressor: 70225
Pages decompressed: 2198442
Pages compressed: 2632230
Pageins: 8468475
Pageouts: 3148
System-wide memory free percentage: 90%
`;

const MEMORY_POST = `The system has 34359738368 (2097152 pages with a page size of 16384).
Pages free: 1045135
Swapins: 0
Swapouts: 0
Pages used by compressor: 77189
Pages decompressed: 3348363
Pages compressed: 4029365
Pageins: 12132752
Pageouts: 4762
System-wide memory free percentage: 90%
`;

const VM_PRE = `Mach Virtual Memory Statistics: (page size of 16384 bytes)
Pages free: 777400.
Pages occupied by compressor: 70224.
Decompressions: 2198444.
Compressions: 2632230.
Pageins: 8468477.
Pageouts: 3148.
Swapins: 0.
Swapouts: 0.
`;

const VM_POST = `Mach Virtual Memory Statistics: (page size of 16384 bytes)
Pages free: 1045130.
Pages occupied by compressor: 77189.
Decompressions: 3348363.
Compressions: 4029365.
Pageins: 12132756.
Pageouts: 4762.
Swapins: 0.
Swapouts: 0.
`;

describe("Colibri G0 report parser", () => {
  test("extracts the matched run, MTP, I/O, Metal, and time -l metrics", () => {
    const parsed = parseColibriLog(LOG);
    expect(parsed).toMatchObject({
      unified_memory_zero_copy: true,
      mtp_active: true,
      draft_tokens: 3,
      ram_budget_gb: 18,
      projected_peak_gb: 16.8,
      cache_cap_per_layer: 1,
      direct_io: true,
      mmap: false,
      prompt_tokens: 32,
      generated_tokens: 64,
      decode_tokens_per_second: 0.33,
      tokens_per_forward: 2.13,
      mtp_accepted: 34,
      mtp_proposed: 90,
      disk_misses_draft: 750,
      disk_misses_absorb: 401,
      mtp_layer_gb: 43.49,
      main_layer_gb: 965.36,
      expert_fetch_gb: 983.671,
      metal_fallback_cpu_max_observed: 0,
      maximum_resident_set_bytes: 8359444480,
      peak_memory_footprint_bytes: 16981702576,
    });
    expect(parsed.token_ids).toHaveLength(64);
    expect(parsed.token_ids?.slice(0, 4)).toEqual([0, 1, 2, 3]);
  });

  test("accepts Colibri's cap-lowered budget line and missing token dump", () => {
    const off = LOG
      .replace("[MTP] active: native speculative decoding (draft=3)", "[MTP] absent (draft=0)")
      .replace("[RAM_GB=18.0] cap=1 ok (projected peak 16.8 GB)", "[RAM_GB=18.0] resident 10.1 GB -> cap lowered 8->2 (projected peak 17.9 GB)")
      .replace("expert cache cap 1/layer", "expert cache cap 2/layer")
      .replace("cap 1/layer)", "cap 2/layer)")
      .replace("DRAFT=3", "DRAFT=0")
      .replace("MTP ACTIVE (draft=3)", "MTP absent (draft=0)")
      .replace("n-gram draft=3", "n-gram draft=0")
      .replace(/^speculation:.*$/m, "speculation: 1.00 tokens/forward (64 forwards per 64 tokens) | MTP acceptance 0% (0/0)")
      .replace(/^disk-load split:.*$/m, "disk-load split: draft 0 + absorb 0 + verify/main 51030 misses | MTP-layer 0 loads 0.00 GB | main-layers 51030 loads 965.36 GB (MTP 0.0% of bytes)")
      .replace(/^\[TOKENS\].*\n/m, "");
    const parsed = parseColibriLog(off);
    expect(parsed.mtp_active).toBe(false);
    expect(parsed.cache_cap_per_layer).toBe(2);
    expect(parsed.projected_peak_gb).toBe(17.9);
    expect(parsed.token_ids).toBeNull();
  });

  test("marks an omitted disk split unavailable and rejects truncated token evidence", () => {
    const noSplit = LOG.replace(/^disk-load split:.*\n/m, "");
    expect(parseColibriLog(noSplit).main_layer_gb).toBeNull();
    expect(() => parseColibriLog(LOG.replace(/^\[TOKENS\].*$/m, "[TOKENS] 64 generated: 1 2")))
      .toThrow("declares 64 tokens but contains 2");
  });

  test("rejects cross-field contradictions instead of producing evidence", () => {
    expect(() => parseColibriLog(LOG.replace("prefill 32 tokens", "prefill 31 tokens")))
      .toThrow("prefill token count");
    expect(() => parseColibriLog(LOG.replace("30 forwards per 64 tokens", "30 forwards per 63 tokens")))
      .toThrow("speculation token total");
    expect(() => parseColibriLog(LOG.replace("(34/90)", "(91/90)")))
      .toThrow("accepted count exceeds");
    expect(() => parseColibriLog(LOG.replace("expert hit rate 1.3%", "expert hit rate 9.9%")))
      .toThrow("expert hit total");
    expect(() => parseColibriLog(LOG.replace("config: RAM_GB=18.0", "config: RAM_GB=17.0")))
      .toThrow("RAM budget");
    expect(() => parseColibriLog(LOG.replace("cap 1/layer)", "cap 2/layer)")))
      .toThrow("resident cache cap");
  });

  test("parses memory_pressure, vm_stat, and swap snapshots", () => {
    expect(parseMemoryPressure(MEMORY_PRE)).toMatchObject({
      page_size_bytes: 16384,
      total_memory_bytes: 34359738368,
      free_percent: 90,
      values: { pages_used_by_compressor: 70225, pages_compressed: 2632230 },
    });
    expect(parseVmStat(VM_POST)).toMatchObject({
      page_size_bytes: 16384,
      values: { pages_occupied_by_compressor: 77189, compressions: 4029365 },
    });
    expect(parseSwapUsedMb("vm.swapusage: total = 0.00M  used = 12.50M  free = 0.00M")).toBe(12.5);
  });

  test("autodiscovers sidecars and writes deterministic JSON and Markdown", () => {
    const temp = mkdtempSync(join(tmpdir(), "mlx-bun-colibri-g0-report-"));
    const log = join(temp, "matched-mtp-on-r1.log");
    try {
      writeFileSync(log, LOG);
      writeFileSync(join(temp, "matched-mtp-on-r1.memory-pressure.pre.txt"), MEMORY_PRE);
      writeFileSync(join(temp, "matched-mtp-on-r1.memory-pressure.post.txt"), MEMORY_POST);
      writeFileSync(join(temp, "matched-mtp-on-r1.vm-stat.pre.txt"), VM_PRE);
      writeFileSync(join(temp, "matched-mtp-on-r1.vm-stat.post.txt"), VM_POST);
      writeFileSync(join(temp, "matched-mtp-on-r1.swap.pre.txt"), "vm.swapusage: total = 0.00M  used = 0.00M  free = 0.00M\n");
      writeFileSync(join(temp, "matched-mtp-on-r1.swap.post.txt"), "vm.swapusage: total = 0.00M  used = 0.00M  free = 0.00M\n");
      const result = Bun.spawnSync([
        process.execPath, "scripts/colibri-g0-report.ts",
        "--log", log,
        "--cache-state", "process-cold",
        "--boot-state", "not-boot-cold",
        "--classification-source", "test fixture: fresh fake process",
      ], { cwd: ROOT, stdout: "pipe", stderr: "pipe" });
      expect(result.exitCode).toBe(0);

      const json = JSON.parse(readFileSync(join(temp, "matched-mtp-on-r1.summary.json"), "utf8"));
      expect(json.classification).toEqual({
        cache_state: "process-cold",
        boot_state: "not-boot-cold",
        evidence_source: "test fixture: fresh fake process",
      });
      expect(json.system_memory.vm_stat_post_minus_pre).toMatchObject({
        pages_occupied_by_compressor: 6965,
        compressions: 1397135,
        decompressions: 1149919,
      });
      expect(json.system_memory.vm_stat_compressor_bytes_post_minus_pre).toBe(6965 * 16384);
      expect(json.sources).toHaveProperty("memory_pressure_pre.sha256");
      expect(json.sources.log.path).toBe("matched-mtp-on-r1.log");
      expect(json.analyzer.path).toBe("scripts/colibri-g0-report.ts");
      expect(json.completeness).toMatchObject({
        ttft: false,
        token_ids: true,
        disk_split: true,
        memory_pressure_pre_post: true,
      });
      const markdown = readFileSync(join(temp, "matched-mtp-on-r1.summary.md"), "utf8");
      expect(markdown).toContain("MTP acceptance | 34/90 (38.0%)");
      expect(markdown).toContain("Cache state: **process-cold**");

      const direct = analyzeCell({
        log,
        jsonOut: join(temp, "unused.json"),
        markdownOut: join(temp, "unused.md"),
        cacheState: "unspecified",
        bootState: "unspecified",
        classificationSource: "test fixture without sidecars",
      });
      expect(renderMarkdown(direct)).toContain("system swap used pre / post | — / — MB");
    } finally {
      rmSync(temp, { recursive: true, force: true });
    }
  });

  test("rejects unsupported warm claims and malformed or mismatched sidecars", () => {
    const temp = mkdtempSync(join(tmpdir(), "mlx-bun-colibri-g0-invalid-"));
    const log = join(temp, "cell.log");
    try {
      writeFileSync(log, LOG);
      const base = {
        log,
        jsonOut: join(temp, "unused.json"),
        markdownOut: join(temp, "unused.md"),
        bootState: "unspecified" as const,
        classificationSource: "test evidence",
      };
      expect(() => analyzeCell({ ...base, cacheState: "warm-explicit-lru" })).toThrow("cannot prove warm");
      writeFileSync(join(temp, "bad-memory.txt"), MEMORY_PRE);
      expect(() => analyzeCell({
        ...base,
        cacheState: "process-cold",
        memoryPressurePost: join(temp, "bad-memory.txt"),
      })).toThrow("requires both pre and post");
      expect(() => parseMemoryPressure("Pages free: 1\n")).toThrow("malformed memory_pressure");
      expect(() => parseVmStat(VM_POST.replace("page size of 16384", "page size of 4096").replace("Compressions: 4029365.", "")))
        .toThrow("missing compressions");
      const vmPrePath = join(temp, "vm-pre.txt");
      const vmPostPath = join(temp, "vm-post.txt");
      writeFileSync(vmPrePath, VM_PRE);
      writeFileSync(vmPostPath, VM_POST.replace("page size of 16384", "page size of 4096"));
      expect(() => analyzeCell({
        ...base,
        cacheState: "process-cold",
        vmStatPre: vmPrePath,
        vmStatPost: vmPostPath,
      })).toThrow("page sizes do not match");
      writeFileSync(vmPostPath, VM_POST.replace("Compressions: 4029365.", "Compressions: 1."));
      expect(() => analyzeCell({
        ...base,
        cacheState: "process-cold",
        vmStatPre: vmPrePath,
        vmStatPost: vmPostPath,
      })).toThrow("cumulative counter decreased: compressions");
    } finally {
      rmSync(temp, { recursive: true, force: true });
    }
  });
});
