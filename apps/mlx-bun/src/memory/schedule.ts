// mlx-bun memory — nightly scheduling via launchd, main's src/memory/schedule.ts.
//
// mlx-bun is macOS/Apple-silicon-only by identity, so launchd is the native
// choice over crontab: it survives reboot, runs jobs missed while asleep on
// next wake, and gives clean install/uninstall. `memory schedule` writes
// ~/Library/LaunchAgents/com.mlx-bun.memory.plist (a StartCalendarInterval that
// runs `mlx-bun memory synthesize`) and loads it; `unschedule` unloads + removes
// it. The plist, the launchd log paths, and the calendar interval are main's.
//
// Every persistent-system touch is a seam: the home directory (plist + logs),
// the `launchctl` runner, and the program launchd executes. Composition supplies
// the executable identity captured at startup (jobs/executable.ts); this domain
// never reads process.execPath, and tests inject a temporary home and a
// recording launchctl so the real launchd is never reached.
//
// Deviation from main: synthesis now reaches the model through a serving
// mlx-bun, so the job needs `mlx-bun serve` running at its time. The status
// carries that note so every surface reports the schedule honestly.

import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

export const LAUNCHD_LABEL = "com.mlx-bun.memory";

/** What the installed job does and what it needs; every status surface prints it. */
export const SCHEDULE_NOTE = "runs mlx-bun memory synthesize, which needs a serving mlx-bun (mlx-bun serve) at that time";

/** The persistent system the schedule touches; composition uses the real one. */
export interface LaunchdSystem {
  /** Home directory whose Library/LaunchAgents and .mlx-bun/logs the job uses. */
  home: string;
  /** Run `launchctl <args>`; resolves true on exit 0, false otherwise (never throws). */
  launchctl(args: string[]): Promise<boolean>;
}

async function runLaunchctl(args: string[]): Promise<boolean> {
  try {
    const proc = Bun.spawn(["launchctl", ...args], { stdin: "ignore", stdout: "ignore", stderr: "ignore" });
    return (await proc.exited) === 0;
  } catch {
    return false;
  }
}

function system(supplied: Partial<LaunchdSystem>): LaunchdSystem {
  return { home: supplied.home ?? homedir(), launchctl: supplied.launchctl ?? runLaunchctl };
}

export function plistPath(home = homedir()): string {
  return join(home, "Library", "LaunchAgents", `${LAUNCHD_LABEL}.plist`);
}

function logsDir(home: string): string {
  return join(home, ".mlx-bun", "logs");
}

function shQuote(s: string): string {
  return `'${s.replace(/'/g, "'\\''")}'`;
}

function xmlEscape(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

export interface ScheduleOptions {
  /** Local wall-clock time, "HH:MM" 24h. Default 03:00. */
  at?: string;
  /** The command launchd runs before `memory synthesize`: the executable
   *  captured at startup, plus the CLI entry when running from source. */
  program: readonly string[];
}

export interface ClockTime { hour: number; minute: number }

/** Parse "HH:MM" → {hour, minute}; defaults to 03:00 on bad/empty input. */
export function parseAt(at?: string): ClockTime {
  const m = /^(\d{1,2}):(\d{2})$/.exec((at ?? "").trim());
  if (!m) return { hour: 3, minute: 0 };
  const hour = Math.min(23, Math.max(0, Number(m[1])));
  const minute = Math.min(59, Math.max(0, Number(m[2])));
  return { hour, minute };
}

/** "HH:MM" for a parsed time (main's fmtAt). */
export function formatAt(at: ClockTime): string {
  return `${String(at.hour).padStart(2, "0")}:${String(at.minute).padStart(2, "0")}`;
}

/** Pure: build the launchd plist XML for the nightly synthesis job. */
export function buildPlist(opts: ScheduleOptions, home = homedir()): string {
  const { hour, minute } = parseAt(opts.at);
  if (!opts.program.length) throw new Error("memory schedule: the job's program is required");
  // Login shell so the user's PATH resolves under launchd.
  const cmd = `exec ${opts.program.map(shQuote).join(" ")} memory synthesize`;
  const out = join(logsDir(home), "memory-synthesis.out.log");
  const err = join(logsDir(home), "memory-synthesis.err.log");
  return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LAUNCHD_LABEL}</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>-lc</string>
        <string>${xmlEscape(cmd)}</string>
    </array>

    <!-- Local wall-clock; if asleep at the time, launchd runs on next wake. -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>${hour}</integer>
        <key>Minute</key>
        <integer>${minute}</integer>
    </dict>

    <key>RunAtLoad</key>
    <false/>

    <key>StandardOutPath</key>
    <string>${xmlEscape(out)}</string>
    <key>StandardErrorPath</key>
    <string>${xmlEscape(err)}</string>

    <key>ProcessType</key>
    <string>Background</string>
</dict>
</plist>
`;
}

export interface InstallResult {
  plistPath: string;
  at: ClockTime;
  loaded: boolean;
}

/** Write the plist and (re)load it into launchd. */
export async function installSchedule(opts: ScheduleOptions, supplied: Partial<LaunchdSystem> = {}): Promise<InstallResult> {
  const { home, launchctl } = system(supplied);
  const path = plistPath(home);
  const content = buildPlist(opts, home);
  await mkdir(join(home, "Library", "LaunchAgents"), { recursive: true });
  await mkdir(logsDir(home), { recursive: true });
  await writeFile(path, content);
  // Reload: unload first (ignore failure if not loaded), then load -w.
  await launchctl(["unload", path]);
  const loaded = await launchctl(["load", "-w", path]);
  return { plistPath: path, at: parseAt(opts.at), loaded };
}

/** Unload and remove the launchd agent. Returns true if a plist was removed. */
export async function removeSchedule(supplied: Partial<LaunchdSystem> = {}): Promise<boolean> {
  const { home, launchctl } = system(supplied);
  const path = plistPath(home);
  if (!existsSync(path)) return false;
  await launchctl(["unload", "-w", path]);
  await rm(path, { force: true });
  return true;
}

export interface ScheduleStatus {
  installed: boolean;
  plistPath: string;
  /** Whether launchctl currently lists the agent (best-effort). */
  loaded: boolean;
  /** The plist's calendar time; null when not installed or hand-edited beyond recognition. */
  at: ClockTime | null;
  /** SCHEDULE_NOTE: what the job runs and needs. */
  note: string;
}

/** The plist's StartCalendarInterval, read back so status reports the real time. */
function readAt(content: string): ClockTime | null {
  const hour = /<key>Hour<\/key>\s*<integer>(\d+)<\/integer>/.exec(content);
  const minute = /<key>Minute<\/key>\s*<integer>(\d+)<\/integer>/.exec(content);
  if (!hour || !minute) return null;
  return parseAt(`${hour[1]}:${minute[1]!.padStart(2, "0")}`);
}

export async function scheduleStatus(supplied: Partial<LaunchdSystem> = {}): Promise<ScheduleStatus> {
  const { home, launchctl } = system(supplied);
  const path = plistPath(home);
  const installed = existsSync(path);
  let loaded = false;
  let at: ClockTime | null = null;
  if (installed) {
    loaded = await launchctl(["list", LAUNCHD_LABEL]);
    try { at = readAt(await readFile(path, "utf8")); } catch { at = null; }
  }
  return { installed, plistPath: path, loaded, at, note: SCHEDULE_NOTE };
}
