import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "bun:test";

// Gold-entity vocabulary miner (P0-T5). The miner is pure file I/O over the
// local Dreaming oracle vault, so these checks are skipped when the vault is
// absent (e.g. CI without the personal corpus).

const REPO = join(import.meta.dir, "..");
const SCRIPT = join(REPO, "scripts", "memory", "mine-gold-entities.ts");
const OUT_FILE = join(REPO, "goldens", "entities.json");
const ARTICLES_GLOB = join(process.env.HOME ?? "", "Dreaming", "articles", "*.md");
const HAS_VAULT = existsSync(join(process.env.HOME ?? "", "Dreaming", "articles"));

interface Entity {
  name: string;
  aliases: string[];
  sourceTitle?: string;
}
interface GoldEntities {
  entities: Entity[];
  builtFromSha: string;
}

function runMiner(): string {
  execFileSync("bun", [SCRIPT], { cwd: REPO, encoding: "utf8" });
  return readFileSync(OUT_FILE, "utf8");
}

function articleCount(): number {
  // Shell-glob count of the oracle article files (relative gate, never hardcoded).
  const out = execFileSync("bash", ["-c", `ls ${ARTICLES_GLOB} | wc -l`], { encoding: "utf8" });
  return parseInt(out.trim(), 10);
}

describe.if(HAS_VAULT)("gold-entity miner", () => {
  it("emits exactly one title-derived entry per article file", () => {
    const gold = JSON.parse(runMiner()) as GoldEntities;
    const titleDerived = gold.entities.filter((e) => e.sourceTitle);
    expect(titleDerived.length).toBe(articleCount());
  });

  it("gives every entry a non-empty name", () => {
    const gold = JSON.parse(readFileSync(OUT_FILE, "utf8")) as GoldEntities;
    expect(gold.entities.length).toBeGreaterThan(0);
    for (const e of gold.entities) expect(e.name.length).toBeGreaterThan(0);
  });

  it("records the oracle SHA it was built from", () => {
    const gold = JSON.parse(readFileSync(OUT_FILE, "utf8")) as GoldEntities;
    expect(gold.builtFromSha).toMatch(/^[0-9a-f]{40}$/);
  });

  it("is byte-identical when re-run over the same SHA", () => {
    const first = runMiner();
    const second = runMiner();
    expect(second).toBe(first);
  });
});
