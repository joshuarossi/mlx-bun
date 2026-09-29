import { createHash, randomUUID } from "node:crypto";
import { mkdir, readdir, readFile, realpath, rename, rm, stat, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join, resolve } from "node:path";
import { runtimeValue } from "../runtime/config";

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

let defaultStore: FileArtifactIdentityStore | undefined;
/** The memo directory under the mlx-bun storage root (MLX_BUN_HOME, default
 * ~/.mlx-bun), read at call time so an isolated environment gets its own. */
function defaultIdentityStore(): FileArtifactIdentityStore {
  const configured = runtimeValue("MLX_BUN_HOME");
  const root = configured ? resolve(configured) : join(process.env.HOME || homedir(), ".mlx-bun");
  const directory = join(root, "cache", "artifact-identities");
  if (defaultStore?.directory !== directory) defaultStore = new FileArtifactIdentityStore(directory);
  return defaultStore;
}
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
  store: ArtifactIdentityStore = defaultIdentityStore()): Promise<string> {
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

/** Content identity of a model directory's weights: config.json plus every
 * safetensors shard (and the shard index), so quantization, fine-tunes and
 * revised weights each get their own digest under one repo id. Memoized by
 * file revision like every artifactIdentity. */
export async function modelWeightsIdentity(modelDir: string, seed: string,
  store?: ArtifactIdentityStore): Promise<string> {
  const names = (await readdir(modelDir)).filter(name =>
    name === "config.json" || name === "model.safetensors.index.json" || name.endsWith(".safetensors"));
  return artifactIdentity(seed, names.map(name => ({ name, path: join(modelDir, name) })), store);
}
