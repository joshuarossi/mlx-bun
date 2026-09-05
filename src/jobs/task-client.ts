import type { TaskClient } from "../contracts/completion";
import { throwIfCancelled } from "../engine/cancellation";
import type { JobEvent, JobRunner } from "./types";

/** Numerical runners retain their artifact policy; the client owns delivery
 * and cooperative cancellation at progress boundaries. No event buffering. */
export function createJobTaskClient(runner: JobRunner): TaskClient<
  Record<string, unknown>, JobEvent, { outputPath?: string } | void
> {
  return {
    async run(request, report, cancellation) {
      const check = () => { if (cancellation) throwIfCancelled(cancellation); };
      check();
      const result = await runner((event) => { check(); report(event); check(); }, request);
      check();
      return result;
    },
  };
}
