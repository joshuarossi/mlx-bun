import { realpath } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, resolve, sep } from "node:path";
import {
  vaultRoot, vaultStatus, listArticles, listReferenceDocs, readArticle,
  searchArticles, getArticleLinks, resolveArticleRelPath, articleHistory, articleDiff,
  setupVault, VaultPathError, type VaultStatus,
} from "../memory/vault";
import { parseInfobox, parseLead, parseSeriesBanner, articleStructure } from "../memory/article";

/** Request-only memory API. The caller supplies the vault root; no model or
 * listener is created, and the handler owns no long-lived resources. */
export function createMemoryRoutes(options: { root?: () => string } = {}) {
  const getRoot = options.root ?? vaultRoot;
  function jsonOk<T extends object>(body: T, init?: ResponseInit): Response {
    return Response.json({ ok: true, ...body }, init);
  }

  function jsonErr(error: string, status = 400): Response {
    return Response.json({ ok: false, error }, { status });
  }

  /** `{ ok:false, enabled:false }` shape shared by every route when no vault
   *  exists yet — never a throw, never a 404: the frontend uses this to
   *  render the first-run consent card instead of an error toast. */
  function noVault(root: string): Response {
    return Response.json({ ok: false, enabled: false, error: "no memory vault yet", root });
  }

  // ---- GET /api/memory/status -------------------------------------------

  async function handleMemoryStatus(): Promise<Response> {
    const st = await vaultStatus(getRoot());
    if (!st.exists) return noVault(st.root);
    return jsonOk({ enabled: true, status: st satisfies VaultStatus });
  }

  // ---- GET /api/memory/list ----------------------------------------------

  async function handleMemoryList(): Promise<Response> {
    const root = getRoot();
    const st = await vaultStatus(root);
    if (!st.exists) return noVault(root);
    const [articles, reference] = await Promise.all([listArticles(root), listReferenceDocs(root)]);
    return jsonOk({ articles, reference });
  }

  // ---- GET /api/memory/search?q=&scope= -----------------------------------

  async function handleMemorySearch(url: URL): Promise<Response> {
    const root = getRoot();
    const st = await vaultStatus(root);
    if (!st.exists) return noVault(root);
    const q = (url.searchParams.get("q") ?? "").trim();
    if (!q) return jsonErr("q is required");
    const scopeParam = url.searchParams.get("scope");
    const scope = scopeParam === "articles" || scopeParam === "reference" ? scopeParam : "all";
    const limitParam = Number(url.searchParams.get("limit") ?? "50");
    const limit = Number.isFinite(limitParam) && limitParam > 0 ? Math.min(limitParam, 200) : 50;
    try {
      const { summaries, hits } = await searchArticles(root, q, { limit, scope });
      return jsonOk({ summaries, hits });
    } catch (e) {
      return jsonErr((e as Error).message);
    }
  }

  // ---- GET /api/memory/article?name= --------------------------------------
  //
  // Rendered source + metadata: the article's raw Markdown plus the
  // deterministic structure the panel needs to render it without re-parsing
  // client-side (infobox, lead, series banner, section skeleton).

  async function handleMemoryArticle(url: URL): Promise<Response> {
    const root = getRoot();
    const st = await vaultStatus(root);
    if (!st.exists) return noVault(root);
    const name = (url.searchParams.get("name") ?? "").trim();
    if (!name) return jsonErr("name is required");
    try {
      const { path, content } = await readArticle(root, name);
      return jsonOk({
        name,
        path,
        content,
        infobox: parseInfobox(content),
        lead: parseLead(content),
        series: parseSeriesBanner(content),
        structure: articleStructure(content),
      });
    } catch (e) {
      return jsonErr((e as Error).message, 404);
    }
  }

  // ---- GET /api/memory/links?name= -----------------------------------------

  async function handleMemoryLinks(url: URL): Promise<Response> {
    const root = getRoot();
    const st = await vaultStatus(root);
    if (!st.exists) return noVault(root);
    const name = (url.searchParams.get("name") ?? "").trim();
    if (!name) return jsonErr("name is required");
    try {
      const links = await getArticleLinks(root, name);
      return jsonOk({ name, ...links });
    } catch (e) {
      return jsonErr((e as Error).message, 404);
    }
  }

  // ---- GET /api/memory/history?name= ---------------------------------------

  async function handleMemoryHistory(url: URL): Promise<Response> {
    const root = getRoot();
    const st = await vaultStatus(root);
    if (!st.exists) return noVault(root);
    const name = (url.searchParams.get("name") ?? "").trim();
    if (!name) return jsonErr("name is required");
    const limitParam = Number(url.searchParams.get("limit") ?? "50");
    const limit = Number.isFinite(limitParam) && limitParam > 0 ? Math.min(limitParam, 200) : 50;
    try {
      const relPath = await resolveArticleRelPath(root, name); // throws if not found — validates `name`
      const entries = await articleHistory(root, relPath, limit);
      return jsonOk({ name, isGitRepo: st.isGitRepo, entries });
    } catch (e) {
      return jsonErr((e as Error).message, 404);
    }
  }

  // ---- GET /api/memory/diff?name=&rev= -------------------------------------

  /** Full 40-hex or an abbreviated (≥4 hex) commit hash — never a ref
   *  expression (`HEAD~1`, `main^`, `refs/...`), which could otherwise be
   *  abused to walk outside the intended commit or (in principle) smuggle
   *  option-like text into the argv. `rev` is passed to Bun.spawn as its own
   *  argv element (never through a shell), but this check is the defense
   *  against a caller trying to pass anything other than a bare commit id. */
  const REV_RE = /^[0-9a-f]{4,40}$/;

  async function handleMemoryDiff(url: URL): Promise<Response> {
    const root = getRoot();
    const st = await vaultStatus(root);
    if (!st.exists) return noVault(root);
    const name = (url.searchParams.get("name") ?? "").trim();
    const rev = (url.searchParams.get("rev") ?? "").trim();
    if (!name) return jsonErr("name is required");
    if (!rev) return jsonErr("rev is required");
    if (!REV_RE.test(rev)) return jsonErr("rev must be a commit hash (4-40 hex chars)");
    try {
      const relPath = await resolveArticleRelPath(root, name); // throws if not found — validates `name`
      const diff = await articleDiff(root, rev, relPath);
      if (diff === null) return jsonErr("commit not found or no diff for this article at that revision", 404);
      return jsonOk({ name, rev, diff });
    } catch (e) {
      return jsonErr((e as Error).message, 404);
    }
  }

  // ---- POST /api/memory/init { path?: string } -----------------------------
  //
  // The consent-card backend: wraps the exact same `setupVault` the CLI's
  // `mlx-bun memory init` calls (src/cli.ts, `case "memory":` → `sub === "init"`)
  // — same idempotent create-dirs/README/Meta-pages/git-init behavior, minus
  // the CLI's interactive extras (seed-from-existing-vault prompt, nightly
  // schedule prompt), which stay CLI-only/TTY-gated and are out of scope here.
  //
  // Unlike the CLI (which only ever calls setupVault(getRoot()) — a
  // user-supplied path there is a read-only *seed source*, never the
  // setupVault target), this route takes `path` straight from an untrusted
  // loopback caller. setupVault() mkdir -p's subdirectories into it and, if
  // it isn't already a git repo, runs `git init && git add . && git commit`
  // there — pointed at an arbitrary directory that's a destructive foot-gun
  // (force-commits whatever's already there into a fresh history). There is
  // no product reason for the web panel to redirect the vault root outside
  // the machine's own tmp/vault trees, so `path` is confined to those before
  // it ever reaches setupVault; anything else 400s instead of writing files.

  /** realpath() of the deepest existing ancestor of `path`, with the
   *  non-existent tail (e.g. a not-yet-created vault dir) re-appended
   *  literally. Needed because macOS resolves `/var/folders/...` (os.tmpdir())
   *  through a `/private` symlink: a brand-new mkdtemp path under it won't
   *  literal-prefix-match the realpath'd tmpdir unless we walk up to a real
   *  segment the same way. */
  async function realpathNearest(path: string): Promise<string> {
    let cur = resolve(path);
    const tail: string[] = [];
    while (true) {
      try {
        return [await realpath(cur), ...tail.reverse()].join(sep);
      } catch {
        const parent = dirname(cur);
        if (parent === cur) return resolve(path); // hit the fs root without finding anything real
        tail.push(cur.slice(parent.length + 1));
        cur = parent;
      }
    }
  }

  /** Is `candidate` equal to or a descendant of `ancestor`, after resolving
   *  symlinks on both sides? */
  async function isUnder(candidate: string, ancestor: string): Promise<boolean> {
    const realAncestor = await realpathNearest(ancestor);
    const realCandidate = await realpathNearest(candidate);
    return realCandidate === realAncestor || realCandidate.startsWith(realAncestor + sep);
  }

  /** Confine an init target to the machine's own vault/tmp trees — the only
   *  legitimate destinations for this route (default vault root, or a tmp dir
   *  for tests). Rejects anything else rather than handing setupVault() an
   *  arbitrary, possibly pre-existing directory to mkdir/git-init into. */
  async function isAllowedVaultTarget(path: string): Promise<boolean> {
    return (await isUnder(path, getRoot())) || (await isUnder(path, tmpdir()));
  }

  async function handleMemoryInit(request: Request): Promise<Response> {
    let parsed: unknown = {};
    try {
      const text = await request.text();
      if (text.trim()) parsed = JSON.parse(text);
    } catch {
      return jsonErr("invalid JSON body");
    }
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return jsonErr("body must be an object");
    if ("path" in parsed && parsed.path !== undefined && typeof parsed.path !== "string") return jsonErr("path must be a string");
    const body = parsed as { path?: string };
    const root = body.path && body.path.trim() ? body.path.trim() : getRoot();
    if (!(await isAllowedVaultTarget(root))) {
      return jsonErr("path must be under the memory vault root or a temp directory", 400);
    }
    try {
      const res = await setupVault(root);
      const st = await vaultStatus(res.root);
      return jsonOk({ result: res, status: st });
    } catch (e) {
      return jsonErr((e as Error).message, e instanceof VaultPathError ? 400 : 500);
    }
  }

  return {
    async handle(request: Request): Promise<Response | null> {
      const url = new URL(request.url);
      switch (`${request.method} ${url.pathname}`) {
        case "GET /api/memory/status": return handleMemoryStatus();
        case "GET /api/memory/list": return handleMemoryList();
        case "GET /api/memory/search": return handleMemorySearch(url);
        case "GET /api/memory/article": return handleMemoryArticle(url);
        case "GET /api/memory/links": return handleMemoryLinks(url);
        case "GET /api/memory/history": return handleMemoryHistory(url);
        case "GET /api/memory/diff": return handleMemoryDiff(url);
        case "POST /api/memory/init": return handleMemoryInit(request);
        default: return null;
      }
    },
  };
}
