// One byte budget over the saved-state root (`MLX_BUN_HOME/kv`). Every model's
// store lives in its own directory `<root>/<fingerprint>/`; a store enforces
// only its own directory, so the budget lends each live store the room the
// others leave and evicts the oldest files of directories no live store owns.
// Saved state is always droppable: an evicted file is a prefix miss, never an
// error. A live store never loses a file it indexed; it shrinks itself.
import { existsSync, readdirSync, rmdirSync, rmSync, statSync } from "node:fs";
import { join } from "node:path";

/** What the budget needs from one live store. */
export interface KvBudgetMember {
  /** The store's own directory under the root. */
  readonly dir: string;
  /** Bytes the store holds now. */
  bytes(): number;
}

export interface KvBudgetUsage {
  /** Every byte under the root. */
  readonly bytes: number;
  /** Held by directories no live store owns. */
  readonly idleBytes: number;
  readonly maxBytes: number;
}

export interface KvBudget {
  readonly root: string;
  /** Infinity: unlimited. */
  readonly maxBytes: number;
  /** Count a live store against the budget; `limit()` is the cap it enforces on itself now. */
  attach(member: KvBudgetMember): { limit(): number; detach(): void };
  /** Evict the oldest files of idle directories until the root fits. Live stores are never touched. */
  reclaim(): { removedFiles: number; removedBytes: number };
  usage(): KvBudgetUsage;
}

interface FileEntry { path: string; bytes: number; mtimeMs: number }

function walk(dir: string, into: FileEntry[]): void {
  let entries;
  try { entries = readdirSync(dir, { withFileTypes: true }); } catch { return; }
  for (const entry of entries) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) { walk(path, into); continue; }
    try { const stat = statSync(path); into.push({ path, bytes: stat.size, mtimeMs: stat.mtimeMs }); } catch { /* raced with a delete */ }
  }
}

/** A live store keeps at least this share of the budget however full the others are. */
const LIVE_FLOOR = 0.25;

export function createKvBudget(root: string, maxBytes: number = Infinity): KvBudget {
  if (!(maxBytes > 0)) throw new Error("a saved-state budget must be positive; use Infinity for none");
  const members = new Set<KvBudgetMember>();
  let idleBytes = 0, scanned = false;
  const isLive = (dir: string) => [...members].some(member => member.dir === dir);
  /** Files of every top-level directory that no live store owns. */
  const idleFiles = (): FileEntry[] => {
    const files: FileEntry[] = [];
    let names: string[] = [];
    try { names = readdirSync(root); } catch { /* no root yet: nothing saved */ }
    for (const name of names) if (!isLive(join(root, name))) walk(join(root, name), files);
    return files;
  };
  const refresh = (files = idleFiles()) => { idleBytes = files.reduce((sum, file) => sum + file.bytes, 0); scanned = true; };
  const liveBytes = (except?: KvBudgetMember) => [...members].reduce((sum, member) => member === except ? sum : sum + member.bytes(), 0);
  return {
    root, maxBytes,
    attach(member) {
      members.add(member);
      scanned = false;
      return {
        limit: () => {
          if (!Number.isFinite(maxBytes)) return Infinity;
          if (!scanned) refresh();
          return Math.max(maxBytes * LIVE_FLOOR, maxBytes - idleBytes - liveBytes(member));
        },
        detach: () => { members.delete(member); scanned = false; },
      };
    },
    reclaim() {
      const files = idleFiles();
      refresh(files);
      let removedFiles = 0, removedBytes = 0;
      if (Number.isFinite(maxBytes)) {
        files.sort((a, b) => a.mtimeMs - b.mtimeMs);
        for (const file of files) {
          if (idleBytes + liveBytes() <= maxBytes) break;
          try { rmSync(file.path, { force: true }); } catch { continue; }
          idleBytes -= file.bytes; removedFiles++; removedBytes += file.bytes;
        }
        if (removedFiles) pruneEmpty(root, members);
      }
      return { removedFiles, removedBytes };
    },
    usage() {
      refresh();
      return { bytes: idleBytes + liveBytes(), idleBytes, maxBytes };
    },
  };
}

/** Remove directories the eviction emptied, never a live store's own. */
function pruneEmpty(root: string, members: ReadonlySet<KvBudgetMember>): void {
  const live = new Set([...members].map(member => member.dir));
  const prune = (dir: string): boolean => {
    let entries;
    try { entries = readdirSync(dir, { withFileTypes: true }); } catch { return false; }
    let empty = true;
    for (const entry of entries) {
      if (entry.isDirectory() && prune(join(dir, entry.name))) continue;
      empty = false;
    }
    if (!empty || live.has(dir)) return false;
    try { rmdirSync(dir); return true; } catch { return false; }
  };
  if (!existsSync(root)) return;
  for (const entry of readdirSync(root, { withFileTypes: true }))
    if (entry.isDirectory() && !live.has(join(root, entry.name))) prune(join(root, entry.name));
}
