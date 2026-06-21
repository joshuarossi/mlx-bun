// `mlx-bun train-watch <adapter-dir>` — a mactop-style live dashboard for a
// training run. It tails the trainer's append-only `<adapter>/metrics.jsonl`
// (written by trainLora) and renders auto-scaled line charts for loss, margin,
// accuracy (train line + val markers) and memory, plus a progress/ETA header.
//
// Decoupled by design: the trainer only writes the stream, this viewer only
// reads it. So it attaches/detaches freely to a LIVE run, replays a FINISHED
// one, and never touches training. The renderer is a PURE function
// (renderFrame) over parsed state, so it can be exercised against a captured
// fixture with no TTY.

import { readFileSync } from "node:fs";

// ---------------------------------------------------------------------------
// Parsed run state
// ---------------------------------------------------------------------------

export interface Pt { step: number; t: number; y: number }
/** A validation point — sparse (one per eval step). Accuracy carries its raw
 *  correct/total so it can be shown as a count, not a bare ratio. */
export interface ValPt extends Pt { nc?: number; nt?: number }
export interface RunState {
  meta: {
    method: string; model: string; iters: number; lambda?: number;
    lr?: number; seq?: number; startedAt?: number; adapterPath?: string;
  };
  // Dense per-iter series (a line per metric).
  loss: Pt[];
  margin: Pt[];
  trainAcc: Pt[];   // y ∈ {0,1} at B=1 — render as a rolling fraction, not raw
  mem: Pt[];        // y = active GB (resident — flat = no leak)
  peak: Pt[];       // y = peak GB (cumulative high-water — the climb-to-plateau)
  // Sparse per-eval series (markers, not lines — they only exist at eval steps).
  valAcc: ValPt[];
  valLoss: Pt[];
  peakGb: number;   // running high-water
  lastStep: number;
  lastT: number;
  done: boolean;
}

function emptyState(): RunState {
  return {
    meta: { method: "?", model: "", iters: 0 },
    loss: [], margin: [], trainAcc: [], mem: [], peak: [],
    valAcc: [], valLoss: [],
    peakGb: 0, lastStep: 0, lastT: 0, done: false,
  };
}

/** Fold one parsed JSONL record into the state. */
function ingest(s: RunState, o: Record<string, unknown>): void {
  const type = o.type;
  if (type === "meta") {
    s.meta = {
      method: String(o.method ?? "?"),
      model: String(o.model ?? ""),
      iters: Number(o.iters ?? 0),
      lambda: o.orpo_lambda != null ? Number(o.orpo_lambda) : undefined,
      lr: o.learning_rate != null ? Number(o.learning_rate) : undefined,
      seq: o.max_seq_length != null ? Number(o.max_seq_length) : undefined,
      startedAt: o.t != null ? Number(o.t) : undefined,
      adapterPath: o.adapter_path != null ? String(o.adapter_path) : undefined,
    };
    return;
  }
  if (type !== "metric") return;
  const step = Number(o.step), t = Number(o.t);
  if (!Number.isFinite(step)) return;
  if (o.kind === "train") {
    if (Number.isFinite(Number(o.loss))) s.loss.push({ step, t, y: Number(o.loss) });
    if (Number.isFinite(Number(o.margin))) s.margin.push({ step, t, y: Number(o.margin) });
    if (Number.isFinite(Number(o.accuracy))) s.trainAcc.push({ step, t, y: Number(o.accuracy) });
    if (Number.isFinite(Number(o.active_gb))) s.mem.push({ step, t, y: Number(o.active_gb) });
    if (Number.isFinite(Number(o.peak_gb))) {
      s.peak.push({ step, t, y: Number(o.peak_gb) });
      s.peakGb = Math.max(s.peakGb, Number(o.peak_gb));
    }
    s.lastStep = Math.max(s.lastStep, step);
    if (Number.isFinite(t)) s.lastT = Math.max(s.lastT, t);
  } else if (o.kind === "val") {
    if (Number.isFinite(Number(o.accuracy)))
      s.valAcc.push({ step, t, y: Number(o.accuracy),
        nc: o.n_correct != null ? Number(o.n_correct) : undefined,
        nt: o.n_total != null ? Number(o.n_total) : undefined });
    if (Number.isFinite(Number(o.loss))) s.valLoss.push({ step, t, y: Number(o.loss) });
  }
}

