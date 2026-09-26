import { afterEach, expect, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, rmSync, statSync, writeFileSync, mkdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  buildPlist, formatAt, installSchedule, LAUNCHD_LABEL, parseAt, plistPath, removeSchedule, SCHEDULE_NOTE, scheduleStatus,
} from "../../src/memory/schedule";

// Main's launchd schedule over an injected home and a recording launchctl: the
// real ~/Library/LaunchAgents and the real launchctl are never reached.

const homes: string[] = [];
afterEach(() => { for (const home of homes.splice(0)) rmSync(home, { recursive: true, force: true }); });
function home(): string { const dir = mkdtempSync(join(tmpdir(), "mlx-schedule-")); homes.push(dir); return dir; }
function recorder(answer: (args: string[]) => boolean = () => true) {
  const calls: string[][] = [];
  return { calls, launchctl: async (args: string[]) => { calls.push(args); return answer(args); } };
}
const program = ["/opt/mlx-bun/bin/mlx-bun"];

test("parseAt accepts HH:MM, clamps out-of-range fields, and defaults to 03:00", () => {
  expect(parseAt("04:30")).toEqual({ hour: 4, minute: 30 });
  expect(parseAt("7:05")).toEqual({ hour: 7, minute: 5 });
  expect(parseAt(" 23:59 ")).toEqual({ hour: 23, minute: 59 });
  expect(parseAt("25:70")).toEqual({ hour: 23, minute: 59 });
  expect(parseAt("00:00")).toEqual({ hour: 0, minute: 0 });
  for (const bad of [undefined, "", "3", "3:5", "03:00:00", "noon", "3.30", "-1:00"]) expect(parseAt(bad)).toEqual({ hour: 3, minute: 0 });
  expect(formatAt(parseAt("7:05"))).toBe("07:05");
  expect(formatAt(parseAt(undefined))).toBe("03:00");
});

test("the plist is main's launchd agent: login shell, exec of the injected program, calendar interval, logs under the home", () => {
  const plist = buildPlist({ at: "02:15", program }, "/Users/someone");
  expect(plist.startsWith('<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n')).toBe(true);
  expect(plist).toContain(`    <key>Label</key>\n    <string>${LAUNCHD_LABEL}</string>\n`);
  expect(plist).toContain("        <string>/bin/zsh</string>\n        <string>-lc</string>\n        <string>exec '/opt/mlx-bun/bin/mlx-bun' memory synthesize</string>\n");
  expect(plist).toContain("    <key>StartCalendarInterval</key>\n    <dict>\n        <key>Hour</key>\n        <integer>2</integer>\n        <key>Minute</key>\n        <integer>15</integer>\n    </dict>\n");
  expect(plist).toContain("    <key>RunAtLoad</key>\n    <false/>\n");
  expect(plist).toContain("    <key>StandardOutPath</key>\n    <string>/Users/someone/.mlx-bun/logs/memory-synthesis.out.log</string>\n");
  expect(plist).toContain("    <key>StandardErrorPath</key>\n    <string>/Users/someone/.mlx-bun/logs/memory-synthesis.err.log</string>\n");
  expect(plist).toContain("    <key>ProcessType</key>\n    <string>Background</string>\n</dict>\n</plist>\n");
  expect(plist).not.toContain(process.execPath);
  // Default time; a source run carries the CLI entry after the runtime; shell and XML quoting.
  expect(buildPlist({ program }, "/h")).toContain("<integer>3</integer>\n        <key>Minute</key>\n        <integer>0</integer>");
  expect(buildPlist({ program: ["/usr/local/bin/bun", "/src/cli/main.ts"] }, "/h")).toContain("exec '/usr/local/bin/bun' '/src/cli/main.ts' memory synthesize");
  expect(buildPlist({ program: ["/Apps/it's <mlx> & co/mlx-bun"] }, "/h"))
    .toContain("<string>exec '/Apps/it'\\''s &lt;mlx&gt; &amp; co/mlx-bun' memory synthesize</string>");
  expect(() => buildPlist({ program: [] }, "/h")).toThrow("memory schedule: the job's program is required");
});

