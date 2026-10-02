import type { CliTerminal, CliVerbSpec, JobRecord, JobSubmission } from "@mlx-bun/app-core";
import { createModuleRoutes, parseVerb } from "@mlx-bun/app-services";
import { createTrainHandlers, manifest, type TrainRouteServices } from "../src";

export const strip = (text: string) => text.replace(/\x1b\[[0-9;]*m/g, "");
/** A verb's arguments as the host parses them from the manifest. */
export const verbArgs = (name: string) => (...args: string[]) => parseVerb("mlx-bun", manifest.verbs.find(verb => verb.name === name) as unknown as CliVerbSpec, args);
/** The host's terminal: tests read what a verb writes, with no colour or border. */
export function fakeTerminal(logs: string[], steps: string[] = []): CliTerminal {
  return { step: text => { steps.push(`start:${text}`); return { update: t => steps.push(`update:${t}`), done: t => steps.push(`done:${t}`), fail: t => steps.push(`fail:${t}`) }; },
    box: lines => { logs.push(...lines); }, heading() {}, table() {},
    style: { dim: text => text, bold: text => text, green: text => text, accent: text => text, url: text => text, gradient: text => text } };
}

/** The module's routes as the host mounts them (by method and path), over fake services. */
export function trainRoutes(services: Partial<TrainRouteServices> & { submitted?: JobSubmission[] } = {}, defaultAdapterPath?: () => string) {
  const submitted = services.submitted ?? [];
  const handlers = createTrainHandlers({
    jobs: services.jobs ?? { async submit(submission) {
      submitted.push(submission);
      return { id: `job_${submitted.length}`, kind: submission.kind, status: "queued", progress: 0, message: null, outputPath: submission.outputPath ?? null,
        error: null, startedAt: "", endedAt: null } satisfies JobRecord;
    } },
    storage: services.storage ?? { path: key => `/store/${key}` },
  }, defaultAdapterPath);
  const routes = createModuleRoutes(manifest.routes.map(spec => ({ spec, path: spec.path, handler: handlers[spec.id] })));
  return { routes, submitted };
}
