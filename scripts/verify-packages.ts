import assert from "node:assert/strict";
import { cp, mkdir, mkdtemp, readFile, realpath, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, dirname, join, resolve } from "node:path";

const workspace = resolve(import.meta.dir, "..");
const args = process.argv.slice(2);
if (args.includes("--help")) {
  console.log("Usage: bun scripts/verify-packages.ts [--keep] [--app-only]\nPack workspace libraries and the app, install into a temporary Bun project, import every public entry,\nand run model-free consumer tests and examples against bundled natives.\nRequires staged native artifacts; does not download models or publish packages.\n--keep retains the temporary project for inspection.\n--app-only checks the installed CLI without building or loading native libraries.");
  process.exit(0);
}
if (args.some(arg => arg !== "--keep" && arg !== "--app-only")) throw new Error("Unknown option; use --help");
const scratch = await mkdtemp(join(tmpdir(), "mlx-package-consumer-"));
const consumer = join(scratch, "consumer"), archives = join(scratch, "archives");
const env = Object.fromEntries(Object.entries(process.env).filter(([name]) => !name.startsWith("MLX_BUN_")));

async function run(command: string[], cwd: string): Promise<string> {
  const child = Bun.spawn(command, { cwd, env, stdout: "pipe", stderr: "pipe" });
  const [stdout, stderr, status] = await Promise.all([
    new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited,
  ]);
  if (status !== 0) throw new Error(`${command.join(" ")} exited ${status}\n${stdout}\n${stderr}`);
  if (command[1] === "test") console.log(stderr.trim().split("\n").slice(-4).join("\n"));
  return stdout;
}

