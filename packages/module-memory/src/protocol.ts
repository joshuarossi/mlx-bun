export interface ApiEnvelope { ok?: boolean; error?: string; message?: string; [key: string]: unknown }
export interface PanelConnection {
  readonly apiBase: string;
  readonly eventsUrl: string;
  /** The host's notifications; without them the panel's notices are dropped (the drawer shows its own errors in place). */
  readonly ui?: { notify?(message: string, kind?: "ok" | "err"): void };
}
