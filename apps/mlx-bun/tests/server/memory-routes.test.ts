import { afterEach, beforeEach, describe, expect, test } from "bun:test";
import { access, mkdtemp, mkdir, readdir, writeFile, rm, symlink, readlink, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createMemoryRoutes } from "../../src/server/memory-routes";

let routeRoot = "";
/** Nightly launchd state injected through the seam; the real launchctl is never consulted. */
let schedule = { installed: false, plistPath: "/home/Library/LaunchAgents/com.mlx-bun.memory.plist", loaded: false, at: null as { hour: number; minute: number } | null, note: "the job runs mlx-bun memory synthesize and needs a serving mlx-bun (mlx-bun serve) at that time" };
let scheduleProbes = 0;
const routes = createMemoryRoutes({ root: () => routeRoot, schedule: async () => { scheduleProbes++; return schedule; } });
async function call(input: URL | Request): Promise<Response> {
  const response = await routes.handle(input instanceof Request ? input : new Request(input));
  if (!response) throw new Error("Expected a memory route");
  return response;
}
let root = "";

async function runGit(args: string[], cwd: string): Promise<void> {
  const proc = Bun.spawn(["git", ...args], { cwd, stdout: "ignore", stderr: "ignore" });
  const code = await proc.exited;
  if (code !== 0) throw new Error(`git ${args.join(" ")} failed (${code})`);
}

/** Fresh vault: articles/{Alpha,Beta}.md (Beta links to Alpha), a
 *  Reference/ doc, git-initialized with two commits so history/diff have
 *  something real to read. */
async function seedVault(): Promise<string> {
  const dir = await mkdtemp(join(tmpdir(), "mlxbun-memrest-"));
  await mkdir(join(dir, "articles"), { recursive: true });
  await mkdir(join(dir, "Reference"), { recursive: true });

  await writeFile(
    join(dir, "articles", "Alpha.md"),
    "# Alpha\n\n```info\ntype: thing\nkind: thing\n```\n\nThe **Alpha** is a test article.\n\n## See also\n\n## References\n",
  );
  await runGit(["init"], dir);
  await runGit(["config", "user.email", "test@example.com"], dir);
  await runGit(["config", "user.name", "Test"], dir);
  await runGit(["add", "."], dir);
  await runGit(["commit", "-m", "Add Alpha"], dir);

  await writeFile(
    join(dir, "articles", "Beta.md"),
    "# Beta\n\nThe **Beta** article links to [[Alpha]].\n\n## References\n",
  );
  await writeFile(join(dir, "Reference", "Doc_One.md"), "# Doc One\n\nA reference document.\n");
  await runGit(["add", "."], dir);
  await runGit(["commit", "-m", "Add Beta + reference doc"], dir);

  // A second commit touching Alpha so history/diff have >1 entry to pick from.
  await writeFile(
    join(dir, "articles", "Alpha.md"),
    "# Alpha\n\n```info\ntype: thing\nkind: thing\n```\n\nThe **Alpha** is a test article, revised.\n\n## See also\n\n## References\n",
  );
  await runGit(["add", "."], dir);
  await runGit(["commit", "-m", "Revise Alpha"], dir);

  return dir;
}

beforeEach(async () => {
  root = await seedVault();
  routeRoot = root;
});

afterEach(async () => {
  await rm(root, { recursive: true, force: true });
});