/** Build full state from a metrics.jsonl text blob (replay-from-start). */
export function parseStream(text: string): RunState {
  const s = emptyState();
  for (const line of text.split("\n")) {
    const t = line.trim();
    if (!t) continue;
    try { ingest(s, JSON.parse(t) as Record<string, unknown>); } catch { /* skip partial/garbled */ }
  }
  if (s.meta.iters > 0 && s.lastStep >= s.meta.iters) s.done = true;
  return s;
}

/** Median step time (seconds) from the last K train timestamps. */
export function sPerStep(s: RunState, k = 30): number {
  const pts = s.loss.slice(-k - 1);
  const d: number[] = [];
  for (let i = 1; i < pts.length; i++) {
    const dt = (pts[i]!.t - pts[i - 1]!.t) / 1000;
    if (dt > 0 && dt < 600) d.push(dt);
  }
  if (d.length === 0) return 0;
  d.sort((a, b) => a - b);
  return d[Math.floor(d.length / 2)]!;
}

// ---------------------------------------------------------------------------
// Cell grid compositor — the whole frame is built into a typed grid, then
// run-length colored on render. Unifies header / charts / axis labels / markers
// and sidesteps any mid-ANSI string splicing.
// ---------------------------------------------------------------------------

const DEFAULT_FG = -1;
interface Cell { ch: string; fg: number }

// 256-color palette (xterm).
const C = {
  dim: 240, axis: 244, label: 250, title: 255,
  loss: 203, margin: 78, accT: 45, accV: 207, mem: 221, ok: 78, warn: 203, accent: 81,
};