try {
  await mkdir(consumer); await mkdir(archives);
  const packages: { name: string; entries: string[] }[] = [];
  const dependencies: Record<string, string> = {};
  for (const path of [...new Bun.Glob("{packages,apps}/*/package.json").scanSync(workspace)].sort()) {
    const manifest = JSON.parse(await readFile(join(workspace, path), "utf8"));
    if (manifest.private && !manifest.bin) continue;
    const directory = dirname(join(workspace, path));
    const archive = join(archives, `${basename(directory)}.tgz`);
    console.log(`Packing ${manifest.name}`);
    if (manifest.name === "mlx-bun" && args.includes("--app-only"))
      await run([process.execPath, "run", "build:web"], directory);
    await run([process.execPath, "pm", "pack", "--filename", archive, "--quiet", ...(args.includes("--app-only") ? ["--ignore-scripts"] : [])], directory);
    dependencies[manifest.name] = `file:${archive}`;
    const entries = Object.keys(manifest.exports ?? {}).map(key => {
      assert(key === "." || key.startsWith("./"), `Unsupported export key: ${key}`);
      assert(!key.includes("*"), "Enumerate wildcard exports before adding them to the public surface");
      return key === "." ? manifest.name : manifest.name + key.slice(1);
    });
    packages.push({ name: manifest.name, entries });
  }
  assert(packages.length > 0, "No public workspace packages found");
  await Bun.write(join(consumer, "package.json"), JSON.stringify({
    private: true, type: "module", dependencies, overrides: dependencies,
  }, null, 2));
  await run([process.execPath, "install", "--ignore-scripts"], consumer);
  // Exercise the installed bin and reuse its behavior tests against the tarball.
  const appEntry = join(consumer, "node_modules/mlx-bun/src/cli/main.ts");
  assert((await realpath(appEntry)).startsWith((await realpath(consumer)) + "/"), "Installed app is a workspace link");
  const help = await run([join(consumer, "node_modules/.bin/mlx-bun"), "--help"], consumer);
  assert(help.includes("Usage: mlx-bun"));
  await run([process.execPath, "-e", `
    const { createWebHandler } = await import("./node_modules/mlx-bun/src/web/assets.ts");
    const handle = await createWebHandler();
    for (const path of ["/", "/assets/app.js", "/assets/hljs.js", "/assets/hljs.css", "/assets/icon.svg", "/manifest.webmanifest", "/sw.js"]) {
      const response = handle(new Request("http://local" + path));
      if (response?.status !== 200 || !(await response.text()).length) throw new Error("Missing packed asset: " + path);
    }
    const { mkdtemp, mkdir, readFile, rm } = await import("node:fs/promises");
    const { tmpdir } = await import("node:os");
    const { join } = await import("node:path");
    const { createMemorySurface } = await import("./node_modules/mlx-bun/src/memory/surface.ts");
    const vault = await mkdtemp(join(tmpdir(), "mlx-packed-memory-"));
    try {
      await mkdir(join(vault, "articles"));
      const surface = await createMemorySurface(vault, join(vault, "skills"));
      if (!surface?.toolNames.includes("memory_section")) throw new Error("Missing packed memory tools");
      const skill = await readFile(join(surface.skillPaths[0], "SKILL.md"), "utf8");
      if (!skill.includes("name: memory")) throw new Error("Missing packed memory skill");
    } finally { await rm(vault, { recursive: true, force: true }); }
  `], consumer);
  await mkdir(join(consumer, "app-tests"));
  await cp(join(workspace, "apps/mlx-bun/tests/hub-cli.test.ts"), join(consumer, "app-tests/hub-cli.test.ts"));
  env.MLX_BUN_TEST_CLI = appEntry;
  console.log((await run([process.execPath, "test", "app-tests"], consumer)).trim());
  delete env.MLX_BUN_TEST_CLI;
  // Preserve source-relative imports while exercising only the installed app
  // and library artifacts, including the one-shot engine composition.
  // Verb tests that also import app sources run from the installed package's own
  // tests directory; their spawned runs use the installed CLI entry.
  const installedTests = join(consumer, "node_modules/mlx-bun/tests");
  await mkdir(installedTests, { recursive: true });
  const verbTests = ["inference-cli.test.ts", "upload-cli.test.ts", "convert-cli.test.ts", "train-cli.test.ts"];
  for (const file of verbTests) await cp(join(workspace, "apps/mlx-bun/tests", file), join(installedTests, file));
  env.MLX_BUN_LIBMLXC = "/does-not-exist";
  env.MLX_BUN_TEST_CLI = appEntry;
  try { console.log((await run([process.execPath, "test", ...verbTests.map(file => `./node_modules/mlx-bun/tests/${file}`)], consumer)).trim()); }
  finally { delete env.MLX_BUN_LIBMLXC; delete env.MLX_BUN_TEST_CLI; }
  // Public hub protocol tests run against the installed tarball, including
  // --app-only: local mock HTTP and explicit temporary token inputs, no MLX.
  await mkdir(join(consumer, "hub-tests"));
  for (const file of ["upload.test.ts", "token.test.ts"])
    await cp(join(workspace, "packages/hub/tests", file), join(consumer, "hub-tests", file));
  env.MLX_BUN_LIBMLXC = "/does-not-exist";
  try { console.log((await run([process.execPath, "test", "hub-tests"], consumer)).trim()); }
  finally { delete env.MLX_BUN_LIBMLXC; }
  if (args.includes("--app-only")) {
    console.log("Packed app passed CPU-only consumer tests.");
  } else {
    const entries = packages.flatMap(pkg => pkg.entries);
    await Bun.write(join(consumer, "imports.ts"), `
  import { realpathSync } from "node:fs";
  import assert from "node:assert/strict";
  const root = realpathSync(import.meta.dir) + "/";
  for (const name of ${JSON.stringify(entries)}) {
    assert(realpathSync(Bun.resolveSync(name, import.meta.dir)).startsWith(root), name + " escapes the installed consumer");
    await import(name);
  }
  console.log("Imported ${entries.length} public entrypoints from installed archives");
  `);
    console.log((await run([process.execPath, "imports.ts"], consumer)).trim());

    // Reuse behavioral tests, rather than keeping a second consumer implementation.
    const tests = {
      mlx: ["mlx-abi.test.ts", "compile.test.ts", "metal-kernel.test.ts"],
      inference: ["models/qwen3.test.ts", "kernels/trellis-vector-expand.test.ts", "execution/expert-io-native.test.ts"],
    };
    for (const [name, files] of Object.entries(tests)) {
      const installed = join(consumer, "node_modules", "@mlx-bun", name);
      assert((await realpath(installed)).startsWith((await realpath(consumer)) + "/"), "Installed package is a workspace link");
      const destination = join(consumer, "packages", name);
      // Examples come from the tarball, so forgetting to publish them fails here.
      await cp(join(installed, "examples"), join(destination, "examples"), { recursive: true });
      for (const file of files) {
        const target = join(destination, "tests", file);
        await mkdir(dirname(target), { recursive: true });
        await cp(join(workspace, "packages", name, "tests", file), target);
      }
    }
    const output = await run([process.execPath, "test", "packages"], consumer);
    if (output.trim()) console.log(output.trim());
    await run([process.execPath, "node_modules/@mlx-bun/mlx/examples/arrays.ts"], consumer);
    await run([process.execPath, "node_modules/@mlx-bun/inference/examples/trellis-expand.ts"], consumer);
    console.log("Packed libraries and app passed consumer tests and executable examples.");
  }
} finally {
  if (args.includes("--keep")) console.log(`Consumer project retained: ${scratch}`);
  else await rm(scratch, { recursive: true, force: true });
}
