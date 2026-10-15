import { resolve } from "node:path";

// The workspace scripts own the configurations and flags for both compilers.
const compiler = process.env.MLX_BUN_TYPECHECK_COMPILER ?? "typescript";
if (compiler !== "typescript" && compiler !== "tsc-rs") {
  throw new Error(`Unknown MLX_BUN_TYPECHECK_COMPILER: ${compiler}; use typescript or tsc-rs`);
}
if (!process.execve) throw new Error("Typechecking requires Bun 1.4.2 on macOS (process.execve)");

const executable = resolve(import.meta.dir, "../node_modules/.bin", compiler === "typescript" ? "tsc" : "tsc-rs");
// Replace this launcher so the compiler owns its signals, output, and exit status.
process.execve(executable, [executable, ...process.argv.slice(2)]);
