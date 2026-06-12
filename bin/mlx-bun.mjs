#!/usr/bin/env bun
// npm-bin launcher. Plain .mjs so that *any* runtime can parse it and the
// runtime guard below fires before anything touches bun:ffi / bun:sqlite
// (a guard inside cli.ts would never run under Node — its static imports
// hoist and fail on the bun: scheme first).

const MIN_BUN = "1.3.14"; // Bun.Image + verified FFI behavior (see README)

if (typeof Bun === "undefined") {
  console.error(
    `mlx-bun requires Bun >= ${MIN_BUN} (this is ${process.release?.name ?? "an unknown runtime"} ${process.version}).\n` +
      `Install it:  curl -fsSL https://bun.sh/install | bash\n` +
      `Then run:    bunx mlx-bun`,
  );
  process.exit(1);
}

const older = (a, b) => {
  const x = a.split(".").map(Number), y = b.split(".").map(Number);
  for (let i = 0; i < 3; i++) if ((x[i] ?? 0) !== (y[i] ?? 0)) return (x[i] ?? 0) < (y[i] ?? 0);
  return false;
};
if (older(Bun.version, MIN_BUN)) {
  console.error(`mlx-bun requires Bun >= ${MIN_BUN} (you have ${Bun.version}). Run: bun upgrade`);
  process.exit(1);
}
if (process.platform !== "darwin" || process.arch !== "arm64") {
  console.error("mlx-bun runs on Apple Silicon Macs only (MLX is Metal-only by design).");
  process.exit(1);
}

await import("../src/cli.ts");