describe("GET /api/memory/status", () => {
  test("enabled vault returns article/reference counts + git state + the nightly schedule", async () => {
    scheduleProbes = 0;
    const res = await call(new URL("http://x/api/memory/status"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.enabled).toBe(true);
    expect(body.status.articleCount).toBe(2);
    expect(body.status.referenceCount).toBe(1);
    expect(body.status.isGitRepo).toBe(true);
    expect(body.schedule).toEqual({ installed: false, plistPath: schedule.plistPath, loaded: false, at: null, note: schedule.note });
    schedule = { ...schedule, installed: true, loaded: true, at: { hour: 4, minute: 30 } };
    const installed = (await (await call(new URL("http://x/api/memory/status"))).json()) as any;
    expect(installed.schedule).toEqual({ installed: true, plistPath: schedule.plistPath, loaded: true, at: { hour: 4, minute: 30 }, note: schedule.note });
    expect(scheduleProbes).toBe(2);
  });

  test("no vault → enabled:false, never throws, and never probes the schedule", async () => {
    routeRoot = join(tmpdir(), "mlxbun-memrest-does-not-exist");
    scheduleProbes = 0;
    const res = await call(new URL("http://x/api/memory/status"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
    expect(body.enabled).toBe(false);
    expect(body.schedule).toBeUndefined();
    expect(scheduleProbes).toBe(0);
  });
});

describe("GET /api/memory/list", () => {
  test("separates articles from Reference/ docs", async () => {
    const res = await call(new URL("http://x/api/memory/list"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.articles.sort()).toEqual(["Alpha", "Beta"]);
    expect(body.reference).toEqual(["Reference/Doc_One"]);
  });

  test("no vault → ok:false shape", async () => {
    routeRoot = join(tmpdir(), "mlxbun-memrest-does-not-exist");
    const res = await call(new URL("http://x/api/memory/list"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
    expect(body.enabled).toBe(false);
  });
});

describe("GET /api/memory/search", () => {
  test("finds the article containing the query term", async () => {
    const res = await call(new URL("http://x/api/memory/search?q=Beta"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.summaries.some((s: any) => s.article === "Beta")).toBe(true);
  });

  test("missing q → 400 error, not a throw", async () => {
    const res = await call(new URL("http://x/api/memory/search"));
    expect(res.status).toBe(400);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
  });
});

describe("GET /api/memory/article", () => {
  test("returns rendered source + parsed metadata", async () => {
    const res = await call(new URL("http://x/api/memory/article?name=Alpha"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.content).toContain("Alpha");
    expect(body.infobox.entityKind).toBe("thing");
    expect(body.lead).toContain("Alpha");
  });

  test("unknown article → 404, ok:false", async () => {
    const res = await call(new URL("http://x/api/memory/article?name=Nonexistent"));
    expect(res.status).toBe(404);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
  });
});

describe("GET /api/memory/links", () => {
  test("Beta's outbound link to Alpha shows up both directions", async () => {
    const beta = await call(new URL("http://x/api/memory/links?name=Beta"));
    const betaBody = (await beta.json()) as any;
    expect(betaBody.ok).toBe(true);
    expect(betaBody.outbound).toEqual(["Alpha"]);

    const alpha = await call(new URL("http://x/api/memory/links?name=Alpha"));
    const alphaBody = (await alpha.json()) as any;
    expect(alphaBody.inbound).toEqual(["Beta"]);
  });
});

describe("GET /api/memory/history", () => {
  test("Alpha has two commits (create + revise), newest first", async () => {
    const res = await call(new URL("http://x/api/memory/history?name=Alpha"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.entries.length).toBe(2);
    expect(body.entries[0].subject).toBe("Revise Alpha");
    expect(body.entries[0].hash).toMatch(/^[0-9a-f]{40}$/);
    expect(body.entries[1].subject).toBe("Add Alpha");
  });

  test("Beta has one commit", async () => {
    const res = await call(new URL("http://x/api/memory/history?name=Beta"));
    const body = (await res.json()) as any;
    expect(body.entries.length).toBe(1);
  });

  test("unknown article → 404", async () => {
    const res = await call(new URL("http://x/api/memory/history?name=Nonexistent"));
    expect(res.status).toBe(404);
  });
});

describe("GET /api/memory/diff", () => {
  test("valid rev + name returns a diff containing the revised text", async () => {
    const histRes = await call(new URL("http://x/api/memory/history?name=Alpha"));
    const hist = (await histRes.json()) as any;
    const latestRev = hist.entries[0].hash;

    const res = await call(new URL(`http://x/api/memory/diff?name=Alpha&rev=${latestRev}`));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.diff).toContain("revised");
  });

  test("rev failing the hex-hash shape is rejected before touching git", async () => {
    for (const bad of ["HEAD~1", "main^", "; rm -rf /", "abc", "not-a-hash"]) {
      const res = await call(new URL(`http://x/api/memory/diff?name=Alpha&rev=${encodeURIComponent(bad)}`));
      expect(res.status).toBe(400);
      const body = (await res.json()) as any;
      expect(body.ok).toBe(false);
    }
  });

  test("path-traversal name is rejected (normalizeBareStem throws → 404, no shell reached)", async () => {
    const res = await call(
      new URL(`http://x/api/memory/diff?name=${encodeURIComponent("../../etc/passwd")}&rev=abcd`),
    );
    expect(res.status).toBe(404);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
  });

  test("missing rev or name → 400", async () => {
    const noRev = await call(new URL("http://x/api/memory/diff?name=Alpha"));
    expect(noRev.status).toBe(400);
    const noName = await call(new URL("http://x/api/memory/diff?rev=abcd1234"));
    expect(noName.status).toBe(400);
  });
});

describe("POST /api/memory/init", () => {
  test("initialization preserves external article, Talk, and unseeded Reference directory links", async () => {
    const outside = await mkdtemp(join(tmpdir(), "mlxbun-memrest-linked-"));
    try {
      for (const name of ["articles", "Talk", "Reference"]) {
        const destination = join(outside, name);
        await mkdir(destination);
        await writeFile(join(destination, "Existing.md"), "User content");
        await rm(join(root, name), { recursive: true, force: true });
        await symlink(destination, join(root, name));
      }
      expect((await call(new Request("http://x/api/memory/init", { method: "POST", body: "{}" }))).status).toBe(200);
      for (const name of ["articles", "Talk", "Reference"]) {
        expect(await readdir(join(outside, name))).toEqual(["Existing.md"]);
        expect(await readFile(join(outside, name, "Existing.md"), "utf8")).toBe("User content");
        expect(await readlink(join(root, name))).toBe(join(outside, name));
      }
    } finally { await rm(outside, { recursive: true, force: true }); }
  });

  test("initialization can write Meta pages through an internal directory symlink", async () => {
    const internal = join(root, "InternalMeta");
    await mkdir(internal);
    await symlink(internal, join(root, "Meta"));
    const response = await call(new Request("http://x/api/memory/init", { method: "POST", body: "{}" }));
    expect(response.status).toBe(200);
    expect(await readlink(join(root, "Meta"))).toBe(internal);
    expect(await readFile(join(internal, "Editorial_Guidelines.md"), "utf8")).toContain("Editorial");
  });

  test("only explicitly supplied reference sources are seeded and default re-init leaves existing links unchanged", async () => {
    const fresh = join(root, "new-vault");
    const source = join(root, "approved.md"), replacement = join(root, "replacement.md");
    await writeFile(source, "# Approved reference");
    await writeFile(replacement, "# Explicit replacement");
    const seeded = createMemoryRoutes({ root: () => fresh,
      referenceSources: [{ name: "Approved_Guide", source }] });
    const request = () => new Request("http://x/api/memory/init", { method: "POST", body: "{}" });
    const result = await (await seeded.handle(request()))!.json();
    const link = join(fresh, "Reference", "Approved_Guide.md");
    expect(result.result.created).toContain(link);
    expect(await readdir(join(fresh, "Reference"))).toEqual(["Approved_Guide.md"]);
    expect(await readlink(link)).toBe(source);
    // A legacy link must not be silently repointed at the app README.
    const legacy = join(fresh, "Reference", "mlx-bun_README.md");
    await symlink(source, legacy);
    const unseeded = createMemoryRoutes({ root: () => fresh });
    const unchanged = await (await unseeded.handle(request()))!.json();
    expect(unchanged.result.created).toEqual([]);
    expect(await readlink(legacy)).toBe(source);
    expect(await readlink(link)).toBe(source);
    const replace = createMemoryRoutes({ root: () => fresh,
      referenceSources: [{ name: "Approved_Guide", source: replacement }] });
    expect((await replace.handle(request()))!.status).toBe(200);
    expect(await readlink(link)).toBe(replacement);
    expect(await readlink(legacy)).toBe(source);
  });

  test("reference seeding rejects an external directory without writing links there", async () => {
    const outside = await mkdtemp(join(tmpdir(), "mlxbun-memrest-seeds-"));
    try {
      const source = join(root, "approved.md");
      await writeFile(source, "# Approved");
      await rm(join(root, "Reference"), { recursive: true });
      await symlink(outside, join(root, "Reference"));
      const seeded = createMemoryRoutes({ root: () => root, referenceSources: [{ name: "Approved", source }] });
      expect((await seeded.handle(new Request("http://x/api/memory/init", { method: "POST", body: "{}" })))!.status).toBe(400);
      expect(await readdir(outside)).toEqual([]);
    } finally { await rm(outside, { recursive: true, force: true }); }
  });

  test("invalid JSON shapes and path types return 400 without initializing a vault", async () => {
    const fresh = join(root, "not-created");
    routeRoot = fresh;
    for (const body of ["null", "[]", "42", "{", JSON.stringify({ path: 42 }), JSON.stringify({ path: null })]) {
      const res = await call(new Request("http://x/api/memory/init", { method: "POST", body }));
      expect(res.status).toBe(400); expect((await res.json()).ok).toBe(false);
      await expect(access(fresh)).rejects.toThrow();
    }
  });

  test("initialization cannot write through an escaping child directory or dangling file symlink", async () => {
    const outside = await mkdtemp(join(tmpdir(), "mlxbun-memrest-outside-"));
    try {
      await symlink(outside, join(root, "Meta"));
      const init = () => call(new Request("http://x/api/memory/init", { method: "POST", body: "{}" }));
      expect((await init()).status).toBe(400);
      expect(await readdir(outside)).toEqual([]);
      await rm(join(root, "Meta"));
      await symlink(join(outside, "new-file.md"), join(root, "README.md"));
      expect((await init()).status).toBe(400);
      expect(await readdir(outside)).toEqual([]);
    } finally { await rm(outside, { recursive: true, force: true }); }
  });

  test("initialization preserves intentional read-only Reference document symlinks", async () => {
    const outside = await mkdtemp(join(tmpdir(), "mlxbun-memrest-reference-"));
    try {
      await writeFile(join(outside, "guide.md"), "# External guide\n\nRead-only reference.\n");
      await symlink(join(outside, "guide.md"), join(root, "Reference", "External_Guide.md"));
      expect((await call(new Request("http://x/api/memory/init", { method: "POST", body: "{}" }))).status).toBe(200);
      const read = await call(new URL("http://x/api/memory/article?name=Reference/External_Guide"));
      expect((await read.json()).content).toContain("Read-only reference.");
    } finally { await rm(outside, { recursive: true, force: true }); }
  });

  test("creates a fresh vault at an explicit path (delegates to setupVault)", async () => {
    const fresh = await mkdtemp(join(tmpdir(), "mlxbun-memrest-init-"));
    await rm(fresh, { recursive: true, force: true }); // setupVault creates it
    try {
      const req = new Request("http://x/api/memory/init", {
        method: "POST",
        body: JSON.stringify({ path: fresh }),
      });
      const res = await call(req);
      const body = (await res.json()) as any;
      expect(body.ok).toBe(true);
      expect(body.result.root).toBe(fresh);
      expect(body.result.gitInitialized).toBe(true);
      expect(body.status.exists).toBe(true);
    } finally {
      await rm(fresh, { recursive: true, force: true });
    }
  });

  test("idempotent: re-running against an already-set-up vault is a no-op", async () => {
    const req = new Request("http://x/api/memory/init", {
      method: "POST",
      body: JSON.stringify({ path: root }),
    });
    const res = await call(req);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    // Meta pages etc. already exist from the fixture's own git history plus
    // setupVault's own writeIfMissing guards — no articles/README clobbered.
    expect(body.status.articleCount).toBe(2);
  });

  test("no body uses the injected vault root", async () => {
    const req = new Request("http://x/api/memory/init", { method: "POST" });
    const res = await call(req);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.result.root).toBe(root);
  });

  test("rejects a path outside the vault root / temp trees (no mkdir, no git init)", async () => {
    // Sibling of the seeded vault dir, itself under tmpdir() but not created —
    // still rejected because it isn't under the *default* vaultRoot() and we
    // exercise the reject path with something that would exist for real: an
    // absolute path with no relation to either allowed tree.
    const outside = "/var/mlxbun-memrest-should-not-exist";
    const req = new Request("http://x/api/memory/init", {
      method: "POST",
      body: JSON.stringify({ path: outside }),
    });
    const res = await call(req);
    expect(res.status).toBe(400);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
    // Confirm setupVault() never ran against it.
    const { access } = await import("node:fs/promises");
    await expect(access(outside)).rejects.toThrow();
  });
});


test("other routes and unsupported methods remain available to the next handler", async () => {
  for (const path of ["/v1/memory/synthesize", "/api/memory/unknown", "/v1/models"]) {
    expect(await routes.handle(new Request(`http://x${path}`))).toBeNull();
  }
  expect(await routes.handle(new Request("http://x/api/memory/init"))).toBeNull();
  expect(await routes.handle(new Request("http://x/api/memory/status", { method: "POST" }))).toBeNull();
});


test("init rejects a symlink escaping the allowed vault and temporary trees", async () => {
  const escape = join(root, "escape");
  await symlink("/", escape);
  const response = await call(new Request("http://x/api/memory/init", {
    method: "POST", body: JSON.stringify({ path: join(escape, "var", "mlx-memory-should-not-exist") }),
  }));
  expect(response.status).toBe(400);
});


describe("GET /v1/memory/synthesize (present only when composition supplies the pipeline)", () => {
  function synthesizer() {
    const calls: { dryRun: boolean; signal?: AbortSignal }[] = [];
    const routes = createMemoryRoutes({ root: () => routeRoot, synthesize: async (options, onEvent) => {
      calls.push(options);
      onEvent({ type: "stage", stage: "ingest", message: "ingest: planned (dry-run)" });
      onEvent({ type: "done", message: "dry-run complete — no articles written." });
      return { implemented: true, stages: ["ingest"], note: "dry-run: DAG wired; no model calls made." };
    } });
    return { calls, routes };
  }

  test("streams every event, then the summary and [DONE], as SSE; ?dry=1 plans only", async () => {
    const { calls, routes: synth } = synthesizer();
    const res = await synth.handle(new Request("http://x/v1/memory/synthesize?dry=1"));
    expect(res).not.toBeNull();
    expect(res!.status).toBe(200);
    expect(res!.headers.get("content-type")).toBe("text/event-stream");
    expect(res!.headers.get("cache-control")).toBe("no-cache");
    const frames = (await res!.text()).split("\n\n").filter(Boolean);
    expect(frames).toEqual([
      'data: {"type":"stage","stage":"ingest","message":"ingest: planned (dry-run)"}',
      'data: {"type":"done","message":"dry-run complete — no articles written."}',
      'data: {"type":"summary","implemented":true,"stages":["ingest"],"note":"dry-run: DAG wired; no model calls made."}',
      "data: [DONE]",
    ]);
    expect(calls).toEqual([{ dryRun: true, signal: expect.any(AbortSignal) }]);
    await (await synth.handle(new Request("http://x/v1/memory/synthesize")))!.text();
    expect(calls[1]).toEqual({ dryRun: false, signal: expect.any(AbortSignal) });
  });

  test("a pipeline failure becomes a terminal error event instead of a broken stream", async () => {
    const failing = createMemoryRoutes({ root: () => routeRoot, synthesize: async (_options, onEvent) => {
      onEvent({ type: "log", message: "operating on 0 conversation(s)" });
      throw new Error("memory: no completion client configured");
    } });
    const res = await failing.handle(new Request("http://x/v1/memory/synthesize"));
    const frames = (await res!.text()).split("\n\n").filter(Boolean);
    expect(frames).toEqual([
      'data: {"type":"log","message":"operating on 0 conversation(s)"}',
      'data: {"type":"error","message":"memory: no completion client configured"}',
    ]);
  });

  test("only GET is routed; the read-only factory without a pipeline still yields null", async () => {
    const { routes: synth } = synthesizer();
    expect(await synth.handle(new Request("http://x/v1/memory/synthesize", { method: "POST" }))).toBeNull();
    expect(await routes.handle(new Request("http://x/v1/memory/synthesize"))).toBeNull();
  });
});
