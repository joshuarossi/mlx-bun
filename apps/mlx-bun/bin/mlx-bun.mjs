#!/usr/bin/env bun
// Stay parseable by Node so unsupported runtimes get a useful error before
// the application imports bun:sqlite or bun:ffi.
import { readFileSync } from "node:fs";

const { engines } = JSON.parse(readFileSync(new URL("../package.json", import.meta.url), "utf8"));
const minimum = engines.bun.replace(/^>=/, "");
if (typeof Bun === "undefined") {
  console.error(`mlx-bun requires Bun >= ${minimum}. Install Bun, then run: bunx mlx-bun`);
  process.exit(1);
}
const actual = Bun.version.split("-")[0].split(".").map(Number);
const required = minimum.split(".").map(Number);
const difference = required.findIndex((part, index) => part !== actual[index]);
if (difference !== -1 && actual[difference] < required[difference]) {
  console.error(`mlx-bun requires Bun >= ${minimum} (you have ${Bun.version}). Run: bun upgrade`);
  process.exit(1);
}
if (process.platform !== "darwin" || process.arch !== "arm64") {
  console.error("mlx-bun runs on Apple Silicon Macs only.");
  process.exit(1);
}

await import("../src/cli/main.ts");
