// mlx-bun memory — the synthesis event contract every stage emits.
//
// Lives in its own leaf module so the stage workers (chunk / ingest / stages)
// and the orchestrator (pipeline) share one event type without an import cycle.

export type SynthesisStage =
  | "ingest"
  | "segment"
  | "chunk"
  | "extract"
  | "route"
  | "create"
  | "section-route"
  | "patch"
  | "reconcile"
  | "link"
  | "wikify"
  | "commit";

export interface SynthesisEvent {
  type: "stage" | "log" | "done";
  stage?: SynthesisStage;
  message: string;
}
