// Machine-state preflight for fair benchmarks (Phase 15 method rules).
// Every failure mode here was MEASURED on this machine (PLAN findings):
//   - 6.4 GB swap residue: 26B decode 32 tok/s → 0.02 tok/s
//   - session drift: identical bf16 runs 15.5 vs 14.3 tok/s an hour apart
//   - cold page cache: prefill timer dominated by SSD page-in
// The harness refuses to record headline numbers when checks fail;
// the state snapshot is stored in every eval-DB row either way.

export interface MachineState {
  swapUsedMB: number;
  freePercent: number;
  /** pmset -g therm CPU_Speed_Limit (100 = no thermal throttle; -1 if
   *  unavailable on this platform). */
  cpuSpeedLimit: number;
  /** Foreign processes holding > bigRssMB resident (excludes kernel,
   *  WindowServer, and our own bun/python benchmark processes). */
  bigProcesses: { rssMB: number; command: string }[];
  ok: boolean;
  problems: string[];
  at: string;
}

export interface PreflightLimits {
  maxSwapUsedMB?: number;   // default 512
  minFreePercent?: number;  // default 35
  bigRssMB?: number;        // default 2048
}

function sh(cmd: string[]): string {
  const r = Bun.spawnSync(cmd, { stdout: "pipe", stderr: "pipe" });
  return r.exitCode === 0 ? r.stdout.toString() : "";
}

export function checkMachine(limits: PreflightLimits = {}): MachineState {
  const maxSwap = limits.maxSwapUsedMB ?? 512;
  const minFree = limits.minFreePercent ?? 35;
  const bigRss = limits.bigRssMB ?? 2048;
  const problems: string[] = [];

  // swap: "vm.swapusage: total = 7168.00M  used = 6413.06M  free = ..."
  const swapOut = sh(["sysctl", "vm.swapusage"]);
  const swapUsedMB = Number(swapOut.match(/used = ([\d.]+)M/)?.[1] ?? -1);
  if (swapUsedMB < 0) problems.push("could not read vm.swapusage");
  else if (swapUsedMB > maxSwap)
    problems.push(`swap in use: ${swapUsedMB.toFixed(0)} MB (> ${maxSwap} MB) — reboot before benchmarking`);

  // free memory: "System-wide memory free percentage: 34%"
  const memOut = sh(["memory_pressure", "-Q"]);
  const freePercent = Number(memOut.match(/free percentage: (\d+)/)?.[1] ?? -1);
  if (freePercent < 0) problems.push("could not read memory_pressure");
  else if (freePercent < minFree)
    problems.push(`free memory ${freePercent}% (< ${minFree}%) — close apps / reboot`);

  // thermal: "CPU_Speed_Limit     = 100"
  const thermOut = sh(["pmset", "-g", "therm"]);
  const speedMatch = thermOut.match(/CPU_Speed_Limit\s*=\s*(\d+)/);
  const cpuSpeedLimit = speedMatch ? Number(speedMatch[1]) : -1;
  if (cpuSpeedLimit !== -1 && cpuSpeedLimit < 100)
    problems.push(`thermal throttle active: CPU speed limit ${cpuSpeedLimit}% — let the machine cool`);

  // big foreign processes (rss in KB from ps)
  const SELF_PATTERN = /(bun|\.venv\/bin\/python|mlx_lm|optiq)/;
  const SYSTEM_PATTERN = /(kernel_task|WindowServer|launchd|mds|spotlight)/i;
  const bigProcesses: { rssMB: number; command: string }[] = [];
  for (const line of sh(["ps", "axo", "rss=,command="]).split("\n")) {
    const m = line.match(/^\s*(\d+)\s+(.*)$/);
    if (!m) continue;
    const rssMB = Number(m[1]) / 1024;
    const command = m[2]!.slice(0, 80);
    if (rssMB < bigRss) continue;
    if (SELF_PATTERN.test(command) || SYSTEM_PATTERN.test(command)) continue;
    bigProcesses.push({ rssMB: Math.round(rssMB), command });
  }
  for (const p of bigProcesses)
    problems.push(`big process resident: ${p.rssMB} MB — ${p.command}`);

  return {
    swapUsedMB, freePercent, cpuSpeedLimit, bigProcesses,
    ok: problems.length === 0,
    problems,
    at: new Date().toISOString(),
  };
}

/** Compact JSON for the eval-DB machine_state column. */
export function machineStateJson(s: MachineState): string {
  return JSON.stringify({
    swap_mb: Math.round(s.swapUsedMB),
    free_pct: s.freePercent,
    cpu_limit: s.cpuSpeedLimit,
    big_procs: s.bigProcesses.length,
    ok: s.ok,
    at: s.at,
  });
}
