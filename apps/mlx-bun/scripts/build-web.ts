import { mkdir } from "node:fs/promises";
import { dirname } from "node:path";
import { buildWebBundle, OUTFILE } from "../src/web/build";

if (import.meta.main) {
  await mkdir(dirname(OUTFILE), { recursive: true });
  await Bun.write(OUTFILE, await buildWebBundle());
  console.log(`Built ${OUTFILE}`);
}
