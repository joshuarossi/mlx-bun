// Does madvise actually relieve memory pressure on macOS? rss doesn't capture
// MADV_FREE_REUSABLE — phys_footprint (what macOS uses for pressure, shown in
// Activity Monitor) does. Measure phys_footprint via vmmap across DONTNEED /
// FREE / FREE_REUSABLE / munmap.  Run: bun scripts/probe-footprint.ts

import { MmapFile, MADV_DONTNEED, MADV_FREE, MADV_FREE_REUSABLE } from "../src/mmap";
import { openSync, writeSync, closeSync, unlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const PAGE = 16384, MB = 1024 * 1024, GB = 1024 * MB;
function footprintGB(): number {
  const out = Bun.spawnSync(["vmmap", "--summary", String(process.pid)]).stdout.toString();
  const m = out.match(/Physical footprint:\s+([\d.]+)([KMG])/);
  if (!m) return NaN;
  const v = parseFloat(m[1]!), u = m[2]!;
  return (u === "G" ? v : u === "M" ? v / 1024 : v / 1024 / 1024);
}
const show = (label: string) => console.log(`    ${label.padEnd(26)} phys_footprint ${footprintGB().toFixed(3)} GB`);

const bytes = 1 * GB;
const tmp = join(tmpdir(), `mlxbun-fp-${process.pid}.bin`);
const chunk = Buffer.alloc(64 * MB);
for (let i = 0; i < chunk.length; i += 4) chunk.writeFloatLE((i % 991) / 991, i);
const fd = openSync(tmp, "w");
for (let w = 0; w < bytes; w += chunk.length) writeSync(fd, chunk);
closeSync(fd);

console.log(`\n=== madvise vs phys_footprint (pid ${process.pid}) ===\n`);
show("baseline");
const mm = MmapFile.open(tmp, "ro");
const view = mm.view(0, bytes);
let acc = 0;
for (let p = 0; p < bytes; p += PAGE) acc ^= view[p]!;
show(`faulted 1 GB (chk ${acc & 1})`);
mm.advise(0, bytes, MADV_DONTNEED);
show("MADV_DONTNEED");
mm.advise(0, bytes, MADV_FREE);
show("MADV_FREE");
mm.advise(0, bytes, MADV_FREE_REUSABLE);
show("MADV_FREE_REUSABLE");
mm.unmap();
show("munmap");
try { unlinkSync(tmp); } catch {}
console.log("");
