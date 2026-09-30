import { fileURLToPath } from "node:url";
import { runMemory as runModuleMemory, type MemoryDependencies, type CommandArgs } from "@mlx-bun/module-memory/cli";
import { vaultRoot } from "@mlx-bun/module-memory/vault";
import { executablePath } from "../jobs/executable";
import { userHome } from "../storage/paths";
import { createInProcessMemoryClient } from "./memory-engine";
import { help } from "./args";
import { banner, boxLines, renderHelp, step, style } from "./terminal";
import pkg from "../../package.json" with { type: "json" };
export type { MemoryDependencies } from "@mlx-bun/module-memory/cli";

/** The app's executable, terminal and task-model adapters; memory policy belongs to its module. */
export function defaultMemoryDependencies(): MemoryDependencies {
  const entry = fileURLToPath(new URL("./main.ts", import.meta.url));
  return {
    log: console.log, error: console.error, banner: () => banner(pkg.version),
    box: lines => { for (const line of boxLines(lines)) console.log(line); }, step, style,
    help: () => renderHelp(help("memory")), vault: vaultRoot(), home: userHome(),
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
  await runModuleMemory(args, deps);
}
