import { createHash, randomUUID } from "node:crypto";
import { mkdir, readFile, realpath, rename, rm, stat, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

/** Identity calculation owns bytes; this interface owns memo persistence. */
export interface ArtifactIdentityStore {
  get(key: string): Promise<string | undefined>;
  put(key: string, digest: string): void;
}

export class FileArtifactIdentityStore implements ArtifactIdentityStore {
  readonly #memory = new Map<string, string>();
  readonly #pending = new Set<Promise<void>>();
  constructor(readonly directory: string) {}

  async get(key: string): Promise<string | undefined> {
    const memory = this.#memory.get(key);
    if (memory) return memory;
    try {
      const digest = await readFile(join(this.directory, key), "utf8");
      if (!/^[0-9a-f]{64}$/.test(digest)) return undefined;
      this.#memory.set(key, digest);
      return digest;
    } catch { return undefined; }
  }

  put(key: string, digest: string): void {
    this.#memory.set(key, digest);
    const temporary = join(this.directory, `${key}.${process.pid}.${randomUUID()}.tmp`);
    const write = async () => {
      try {
        await mkdir(this.directory, { recursive: true });
        await writeFile(temporary, digest);
        await rename(temporary, join(this.directory, key));
      } catch { await rm(temporary, { force: true }).catch(() => {}); }
    };
    const pending = write().finally(() => this.#pending.delete(pending));
    this.#pending.add(pending);
  }

  async flush(): Promise<void> { await Promise.all(this.#pending); }
}

const defaultStore = new FileArtifactIdentityStore(join(homedir(), ".cache", "mlx-bun", "artifact-identities"));
export interface ArtifactIdentityFile { name: string; path: string; }

async function revision(files: readonly ArtifactIdentityFile[]): Promise<string> {
  return JSON.stringify(await Promise.all(files.map(async file => {
    const path = await realpath(file.path), info = await stat(path, { bigint: true });
    return [file.name, path, info.dev, info.ino, info.size, info.mtimeNs, info.ctimeNs].map(String);
  })));
}

/** Preserve the existing seed/name/byte digest, reusing it while file revisions
 * are unchanged. ctime catches same-size edits even when mtime is restored.
 * A memo miss computes the full identity; persistence never delays its caller. */
export async function artifactIdentity(seed: string, input: readonly ArtifactIdentityFile[],
  store: ArtifactIdentityStore = defaultStore): Promise<string> {
  const files = [...input].sort((a, b) => a.name < b.name ? -1 : a.name > b.name ? 1 : 0);
  const before = await revision(files);
  const key = createHash("sha256").update(JSON.stringify([seed, before])).digest("hex");
  const cached = await store.get(key);
  if (cached) return cached;
  const digest = createHash("sha256").update(seed);
  for (const file of files) {
    digest.update(file.name);
    for await (const chunk of Bun.file(file.path).stream()) digest.update(chunk);
  }
  const value = digest.digest("hex");
  if (before === await revision(files)) store.put(key, value);
  return value;
}
