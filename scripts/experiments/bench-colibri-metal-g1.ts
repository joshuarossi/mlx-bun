#!/usr/bin/env bun

/**
 * Build/run orchestrator for the pinned Colibri Metal side of the G1 quiet
 * kernel matrix. The external checkout is validated and consumed read-only;
 * the binary and report are written only to caller-selected mlx-bun/tmp paths.
 */

import {
  existsSync,
  mkdirSync,
  readFileSync,
} from "node:fs";
import { dirname, join, resolve } from "node:path";

const PINNED_COMMIT = "44e489b196c9b7876b3d37a0570ebf1c6f90f54c";
const PINNED_METAL_SHA256 =
  "50f3188e770a487efb972d1b54142d8557e80b875c95f1ea8d776173f159f774";
const PINNED_HEADER_SHA256 =
  "2b0ea2beb0226b60e4008f2a6792ae75cee82cfe8207cfeb159a84325f309660";

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index++) {
    const key = argv[index]!;
    if (!key.startsWith("--"))
      throw new Error(`unexpected argument ${key}`);
    if (key === "--build-only") {
      out.set("build-only", "1");
      continue;
    }
    const value = argv[++index];
    if (value === undefined)
      throw new Error(`missing value for ${key}`);
    out.set(key.slice(2), value);
  }
  return out;
}

function sha256(path: string): string {
  return new Bun.CryptoHasher("sha256")
    .update(readFileSync(path))
    .digest("hex");
}

function command(command: readonly string[], cwd?: string): string {
  const result = Bun.spawnSync([...command], {
    cwd,
    stdout: "pipe",
    stderr: "pipe",
  });
  const stdout = new TextDecoder().decode(result.stdout);
  const stderr = new TextDecoder().decode(result.stderr);
  if (result.exitCode !== 0)
    throw new Error(
      `${command.join(" ")} failed (${result.exitCode}):\n${stdout}${stderr}`,
    );
  return stdout.trim();
}

function exact(actual: string, expected: string, label: string): void {
  if (actual !== expected)
    throw new Error(`${label} ${actual} != pinned ${expected}`);
}

const values = argumentsMap(Bun.argv.slice(2));
const colibri = resolve(
  values.get("colibri") ?? "/Users/joshrossi/Code/colibri",
);
const output = resolve(
  values.get("output") ?? "runs/colibri-g1/colibri-metal-matrix.json",
);
const binary = resolve(
  values.get("binary") ?? "runs/colibri-g1/colibri-metal-g1",
);
const warmups = values.get("warmups") ?? "3";
const repeats = values.get("repeats") ?? "11";
for (const [label, value] of Object.entries({ warmups, repeats })) {
  if (!/^\d+$/.test(value) || (label === "repeats" && Number(value) < 1))
    throw new RangeError(`--${label} must be a valid non-negative integer`);
}

const backend = join(colibri, "c", "backend_metal.mm");
const header = join(colibri, "c", "backend_metal.h");
const harness = resolve(
  import.meta.dir,
  "bench-colibri-metal-g1.mm",
);
for (const path of [backend, header, harness])
  if (!existsSync(path)) throw new Error(`missing source: ${path}`);

exact(
  command(["git", "-C", colibri, "rev-parse", "HEAD"]),
  PINNED_COMMIT,
  "Colibri commit",
);
if (command(["git", "-C", colibri, "status", "--porcelain"]).length)
  throw new Error("Colibri checkout is dirty; refusing a mislabeled matrix");
exact(sha256(backend), PINNED_METAL_SHA256, "backend_metal.mm SHA-256");
exact(sha256(header), PINNED_HEADER_SHA256, "backend_metal.h SHA-256");
const harnessSha256 = sha256(harness);

mkdirSync(dirname(binary), { recursive: true });
mkdirSync(dirname(output), { recursive: true });
const compile = [
  "/usr/bin/clang++",
  "-x",
  "objective-c++",
  "-std=gnu++17",
  "-fobjc-arc",
  "-O3",
  "-Wall",
  "-Wextra",
  "-Werror",
  "-Wno-unused-const-variable",
  `-I${join(colibri, "c")}`,
  `-DCOLIBRI_PIN="${PINNED_COMMIT}"`,
  `-DCOLIBRI_METAL_SHA256="${PINNED_METAL_SHA256}"`,
  `-DCOLIBRI_HEADER_SHA256="${PINNED_HEADER_SHA256}"`,
  `-DHARNESS_SHA256="${harnessSha256}"`,
  harness,
  backend,
  "-framework",
  "Metal",
  "-framework",
  "Foundation",
  "-o",
  binary,
];
console.log(`build: ${compile.join(" ")}`);
command(compile);
console.log(`built: ${binary}`);

if (!values.has("build-only")) {
  const run = [
    binary,
    "--output",
    output,
    "--warmups",
    warmups,
    "--repeats",
    repeats,
  ];
  console.log(`run: ${run.join(" ")}`);
  const stdout = command(run);
  if (stdout) console.log(stdout);
  console.log(`report: ${output}`);
}