test("install writes the plist under the injected home, creates the log directory, and reloads through launchctl", async () => {
  const dir = home();
  const { calls, launchctl } = recorder();
  const result = await installSchedule({ at: "04:30", program }, { home: dir, launchctl });
  const path = join(dir, "Library", "LaunchAgents", `${LAUNCHD_LABEL}.plist`);
  expect(plistPath(dir)).toBe(path);
  expect(result).toEqual({ plistPath: path, at: { hour: 4, minute: 30 }, loaded: true });
  expect(readFileSync(path, "utf8")).toBe(buildPlist({ at: "04:30", program }, dir));
  expect(statSync(join(dir, ".mlx-bun", "logs")).isDirectory()).toBe(true);
  expect(calls).toEqual([["unload", path], ["load", "-w", path]]);
  // Reinstalling overwrites the time and reloads again; a failed load is reported, never thrown.
  const failing = recorder(args => args[0] !== "load");
  const again = await installSchedule({ at: "23:05", program }, { home: dir, launchctl: failing.launchctl });
  expect(again).toEqual({ plistPath: path, at: { hour: 23, minute: 5 }, loaded: false });
  expect(readFileSync(path, "utf8")).toContain("<integer>23</integer>\n        <key>Minute</key>\n        <integer>5</integer>");
  expect(failing.calls).toEqual([["unload", path], ["load", "-w", path]]);
});

test("remove unloads with -w and deletes the plist; nothing installed means no launchctl call", async () => {
  const dir = home();
  const { calls, launchctl } = recorder();
  expect(await removeSchedule({ home: dir, launchctl })).toBe(false);
  expect(calls).toEqual([]);
  await installSchedule({ program }, { home: dir, launchctl });
  const path = plistPath(dir);
  calls.length = 0;
  expect(await removeSchedule({ home: dir, launchctl })).toBe(true);
  expect(calls).toEqual([["unload", "-w", path]]);
  expect(existsSync(path)).toBe(false);
  expect(await removeSchedule({ home: dir, launchctl })).toBe(false);
});

test("status reports not installed, installed (loaded or not) with the plist's time, and the honest note", async () => {
  const dir = home();
  const { calls, launchctl } = recorder(args => args[0] === "list");
  const path = plistPath(dir);
  expect(await scheduleStatus({ home: dir, launchctl })).toEqual({ installed: false, plistPath: path, loaded: false, at: null, note: SCHEDULE_NOTE });
  expect(calls).toEqual([]);
  await installSchedule({ at: "1:07", program }, { home: dir, launchctl });
  calls.length = 0;
  expect(await scheduleStatus({ home: dir, launchctl })).toEqual({ installed: true, plistPath: path, loaded: true, at: { hour: 1, minute: 7 }, note: SCHEDULE_NOTE });
  expect(calls).toEqual([["list", LAUNCHD_LABEL]]);
  const unloaded = recorder(() => false);
  expect((await scheduleStatus({ home: dir, launchctl: unloaded.launchctl })).loaded).toBe(false);
  expect(unloaded.calls).toEqual([["list", LAUNCHD_LABEL]]);
  // A hand-edited plist without a calendar interval still counts as installed, with no time.
  writeFileSync(path, "<plist><dict><key>Label</key><string>x</string></dict></plist>\n");
  expect(await scheduleStatus({ home: dir, launchctl })).toMatchObject({ installed: true, loaded: true, at: null });
  expect(SCHEDULE_NOTE).toBe("runs mlx-bun memory synthesize, which needs a serving mlx-bun (mlx-bun serve) at that time");
});

test("the default home is the process home, so a temporary HOME confines the plist path", () => {
  // In-process os.homedir() ignores later HOME mutations, so the seam is the only way a test redirects it.
  const dir = home();
  mkdirSync(join(dir, "Library", "LaunchAgents"), { recursive: true });
  expect(plistPath(dir)).toBe(join(dir, "Library", "LaunchAgents", "com.mlx-bun.memory.plist"));
  expect(plistPath()).toBe(join(process.env.HOME ?? "", "Library", "LaunchAgents", "com.mlx-bun.memory.plist"));
});
