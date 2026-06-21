// mlx-bun memory — synthesis pipeline orchestrator.  ⚠️ M1 STUB.
//
// Ties the stages together: ingest → chunk → cluster → synthesize → wikify →
// changelog (the lucien nightly chain, reimplemented on the local model). What
// `mlx-bun memory synthesize` and the nightly launchd job invoke.
//
// CURRENTLY A NO-OP: it logs each stage as stubbed and writes nothing, so the
// scheduled job runs cleanly tonight and every night without touching your
// vault. When M1 lands, flip runSynthesis to actually call the stage modules
// (each currently throws "not implemented") and move it onto the src/jobs/*
// background runner with SSE progress, per the design doc.
//
// See docs/design/memory-system.md → "The nightly pipeline".

export type SynthesisStage = "ingest" | "chunk" | "cluster" | "synthesize" | "wikify" | "changelog";

export interface SynthesisEvent {
  type: "stage" | "log" | "done";
  stage?: SynthesisStage;
  message: string;
}

export interface SynthesisOptions {
  /** Only synthesize conversations newer than this (ISO date / conv cursor). */
  since?: string;
  /** Override the synthesis model (default e4b). */
  model?: string;
  /** Plan only — never write the vault. */
  dryRun?: boolean;
}

export interface SynthesisSummary {
  /** False while stubbed; flip to true when the stages are implemented. */
  implemented: boolean;
  stages: SynthesisStage[];
  note: string;
}

const STAGES: SynthesisStage[] = ["ingest", "chunk", "cluster", "synthesize", "wikify", "changelog"];

/**
 * Run the synthesis pipeline. STUB: walks the stage list, emits a `stage` event
 * for each (marked skipped), and returns implemented:false. Deterministic and
 * side-effect-free, so it's safe for the nightly job to call today.
 */
export async function runSynthesis(
  opts: SynthesisOptions = {},
  onEvent?: (e: SynthesisEvent) => void,
): Promise<SynthesisSummary> {
  onEvent?.({
    type: "log",
    message: `memory synthesis is not implemented yet (M1)${opts.dryRun ? " · dry-run" : ""} — running as a no-op, nothing will be written.`,
  });
  for (const stage of STAGES) {
    onEvent?.({ type: "stage", stage, message: `${stage}: stubbed (skipped)` });
  }
  onEvent?.({ type: "done", message: "no articles were written (synthesis is stubbed)." });
  return {
    implemented: false,
    stages: STAGES,
    note: "M1 stub — pipeline + scheduling wired; stage modules not implemented.",
  };
}
