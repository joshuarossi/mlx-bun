import { appendFileSync } from "node:fs";
import type { Emit, JobEvent } from "./protocol";
import type { JobStore } from "./db";

export function makeEmit(store: JobStore, jobId: string, logPath: string): Emit {
  return (e: JobEvent) => {
    try {
      appendFileSync(logPath, JSON.stringify(e) + "\n");
    } catch {
      // swallow: a job must survive a logging hiccup
    }
    if (e.type === "stage" || e.type === "metric") {
      const progress = typeof e.progress === "number" ? e.progress : undefined;
      const message = typeof e.message === "string" ? e.message : undefined;
      if (progress !== undefined || message !== undefined) {
        try {
          if (progress !== undefined) store.setProgress(jobId, progress, message);
          else if (message !== undefined) {
            // message-only update preserves current progress
            store.db.prepare("UPDATE jobs SET message = ? WHERE id = ?").run(message, jobId);
          }
        } catch {
          // swallow: DB contention must not kill a job
        }
      }
    }
  };
}

