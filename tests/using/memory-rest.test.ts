// Memory REST wrappers (src/memory/rest.ts) — fast tier, no model context.
//
// Vault is a throwaway tmp dir with a handful of fixture articles plus a
// real `git init` + commits (never ~/Dreaming — the hard rule for this
// task). Handlers are called directly (they're plain (url|request) =>
// Response functions with no `ctx` dependency), matching src/server.ts's
// dispatch exactly — no need to boot a Bun.serve or load model weights.

import { afterEach, beforeEach, describe, expect, test } from "bun:test";
import { mkdtemp, mkdir, writeFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { configureRuntime } from "../../src/runtime-config";

let restoreWiki = () => {};
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
  restoreWiki = configureRuntime({ MLX_BUN_WIKI: root });
});

afterEach(async () => {
  restoreWiki();
  restoreWiki = () => {};
  await rm(root, { recursive: true, force: true });
});

describe("GET /api/memory/status", () => {
  test("enabled vault returns article/reference counts + git state", async () => {
    const { handleMemoryStatus } = await import("../../src/memory/rest");
    const res = await handleMemoryStatus();
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.enabled).toBe(true);
    expect(body.status.articleCount).toBe(2);
    expect(body.status.referenceCount).toBe(1);
    expect(body.status.isGitRepo).toBe(true);
  });

  test("no vault → enabled:false, never throws", async () => {
    configureRuntime({
      MLX_BUN_WIKI: join(tmpdir(), "mlxbun-memrest-does-not-exist"),
    });
    const { handleMemoryStatus } = await import("../../src/memory/rest");
    const res = await handleMemoryStatus();
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
    expect(body.enabled).toBe(false);
  });
});

describe("GET /api/memory/list", () => {
  test("separates articles from Reference/ docs", async () => {
    const { handleMemoryList } = await import("../../src/memory/rest");
    const res = await handleMemoryList();
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.articles.sort()).toEqual(["Alpha", "Beta"]);
    expect(body.reference).toEqual(["Reference/Doc_One"]);
  });

  test("no vault → ok:false shape", async () => {
    configureRuntime({
      MLX_BUN_WIKI: join(tmpdir(), "mlxbun-memrest-does-not-exist"),
    });
    const { handleMemoryList } = await import("../../src/memory/rest");
    const res = await handleMemoryList();
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
    expect(body.enabled).toBe(false);
  });
});

