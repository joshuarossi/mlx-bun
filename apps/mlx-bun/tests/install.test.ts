import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { chmod, mkdir, mkdtemp, readFile, readdir, readlink, realpath, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { prepareHomebrew } from "../../../scripts/prepare-homebrew";
import { NATIVE_FILES as MLX_FILES } from "../../../packages/mlx/src/native";
import { NATIVE_FILES as INFERENCE_FILES } from "../../../packages/inference/src/runtime/native";

const installer = resolve(import.meta.dir, "../../../scripts/install.sh");
const required = [...MLX_FILES, ...INFERENCE_FILES, "photon_rs_bg.wasm", "LICENSE", "THIRD_PARTY_NOTICES.md"];
async function readRemaining(stream: ReadableStream<Uint8Array>): Promise<string> {
  const reader = stream.getReader(), decoder = new TextDecoder();
  let text = "";
  try {
    while (true) { const part = await reader.read(); if (part.done) break; text += decoder.decode(part.value, { stream: true }); }
    return text + decoder.decode();
  } finally { reader.releaseLock(); }
}
async function run(command: string[], env = process.env) {
  const child = Bun.spawn(command, { env, stdout: "pipe", stderr: "pipe" });
  const deadline = setTimeout(() => child.kill("SIGKILL"), 15000);
  try {
    const [out, err, code] = await Promise.all([
      new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited,
    ]);
    return { out, err, code };
  } finally { clearTimeout(deadline); }
}
async function fixture() {
  const home = await mkdtemp(join(tmpdir(), "mlx install [test]. "));
  const tools = join(home, "tools"); await mkdir(tools);
  await writeFile(join(tools, "curl"), `#!/bin/sh
set -eu
while [ "$#" -gt 0 ]; do
  case "$1" in
    https://*) printf '%s\\n' "$1" > "$HOME/request-url";;
    -o) shift; output="$1";;
  esac
  shift
done
cp "$TEST_ARCHIVE" "$output"
`);
  await writeFile(join(tools, "mv"), `#!/bin/sh
if [ "$TEST_FAIL_LINK" = 1 ]; then
  for arg in "$@"; do
    if [ "$arg" = "$HOME/.local/bin/mlx-bun" ]; then echo "injected link failure" >&2; exit 1; fi
  done
fi
exec /bin/mv "$@"
`);
  await chmod(join(tools, "curl"), 0o755); await chmod(join(tools, "mv"), 0o755);
  const installRoot = join(home, ".mlx-bun"), app = join(installRoot, "app-install"), bin = join(home, ".local/bin/mlx-bun");
  async function archive(version: string, missing?: string) {
    const directory = await mkdtemp(join(home, "input-"));
    for (const file of required) if (file !== missing) await writeFile(join(directory, file), `fixture ${file}\n`);
    await writeFile(join(directory, "mlx-bun"), `#!/bin/sh\n[ "$1" = --version ] || exit 2\nprintf 'mlx-bun ${version}\\n'\n`);
    await chmod(join(directory, "mlx-bun"), 0o755);
    const path = join(home, `mlx-bun-v${version}-arm64.tar.gz`);
    expect((await run(["tar", "-czf", path, "-C", directory, "."])).code).toBe(0);
    return path;
  }
  async function install(path: string, options: NodeJS.ProcessEnv = {}, script = installer) {
    return run(["/bin/sh", script], { ...process.env, HOME: home, PATH: `${tools}:/usr/bin:/bin`,
      MLX_BUN_INSTALL_DIR: undefined, MLX_BUN_VERSION: "latest", TEST_ARCHIVE: path, ...options });
  }
  return { home, tools, installRoot, app, bin, archive, install, close: () => rm(home, { recursive: true, force: true }) };
}

test("latest and pinned reinstalls replace only the owned bundle and keep user data", async () => {
  const f = await fixture();
  try {
    await mkdir(join(f.installRoot, "sessions"), { recursive: true });
    await mkdir(join(f.installRoot, "wiki"));
    for (const file of ["sessions/chat.jsonl", "wiki/article.md", "hf.json", "mlx-bun", "libmlx.dylib"])
      await writeFile(join(f.installRoot, file), "preserved");
    const first = await f.archive("1.2.3");
    const installed = await f.install(first);
    expect(installed.code, installed.err).toBe(0); expect(installed.err).toBe("");
    expect(await readFile(join(f.home, "request-url"), "utf8")).toContain("releases/latest/download/mlx-bun-arm64.tar.gz");
    expect((await run([f.bin, "--version"])).out).toBe("mlx-bun 1.2.3\n");
    const old = await readlink(join(f.app, "current"));
    await mkdir(join(f.app, "bundle.interrupted"));
    const second = await f.archive("1.2.4");
    expect((await f.install(second, { MLX_BUN_VERSION: "v1.2.4" })).code).toBe(0);
    expect(await readFile(join(f.home, "request-url"), "utf8")).toContain("releases/download/v1.2.4/mlx-bun-arm64.tar.gz");
    expect((await run([f.bin, "--version"])).out).toBe("mlx-bun 1.2.4\n");
    expect(await readlink(join(f.app, "current"))).not.toBe(old);
    expect((await readdir(f.app)).filter(name => name.startsWith("bundle."))).toHaveLength(2);
    expect((await run([join(f.app, old, "mlx-bun"), "--version"])).out).toBe("mlx-bun 1.2.3\n");
    expect((await f.install(await f.archive("1.2.5"))).code).toBe(0);
    expect((await readdir(f.app)).filter(name => name.startsWith("bundle."))).toHaveLength(2);
    await expect(readFile(join(f.app, old, "mlx-bun"))).rejects.toThrow("ENOENT");
    for (const file of ["sessions/chat.jsonl", "wiki/article.md", "hf.json", "mlx-bun", "libmlx.dylib"])
      expect(await readFile(join(f.installRoot, file), "utf8")).toBe("preserved");
  } finally { await f.close(); }
}, 30000);

test("corrupt, incomplete, wrong-version and failed-link upgrades preserve the prior runnable bundle", async () => {
  const f = await fixture();
  try {
    expect((await f.install(await f.archive("1.0.0"))).code).toBe(0);
    const original = await readlink(join(f.app, "current"));
    const corrupt = join(f.home, "corrupt.tar.gz"); await writeFile(corrupt, "not an archive");
    const incomplete = await f.archive("1.0.1", "mlx.metallib");
    const next = await f.archive("1.0.2");
    for (const [archive, options] of [[corrupt, {}], [incomplete, {}], [next, { MLX_BUN_VERSION: "v2.0.0" }], [next, { TEST_FAIL_LINK: "1" }]] as const) {
      expect((await f.install(archive, options)).code).not.toBe(0);
      expect(await readlink(join(f.app, "current"))).toBe(original);
      expect((await run([f.bin, "--version"])).out).toBe("mlx-bun 1.0.0\n");
      expect((await readdir(f.app)).filter(name => name.startsWith("bundle."))).toHaveLength(1);
    }
  } finally { await f.close(); }
}, 30000);

test("cleanup never follows bundle or previous-current symlinks outside the owned root", async () => {
  const f = await fixture();
  try {
    const archive = await f.archive("1.0.0");
    expect((await f.install(archive)).code).toBe(0);
    const outside = join(f.home, "keep me"); await mkdir(outside); await writeFile(join(outside, "data"), "keep");
    await symlink(outside, join(f.app, "bundle.external"));
    await rm(join(f.app, "current")); await symlink(outside, join(f.app, "current"));
    expect((await f.install(archive)).code).toBe(0);
    expect(await readFile(join(outside, "data"), "utf8")).toBe("keep");
    expect(await readlink(join(f.app, "bundle.external"))).toBe(outside);
    expect((await run([f.bin, "--version"])).out).toBe("mlx-bun 1.0.0\n");
  } finally { await f.close(); }
}, 30000);

test("custom installation roots with spaces work through the command symlink", async () => {
  const f = await fixture();
  try {
    const custom = join(f.home, "custom application directory");
    const result = await f.install(await f.archive("1.0.0"), { MLX_BUN_INSTALL_DIR: custom });
    expect(result.code, result.err).toBe(0);
    expect(await readlink(f.bin)).toBe(join(await realpath(custom), "app-install/current/mlx-bun"));
    expect((await run([f.bin, "--version"])).out).toBe("mlx-bun 1.0.0\n");
  } finally { await f.close(); }
}, 30000);

test("an existing unowned app directory is not overwritten", async () => {
  const f = await fixture();
  try {
    await mkdir(f.app, { recursive: true }); await writeFile(join(f.app, "mine"), "keep");
    const result = await f.install(await f.archive("1.0.0"));
    expect(result.code).not.toBe(0); expect(result.err).toContain("not installer-owned");
    expect(await readFile(join(f.app, "mine"), "utf8")).toBe("keep");
  } finally { await f.close(); }
});

test("a bundle containing a symlink is rejected before replacing the existing app", async () => {
  const f = await fixture();
  try {
    const archive = await f.archive("1.0.0");
    expect((await f.install(archive)).code).toBe(0);
    const original = await readlink(join(f.app, "current"));
    const directory = join(f.home, "linked bundle"); await mkdir(directory);
    expect((await run(["tar", "-xzf", archive, "-C", directory])).code).toBe(0);
    await rm(join(directory, "libmlx.dylib"));
    await symlink("/outside/not-a-library", join(directory, "libmlx.dylib"));
    const linkedArchive = join(f.home, "linked.tar.gz");
    expect((await run(["tar", "-czf", linkedArchive, "-C", directory, "."])).code).toBe(0);
    const result = await f.install(linkedArchive);
    expect(result.code).not.toBe(0); expect(result.err).toContain("non-regular");
    expect(await readlink(join(f.app, "current"))).toBe(original);
  } finally { await f.close(); }
}, 30000);

test("an installer lock prevents competing updates without removing its owner's lock", async () => {
  const f = await fixture();
  try {
    const archive = await f.archive("1.0.0");
    expect((await f.install(archive)).code).toBe(0);
    const original = await readlink(join(f.app, "current"));
    await mkdir(join(f.app, "lock")); await writeFile(join(f.app, "lock/pid"), "123");
    const result = await f.install(archive);
    expect(result.code).not.toBe(0); expect(result.err).toContain(`${f.app}/lock exists (installer PID 123)`);
    expect(await readFile(join(f.app, "lock/pid"), "utf8")).toBe("123");
    expect(await readlink(join(f.app, "current"))).toBe(original);
  } finally { await f.close(); }
}, 30000);

test("Homebrew preparation derives version, URL and checksum from a complete local archive", async () => {
  const f = await fixture();
  try {
    const archive = await f.archive("1.2.3");
    const output = await prepareHomebrew(archive);
    const formula = await readFile(output, "utf8");
    expect(formula).toContain('version "1.2.3"');
    expect(formula).toContain('/releases/download/v1.2.3/mlx-bun-v1.2.3-arm64.tar.gz');
    expect(formula).toContain(createHash("sha256").update(await readFile(archive)).digest("hex"));
    expect(formula).toContain('libexec.install Dir["*"]');
    expect(formula).toContain('bin.install_symlink libexec/"mlx-bun"');
    expect(formula).toContain('depends_on arch: :arm64');
    expect(formula).toContain('depends_on macos: :sonoma');
    await expect(prepareHomebrew(archive, archive)).rejects.toThrow("overwrite");
    await expect(prepareHomebrew(await f.archive("1.2.4", "mlx.metallib"))).rejects.toThrow("Incomplete");
    await expect(prepareHomebrew(join(f.home, "random.tgz"))).rejects.toThrow("Expected");
  } finally { await f.close(); }
});


test("symlink and PATH-launched apps retain their original binary across repeated upgrades and re-exec", async () => {
  const f = await fixture();
  const children: ReturnType<typeof Bun.spawn>[] = [];
  const deadlines: ReturnType<typeof setTimeout>[] = [];
  try {
    expect((await f.install(await f.archive("1.0.0"))).code).toBe(0);
    const oldest = await realpath(join(f.app, "current"));
    // Match normal product launches, not the resolved binary path. Each real
    // compiled process records its canonical execPath at startup, then must
    // re-exec that same path for a managed child after multiple upgrades.
    const source = join(f.home, "idle.ts");
    await writeFile(source, `if (process.argv.includes("--probe")) console.log("reentry ok");
else { console.log("ready " + process.execPath); await Bun.stdin.text();
  const child = Bun.spawnSync([process.execPath, "--probe"]);
  process.stdout.write(child.stdout); process.stderr.write(child.stderr); process.exit(child.exitCode); }
`);
    expect((await run([process.execPath, "build", "--compile", source, "--outfile", join(oldest, "mlx-bun")])).code).toBe(0);
    const commands = [[f.bin], ["/bin/sh", "-c", "exec mlx-bun"], ["/bin/sh", "-c", "exec ./mlx-bun"]];
    for (const command of commands) {
      const child = Bun.spawn(command, { cwd: join(f.home, ".local/bin"),
        env: { ...process.env, PATH: `${join(f.home, ".local/bin")}:/usr/bin:/bin` },
        stdin: "pipe", stdout: "pipe", stderr: "pipe" });
      children.push(child);
      deadlines.push(setTimeout(() => child.kill("SIGKILL"), 20000));
      const reader = (child.stdout as ReadableStream<Uint8Array>).getReader();
      try { expect(new TextDecoder().decode((await reader.read()).value)).toContain(`ready ${join(oldest, "mlx-bun")}`); }
      finally { reader.releaseLock(); }
    }
    expect((await f.install(await f.archive("1.0.1"))).code).toBe(0);
    for (const version of ["1.0.2", "1.0.3"]) {
      const upgraded = await f.install(await f.archive(version));
      expect(upgraded.code, upgraded.err).toBe(0);
      expect(upgraded.err).toContain(`Keeping running app bundle: ${oldest}`);
      expect(await readdir(oldest)).toContain("mlx-bun");
      for (const child of children) expect(child.exitCode).toBeNull();
    }
    // Every launch form must still be able to start a child from its original
    // executable, although the user-facing symlink now points at newer builds.
    for (const child of children) {
      (child.stdin as import("bun").FileSink).end();
      const [out, err, code] = await Promise.all([
        readRemaining(child.stdout as ReadableStream<Uint8Array>), new Response(child.stderr as ReadableStream).text(), child.exited,
      ]);
      expect({ code, err }).toEqual({ code: 0, err: "" });
      expect(out).toContain("reentry ok");
    }
    expect((await f.install(await f.archive("1.0.4"))).code).toBe(0);
    await expect(readdir(oldest)).rejects.toThrow("ENOENT");
    expect((await readdir(f.app)).filter(name => name.startsWith("bundle."))).toHaveLength(2);
  } finally {
    for (const deadline of deadlines) clearTimeout(deadline);
    for (const child of children) { if (child.exitCode === null && child.signalCode === null) child.kill("SIGKILL"); await child.exited; }
    await f.close();
  }
}, 30000);

test("failed process inspection keeps all older bundles", async () => {
  const f = await fixture();
  try {
    expect((await f.install(await f.archive("1.0.0"))).code).toBe(0);
    const oldest = await realpath(join(f.app, "current"));
    expect((await f.install(await f.archive("1.0.1"))).code).toBe(0);
    // Inject a failed system command in a temporary copy; production always
    // uses /usr/sbin/lsof, so PATH cannot override vnode inspection.
    const script = join(f.home, "failed-process-inspection.sh");
    const source = await readFile(installer, "utf8");
    expect(source.split("/usr/sbin/lsof -t +w +D")).toHaveLength(2);
    const cases = ["/nonexistent/lsof-inspection", 'sh "$HOME/inspection-error"', 'sh "$HOME/inspection-empty"'];
    await writeFile(join(f.home, "inspection-error"), "echo 'cannot inspect vnode' >&2; exit 1\n");
    await writeFile(join(f.home, "inspection-empty"), "exit 0\n");
    for (const [index, command] of cases.entries()) {
      await writeFile(script, source.replace("/usr/sbin/lsof -t +w +D", command));
      const result = await f.install(await f.archive(`1.0.${index + 2}`), {}, script);
      expect(result.code, result.err).toBe(0);
      expect(result.err).toContain("cannot inspect running app files");
      expect(await readdir(oldest)).toContain("mlx-bun");
      expect((await readdir(f.app)).filter(name => name.startsWith("bundle."))).toHaveLength(3 + index);
      expect(await readdir(f.app)).not.toContain("lock");
    }
    // Real lsof permission warning must not look like an empty no-match result.
    const inaccessible = join(oldest, "inaccessible");
    await mkdir(inaccessible);
    await chmod(inaccessible, 0);
    try {
      const result = await f.install(await f.archive("1.0.5"));
      expect(result.code, result.err).toBe(0);
      expect(result.err).toContain(`cannot inspect running app files in ${oldest}`);
      expect(await readdir(oldest)).toContain("mlx-bun");
      expect(await readdir(f.app)).not.toContain("lock");
    } finally { await chmod(inaccessible, 0o700); }
  } finally { await f.close(); }
}, 30000);

test("a legacy command earlier on PATH is reported instead of suggesting it runs the new app", async () => {
  const f = await fixture();
  try {
    const legacy = join(f.tools, "mlx-bun");
    await writeFile(legacy, "#!/bin/sh\necho legacy\n"); await chmod(legacy, 0o755);
    const result = await f.install(await f.archive("1.0.0"), {
      PATH: `${f.tools}:${join(f.home, ".local/bin")}:/usr/bin:/bin`,
    });
    expect(result.code, result.err).toBe(0);
    expect(result.err).toContain(`mlx-bun on PATH resolves to ${legacy}`);
    expect(result.out).not.toContain("Run: mlx-bun");
    expect((await run([f.bin, "--version"])).out).toBe("mlx-bun 1.0.0\n");
    await rm(legacy);
    const again = await f.install(await f.archive("1.0.1"), {
      PATH: `${f.tools}:${join(f.home, ".local/bin")}:/usr/bin:/bin`,
    });
    expect(again.out).toContain("Run: mlx-bun"); expect(again.err).toBe("");
  } finally { await f.close(); }
}, 30000);
