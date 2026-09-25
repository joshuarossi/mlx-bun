import { expect, test } from "bun:test";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import { CLI_SOURCE, INSTALLER_SOURCE, commandReference, generateReference, helpReference, renderCommandReference } from "../scripts/generate-reference";

const root = resolve(import.meta.dir, "../../..");

async function liveHelp(command?: string): Promise<string> {
  const child = Bun.spawn([process.execPath, "--no-env-file", "apps/mlx-bun/src/cli/main.ts", ...(command ? [command] : []), "--help"], {
    cwd: root, env: { ...process.env, NO_COLOR: "1", MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1" },
    stdout: "pipe", stderr: "pipe",
  });
  const deadline = setTimeout(() => child.kill("SIGKILL"), 5000);
  try {
    const [stdout, stderr, code] = await Promise.all([
      new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited,
    ]);
    expect({ code, stderr }).toEqual({ code: 0, stderr: "" });
    return stdout;
  } finally { clearTimeout(deadline); if (child.exitCode === null) child.kill("SIGKILL"); await child.exited; }
}

test("generated CLI covers the real help's complete command and option sets", async () => {
  const source = await readFile(resolve(root, CLI_SOURCE), "utf8");
  const commands = commandReference(source), common = helpReference(source);
  // An independent consumer of the live table: CLI help, not the generator's
  // AST traversal. A newly parsed verb/flag must appear in both references.
  const globalHelp = await liveHelp();
  const section = globalHelp.split("Commands:\n")[1]!.split("\n\nOptions:")[0]!;
  const names = [...section.matchAll(/^  ([a-z][a-z-]*)\s/gm)].map(match => match[1]!);
  expect(commands.map(command => command.name).sort()).toEqual(names.sort());
  const helpFlags = (text: string) => [...text.matchAll(/^\s+((?:-[a-z], )?--[a-z][a-z-]*)/gm)]
    .flatMap(match => match[1]!.split(", ")).sort();
  expect(common.global.flatMap(option => option.flags).sort()).toEqual(helpFlags(globalHelp));
  const rendered = renderCommandReference(commands, common);
  const globalSection = rendered.split("## Global options\n")[1]!.split("\n## ")[0]!;
  for (const flag of helpFlags(globalHelp)) expect(globalSection).toContain(`\`${flag}\``);
  for (const command of commands) {
    const flags = helpFlags(await liveHelp(command.name));
    expect([...command.options.flatMap(option => [ `--${option.name}`, ...(option.short ? [`-${option.short}`] : []) ]),
      ...common.shared.flatMap(option => option.flags)].sort()).toEqual(flags);
    const ownSection = rendered.split(`## ${command.name}\n`)[1]!.split("\n## ")[0]!;
    for (const flag of flags) expect(ownSection).toContain(`\`${flag}`);
  }
});

test("every documented global flag runs without native libraries", async () => {
  const common = helpReference(await readFile(resolve(root, CLI_SOURCE), "utf8"));
  for (const option of common.global) for (const flag of option.flags) {
    const child = Bun.spawn([process.execPath, "--no-env-file", "apps/mlx-bun/src/cli/main.ts", flag], {
      cwd: root, env: { ...process.env, NO_COLOR: "1", MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1" },
      stdout: "pipe", stderr: "pipe",
    });
    const deadline = setTimeout(() => child.kill("SIGKILL"), 5000);
    try {
      const [stdout, stderr, code] = await Promise.all([
        new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited,
      ]);
      expect({ code, stderr }).toEqual({ code: 0, stderr: "" });
      expect(stdout).toContain("mlx-bun");
    } finally { clearTimeout(deadline); if (child.exitCode === null) child.kill("SIGKILL"); await child.exited; }
  }
});

test("generation copies the canonical installer exactly and emits only build-owned files", async () => {
  const destination = await mkdtemp(resolve(tmpdir(), "mlx-site-reference-"));
  try {
    await generateReference({ destination });
    expect(await readFile(resolve(destination, "public/install.sh"))).toEqual(await readFile(resolve(root, INSTALLER_SOURCE)));
    const doc = await readFile(resolve(destination, "src/content/docs/reference/cli.md"), "utf8");
    expect(doc).toContain("## serve\n"); expect(doc).toContain("## convert\n");
    expect(doc).toContain("Released versions can differ");
  } finally { await rm(destination, { recursive: true, force: true }); }
});

test("changed CLI table syntax fails instead of publishing an incomplete inventory", () => {
  expect(() => commandReference("const commands = loadCommands();")).toThrow("literal command table");
  expect(() => commandReference('const commands = { ...other };')).toThrow("Unsupported CLI table property");
  expect(() => commandReference('const commands = { serve: { description: describe(), positional: "", options: {} } };')).toThrow("string description");
});

test("site links to executable examples and owns no second installer source", async () => {
  const guide = await readFile(resolve(root, "apps/website/src/content/docs/guides/library.md"), "utf8");
  const examples = [...guide.matchAll(/blob\/refactor\/monorepo\/(packages\/[^)]+\/examples\/[^)]+\.ts)/g)].map(match => match[1]!);
  expect(examples.length).toBeGreaterThan(0);
  for (const example of examples) expect((await readFile(resolve(root, example), "utf8")).length).toBeGreaterThan(0);
  expect(await readFile(resolve(root, "apps/website/.gitignore"), "utf8")).toContain("public/install.sh");
});
