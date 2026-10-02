// A verb's presentation when the host has none of its own: plain lines, no
// colour, no cursor movement. A host with a terminal UI supplies its own.
import type { CliStep, CliTerminal } from "@mlx-bun/app-core";

export function plainTerminal(write: (text: string) => void = text => { process.stdout.write(text); }): CliTerminal {
  const line = (text: string) => write(text + "\n");
  return {
    step(text): CliStep {
      let current = text;
      line(`  - ${text}`);
      return { update(next) { current = next; }, done(next) { line(`  ✓ ${next ?? current}`); }, fail(next) { line(`  ✗ ${next ?? current}`); } };
    },
    box(lines) { for (const text of lines) line(`  ${text}`); },
    heading(text) { line(""); line(`  ${text.toUpperCase()}`); },
    table(columns, rows) {
      const widths = columns.map((column, index) => Math.max([...column.header].length, ...rows.map(row => [...(row[index] ?? "")].length)));
      const pad = (text: string, index: number) => columns[index]!.align === "right" ? text.padStart(widths[index]!) : text.padEnd(widths[index]!);
      line("  " + columns.map((column, index) => pad(column.header, index).toUpperCase()).join("  "));
      rows.forEach((row, at) => line("  " + columns.map((column, index) => { const cell = pad(row[index] ?? "", index); return column.paint ? column.paint(cell, at) : cell; }).join("  ")));
    },
    style: { dim: text => text, bold: text => text, green: text => text, accent: text => text, url: text => text, gradient: text => text },
  };
}
