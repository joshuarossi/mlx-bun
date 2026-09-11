import { expect, spyOn, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdtemp, readFile, rm, stat, symlink, unlink, utimes, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { artifactIdentity, FileArtifactIdentityStore } from "../../src/model/artifact-identity";

test("artifact memo preserves full-byte identity across restart, mutation and symlink replacement", async () => {
  const root = await mkdtemp(join(tmpdir(), "artifact-identity-"));
  const a = join(root, "a"), b = join(root, "b"), link = join(root, "weights");
  try {
    await writeFile(a, "abcd"); await writeFile(b, "efgh"); await symlink(a, link);
    const files = [{ name: "b.safetensors", path: b }, { name: "a.safetensors", path: link }];
    const seed = "test-config", cache = join(root, "cache");
    const expected = () => createHash("sha256").update(seed).update("a.safetensors").update("abcd")
      .update("b.safetensors").update("efgh").digest("hex");
    const first = new FileArtifactIdentityStore(cache);
    expect(await artifactIdentity(seed, files, first)).toBe(expected());
    await first.flush();
    const reads = spyOn(Bun, "file");
    try {
      expect(await artifactIdentity(seed, files, new FileArtifactIdentityStore(cache))).toBe(expected());
      expect(reads).not.toHaveBeenCalled();
    } finally { reads.mockRestore(); }
    const prior = await stat(a);
    await writeFile(a, "wxyz"); await utimes(a, prior.atime, prior.mtime);
    const changed = await artifactIdentity(seed, files, first);
    expect(changed).not.toBe(expected());
    expect(await artifactIdentity(seed + "2", files, first)).not.toBe(changed);
    await unlink(link); await symlink(b, link);
    expect(await artifactIdentity(seed, files, first)).not.toBe(changed);
    await first.flush();
    expect(await readFile(a, "utf8")).toBe("wxyz");
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("unavailable identity persistence still returns the full content digest", async () => {
  const root = await mkdtemp(join(tmpdir(), "artifact-identity-unwritable-"));
  try {
    const path = join(root, "weights"); await writeFile(path, "bytes");
    const store = new FileArtifactIdentityStore(join(path, "not-a-directory"));
    const expected = createHash("sha256").update("seed").update("weights").update("bytes").digest("hex");
    expect(await artifactIdentity("seed", [{ name: "weights", path }], store)).toBe(expected);
    await store.flush();
    expect(await artifactIdentity("seed", [{ name: "weights", path }], store)).toBe(expected);
  } finally { await rm(root, { recursive: true, force: true }); }
});
