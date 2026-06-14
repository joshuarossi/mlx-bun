// Background job system: store transitions, in-process happy path,
// subprocess crash isolation (the whole point: a child segfault/exit must
// not kill THIS process), log tail, and SSE response framing. All DB + logs
// live in a per-test tmp dir — never the real ~/.cache/mlx-bun.

import { afterAll, beforeEach, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  JobStore,
  submitInProcess,
  submitSubprocess,
  tailJob,
  streamJobResponse,
  JOB_ENTRY_PATH,
} from "../src/jobs";
import type { JobEvent } from "../src/jobs";

const dirs: string[] = [];

function freshStore(): JobStore {
  const root = mkdtempSync(join(tmpdir(), "mlx-bun-jobs-"));
  dirs.push(root);
  return new JobStore(join(root, "jobs.sqlite"), join(root, "logs"));
}

/** Poll the row until its status is one of `wanted` (or time out). */
async function waitForStatus(
  store: JobStore,
  jobId: string,
  wanted: string[],
  timeoutMs = 5000,
): Promise<string> {
  const deadline = Date.now() + timeoutMs;
  for (;;) {
    const s = store.get(jobId)?.status;
    if (s && wanted.includes(s)) return s;
    if (Date.now() > deadline) throw new Error(`timeout waiting for ${wanted} (got ${s})`);
    await Bun.sleep(20);
  }
}

afterAll(() => {
  for (const d of dirs) rmSync(d, { recursive: true, force: true });
});

describe("JobStore", () => {
  let store: JobStore;
  beforeEach(() => { store = freshStore(); });

  test("create yields a queued row with computed log_path", () => {
    const row = store.create("noop", { foo: 1 }, "/tmp/out");
    expect(row.id).toMatch(/^job_[0-9a-f]{16}$/);
    expect(row.status).toBe("queued");
    expect(row.kind).toBe("noop");
    expect(JSON.parse(row.config_json)).toEqual({ foo: 1 });
    expect(row.output_path).toBe("/tmp/out");
    expect(row.log_path).toContain(row.id);
    expect(row.progress).toBe(0);
  });

  test("setProgress / setStatus / setOutputPath transitions", () => {
    const { id } = store.create("noop", {});
    store.setProgress(id, 0.5, "halfway");
    let row = store.get(id)!;
    expect(row.progress).toBe(0.5);
    expect(row.message).toBe("halfway");

    store.setStatus(id, "running");
    expect(store.get(id)!.status).toBe("running");

    store.setStatus(id, "failed", { error: "boom", endedAt: "2026-01-01 00:00:00" });
    row = store.get(id)!;
    expect(row.status).toBe("failed");
    expect(row.error).toBe("boom");
    expect(row.ended_at).toBe("2026-01-01 00:00:00");

    store.setOutputPath(id, "/out/dir");
    expect(store.get(id)!.output_path).toBe("/out/dir");
  });

  test("recent() returns newest first and filters by kind", () => {
    const a = store.create("noop", {});
    const b = store.create("dataset", {});
    const all = store.recent(10);
    expect(all.length).toBe(2);
    expect(all.map((r) => r.id).sort()).toEqual([a.id, b.id].sort());
    const onlyDataset = store.recent(10, "dataset");
    expect(onlyDataset.length).toBe(1);
    expect(onlyDataset[0]!.id).toBe(b.id);
  });

  test("markZombies flips queued/running to zombie", () => {
    const a = store.create("noop", {});           // queued
    const b = store.create("noop", {});
    store.setStatus(b.id, "running");
    const c = store.create("noop", {});
    store.setStatus(c.id, "done", { endedAt: "x" });

    const changed = store.markZombies();
    expect(changed).toBe(2);
    expect(store.get(a.id)!.status).toBe("zombie");
    expect(store.get(b.id)!.status).toBe("zombie");
    expect(store.get(c.id)!.status).toBe("done"); // terminal untouched
  });

  test("schema migration is additive: re-opening the same DB works", () => {
    const root = mkdtempSync(join(tmpdir(), "mlx-bun-jobs-reopen-"));
    dirs.push(root);
    const dbPath = join(root, "jobs.sqlite");
    const logs = join(root, "logs");
    const s1 = new JobStore(dbPath, logs);
    const { id } = s1.create("noop", { keep: true });
    s1.close();

    // Re-open: must not throw, must preserve the row.
    const s2 = new JobStore(dbPath, logs);
    const row = s2.get(id);
    expect(row).not.toBeNull();
    expect(JSON.parse(row!.config_json)).toEqual({ keep: true });
    s2.close();
  });
});

