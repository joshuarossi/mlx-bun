import { afterAll, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { help, parseCommand } from "../src/cli/args";
import { parseServeOptions } from "../src/cli/serve";
import { parseWorkerLaunch } from "../src/cli/worker-entry";
import { encodeLaunch, WORKER_PROTOCOL_VERSION } from "../src/jobs/worker-process";

const parse = (...args: string[]) => parseServeOptions(parseCommand("serve", args));
const dir = mkdtempSync(join(tmpdir(), "mlx-bun-tool-guard-cli-"));
afterAll(() => rmSync(dir, { recursive: true, force: true }));
const policy = join(dir, "policy.json");
writeFileSync(policy, JSON.stringify({ detectors: [{ id: "pack.answer", severity: "high", pattern: "task\\.toml" }] }));

test("the guard is off unless asked for, and off leaves the serve options as they were", () => {
  expect(parse()).not.toHaveProperty("toolGuard");
  expect(parse("--tool-guard", "off")).toEqual(parse());
});

test("one flag turns the guard on with SafeAgents' defaults; the others tune it", () => {
  expect(parse("--tool-guard", "block").toolGuard).toEqual({ mode: "block" });
  expect(parse("--tool-guard", "log").toolGuard).toEqual({ mode: "log" });
  expect(parse("--tool-guard", "block", "--tool-guard-allow-host", "api.example.dev, Internal.Corp ,10.0.0.5", "--tool-guard-block-severity", "medium",
    "--tool-guard-policy", policy, "--tool-guard-judge", "on", "--tool-guard-on-error", "block", "--tool-guard-journal", join(dir, "calls.jsonl")).toolGuard).toEqual({
    mode: "block", allowHosts: ["api.example.dev", "internal.corp", "10.0.0.5"], blockSeverity: "medium", policyFile: policy,
    judge: true, onError: "block", journal: join(dir, "calls.jsonl"),
  });
  expect(parse("--tool-guard", "block", "--tool-guard-judge", "off").toolGuard).toEqual({ mode: "block" });
  expect(parse("--tool-guard", "log", "--tool-guard-scan", "off").toolGuard).toEqual({ mode: "log", scan: false });
  // Relative paths are resolved once, by the process that parsed them: a worker's directory may differ.
  expect(parse("--tool-guard", "log", "--tool-guard-journal", "calls.jsonl").toolGuard!.journal).toBe(join(process.cwd(), "calls.jsonl"));
});

test("invalid values and options that would do nothing are refused before anything loads", () => {
  const refused: [string[], string][] = [
    [["--tool-guard", "on"], "--tool-guard expects off|log|block"],
    [["--tool-guard-allow-host", "example.dev"], "--tool-guard-allow-host requires --tool-guard log|block"],
    [["--tool-guard", "off", "--tool-guard-journal", "x.jsonl"], "--tool-guard-journal requires --tool-guard log|block"],
    [["--tool-guard", "block", "--tool-guard-scan", "maybe"], "--tool-guard-scan expects on|off"],
    [["--tool-guard", "block", "--tool-guard-block-severity", "info"], "--tool-guard-block-severity expects low|medium|high|critical"],
    [["--tool-guard", "block", "--tool-guard-on-error", "ignore"], "--tool-guard-on-error expects allow|block"],
    [["--tool-guard", "block", "--tool-guard-allow-host", "https://example.dev/x"], "--tool-guard-allow-host expects host names"],
    [["--tool-guard", "block", "--tool-guard-judge", "http://judge.local/v1"], "--tool-guard-judge expects on|off"],
    [["--tool-guard-judge", "on"], "--tool-guard-judge requires --tool-guard log|block"],
    [["--tool-guard", "block", "--tool-guard-scan", "off", "--tool-guard-judge", "on"], "--tool-guard-scan off leaves no findings"],
    [["--tool-guard", "block", "--tool-guard-policy", join(dir, "missing.json")], "--tool-guard-policy"],
  ];
  for (const [args, message] of refused) expect(() => parse(...args), args.join(" ")).toThrow(message);
  const invalid = join(dir, "invalid.json");
  writeFileSync(invalid, JSON.stringify({ allow: [{ id: "expected.x", covers: ["no.such.check"] }] }));
  expect(() => parse("--tool-guard", "block", "--tool-guard-policy", invalid)).toThrow("missing_dependency: no.such.check");
});

test("the options reach a model worker unchanged, and name no endpoint or credential", () => {
  const options = parse("--tool-guard", "block", "--tool-guard-policy", policy, "--tool-guard-judge", "on", "--tool-guard-allow-host", "example.dev");
  const line = encodeLaunch({ version: WORKER_PROTOCOL_VERSION, socketPath: join(dir, "worker.sock"), model: { repoId: "org/model", path: dir }, options });
  const launch = parseWorkerLaunch(line);
  expect("options" in launch && launch.options.toolGuard).toEqual(options.toolGuard!);
  expect(Object.keys(options.toolGuard!).sort()).toEqual(["allowHosts", "judge", "mode", "policyFile"]);
});

test("serve --help documents every guard option with its default", () => {
  const text = help("serve");
  for (const flag of ["--tool-guard <value>", "--tool-guard-allow-host", "--tool-guard-scan", "--tool-guard-block-severity", "--tool-guard-policy",
    "--tool-guard-judge <value>", "--tool-guard-on-error", "--tool-guard-journal"])
    expect(text).toContain(flag);
  expect(text).toContain("off | log | block [default: off]");
  for (const gone of ["API_KEY", "judge-url", "judge-model"]) expect(text).not.toContain(gone);
});
