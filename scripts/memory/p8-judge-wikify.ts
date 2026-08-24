// Bounded P8 cloud-judge fixture (throwaway): run the REAL editor wikify pass on
// 3 smoke articles into a temp vault (smoke vault is read-only), dump before/
// after + per-article result so the cloud judge can grade improve-not-degrade.
import { mkdtemp, mkdir, readFile, cp } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { articlesDir } from "../../src/memory/vault";
import { wikifyArticle } from "../../src/memory/wikify";

const SMOKE = `${process.env.HOME}/.mlx-bun/wiki-smoke`;
const STEMS = ["Helios_44-2", "anamorphic_adapter", "Sankor_16C"];

async function main(): Promise<void> {
  const root = await mkdtemp(join(tmpdir(), "p8-judge-"));
  await mkdir(articlesDir(root), { recursive: true });
  for (const stem of STEMS) {
    await cp(join(articlesDir(SMOKE), `${stem}.md`), join(articlesDir(root), `${stem}.md`));
  }
  for (const stem of STEMS) {
    const path = join(articlesDir(root), `${stem}.md`);
    const before = await readFile(path, "utf8");
    const res = await wikifyArticle({ stem, root, commit: false });
    const after = await readFile(path, "utf8");
    console.log(`\n@@@@@ ${stem} :: status=${res.status} sectionsImproved=${res.sectionsImproved} weakEditRejected=${res.weakEditRejected} infoboxRefreshed=${res.infoboxRefreshed} reason=${res.reason ?? "-"} @@@@@`);
    console.log(`>>>>> AFTER bytes=${after.length} (before=${before.length})`);
    console.log(after);
  }
}
main();
