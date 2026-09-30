import type { AppModule, CliInvocation, ModuleRuntime } from "@mlx-bun/app-core";
import { createMemoryChatModule } from "./chat";
import { runMemory, type MemoryDependencies } from "./cli";
import { manifest } from "./manifest";
import { userHome } from "./paths";
import { createMemoryRoutes } from "./routes";
import { createMemorySynthesis, type SynthesisClient } from "./synthesis";
export { manifest } from "./manifest";
export { createMemoryChatModule, memoryChatTools } from "./chat";
export type { MemoryChatPaths } from "./chat";
export { createMemoryRoutes } from "./routes";
export { createMemorySynthesis } from "./synthesis";
export type { SynthesisClient } from "./synthesis";
export type { MemoryCompletionClient, MemoryCompletionRequest } from "./model";

/** Host adapters for the existing dedicated task model and terminal/system integration. */
export interface MemoryModuleOptions {
  client?(signal: AbortSignal): SynthesisClient | Promise<SynthesisClient>;
  cli?(invocation: CliInvocation): MemoryDependencies;
}
export function createMemoryModule(options: MemoryModuleOptions = {}): AppModule<"storage" | "registry"> {
  return {
    ...manifest,
    activate({ services, signal }): ModuleRuntime {
      // Inspecting an absent vault must not create it or bypass its consent card.
      const vault = () => services.storage.path("vault", { create: false });
      const skills = () => services.storage.path("skills", { create: false });
      createMemoryChatModule({ vault: vault(), skills: skills() }).activate({ moduleId: "memory", services: { registry: services.registry }, signal });
      const unavailable = async (): Promise<string> => { throw new Error("memory synthesis has no task model in this composition"); };
      const synthesis = createMemorySynthesis({ root: vault(), dbPath: () => services.storage.path("db"),
        client: options.client ?? (() => ({ complete: unavailable, completeBatch: async () => { throw new Error("memory synthesis has no task model in this composition"); } })) });
      const routes = createMemoryRoutes({ root: vault, synthesize: synthesis.run });
      const verb = async (invocation: CliInvocation): Promise<number> => {
        const deps = options.cli?.(invocation) ?? {
          log: (line: string) => invocation.stdout(line + "\n"), error: (line: string) => invocation.stderr(line + "\n"),
          banner() {}, box: (lines: string[]) => invocation.terminal.box(lines), step: invocation.terminal.step,
          style: invocation.terminal.style, help: () => manifest.verbs[0].usage,
          vault: vault(), home: userHome(), program: ["mlx-bun"],
          ask: async (_question: string, fallback: string) => fallback,
          open: async (args: string[]) => await Bun.spawn(["open", ...args], { stdout: "ignore", stderr: "ignore" }).exited,
          taskModel: () => { throw new Error("memory: this host supplied no dedicated task-model adapter"); },
        };
        await runMemory(invocation, { ...deps, vault: vault(), dbPath: () => services.storage.path("db") });
        return 0;
      };
      return {
        routes: Object.fromEntries(manifest.routes.map(route => [route.id, async (request: Request) => await routes.handle(request) ?? new Response("not found", { status: 404 })])),
        verbs: { memory: verb, setup: verb },
        dispose: () => synthesis.close(),
      };
    },
  };
}
export default createMemoryModule();
