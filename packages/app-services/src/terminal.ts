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
    style: { dim: text => text, bold: text => text, green: text => text, accent: text => text, url: text => text },
  };
}
