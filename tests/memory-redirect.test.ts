// Sub-concept aliases / redirects — every discussed subject must RESOLVE.
//
// Three resolution paths, all deterministic + embedding-free:
//   1. NEAR-NAME — a query that is plainly the same subject as an existing
//      article (the title minus a generic suffix) resolves to it, while a distinct
//      subject or a purely-generic query does NOT (the over-merge guard).
//   2. FOLD — a sub-concept folded into a broader article (a `subject_redirects`
//      "fold" edge) resolves to that article once reindex projects the edge.
//   3. CAPTURE — a captured subject (no own article) resolves to the article it
//      most co-occurs with, via the same redirect projection.

import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, describe, expect, it } from "bun:test";

import { MemoryStore } from "../src/memory/db";
import { buildMemoryIndex, resetMemoryIndexCache, resolveName as resolveIndex } from "../src/memory/query";
import { reindex, resolveName as resolveStore } from "../src/memory/reindex";
import { registerRedirect, relatedArticleStem } from "../src/memory/redirect";

const temps: string[] = [];

/** A throwaway vault with the given `stem → markdown` articles. */
function vaultWith(articles: Record<string, string>): string {
  const root = mkdtempSync(join(tmpdir(), "mlxbun-redirect-"));
  temps.push(root);
  const dir = join(root, "articles");
  mkdirSync(dir, { recursive: true });
  for (const [stem, md] of Object.entries(articles)) writeFileSync(join(dir, `${stem}.md`), md);
  return root;
}

function article(title: string): string {
  return `# ${title}\n\nThe **${title}** is a subject the user thinks about.\n`;
}

/** Three distinct subjects: two "… Theory"-style concepts and a broad domain. */
function sampleVault(): string {
  return vaultWith({
    Predictive_Coding_Theory: article("Predictive Coding Theory"),
    Active_Inference: article("Active Inference"),
    Toyota_Production_System: article("Toyota Production System"),
  });
}

afterAll(() => {
  for (const d of temps) rmSync(d, { recursive: true, force: true });
});

describe("near-name resolution (read index)", () => {
  it("resolves a sub-concept that is the article title minus a generic suffix", () => {
    resetMemoryIndexCache();
    const idx = buildMemoryIndex(sampleVault());
    // "Predictive Coding" → "Predictive Coding Theory" (generic "Theory" dropped).
    expect(resolveIndex(idx, "predictive coding")).toBe("Predictive_Coding_Theory");
    expect(resolveIndex(idx, "Predictive Coding")).toBe("Predictive_Coding_Theory");
    // Exact alias still wins unchanged.
    expect(resolveIndex(idx, "Active Inference")).toBe("Active_Inference");
  });

  it("does NOT merge a distinct subject or a purely-generic query", () => {
    resetMemoryIndexCache();
    const idx = buildMemoryIndex(sampleVault());
    // Shares only the generic word "theory" but is a different subject.
    expect(resolveIndex(idx, "decision theory")).toBeNull();
    // Purely generic — must never redirect onto an arbitrary article.
    expect(resolveIndex(idx, "theory")).toBeNull();
    expect(resolveIndex(idx, "framework")).toBeNull();
    // A query that names MORE than the article (extra token) is not a subset.
    expect(resolveIndex(idx, "predictive coding of vision")).toBeNull();
  });
});

describe("near-name resolution (store / reindex)", () => {
  it("resolves the same near-names through the DB alias path", () => {
    const store = new MemoryStore(":memory:");
    reindex(store, sampleVault());
    expect(resolveStore(store, "predictive coding")).toBe("Predictive_Coding_Theory");
    expect(resolveStore(store, "decision theory")).toBeNull();
    expect(resolveStore(store, "theory")).toBeNull();
    store.close();
  });
});

describe("fold registers an alias", () => {
  it("a folded sub-concept resolves to its home article after reindex projects the edge", () => {
    const root = sampleVault();
    const store = new MemoryStore(":memory:");
    reindex(store, root);
    // Before: an unrelated discussed sub-concept does not resolve.
    expect(resolveStore(store, "Kaizen")).toBeNull();

    // Fold it into the broad article, reindex, and it now resolves to the home.
    expect(registerRedirect(store, "Kaizen", "Toyota_Production_System", "fold")).toBe(true);
    reindex(store, root);
    expect(resolveStore(store, "Kaizen")).toBe("Toyota_Production_System");
    expect(resolveStore(store, "kaizen")).toBe("Toyota_Production_System");
    store.close();
  });

  it("a redirect to a NON-existent article is not projected (article is truth)", () => {
    const root = sampleVault();
    const store = new MemoryStore(":memory:");
    registerRedirect(store, "Kanban", "No_Such_Article", "fold");
    reindex(store, root);
    expect(resolveStore(store, "Kanban")).toBeNull();
    store.close();
  });
});

describe("captured subject resolves", () => {
  it("a captured subject resolves to its home article via the redirect projection", () => {
    const root = sampleVault();
    const store = new MemoryStore(":memory:");
    reindex(store, root);
    expect(registerRedirect(store, "Just In Time", "Toyota_Production_System", "capture")).toBe(true);
    reindex(store, root);
    expect(resolveStore(store, "just in time")).toBe("Toyota_Production_System");
    store.close();
  });
});

describe("relatedArticleStem (capture neighbourhood)", () => {
  it("picks the homed article a captured subject co-occurs with most", () => {
    const store = new MemoryStore(":memory:");
    const db = store.db;
    db.exec("PRAGMA foreign_keys = OFF");
    db.exec(
      "INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES ('c1','t','C1',1,1)",
    );
    for (const [id, s, e] of [["c1:0-1", 0, 1], ["c1:2-3", 2, 3]] as const) {
      db.query("INSERT INTO chunks (id, conv, start, end, label) VALUES (?, 'c1', ?, ?, NULL)").run(id, s, e);
    }
    // A homed article entity, and a captured (not homed) subject co-occurring with it.
    db.query("INSERT INTO entities (name, article_stem, kind, notable) VALUES ('Toyota_Production_System','Toyota_Production_System','domain',1)").run();
    db.query("INSERT INTO entities (name, article_stem, kind, notable) VALUES ('Kaizen', NULL, 'thing', 0)").run();
    for (const cid of ["c1:0-1", "c1:2-3"]) {
      db.query("INSERT INTO chunk_entities (chunk_id, entity_name, surface_form) VALUES (?, 'Toyota_Production_System', 'TPS')").run(cid);
      db.query("INSERT INTO chunk_entities (chunk_id, entity_name, surface_form) VALUES (?, 'Kaizen', 'Kaizen')").run(cid);
    }
    expect(relatedArticleStem(store, "Kaizen")).toBe("Toyota_Production_System");
    // A subject that co-occurs with no homed article has no related stem.
    expect(relatedArticleStem(store, "Toyota_Production_System")).toBeNull();
    store.close();
  });
});

describe("registerRedirect hygiene", () => {
  it("is idempotent and never registers a self-redirect", () => {
    const store = new MemoryStore(":memory:");
    expect(registerRedirect(store, "Lean", "Toyota_Production_System", "fold")).toBe(true);
    expect(registerRedirect(store, "Lean", "Toyota_Production_System", "fold")).toBe(false); // dup
    // surface IS the title (spaced or stem form) → not a redirect.
    expect(registerRedirect(store, "Toyota Production System", "Toyota_Production_System", "fold")).toBe(false);
    expect(registerRedirect(store, "Toyota_Production_System", "Toyota_Production_System", "fold")).toBe(false);
    store.close();
  });
});
