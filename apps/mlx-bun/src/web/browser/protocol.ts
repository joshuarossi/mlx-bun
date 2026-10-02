import type { JobEvent } from "../../jobs/protocol";
export type { JobEvent } from "../../jobs/protocol";

/** Generic envelope every /api/* JSON endpoint returns on success or
 *  failure (api() in api.ts unwraps {error:{message}} to a plain string —
 *  see the doc-comment there). Individual endpoints add their own fields
 *  on top via intersection at the call site; this is just the shared base. */
export interface ApiEnvelope {
  ok?: boolean;
  error?: string;
  message?: string;
  [key: string]: unknown;
}
