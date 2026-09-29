// The module's data protocol: what its routes return and its panel reads. Plain
// types, no imports, so the panel (which imports only this file) loads in any webview.

/** One task the runner can evaluate (`eval-serve.ts tasks`). */
export interface BenchmarkTask {
  readonly id: string;
  /** The capability component the task feeds; the smoketest subset has none. */
  readonly component: string | null;
  /** The task sets that contain it: `capability`, `smoketest`, `all`. */
  readonly sets: readonly string[];
  /** Executes generated code, so it needs the Docker verifier; without one it is skipped as unverified. */
  readonly needsVerifier: boolean;
  /** The pinned dataset files the task reads, and whether each is in the module's data directory. */
  readonly datasets: readonly { readonly name: string; readonly rows: number; readonly sha256: string; readonly source: string; readonly present: boolean }[];
}

export interface BenchmarkTasks {
  readonly tasks: readonly BenchmarkTask[];
  /** Where the pinned dataset files must already be; the module never downloads them. */
  readonly dataDirectory: string;
}

/** One task of a finished run, reduced to its score. */
export interface TaskSummary {
  readonly task: string;
  readonly status: "complete" | "incomplete" | "skipped";
  /** Why it was skipped or incomplete. */
  readonly reason: string | null;
  /** 0 to 1; null when the task did not run. */
  readonly accuracy: number | null;
  readonly correct: number | null;
  readonly total: number | null;
  readonly wallMs: number;
}

/** A finished evaluation run, stored beside (never inside) the source tree. */
export interface EvalHistoryEntry {
  readonly id: string;
  readonly label: string;
  readonly startedAt: string;
  readonly finishedAt: string | null;
  readonly durationMs: number;
  /** Whether the runner judged every planned task complete and every pin intact; score acceptance stays unreviewed. */
  readonly complete: boolean;
  readonly exitCode: number;
  readonly problems: readonly string[];
  readonly model: { readonly path: string; readonly repo: string | null; readonly revision: string | null };
  readonly enableThinking: boolean;
  readonly machine: { readonly chip: string; readonly memoryBytes: number; readonly host: string; readonly os: string } | null;
  readonly tasks: readonly TaskSummary[];
  /** The runner's mean over the capability tasks that completed; the rest are named in `excluded`. */
  readonly capability: { readonly score: number; readonly components: Readonly<Record<string, number>>; readonly excluded: readonly string[] } | null;
  /** The run's own directory: `result.json` (with provenance), `samples.jsonl`, `report.md`, the server's log. */
  readonly runDirectory: string;
}

/** The paired comparison of two runs. */
export interface BenchmarkComparison {
  readonly base: string;
  readonly candidate: string;
  /** The runner's verdict: both runs complete and comparable. Differences are never accepted by a tolerance. */
  readonly comparable: boolean;
  /** Accuracy per task in either run. */
  readonly tasks: readonly { readonly task: string; readonly base: number | null; readonly candidate: number | null; readonly delta: number | null }[];
  /** `eval-serve.ts compare`'s report: every score difference, sample flip, skip and provenance mismatch. */
  readonly markdown: string;
}

/** What the panel and a client see of a launched run. */
export interface BenchmarkJob {
  readonly id: string;
  readonly status: string;
  readonly progress: number;
  readonly message: string | null;
  readonly error: string | null;
  readonly startedAt: string;
  readonly endedAt: string | null;
}

/** Set on the panel element's `connection` property before it connects (`PanelConnection` in app-core, restated because a panel imports only this file). */
export interface PanelConnection {
  /** Absolute or origin-relative base of `/api/benchmarks`. */
  readonly apiBase: string;
  /** The host's event stream; this panel polls its own routes and does not read it. */
  readonly eventsUrl: string;
}
