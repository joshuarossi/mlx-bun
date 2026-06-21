// mlx-bun memory — nightly scheduling via launchd.  ✅ REAL (the pipeline it
// runs is the M1 stub, but install/remove/status here are fully functional).
//
// mlx-bun is macOS/Apple-silicon-only by identity, so launchd is the native
// choice over crontab: it survives reboot, runs jobs missed while asleep on
// next wake, and gives clean install/uninstall. `memory schedule` writes
// ~/Library/LaunchAgents/com.mlx-bun.memory.plist (a StartCalendarInterval that
// runs `mlx-bun memory synthesize`) and loads it; `unschedule` unloads + removes
// it. Today that job is a no-op (synthesis is stubbed) — harmless; when M1 lands
// the same schedule starts producing articles with no reconfiguration.
//
// See docs/design/memory-system.md → "Scheduling (launchd)".

import { spawn } from "node:child_process";
import { mkdir, rm, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

export const LAUNCHD_LABEL = "com.mlx-bun.memory";

export function plistPath(): string {
  return join(homedir(), "Library", "LaunchAgents", `${LAUNCHD_LABEL}.plist`);
}

function logsDir(): string {
  return join(homedir(), ".mlx-bun", "logs");
}

/**
 * Resolve how to invoke mlx-bun from launchd's minimal environment. Prefer the
 * installed binary on PATH; fall back to the current dev invocation
 * (`<bun> <cli.ts>`). Wrapped in a login shell at call time so PATH/bun resolve.
 */
function mlxBunCommand(): string {
  const onPath = Bun.which("mlx-bun");
  if (onPath) return shQuote(onPath);
  // Dev: process.execPath is bun, argv[1] is .../src/cli.ts.
  return `${shQuote(process.execPath)} ${shQuote(process.argv[1] ?? "")}`.trim();
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
}

/** Parse "HH:MM" → {hour, minute}; defaults to 03:00 on bad/empty input. */
export function parseAt(at?: string): { hour: number; minute: number } {
  const m = /^(\d{1,2}):(\d{2})$/.exec((at ?? "").trim());
  if (!m) return { hour: 3, minute: 0 };
  const hour = Math.min(23, Math.max(0, Number(m[1])));
  const minute = Math.min(59, Math.max(0, Number(m[2])));
  return { hour, minute };
}

/** Pure: build the launchd plist XML for the nightly synthesis job. */
export function buildPlist(opts: ScheduleOptions = {}): string {
  const { hour, minute } = parseAt(opts.at);
  // Login shell so the user's PATH (bun, mlx-bun) resolves under launchd.
  const cmd = `exec ${mlxBunCommand()} memory synthesize`;
  const out = join(logsDir(), "memory-synthesis.out.log");
  const err = join(logsDir(), "memory-synthesis.err.log");
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

function launchctl(args: string[]): Promise<boolean> {
  return new Promise((resolve) => {
    const proc = spawn("launchctl", args, { stdio: "ignore" });
    proc.on("exit", (code) => resolve(code === 0));
    proc.on("error", () => resolve(false));
  });
}

export interface InstallResult {
  plistPath: string;
  at: { hour: number; minute: number };
  loaded: boolean;
}

/** Write the plist and (re)load it into launchd. */
export async function installSchedule(opts: ScheduleOptions = {}): Promise<InstallResult> {
  const path = plistPath();
  await mkdir(join(homedir(), "Library", "LaunchAgents"), { recursive: true });
  await mkdir(logsDir(), { recursive: true });
  await writeFile(path, buildPlist(opts));
  // Reload: unload first (ignore failure if not loaded), then load -w.
  await launchctl(["unload", path]);
  const loaded = await launchctl(["load", "-w", path]);
  return { plistPath: path, at: parseAt(opts.at), loaded };
}

/** Unload and remove the launchd agent. Returns true if a plist was removed. */
export async function removeSchedule(): Promise<boolean> {
  const path = plistPath();
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
}

export async function scheduleStatus(): Promise<ScheduleStatus> {
  const path = plistPath();
  const installed = existsSync(path);
  let loaded = false;
  if (installed) {
    loaded = await new Promise<boolean>((resolve) => {
      const proc = spawn("launchctl", ["list", LAUNCHD_LABEL], { stdio: "ignore" });
      proc.on("exit", (code) => resolve(code === 0));
      proc.on("error", () => resolve(false));
    });
  }
  return { installed, plistPath: path, loaded };
}