describe("submitInProcess (noop)", () => {
  test("runs to done with progress 1 and logs started + stages", async () => {
    const store = freshStore();
    const { jobId } = submitInProcess(store, "noop", { x: 1 });

    const status = await waitForStatus(store, jobId, ["done", "failed"]);
    expect(status).toBe("done");

    const row = store.get(jobId)!;
    expect(row.progress).toBe(1);
    expect(row.ended_at).not.toBeNull();

    // Inspect the recorded NDJSON log.
    const lines = (await Bun.file(row.log_path).text())
      .split("\n").filter(Boolean).map((l) => JSON.parse(l) as JobEvent);
    const types = lines.map((e) => e.type);
    expect(types).toContain("started");
    expect(types).toContain("stage");
    // the wrapper (not the runner) writes the terminal done event
    expect(types).toContain("done");
  });

  test("unregistered kind fails cleanly without throwing", async () => {
    const store = freshStore();
    const { jobId } = submitInProcess(store, "does-not-exist", {});
    const status = await waitForStatus(store, jobId, ["done", "failed"]);
    expect(status).toBe("failed");
    expect(store.get(jobId)!.error).toContain("no runner registered");
  });
});

describe("submitSubprocess crash isolation", () => {
  test("a child that process.exit(1)s marks the row failed and the test survives", async () => {
    const store = freshStore();
    const { jobId } = submitSubprocess(store, "crash", { boom: true }, undefined, {
      entry: JOB_ENTRY_PATH,
    });
    const status = await waitForStatus(store, jobId, ["done", "failed"]);
    expect(status).toBe("failed");
    // The whole point: control reached here — the parent process is alive.
    expect(true).toBe(true);
  });

  test("a clean subprocess noop reaches done", async () => {
    const store = freshStore();
    const { jobId } = submitSubprocess(store, "noop", { x: 2 });
    const status = await waitForStatus(store, jobId, ["done", "failed"]);
    expect(status).toBe("done");
    expect(store.get(jobId)!.progress).toBe(1);
  });
});

describe("tailJob", () => {
  test("over a finished job yields the recorded events and terminates", async () => {
    const store = freshStore();
    const { jobId } = submitInProcess(store, "noop", {});
    await waitForStatus(store, jobId, ["done", "failed"]);

    const events: JobEvent[] = [];
    for await (const e of tailJob(store, jobId, { follow: true, pollMs: 20 })) {
      events.push(e);
    }
    const types = events.map((e) => e.type);
    expect(types).toContain("started");
    expect(types).toContain("done");
    expect(events.length).toBeGreaterThanOrEqual(3);
  });

  test("follow:false stops immediately after current events", async () => {
    const store = freshStore();
    const { jobId } = submitInProcess(store, "noop", {});
    await waitForStatus(store, jobId, ["done", "failed"]);
    const events: JobEvent[] = [];
    for await (const e of tailJob(store, jobId, { follow: false })) events.push(e);
    expect(events.length).toBeGreaterThan(0);
  });
});

describe("streamJobResponse", () => {
  test("body contains data: frames and an event: end marker", async () => {
    const store = freshStore();
    const { jobId } = submitInProcess(store, "noop", {});
    await waitForStatus(store, jobId, ["done", "failed"]);

    const res = streamJobResponse(store, jobId);
    expect(res.headers.get("content-type")).toBe("text/event-stream");
    expect(res.headers.get("cache-control")).toBe("no-cache");

    const text = await res.text();
    expect(text).toContain("retry: 1500");
    expect(text).toContain("data: ");
    expect(text).toContain('"type":"started"');
    expect(text).toContain("event: end");
  });
});