class Grid {
  rows: number; cols: number; cells: Cell[];
  constructor(rows: number, cols: number) {
    this.rows = rows; this.cols = cols;
    this.cells = new Array(rows * cols);
    for (let i = 0; i < this.cells.length; i++) this.cells[i] = { ch: " ", fg: DEFAULT_FG };
  }
  put(r: number, c: number, ch: string, fg = DEFAULT_FG): void {
    if (r < 0 || r >= this.rows || c < 0 || c >= this.cols) return;
    const cell = this.cells[r * this.cols + c]!;
    cell.ch = ch; cell.fg = fg;
  }
  text(r: number, c: number, str: string, fg = DEFAULT_FG): void {
    for (let i = 0; i < str.length; i++) this.put(r, c + i, str[i]!, fg);
  }
  /** Right-align str ending at column `cEnd`. */
  textRight(r: number, cEnd: number, str: string, fg = DEFAULT_FG): void {
    this.text(r, cEnd - str.length + 1, str, fg);
  }
  render(): string[] {
    const out: string[] = [];
    for (let r = 0; r < this.rows; r++) {
      let line = "", curFg = DEFAULT_FG;
      for (let c = 0; c < this.cols; c++) {
        const cell = this.cells[r * this.cols + c]!;
        if (cell.fg !== curFg) {
          line += cell.fg === DEFAULT_FG ? "\x1b[0m" : `\x1b[38;5;${cell.fg}m`;
          curFg = cell.fg;
        }
        line += cell.ch;
      }
      if (curFg !== DEFAULT_FG) line += "\x1b[0m";
      out.push(line);
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// Braille (2×4 dot) canvas — sub-cell line resolution for the charts.
// ---------------------------------------------------------------------------

// dot bit for (col∈{0,1}, row∈{0..3}) within a cell.
const DOT = [
  [0x01, 0x08],
  [0x02, 0x10],
  [0x04, 0x20],
  [0x40, 0x80],
];

class Braille {
  cols: number; rows: number; data: Uint8Array;
  constructor(cols: number, rows: number) {
    this.cols = cols; this.rows = rows;
    this.data = new Uint8Array(cols * rows);
  }
  setDot(dx: number, dy: number): void {
    const cx = dx >> 1, cy = dy >> 2;
    if (cx < 0 || cx >= this.cols || cy < 0 || cy >= this.rows) return;
    this.data[cy * this.cols + cx]! |= DOT[dy & 3]![dx & 1]!;
  }
  line(x0: number, y0: number, x1: number, y1: number): void {
    let dx = Math.abs(x1 - x0), dy = -Math.abs(y1 - y0);
    const sx = x0 < x1 ? 1 : -1, sy = y0 < y1 ? 1 : -1;
    let err = dx + dy;
    for (;;) {
      this.setDot(x0, y0);
      if (x0 === x1 && y0 === y1) break;
      const e2 = 2 * err;
      if (e2 >= dy) { err += dy; x0 += sx; }
      if (e2 <= dx) { err += dx; y0 += sy; }
    }
  }
  char(cx: number, cy: number): string | null {
    const b = this.data[cy * this.cols + cx]!;
    return b === 0 ? null : String.fromCodePoint(0x2800 | b);
  }
}

// ---------------------------------------------------------------------------
// One chart panel: title row + y-axis labels + braille plot + x-axis labels.
// ---------------------------------------------------------------------------

interface ChartOpts {
  title: string;
  series: Pt[];
  color: number;
  fixed?: [number, number];   // fixed y-range (e.g. accuracy 0..1)
  fmtY: (v: number) => string;
  headline?: string;          // colored value shown after the title
  alert?: string;             // warn-colored note after the headline (e.g. "▲ rising")
  zeroLine?: boolean;         // dashed y=0 reference
  refLine?: number;           // dashed reference rule at an arbitrary y (e.g. 0.5 chance)
  markers?: { pts: Pt[]; color: number }; // discrete sparse overlay (val points)
}

function fmtNum(v: number): string {
  if (!Number.isFinite(v)) return "—";
  const a = Math.abs(v);
  if (a >= 100) return v.toFixed(0);
  if (a >= 10) return v.toFixed(1);
  if (a >= 1) return v.toFixed(2);
  return v.toFixed(3);
}

function compactInt(n: number): string {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(n % 1_000_000 ? 1 : 0) + "M";
  if (n >= 10_000) return (n / 1000).toFixed(0) + "k";
  return String(n);
}

/** Draw a chart into `grid` at top-left (r0,c0) spanning (h rows, w cols). */
function drawChart(grid: Grid, r0: number, c0: number, h: number, w: number, o: ChartOpts): void {
  // Title line: title · headline (series color) · alert (warn).
  grid.text(r0, c0, o.title, C.title);
  let hx = c0 + o.title.length + 1;
  if (o.headline) { grid.text(r0, hx, o.headline, o.color); hx += o.headline.length + 2; }
  if (o.alert) grid.text(r0, hx, o.alert, C.warn);

  const plotTop = r0 + 1;
  const plotRows = h - 2;          // minus title + x-axis row
  if (plotRows < 1 || w < 12) return;

  const pts = o.series;
  // y-range.
  let ymin: number, ymax: number;
  if (o.fixed) { [ymin, ymax] = o.fixed; }
  else if (pts.length === 0) { ymin = 0; ymax = 1; }
  else {
    ymin = Infinity; ymax = -Infinity;
    for (const p of pts) { if (p.y < ymin) ymin = p.y; if (p.y > ymax) ymax = p.y; }
    if (o.markers) for (const p of o.markers.pts) { if (p.y < ymin) ymin = p.y; if (p.y > ymax) ymax = p.y; }
    if (o.zeroLine) { ymin = Math.min(ymin, 0); ymax = Math.max(ymax, 0); }
    if (ymin === ymax) { ymin -= 1; ymax += 1; }
    else { const pad = (ymax - ymin) * 0.08; ymin -= pad; ymax += pad; }
  }

  // gutter for y labels.
  const gutter = Math.max(o.fmtY(ymin).length, o.fmtY(ymax).length) + 1;
  const plotCols = w - gutter;
  if (plotCols < 4) return;

  // y-axis labels: top=max, bottom=min, mid where room.
  grid.textRight(plotTop, c0 + gutter - 2, o.fmtY(ymax), C.axis);
  grid.textRight(plotTop + plotRows - 1, c0 + gutter - 2, o.fmtY(ymin), C.axis);
  if (plotRows >= 5) grid.textRight(plotTop + (plotRows >> 1), c0 + gutter - 2, o.fmtY((ymin + ymax) / 2), C.axis);
  // vertical axis rule.
  for (let r = 0; r < plotRows; r++) grid.put(plotTop + r, c0 + gutter - 1, "│", C.dim);

  // x-range (step).
  const xmin = pts.length ? pts[0]!.step : 0;
  const xmax = pts.length ? pts[pts.length - 1]!.step : 1;
  const xspan = Math.max(1, xmax - xmin);

  const nDotX = plotCols * 2, nDotY = plotRows * 4;
  const canvas = new Braille(plotCols, plotRows);
  const mapX = (step: number) => Math.round(((step - xmin) / xspan) * (nDotX - 1));
  const mapY = (y: number) => Math.round((1 - (y - ymin) / (ymax - ymin)) * (nDotY - 1));

  // zero reference: a dim dotted grid rule the data line crosses (drawn first,
  // so the braille blit below overwrites it only where there's data).
  const drawRule = (yval: number) => {
    if (!(yval > ymin && yval < ymax)) return;
    const rRow = plotTop + Math.round((1 - (yval - ymin) / (ymax - ymin)) * (plotRows - 1));
    for (let c = 0; c < plotCols; c++) grid.put(rRow, c0 + gutter + c, "┄", C.dim);
  };
  if (o.zeroLine) drawRule(0);
  if (o.refLine != null) drawRule(o.refLine);

  // Downsample to keep line cost bounded on long runs.
  if (pts.length > 0) {
    const stride = Math.max(1, Math.floor(pts.length / (nDotX * 2)));
    let prevX = mapX(pts[0]!.step), prevY = mapY(pts[0]!.y);
    canvas.setDot(prevX, prevY);
    for (let i = stride; i < pts.length; i += stride) {
      const cx = mapX(pts[i]!.step), cy = mapY(pts[i]!.y);
      canvas.line(prevX, prevY, cx, cy);
      prevX = cx; prevY = cy;
    }
    // always connect the final point.
    const last = pts[pts.length - 1]!;
    canvas.line(prevX, prevY, mapX(last.step), mapY(last.y));
  }

  // Blit braille into grid.
  for (let r = 0; r < plotRows; r++)
    for (let c = 0; c < plotCols; c++) {
      const ch = canvas.char(c, r);
      if (ch) grid.put(plotTop + r, c0 + gutter + c, ch, o.color);
    }

  // Discrete markers (val accuracy) overlaid as ●.
  if (o.markers) {
    for (const p of o.markers.pts) {
      const cx = c0 + gutter + Math.round(((p.step - xmin) / xspan) * (plotCols - 1));
      const cy = plotTop + Math.round((1 - (p.y - ymin) / (ymax - ymin)) * (plotRows - 1));
      grid.put(cy, cx, "●", o.markers.color);
    }
  }

  // x-axis labels row.
  const axisRow = plotTop + plotRows;
  grid.text(axisRow, c0 + gutter, compactInt(xmin), C.axis);
  grid.textRight(axisRow, c0 + gutter + plotCols - 1, compactInt(xmax), C.axis);
}

// ---------------------------------------------------------------------------
// Full-frame renderer (pure).
// ---------------------------------------------------------------------------

/** Rolling MEDIAN over a trailing window — robust trend for a metric whose
 *  per-step value is per-example (B=1 loss spikes on a long/hard pair are
 *  rejected, unlike a mean). This is what makes the loss trend legible. */
function rollingMedian(pts: Pt[], w: number): Pt[] {
  const out: Pt[] = [];
  for (let i = 0; i < pts.length; i++) {
    const lo = Math.max(0, i - w + 1);
    const win: number[] = [];
    for (let j = lo; j <= i; j++) win.push(pts[j]!.y);
    win.sort((a, b) => a - b);
    out.push({ step: pts[i]!.step, t: pts[i]!.t, y: win[win.length >> 1]! });
  }
  return out;
}

function minPt(pts: Pt[]): { y: number; step: number } | null {
  if (!pts.length) return null;
  let y = Infinity, step = pts[0]!.step;
  for (const p of pts) if (p.y < y) { y = p.y; step = p.step; }
  return { y, step };
}

/** Pull a readable model name from an HF cache path
 *  (".../models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/<hash>") or a
 *  plain repo id, dropping the quant suffix. */
function shortModel(p: string): string {
  const m = p.match(/models--[^/]*--([^/]+)/);
  const name = m ? m[1]! : (p.split("/").filter((s) => s && s !== "snapshots" && !/^[0-9a-f]{16,}$/.test(s)).pop() ?? p);
  return name.replace(/-OptiQ-4bit$/i, "");
}

function fmtDuration(sec: number): string {
  if (!Number.isFinite(sec) || sec < 0) return "—";
  const h = Math.floor(sec / 3600), m = Math.floor((sec % 3600) / 60), s = Math.floor(sec % 60);
  if (h > 0) return `${h}h${String(m).padStart(2, "0")}m`;
  if (m > 0) return `${m}m${String(s).padStart(2, "0")}s`;
  return `${s}s`;
}

export function renderFrame(st: RunState, cols: number, rows: number): string[] {
  const grid = new Grid(rows, cols);
  const sps = sPerStep(st);
  const iters = st.meta.iters || st.lastStep || 1;
  const frac = Math.min(1, st.lastStep / iters);
  const eta = sps > 0 ? (iters - st.lastStep) * sps : NaN;
  const elapsed = st.meta.startedAt && st.lastT ? (st.lastT - st.meta.startedAt) / 1000 : NaN;

  // Header line 1: identity + progress.
  const modelShort = shortModel(st.meta.model);
  const statusDot = st.done ? "✓" : "●";
  const statusFg = st.done ? C.ok : C.accent;
  grid.put(0, 0, statusDot, statusFg);
  grid.text(0, 2, `${st.meta.method} · ${modelShort}`, C.title);
  const hdr = st.done
    ? `step ${st.lastStep}/${iters} · complete · ${fmtDuration(elapsed)}`
    : `step ${st.lastStep}/${iters} · ${(frac * 100).toFixed(1)}% · ETA ${fmtDuration(eta)} · ${sps ? sps.toFixed(2) + "s/step" : "—"} · ${fmtDuration(elapsed)}`;
  grid.textRight(0, cols - 1, hdr, C.label);

  // Progress bar (row 1).
  const barW = cols - 2;
  const filled = Math.round(frac * barW);
  for (let i = 0; i < barW; i++) grid.put(1, 1 + i, i < filled ? "█" : "░", i < filled ? statusFg : C.dim);

  // Legend (row 2): trend lines are smoothed because B=1 per-step is per-example;
  // ● markers are val (sparse, one per eval step).
  grid.text(2, 1, "loss = orpo/step · margin = confidence · accuracy = correct on val · ● = val @ eval", C.dim);

  // Chart stack (rows 2..).
  const top = 3;
  const avail = rows - top;
  if (avail < 6) return grid.render();

  const cur = (a: Pt[]) => (a.length ? a[a.length - 1]!.y : NaN);
  const pct = (v: number) => (Number.isFinite(v) ? `${(v * 100).toFixed(1)}%` : "—");
  const SMOOTH = 15;

  // Loss: at B=1 the per-step loss is per-EXAMPLE (a long/hard pair spikes it),
  // so the displayed trend is a rolling MEDIAN (robust to those spikes) plus the
  // sparse val-loss markers. The min/rising detector runs on the median — the
  // "loss bottomed out and turned back up" early-stop signal.
  const lossMed = rollingMedian(st.loss, SMOOTH);
  const lm = minPt(lossMed);
  const recentLoss = cur(lossMed);
  const rising = !!(lm && lossMed.length > SMOOTH + 5 && lm.step < st.lastStep - SMOOTH
    && recentLoss > lm.y * 1.05);

  const marginMed = rollingMedian(st.margin, SMOOTH);

  // Val accuracy — the metric that matters: of the held-out val set, how many
  // pairs it correctly prefers (chosen > rejected). Sparse (one per eval step),
  // drawn as a line + markers; 50% is chance.
  const lastVal = st.valAcc[st.valAcc.length - 1];
  const bestVal = st.valAcc.reduce<ValPt | null>((b, p) => (!b || p.y > b.y ? p : b), null);

  const panels: ChartOpts[] = [
    {
      title: "loss · orpo per step", series: lossMed, color: C.loss, fmtY: fmtNum,
      markers: st.valLoss.length ? { pts: st.valLoss, color: C.accV } : undefined,
      headline: `${fmtNum(recentLoss)}${lm ? `  ↓min ${fmtNum(lm.y)} @ ${lm.step}` : ""}`,
      alert: rising ? `▲ rising +${fmtNum(recentLoss - lm!.y)} since ${lm!.step}` : undefined,
    },
    {
      title: "margin · confidence in the choice", series: marginMed, color: C.margin,
      fmtY: (v) => (v >= 0 ? "+" : "") + fmtNum(v),
      zeroLine: true,
      headline: `${cur(marginMed) >= 0 ? "+" : ""}${fmtNum(cur(marginMed))}  ${cur(marginMed) > 0 ? "leans chosen" : "leans rejected"}`,
    },
    {
      title: "accuracy · correct choices on val", series: st.valAcc, color: C.accT, fixed: [0, 1],
      fmtY: (v) => `${Math.round(v * 100)}%`,
      refLine: 0.5,
      markers: { pts: st.valAcc, color: C.accT },
      headline: lastVal
        ? `${lastVal.nc ?? "?"}/${lastVal.nt ?? "?"} correct = ${pct(lastVal.y)}`
          + (bestVal ? `  · best ${pct(bestVal.y)} @ ${bestVal.step}` : "")
        : "awaiting first eval (50% = chance)",
    },
    {
      title: "memory", series: st.peak, color: C.mem, fmtY: (v) => v.toFixed(1) + "G",
      headline: `peak ${st.peakGb.toFixed(2)}GB · active ${fmtNum(cur(st.mem))}GB`,
    },
  ];

  const ph = Math.floor(avail / panels.length);
  if (ph < 4) {
    // Too short: only loss.
    drawChart(grid, top, 1, avail, cols - 2, panels[0]!);
    return grid.render();
  }
  panels.forEach((p, i) => drawChart(grid, top + i * ph, 1, ph, cols - 2, p));
  return grid.render();
}

// ---------------------------------------------------------------------------
// Live TUI loop.
// ---------------------------------------------------------------------------

const ALT_ON = "\x1b[?1049h\x1b[?25l", ALT_OFF = "\x1b[?25h\x1b[?1049l\x1b[0m";
const HOME = "\x1b[H", CLEAR = "\x1b[2J";

export async function runWatch(adapterDir: string): Promise<void> {
  const path = `${adapterDir}/metrics.jsonl`;
  if (!(await Bun.file(path).exists())) {
    console.error(`no metrics.jsonl in ${adapterDir} — is this an mlx-bun training run dir?`);
    console.error(`(the trainer writes ${path} as it runs; point train-watch at the --adapter dir)`);
    process.exit(1);
  }

  let lastRender = "";
  const draw = (st: RunState) => {
    const cols = process.stdout.columns ?? 100;
    const rows = process.stdout.rows ?? 30;
    const frame = HOME + renderFrame(st, cols, rows).join("\n");
    if (frame !== lastRender) { process.stdout.write(frame); lastRender = frame; }
  };

  const restore = () => { process.stdout.write(ALT_OFF); };
  const quit = (code = 0) => {
    if (process.stdin.isTTY) process.stdin.setRawMode(false);
    restore();
    process.exit(code);
  };

  process.stdout.write(ALT_ON + CLEAR);
  if (process.stdin.isTTY) {
    process.stdin.setRawMode(true);
    process.stdin.resume();
    process.stdin.on("data", (b) => {
      const s = b.toString();
      if (s === "q" || s === "\x03" /* ^C */) quit(0);
    });
  }
  process.on("SIGINT", () => quit(0));
  process.on("SIGTERM", () => quit(0));
  process.stdout.on("resize", () => { lastRender = ""; });

  // Poll the file; reparse fully each tick (it's small, single-digit MB) — keeps
  // the loop dead simple and robust to truncation/rotation. Stop redrawing once
  // the run is done AND the file has settled.
  let stableTicks = 0;
  for (;;) {
    let st: RunState;
    try { st = parseStream(readFileSync(path, "utf8")); }
    catch { st = emptyState(); }
    draw(st);
    if (st.done) { if (++stableTicks > 8) { /* keep showing final frame, slow poll */ } }
    await Bun.sleep(st.done ? 1000 : 250);
  }
}
