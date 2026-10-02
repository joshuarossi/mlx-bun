import { expect, test } from "bun:test";
import { copyFile, mkdir, mkdtemp, realpath, rename, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { JobStore } from "../../src/jobs/db";
import { closeSubprocessJobs, submitSubprocess } from "../../src/jobs/runner";

test("source and compiled job launchers honor an explicit executable override", async () => {
  const root = await mkdtemp(join(tmpdir(), "mlx-job-bin-"));
  try {
    for (const entry of ["/source/job-entry.ts", "/$bunfs/root/job-entry.ts"]) {
      const store = new JobStore(":memory:", root);
      let command: string[] | undefined;
      const complete = Promise.withResolvers<void>();
      submitSubprocess(store, "test", {}, undefined, { entry, bin: "/chosen/runtime",
        acquire: async () => ({ dispose() {} }),
        spawn: ((argv: string[]) => {
          command = argv;
          return { stdout: undefined, stderr: undefined, exited: Promise.resolve(0), exitCode: 0 };
        }) as unknown as typeof Bun.spawn,
        onComplete: () => complete.resolve(),
      });
      try {
        await complete.promise;
        expect(command?.slice(0, 2)).toEqual(["/chosen/runtime", entry.includes("$bunfs") ? "__job" : entry]);
      } finally { await closeSubprocessJobs(store); store.close(); }
    }
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("the compiled CLI pins its executable before the first job follows a current-link upgrade", async () => {
  const root = await mkdtemp(join(tmpdir(), "mlx-executable-upgrade-"));
  const app = resolve(import.meta.dir, "../.."), original = join(root, "original"), replacement = join(root, "replacement");
  const entry = join(root, "consumer.ts"), binary = join(original, "mlx-bun");
  const children: Bun.Subprocess[] = [];
  const deadline = setTimeout(() => {
    for (const child of children) if (child.exitCode === null && child.signalCode === null) child.kill("SIGKILL");
  }, 45_000);
  try {
    await mkdir(original); await mkdir(replacement); await mkdir(join(root, "bin"));
    await writeFile(join(original, "identity"), "original");
    await writeFile(join(replacement, "identity"), "replacement");
    // Import the actual CLI before readiness. Its --help path must capture the
    // executable even though serve/job modules have never been evaluated. The
    // runner is deliberately imported only AFTER the parent swaps current.
    await writeFile(entry, `
import { dirname, join } from "node:path";
import { readFileSync } from "node:fs";
if (process.argv[2] === "__job") {
  console.log(JSON.stringify({ executable: process.execPath, identity: readFileSync(join(dirname(process.execPath), "identity"), "utf8") }));
} else {
  const args = process.argv;
  process.argv = [args[0], args[1], "--help"];
  await import(${JSON.stringify(join(app, "src/cli/main.ts"))});
  process.argv = args;
  console.log("READY");
  await Bun.stdin.stream().getReader().read();
  const { JobStore } = await import(${JSON.stringify(join(app, "src/jobs/db.ts"))});
  const { submitSubprocess, closeSubprocessJobs } = await import(${JSON.stringify(join(app, "src/jobs/runner.ts"))});
  const store = new JobStore(join(args[2], "jobs.sqlite"), join(args[2], "logs"));
  const complete = Promise.withResolvers();
  const job = submitSubprocess(store, "identity", {}, undefined, {
    entry: import.meta.filename, acquire: async () => ({ dispose() {} }), onComplete: () => complete.resolve()
  });
  try { await complete.promise; console.log("RESULT " + readFileSync(store.get(job.jobId).log_path, "utf8").trim()); }
  finally { await closeSubprocessJobs(store); store.close(); }
}
`);
    const build = Bun.spawn([process.execPath, "build", "--compile", "--minify", entry, "--outfile", binary,
      "--no-compile-autoload-dotenv", "--no-compile-autoload-bunfig"], { stdout: "pipe", stderr: "pipe" });
    children.push(build);
    const [buildOut, buildErr, buildCode] = await Promise.all([
      new Response(build.stdout).text(), new Response(build.stderr).text(), build.exited,
    ]);
    expect({ code: buildCode, diagnostics: buildCode ? buildOut + buildErr : "" }).toEqual({ code: 0, diagnostics: "" });
    await copyFile(binary, join(replacement, "mlx-bun"));
    await symlink(join(root, "current", "mlx-bun"), join(root, "bin", "mlx-bun"));
    for (const viaPath of [false, true]) {
      const current = join(root, "current");
      await rm(current, { force: true }); await symlink(original, current);
      const data = join(root, viaPath ? "path-data" : "current-data"); await mkdir(data);
      const child = Bun.spawn([viaPath ? "mlx-bun" : join(current, "mlx-bun"), data], {
        cwd: root, env: { ...process.env, PATH: join(root, "bin") + ":" + process.env.PATH,
          HOME: data, MLX_BUN_LIBMLXC: "/nonexistent", HF_HUB_OFFLINE: "1", NO_COLOR: "1" },
        stdin: "pipe", stdout: "pipe", stderr: "pipe",
      });
      children.push(child);
      const errors = new Response(child.stderr).text();
      const reader = child.stdout.getReader(), decoder = new TextDecoder();
      let output = "";
      try {
        while (!output.includes("READY\n")) {
          const part = await reader.read();
          if (part.done) throw new Error(`CLI exited before ready: ${output}\n${await errors}`);
          output += decoder.decode(part.value, { stream: true });
        }
        await symlink(replacement, join(root, "next")); await rename(join(root, "next"), current);
        child.stdin.write("go\n"); child.stdin.end();
        while (true) { const part = await reader.read(); if (part.done) break; output += decoder.decode(part.value, { stream: true }); }
        expect({ code: await child.exited, stderr: await errors }).toEqual({ code: 0, stderr: "" });
        const event = JSON.parse(output.split("\n").find(line => line.startsWith("RESULT "))!.slice(7));
        expect(event.type).toBe("log");
        expect(JSON.parse(event.line)).toEqual({ executable: await realpath(binary), identity: "original" });
      } finally { reader.releaseLock(); }
    }
  } finally {
    clearTimeout(deadline);
    for (const child of children) if (child.exitCode === null && child.signalCode === null) child.kill("SIGKILL");
    await Promise.all(children.map(child => child.exited));
    await rm(root, { recursive: true, force: true });
  }
}, 60_000);
