// Startup TUI: gradient banner, spinner steps, boxed ready-card.
// Zero dependencies — truecolor ANSI by hand, matching the status
// page's keynote gradient (orange → pink → purple → blue). Everything
// degrades to plain text when stdout isn't a TTY or NO_COLOR is set.

const tty = (): boolean => Boolean(process.stdout.isTTY) && !process.env.NO_COLOR;

const RESET = "\x1b[0m";
const DIM = "\x1b[2m";
const BOLD = "\x1b[1m";

type Rgb = [number, number, number];
// the keynote ramp
const RAMP: Rgb[] = [[255, 159, 10], [255, 55, 95], [191, 90, 242], [10, 132, 255]];

function lerp(a: Rgb, b: Rgb, t: number): Rgb {
  return [0, 1, 2].map((i) => Math.round(a[i]! + (b[i]! - a[i]!) * t)) as Rgb;
}
function rampAt(t: number): Rgb {
  const x = Math.min(0.999, Math.max(0, t)) * (RAMP.length - 1);
  return lerp(RAMP[Math.floor(x)]!, RAMP[Math.floor(x) + 1]!, x - Math.floor(x));
}
const fg = ([r, g, b]: Rgb) => `\x1b[38;2;${r};${g};${b}m`;

/** Horizontal gradient across each line (visible chars only). */
export function gradient(text: string): string {
  if (!tty()) return text;
  return text.split("\n").map((line) => {
    const chars = [...line];
    const n = Math.max(1, chars.length - 1);
    return chars.map((ch, i) => (ch === " " ? ch : fg(rampAt(i / n)) + ch)).join("") + RESET;
  }).join("\n");
}

const WORDMARK = `
███╗   ███╗██╗     ██╗  ██╗      ██████╗ ██╗   ██╗███╗   ██╗
████╗ ████║██║     ╚██╗██╔╝      ██╔══██╗██║   ██║████╗  ██║
██╔████╔██║██║      ╚███╔╝ █████╗██████╔╝██║   ██║██╔██╗ ██║
██║╚██╔╝██║██║      ██╔██╗ ╚════╝██╔══██╗██║   ██║██║╚██╗██║
██║ ╚═╝ ██║███████╗██╔╝ ██╗      ██████╔╝╚██████╔╝██║ ╚████║
╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝      ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝`.slice(1);

export function banner(version: string, tagline = "local AI · apple silicon · one binary"): void {
  if (!tty()) {
    console.log(`mlx-bun ${version} — ${tagline}`);
    return;
  }
  console.log();
  console.log(gradient(WORDMARK));
  console.log(`${DIM}  v${version} · ${tagline}${RESET}\n`);
}

const FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
const OK = tty() ? "\x1b[38;2;48;209;88m✓\x1b[0m" : "✓";
const FAIL = tty() ? "\x1b[38;2;255;69;58m✗\x1b[0m" : "✗";

export interface Step {
  update(text: string): void;
  done(text?: string): void;
  fail(text?: string): void;
}

/** Spinner line; on non-TTY prints start/end lines instead. */
export function step(text: string): Step {
  let current = text;
  if (!tty()) {
    console.log(`  - ${text}`);
    return {
      update(t) { current = t; },
      done(t) { console.log(`  ${OK} ${t ?? current}`); },
      fail(t) { console.log(`  ${FAIL} ${t ?? current}`); },
    };
  }
  let i = 0;
  const draw = () => process.stdout.write(`\r\x1b[2K  ${fg(rampAt((i % 20) / 20))}${FRAMES[i % FRAMES.length]}${RESET} ${current}`);
  draw();
  const timer = setInterval(() => { i++; draw(); }, 80);
  const finish = (mark: string, t?: string) => {
    clearInterval(timer);
    process.stdout.write(`\r\x1b[2K  ${mark} ${t ?? current}\n`);
  };
  return {
    update(t) { current = t; draw(); },
    done(t) { finish(OK, t); },
    fail(t) { finish(FAIL, t); },
  };
}

/** Rounded box with a gradient border. Lines may contain ANSI codes. */
export function box(lines: string[], { pad = 1 }: { pad?: number } = {}): void {
  const visible = (s: string) => [...s.replace(/\x1b\[[0-9;]*m/g, "")].length;
  const width = Math.max(...lines.map(visible)) + pad * 2;
  const hue = (s: string) => (tty() ? fg(rampAt(0.15)) + s + RESET : s);
  console.log(hue(`  ╭${"─".repeat(width)}╮`));
  for (const l of lines) {
    const fill = " ".repeat(width - visible(l) - pad * 2);
    console.log(`${hue("  │")}${" ".repeat(pad)}${l}${fill}${" ".repeat(pad)}${hue("│")}`);
  }
  console.log(hue(`  ╰${"─".repeat(width)}╯`));
}

export interface Column {
  header: string;
  align?: "left" | "right";
  /** Optional per-cell styling (receives the padded cell). */
  paint?: (cell: string, row: number) => string;
}

/** Aligned table with dim uppercase headers; rows are plain strings. */
export function table(cols: Column[], rows: string[][], indent = "  "): void {
  const widths = cols.map((c, i) =>
    Math.max([...c.header].length, ...rows.map((r) => [...(r[i] ?? "")].length)));
  console.log(indent + cols.map((c, i) =>
    style.dim((c.align === "right" ? c.header.padStart(widths[i]!) : c.header.padEnd(widths[i]!)).toUpperCase())).join("  "));
  rows.forEach((r, ri) => {
    console.log(indent + cols.map((c, i) => {
      const cell = c.align === "right" ? (r[i] ?? "").padStart(widths[i]!) : (r[i] ?? "").padEnd(widths[i]!);
      return c.paint ? c.paint(cell, ri) : cell;
    }).join("  "));
  });
}

/** Gradient section header, e.g. `h1("library")`. */
export function h1(text: string): void {
  console.log();
  console.log("  " + (tty() ? gradient(text.toUpperCase()) : text.toUpperCase()));
}

export const style = {
  dim: (s: string) => (tty() ? DIM + s + RESET : s),
  bold: (s: string) => (tty() ? BOLD + s + RESET : s),
  green: (s: string) => (tty() ? "\x1b[38;2;48;209;88m" + s + RESET : s),
  accent: (s: string) => (tty() ? fg(rampAt(0.35)) + s + RESET : s),
  url: (s: string) => (tty() ? "\x1b[4m" + fg(rampAt(0.9)) + s + RESET : s),
};
