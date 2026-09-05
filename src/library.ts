/** CPU-safe high-level entry. Native modules load only after bootstrap. */
export { createInferenceEngine } from "./engine/engine";
export { CancellationSource } from "./engine/cancellation";
export { createCompletionClient, createDirectHost } from "./client";
export type * from "./contracts/generation";
export type * from "./contracts/completion";
export type * from "./contracts/host";

/** Install/locate the native pack before importing the compatibility API. */
export async function initializeMlx(): Promise<typeof import("./index")> {
  const { ensureNativeRuntime } = await import("./native-pack");
  await ensureNativeRuntime();
  return import("./index");
}

/** Own one local worker. Model resolution and native initialization remain in
 * the existing CLI; importing this module does not start it or download weights. */
export async function openIsolatedHost(model: string, options: {
  arguments?: readonly string[];
  command?: readonly string[];
  readyTimeoutMs?: number;
} = {}): Promise<import("./contracts/host").EngineHost<Request, Response>> {
  const { EngineChild } = await import("./serve/isolate");
  const { tmpdir } = await import("node:os");
  const { join } = await import("node:path");
  const { fileURLToPath } = await import("node:url");
  const source = fileURLToPath(new URL("./cli.ts", import.meta.url));
  if (!options.command && source.includes("$bunfs"))
    throw new Error("a compiled library consumer must supply the mlx-bun executable as command");
  const command = options.command ?? [process.execPath, source];
  if (!command.length) throw new Error("engine command must not be empty");
  const socketPath = join(tmpdir(), `mlx-bun-library-${crypto.randomUUID()}.sock`);
  const host = new EngineChild({
    argv: [...command,
      "serve", "--model", model, ...options.arguments ?? [], "--unix", socketPath, "--no-open"],
    socketPath, readyTimeoutMs: options.readyTimeoutMs,
  });
  try { await host.ready; return host; }
  catch (error) { await host.close(); throw error; }
}
