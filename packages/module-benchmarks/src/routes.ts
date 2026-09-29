// The module's HTTP handlers, declared in `manifest.ts` and mounted by the
// host under `/api/benchmarks`. They read the history directory, ask the runner
// for its task list and comparison, and drive the job service; none loads a
// model or scores anything.
import type { JobRecord, JobService, RouteHandler } from "@mlx-bun/app-core";
import { compareRuns, listHistory, listTasks, readHistory, resolveModel, taskSpec, type EvalOptions } from "./evals";
import type { BenchmarkJob } from "./protocol";

export interface BenchmarkRoutesOptions {
  evals: EvalOptions;
  jobs: JobService;
}

const JOB_KIND = "eval-serve";
const message = (failure: unknown) => failure instanceof Error ? failure.message : String(failure);
const error = (text: string, status: number) => Response.json({ error: { message: text, type: status >= 500 ? "server_error" : "invalid_request_error" } }, { status });
const job = (record: JobRecord): BenchmarkJob => ({ id: record.id, status: record.status, progress: record.progress, message: record.message, error: record.error,
  startedAt: record.startedAt, endedAt: record.endedAt });
const idOf = (request: Request) => new URL(request.url).pathname.split("/").at(-1) ?? "";

export function createBenchmarkRoutes(options: BenchmarkRoutesOptions) {
  const { evals, jobs } = options;
  const evalJob = async (id: string) => {
    const record = await jobs.get(id);
    return record?.kind === JOB_KIND ? record : undefined;
  };

  return {
    tasks: (async () => {
      try { return Response.json(await listTasks(evals)); } catch (failure) { return error(message(failure), 503); }
    }) as RouteHandler,
    "run-start": (async request => {
      let body: Record<string, unknown>;
      try { body = await request.json() as Record<string, unknown>; } catch { return error("body must be JSON", 400); }
      if (!body || typeof body !== "object" || Array.isArray(body)) return error("body must be a JSON object", 400);
      // Only what a request may choose: a plan or a data directory carries paths the runner opens, so a job's own config takes those, never a request.
      const { model, enableThinking } = body;
      if (model !== undefined && typeof model !== "string") return error("model must be a string", 400);
      if (enableThinking !== undefined && typeof enableThinking !== "boolean") return error("enableThinking must be a boolean", 400);
      let tasks: string;
      try { tasks = taskSpec(body); await resolveModel(evals, { ...(model ? { model } : {}) }); }
      catch (failure) { return error(message(failure), 400); }
      try {
        return Response.json(job(await jobs.submit({ kind: JOB_KIND, config: { tasks, ...(model ? { model } : {}), ...(enableThinking !== undefined ? { enableThinking } : {}) } })), { status: 202 });
      } catch (failure) { return error(message(failure), 409); }
    }) as RouteHandler,
    history: (request => {
      const limit = Number(new URL(request.url).searchParams.get("limit") ?? "50");
      return Response.json({ runs: listHistory(evals.storage, Number.isFinite(limit) ? limit : 50) });
    }) as RouteHandler,
    run: (request => {
      const entry = readHistory(evals.storage, idOf(request));
      return entry ? Response.json(entry) : error("no such run", 404);
    }) as RouteHandler,
    compare: (async request => {
      const query = new URL(request.url).searchParams, ids = [query.get("base"), query.get("candidate")];
      if (!ids[0] || !ids[1]) return error("name two runs: `base` and `candidate` (see GET /runs)", 400);
      const [base, candidate] = ids.map(id => readHistory(evals.storage, id!));
      if (!base || !candidate) return error(`no such run: ${!base ? ids[0] : ids[1]}`, 404);
      try { return Response.json(await compareRuns(evals, base, candidate)); } catch (failure) { return error(message(failure), 500); }
    }) as RouteHandler,
    jobs: (async () => Response.json({ jobs: (await jobs.list({ kind: JOB_KIND })).map(job) })) as RouteHandler,
    job: (async request => {
      const record = await evalJob(idOf(request));
      return record ? Response.json(job(record)) : error("no such job", 404);
    }) as RouteHandler,
    "job-cancel": (async request => {
      const record = await evalJob(idOf(request));
      if (!record) return error("no such job", 404);
      await jobs.cancel(record.id);
      return Response.json(job((await jobs.get(record.id)) ?? record));
    }) as RouteHandler,
  } as const;
}
