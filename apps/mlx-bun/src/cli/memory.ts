import { fileURLToPath } from "node:url";
import { runModuleMemory, vaultRoot, memoryManifest, type MemoryDependencies, type MemoryCommandArgs as CommandArgs } from "../modules";
import { verbHelp } from "@mlx-bun/app-services";
import { executablePath } from "../jobs/executable";
import { userHome } from "../storage/paths";
import { createInProcessMemoryClient } from "./memory-engine";
import { banner, boxLines, renderHelp, step, style, gradient } from "./terminal";
import pkg from "../../package.json" with { type: "json" };
export type { MemoryDependencies } from "../modules";

/** The app's executable, terminal and task-model adapters; memory policy belongs to its module. */
export function defaultMemoryDependencies(): MemoryDependencies {
  const entry = fileURLToPath(new URL("./main.ts", import.meta.url));
  return {
    log: console.log, error: console.error, banner: () => banner(pkg.version),
    box: lines => { for (const line of boxLines(lines)) console.log(line); }, step, style: { ...style, gradient },
    help: () => renderHelp(verbHelp("mlx-bun", memoryManifest.verbs[0])), vault: vaultRoot(), home: userHome(),
    program: entry.includes("$bunfs") ? [executablePath] : [executablePath, entry],
    taskModel: () => createInProcessMemoryClient(),
    async open(args) { return await Bun.spawn(["open", ...args], { stdout: "ignore", stderr: "ignore" }).exited; },
    async ask(question, fallback) {
      if (!process.stdin.isTTY) return fallback;
      const { createInterface } = await import("node:readline/promises");
      const reader = createInterface({ input: process.stdin, output: process.stdout });
      try { return (await reader.question(question)).trim() || fallback; } finally { reader.close(); }
    },
  };
}
export async function runMemory(args: CommandArgs, supplied: Partial<MemoryDependencies> = {}): Promise<void> {
  const defaults = defaultMemoryDependencies();
  const deps = { ...defaults, ...supplied };
  // Injected output callbacks also capture the existing boxed presentation in the CLI tests.
  if (supplied.log && !supplied.box) deps.box = lines => { for (const line of boxLines(lines)) supplied.log!(line); };
  const code = await runModuleMemory(args, deps);
  if (code) process.exitCode = code;
}
