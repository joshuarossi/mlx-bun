// The public `mlx-bun/engine` entry (main's src/library.ts without
// `initializeMlx`): the embedding client, the portable token-session API, and
// `openIsolatedHost`, which owns one full-app worker process. Loading it loads
// no native module and starts nothing; the worker's composition is imported
// only when a host is opened (library-host.ts).
import type { EngineHost } from "../server/client";

export { createCompletionClient, createDirectHost } from "../server/client";
export type { BatchCompletionClient, CompletionCall, CompletionClient, CompletionResponse, EngineHost, TaskClient } from "../server/client";
export { createInferenceEngine } from "@mlx-bun/inference/execution/engine";
export { CancellationSource } from "@mlx-bun/inference/execution/cancellation";
export type {
  CancelReason, Cancellation, ExecutionPlan, ExecutionPlanner, GenerationEvent, GenerationOutcome, GenerationOutput,
  GenerationSession, InferenceEngine, InferenceMethod, MethodResult, MethodRun, RunControl, SessionState, Timer, TokenLogprobs,
} from "@mlx-bun/inference/contracts/portable";

/**
 * Start one mlx-bun app worker on a private Unix socket, running
 * `serve --model <model> ...arguments` through the CLI's own composition, and
 * resolve once it serves. The host forwards to the whole app.
 *
 * Refused before anything is spawned: a blank `model` (an empty query would
 * select a model automatically and may download the starter model), and any
 * `arguments` the CLI refuses, plus `--isolate` and `--model-pool`. `--host`,
 * `--port`, and `--no-open` are accepted and do not affect the socket.
 *
 * `command` is the program and leading arguments of an mlx-bun CLI of this
 * package version (the installed binary, `[bun, <package>/bin/mlx-bun.mjs]`, or
 * `[bun, <package>/src/cli/main.ts]`), spawned as `[...command, "__worker"]`.
 * An empty command is refused ("engine command must not be empty"). Omitted, it
 * is this package's CLI source under the current Bun, except in a compiled
 * consumer, which must supply one ("a compiled library consumer must supply
 * the mlx-bun executable as command"). A CLI of another package version
 * refuses the launch ("worker protocol version mismatch"); two builds with the
 * same package version are not told apart.
 *
 * A worker that fails before ready (a load failure, a refused launch, or
 * `readyTimeoutMs`, default 15 minutes) is stopped, its socket directory
 * removed, and the returned promise rejects with its error. A crash after
 * ready respawns within the CLI's restart budget.
 *
 * The host:
 * - `ready` follows the current worker: pending during a respawn, rejected
 *   ("engine restart limit reached") once the budget is spent, and rejected
 *   ("engine host is closed") after `close()`.
 * - `forward(request)` waits for a serving worker and sends nothing while it
 *   waits; an aborted request rejects with its signal's reason. Hop-by-hop
 *   headers are stripped both ways and both bodies stream. A GET or HEAD that
 *   fails is retried once after 250 ms; nothing else is replayed. After
 *   `close()` it rejects ("engine host is closed").
 * - `close()` returns one promise however often it is called: it aborts
 *   requests in flight, drains and stops the worker (SIGTERM, then SIGKILL
 *   after the CLI's shutdown deadline, `MLX_BUN_SHUTDOWN_TIMEOUT_MS`), waits
 *   for its exit, and then removes the socket directory.
 *
 * The worker's stdout and stderr lines reach this process's `console.log` and
 * `console.error`; restart notices go to `console.error`.
 */
export async function openIsolatedHost(model: string, options: {
  /** Serve arguments after `--model <model>`, as `mlx-bun serve` takes them. */
  arguments?: readonly string[];
  /** The mlx-bun CLI to run as the worker; required in a compiled consumer. */
  command?: readonly string[];
  /** How long the worker may take to report ready; default 15 minutes. */
  readyTimeoutMs?: number;
} = {}): Promise<EngineHost<Request, Response>> {
  return (await import("./library-host")).openLibraryHost(model, options);
}
