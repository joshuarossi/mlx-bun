import { afterEach, expect, spyOn, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { parseCommand } from "../src/cli/args";
import { runMemory } from "../src/cli/memory";
import { LAUNCHD_LABEL, SCHEDULE_NOTE } from "../src/memory/schedule";

// `mlx-bun setup` / `mlx-bun memory {init,setup,schedule,unschedule,status}`:
// main's onboarding wizard and launchd schedule. In-process runs inject a
// temporary home, a recording launchctl, the job's program, and scripted
// answers; spawned runs get a temporary HOME and a non-TTY stdin, so nothing
// here ever reaches the real ~/Library/LaunchAgents, launchctl, or ~/.mlx-bun.

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
const strip = (s: string) => s.replace(/\x1b\[[0-9;]*m/g, "");
const homes: string[] = [];
const color = process.env.NO_COLOR;
afterEach(() => {
  for (const home of homes.splice(0)) rmSync(home, { recursive: true, force: true });
  if (color === undefined) delete process.env.NO_COLOR; else process.env.NO_COLOR = color;
});
function home() {
  const root = mkdtempSync(join(tmpdir(), "mlx-setup-cli-"));
  homes.push(root);
  return { home: root, vault: join(root, "vault"), plist: join(root, "Library", "LaunchAgents", `${LAUNCHD_LABEL}.plist`) };
}

/** Run the verb in-process with every persistent seam injected (the vault root
 *  is a seam too: the process-wide MLX_BUN_WIKI is read once at startup, so an
 *  environment override cannot redirect it); captures the console (box, step,
 *  banner lines) with ANSI stripped. */
async function drive(paths: { home: string; vault: string }, argv: string[], options: { answers?: string[]; load?: boolean; program?: string[] } = {}) {
  process.env.NO_COLOR = "1";
  const out: string[] = [], err: string[] = [], calls: string[][] = [], questions: string[] = [];
  const answers = [...(options.answers ?? [])];
  const log = spyOn(console, "log").mockImplementation((...parts: unknown[]) => { out.push(parts.map(String).join(" ")); });
  const error = spyOn(console, "error").mockImplementation((...parts: unknown[]) => { err.push(parts.map(String).join(" ")); });
  try {
    const [verb, ...rest] = argv as [("memory" | "setup"), ...string[]];
    await runMemory(parseCommand(verb, rest), {
      vault: paths.vault,
      home: paths.home,
      launchctl: async (args) => { calls.push(args); return args[0] === "load" ? options.load ?? true : true; },
      ...(options.program ? { program: options.program } : {}),
      ask: async (question, fallback) => { questions.push(question); return (answers.shift() ?? "").trim() || fallback; },
    });
  } finally { log.mockRestore(); error.mockRestore(); }
  // Tripwire: nothing in-process may name the real home's vault or agents.
  for (const line of [...out, ...err]) expect(line).not.toContain(join(homedir(), ".mlx-bun"));
  return { out: strip(out.join("\n")), err: strip(err.join("\n")), calls, questions };
}

async function cli(paths: { home: string; vault: string }, ...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, ...args], {
    env: { ...process.env, HOME: paths.home, MLX_BUN_WIKI: paths.vault, NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib", HF_HUB_OFFLINE: "1" },
    stdin: "ignore", stdout: "pipe", stderr: "pipe",
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

const SEED_PROMPT = (home: string) => `\n  Seed from an existing wiki? Enter its path, or blank to skip [${join(home, "Dreaming")}]: `;
const INSTALL_PROMPT = "  Install the nightly synthesis job (runs in the background)? [y/N] ";
const AT_PROMPT = "    At what time? 24h HH:MM [03:00]: ";

test("memory schedule installs the launchd job at --at through the seams, status reports it, unschedule removes it", async () => {
  const paths = home();
  const scheduled = await drive(paths, ["memory", "schedule", "--at", "04:30"], { program: ["/opt/mlx-bun/bin/mlx-bun"] });
  expect(scheduled.out).toContain("● nightly synthesis scheduled · 04:30 daily");
  expect(scheduled.out).toContain(`plist      ${paths.plist}`);
  expect(scheduled.out).toContain("runs       mlx-bun memory synthesize (full DAG: create + wikify sweep)");
  expect(scheduled.out).toContain("needs      a serving mlx-bun (mlx-bun serve) at that time");
  expect(scheduled.out).toContain("undo       mlx-bun memory unschedule");
  expect(scheduled.calls).toEqual([["unload", paths.plist], ["load", "-w", paths.plist]]);
  const plist = readFileSync(paths.plist, "utf8");
  expect(plist).toContain("<string>exec '/opt/mlx-bun/bin/mlx-bun' memory synthesize</string>");
  expect(plist).toContain("<integer>4</integer>\n        <key>Minute</key>\n        <integer>30</integer>");
  expect(plist).toContain(`<string>${join(paths.home, ".mlx-bun", "logs", "memory-synthesis.out.log")}</string>`);
  expect(existsSync(join(paths.home, ".mlx-bun", "logs"))).toBe(true);
  // Status needs a vault; the nightly line reads the plist back and states what the job needs.
  mkdirSync(join(paths.vault, "articles"), { recursive: true });
  const status = await drive(paths, ["memory", "status"]);
  expect(status.out).toContain(`nightly    scheduled · 04:30 daily · ${paths.plist}`);
  expect(status.out).toContain(`           ${SCHEDULE_NOTE}`);
  expect(status.calls).toEqual([["list", LAUNCHD_LABEL]]);
  const removed = await drive(paths, ["memory", "unschedule"]);
  expect(removed.out).toBe("nightly synthesis job removed");
  expect(removed.calls).toEqual([["unload", "-w", paths.plist]]);
  expect(existsSync(paths.plist)).toBe(false);
  const again = await drive(paths, ["memory", "unschedule"]);
  expect(again.out).toBe("no nightly job was installed");
  expect(again.calls).toEqual([]);
  const after = await drive(paths, ["memory", "status"]);
  expect(after.out).toContain("nightly    not scheduled · mlx-bun memory schedule");
  expect(after.out).not.toContain(SCHEDULE_NOTE);
  expect(after.calls).toEqual([]);
});

test("the default job program is the startup executable plus this CLI entry, never a PATH lookup; a failed load is reported", async () => {
  const paths = home();
  const result = await drive(paths, ["memory", "schedule"], { load: false });
  expect(result.out).toContain("● plist written, but launchctl load failed");
  expect(result.out).toContain(`plist      ${paths.plist}`);
  const plist = readFileSync(paths.plist, "utf8");
  expect(plist).toContain(`<string>exec '${process.execPath}' '${resolve(import.meta.dir, "../src/cli/main.ts")}' memory synthesize</string>`);
  expect(plist).toContain("<integer>3</integer>\n        <key>Minute</key>\n        <integer>0</integer>");
  mkdirSync(join(paths.vault, "articles"), { recursive: true });
  const status = await drive(paths, ["memory", "status"]);
  // The recording launchctl answers `list` with true, so the agent counts as loaded.
  expect(status.out).toContain("nightly    scheduled · 03:00 daily");
});

test("setup init accepts the nightly job: main's prompts verbatim, plist at the answered time, launchctl reload, ready card", async () => {
  const paths = home();
  const result = await drive(paths, ["setup", "init"], { answers: ["", "y", "02:15"], program: ["/opt/mlx-bun/bin/mlx-bun"] });
  expect(result.questions).toEqual([SEED_PROMPT(paths.home), INSTALL_PROMPT, AT_PROMPT]);
  expect(result.out).toContain("mlx-bun 0.0.0 — local AI · apple silicon · one binary");
  expect(result.out).toContain("● Personal memory for your local AI");
  expect(result.out).toContain(`git-tracked at ${paths.vault}, editable in any tool, and it`);
  expect(result.out).toContain(`  ✓ wiki ready · ${paths.vault}`);
  expect(result.out).toContain("  Synthesis (turning your conversations into articles) runs as a nightly job;\n  install it now so your wiki stays current automatically.\n  The job needs a serving mlx-bun (mlx-bun serve) running at that time.");
  expect(result.out).toContain(`  ✓ nightly job installed · 02:15 · ${paths.plist}`);
  expect(result.out).toContain("● memory is set up · 0 article(s) · 0 reference doc(s)");
  expect(result.out).toContain("chat now   mlx-bun serve — the assistant now reads your memory automatically");
  expect(result.out).toContain("inspect    mlx-bun memory status · mlx-bun memory search <q>");
  expect(result.out).toContain(`browse     open ${paths.vault} in Obsidian, or any editor`);
  expect(result.out).toContain("nightly    scheduled · 02:15 daily · mlx-bun memory unschedule to undo");
  expect(result.out).toContain("articles, then an editorial wikify sweep. Run it now: mlx-bun memory synthesize.");
  expect(result.calls).toEqual([["unload", paths.plist], ["load", "-w", paths.plist]]);
  expect(readFileSync(paths.plist, "utf8")).toContain("<integer>2</integer>\n        <key>Minute</key>\n        <integer>15</integer>");
  for (const file of ["README.md", ".gitignore", "Meta/Editorial_Guidelines.md", "articles", "Reference", "Talk", ".git"]) expect(existsSync(join(paths.vault, file))).toBe(true);
  // Idempotent: a second pass reports the existing wiki and asks again; declining leaves the plist alone.
  const again = await drive(paths, ["memory", "setup"], { answers: ["", "n"] });
  expect(again.out).toContain(`  ✓ already set up · ${paths.vault}`);
  expect(again.questions).toEqual([SEED_PROMPT(paths.home), INSTALL_PROMPT]);
  expect(again.calls).toEqual([]);
  expect(existsSync(paths.plist)).toBe(true);
});

test("setup init declines the nightly job by default and imports a seed vault only after confirmation", async () => {
  const paths = home();
  const declined = await drive(paths, ["memory", "init"], { answers: ["", ""] });
  expect(declined.questions).toEqual([SEED_PROMPT(paths.home), INSTALL_PROMPT]);
  expect(declined.out).toContain("nightly    not scheduled · mlx-bun memory schedule to set it up");
  expect(declined.calls).toEqual([]);
  expect(existsSync(paths.plist)).toBe(false);
  expect(existsSync(join(paths.home, "Library"))).toBe(false);
  // A seed path without articles is skipped without a prompt; one with articles asks (default yes) and commits.
  const empty = join(paths.home, "empty-seed");
  mkdirSync(empty, { recursive: true });
  const skipped = await drive(paths, ["memory", "init"], { answers: [empty, "n"] });
  expect(skipped.out).toContain(`  no articles found under ${join(empty, "articles")} — skipping import`);
  expect(skipped.questions).toEqual([SEED_PROMPT(paths.home), INSTALL_PROMPT]);
  const seed = join(paths.home, "Dreaming");
  mkdirSync(join(seed, "articles"), { recursive: true });
  writeFileSync(join(seed, "articles", "Alpha.md"), "# Alpha\n\nSeeded.\n");
  writeFileSync(join(seed, "articles", "Beta.md"), "# Beta\n\nSeeded too.\n");
  writeFileSync(join(seed, "articles", "notes.txt"), "not an article");
  const imported = await drive(paths, ["memory", "init"], { answers: ["~/Dreaming", "", "n"] });
  expect(imported.questions).toEqual([SEED_PROMPT(paths.home), `  Import 2 article(s) from ${join(seed, "articles")}? [Y/n] `, INSTALL_PROMPT]);
  expect(imported.out).toContain("  ✓ imported 2 article(s)");
  expect(imported.out).toContain("● memory is set up · 2 article(s) · 0 reference doc(s)");
  expect(readFileSync(join(paths.vault, "articles", "Alpha.md"), "utf8")).toBe("# Alpha\n\nSeeded.\n");
  expect(existsSync(join(paths.vault, "articles", "notes.txt"))).toBe(false);
  const log = Bun.spawnSync(["git", "log", "--format=%s"], { cwd: paths.vault });
  expect(log.stdout.toString()).toBe("Import 2 article(s) from ~/Dreaming\nInitialize mlx-bun memory wiki\n");
  const refused = await drive(paths, ["memory", "init"], { answers: ["~/Dreaming", "n", "n"] });
  expect(refused.out).not.toContain("imported");
  expect(refused.calls).toEqual([]);
});

test("a non-interactive setup creates the wiki, never prompts, and installs nothing under HOME", async () => {
  const paths = home();
  const result = await cli(paths, "setup", "init");
  expect(result.code).toBe(0);
  expect(result.err).toBe("");
  expect(result.out).toContain("mlx-bun 0.0.0 — local AI · apple silicon · one binary");
  expect(result.out).toContain("  - creating your wiki\n");
  expect(result.out).toContain(`  ✓ wiki ready · ${paths.vault}\n`);
  expect(result.out).not.toContain("Seed from an existing wiki?");
  expect(result.out).not.toContain("Install the nightly synthesis job");
  expect(result.out).toContain("nightly    not scheduled · mlx-bun memory schedule to set it up");
  expect(result.out).toContain("● memory is set up · 0 article(s) · 0 reference doc(s)");
  expect(existsSync(join(paths.vault, "Meta", "Editorial_Guidelines.md"))).toBe(true);
  expect(existsSync(join(paths.home, "Library"))).toBe(false);
  expect(existsSync(join(paths.home, ".mlx-bun"))).toBe(false);
  // `mlx-bun setup` is main's true alias of `mlx-bun memory`: bare, it reports status.
  const status = await cli(paths, "setup");
  expect(status.code).toBe(0);
  expect(status.out).toContain(`memory · ${paths.vault}`);
  expect(status.out).toContain("git        tracked");
  expect(status.out).toContain("nightly    not scheduled · mlx-bun memory schedule");
  const viaMemory = await cli(paths, "memory", "setup");
  expect(viaMemory.code).toBe(0);
  expect(viaMemory.out).toContain(`  ✓ already set up · ${paths.vault}`);
  const fresh = home();
  expect((await cli(fresh, "setup")).out).toContain("set one up:  mlx-bun memory init");
});

test("setup --help and memory schedule --help document the wizard, the schedule, and --at without running anything", async () => {
  const paths = home();
  const setup = await cli(paths, "setup", "--help");
  expect(setup.code).toBe(0);
  expect(setup.err).toBe("");
  expect(setup.out).toContain("mlx-bun setup — Set up your local AI's memory wiki (alias of mlx-bun memory)");
  expect(setup.out).toContain("Usage: mlx-bun setup [subcommand] [args] [options]");
  expect(setup.out).toContain("  init, setup        Create the wiki + walk through setup (idempotent);");
  expect(setup.out).toContain("  schedule           Install the nightly launchd job (--at HH:MM [03:00]);");
  expect(setup.out).toContain("  unschedule         Remove the nightly launchd job");
  expect(setup.out).toContain("--at <value>");
  const schedule = await cli(paths, "memory", "schedule", "--help");
  expect(schedule.code).toBe(0);
  expect(schedule.out).toContain("Usage: mlx-bun memory [subcommand] [args] [options]");
  expect(schedule.out).toContain("--at <value>             schedule: local wall-clock time for the nightly job, 24h HH:MM [default: 03:00]");
  expect(existsSync(join(paths.home, "Library"))).toBe(false);
  expect(existsSync(paths.vault)).toBe(false);
  const overview = await cli(paths, "--help");
  expect(overview.out).toMatch(/\n  setup\s+Set up your local AI's memory wiki \(alias of mlx-bun memory\)\n/);
  expect((await cli(paths, "setup", "--at")).code).toBe(1);
});