describe("GET /api/memory/search", () => {
  test("finds the article containing the query term", async () => {
    const { handleMemorySearch } = await import("../../src/memory/rest");
    const res = await handleMemorySearch(new URL("http://x/api/memory/search?q=Beta"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.summaries.some((s: any) => s.article === "Beta")).toBe(true);
  });

  test("missing q → 400 error, not a throw", async () => {
    const { handleMemorySearch } = await import("../../src/memory/rest");
    const res = await handleMemorySearch(new URL("http://x/api/memory/search"));
    expect(res.status).toBe(400);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
  });
});

describe("GET /api/memory/article", () => {
  test("returns rendered source + parsed metadata", async () => {
    const { handleMemoryArticle } = await import("../../src/memory/rest");
    const res = await handleMemoryArticle(new URL("http://x/api/memory/article?name=Alpha"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.content).toContain("Alpha");
    expect(body.infobox.entityKind).toBe("thing");
    expect(body.lead).toContain("Alpha");
  });

  test("unknown article → 404, ok:false", async () => {
    const { handleMemoryArticle } = await import("../../src/memory/rest");
    const res = await handleMemoryArticle(new URL("http://x/api/memory/article?name=Nonexistent"));
    expect(res.status).toBe(404);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
  });
});

describe("GET /api/memory/links", () => {
  test("Beta's outbound link to Alpha shows up both directions", async () => {
    const { handleMemoryLinks } = await import("../../src/memory/rest");
    const beta = await handleMemoryLinks(new URL("http://x/api/memory/links?name=Beta"));
    const betaBody = (await beta.json()) as any;
    expect(betaBody.ok).toBe(true);
    expect(betaBody.outbound).toEqual(["Alpha"]);

    const alpha = await handleMemoryLinks(new URL("http://x/api/memory/links?name=Alpha"));
    const alphaBody = (await alpha.json()) as any;
    expect(alphaBody.inbound).toEqual(["Beta"]);
  });
});

describe("GET /api/memory/history", () => {
  test("Alpha has two commits (create + revise), newest first", async () => {
    const { handleMemoryHistory } = await import("../../src/memory/rest");
    const res = await handleMemoryHistory(new URL("http://x/api/memory/history?name=Alpha"));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.entries.length).toBe(2);
    expect(body.entries[0].subject).toBe("Revise Alpha");
    expect(body.entries[0].hash).toMatch(/^[0-9a-f]{40}$/);
    expect(body.entries[1].subject).toBe("Add Alpha");
  });

  test("Beta has one commit", async () => {
    const { handleMemoryHistory } = await import("../../src/memory/rest");
    const res = await handleMemoryHistory(new URL("http://x/api/memory/history?name=Beta"));
    const body = (await res.json()) as any;
    expect(body.entries.length).toBe(1);
  });

  test("unknown article → 404", async () => {
    const { handleMemoryHistory } = await import("../../src/memory/rest");
    const res = await handleMemoryHistory(new URL("http://x/api/memory/history?name=Nonexistent"));
    expect(res.status).toBe(404);
  });
});

describe("GET /api/memory/diff", () => {
  test("valid rev + name returns a diff containing the revised text", async () => {
    const { handleMemoryHistory, handleMemoryDiff } = await import("../../src/memory/rest");
    const histRes = await handleMemoryHistory(new URL("http://x/api/memory/history?name=Alpha"));
    const hist = (await histRes.json()) as any;
    const latestRev = hist.entries[0].hash;

    const res = await handleMemoryDiff(new URL(`http://x/api/memory/diff?name=Alpha&rev=${latestRev}`));
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.diff).toContain("revised");
  });

  test("rev failing the hex-hash shape is rejected before touching git", async () => {
    const { handleMemoryDiff } = await import("../../src/memory/rest");
    for (const bad of ["HEAD~1", "main^", "; rm -rf /", "abc", "not-a-hash"]) {
      const res = await handleMemoryDiff(new URL(`http://x/api/memory/diff?name=Alpha&rev=${encodeURIComponent(bad)}`));
      expect(res.status).toBe(400);
      const body = (await res.json()) as any;
      expect(body.ok).toBe(false);
    }
  });

  test("path-traversal name is rejected (normalizeBareStem throws → 404, no shell reached)", async () => {
    const { handleMemoryDiff } = await import("../../src/memory/rest");
    const res = await handleMemoryDiff(
      new URL(`http://x/api/memory/diff?name=${encodeURIComponent("../../etc/passwd")}&rev=abcd`),
    );
    expect(res.status).toBe(404);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
  });

  test("missing rev or name → 400", async () => {
    const { handleMemoryDiff } = await import("../../src/memory/rest");
    const noRev = await handleMemoryDiff(new URL("http://x/api/memory/diff?name=Alpha"));
    expect(noRev.status).toBe(400);
    const noName = await handleMemoryDiff(new URL("http://x/api/memory/diff?rev=abcd1234"));
    expect(noName.status).toBe(400);
  });
});

describe("POST /api/memory/init", () => {
  test("creates a fresh vault at an explicit path (delegates to setupVault)", async () => {
    const { handleMemoryInit } = await import("../../src/memory/rest");
    const fresh = await mkdtemp(join(tmpdir(), "mlxbun-memrest-init-"));
    await rm(fresh, { recursive: true, force: true }); // setupVault creates it
    try {
      const req = new Request("http://x/api/memory/init", {
        method: "POST",
        body: JSON.stringify({ path: fresh }),
      });
      const res = await handleMemoryInit(req);
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
    const { handleMemoryInit } = await import("../../src/memory/rest");
    const req = new Request("http://x/api/memory/init", {
      method: "POST",
      body: JSON.stringify({ path: root }),
    });
    const res = await handleMemoryInit(req);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    // Meta pages etc. already exist from the fixture's own git history plus
    // setupVault's own writeIfMissing guards — no articles/README clobbered.
    expect(body.status.articleCount).toBe(2);
  });

  test("no body → defaults to vaultRoot() (the MLX_BUN_WIKI override in this test)", async () => {
    const { handleMemoryInit } = await import("../../src/memory/rest");
    const req = new Request("http://x/api/memory/init", { method: "POST" });
    const res = await handleMemoryInit(req);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(true);
    expect(body.result.root).toBe(root);
  });

  test("rejects a path outside the vault root / temp trees (no mkdir, no git init)", async () => {
    const { handleMemoryInit } = await import("../../src/memory/rest");
    // Sibling of the seeded vault dir, itself under tmpdir() but not created —
    // still rejected because it isn't under the *default* vaultRoot() and we
    // exercise the reject path with something that would exist for real: an
    // absolute path with no relation to either allowed tree.
    const outside = "/var/mlxbun-memrest-should-not-exist";
    const req = new Request("http://x/api/memory/init", {
      method: "POST",
      body: JSON.stringify({ path: outside }),
    });
    const res = await handleMemoryInit(req);
    expect(res.status).toBe(400);
    const body = (await res.json()) as any;
    expect(body.ok).toBe(false);
    // Confirm setupVault() never ran against it.
    const { access } = await import("node:fs/promises");
    await expect(access(outside)).rejects.toThrow();
  });
});
