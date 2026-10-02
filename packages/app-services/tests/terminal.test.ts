import { expect, test } from "bun:test";
import { plainTerminal } from "../src";

test("the plain terminal draws headings and aligned tables as text, unstyled", () => {
  const out: string[] = [];
  const terminal = plainTerminal(text => { out.push(text); });
  terminal.heading("library");
  terminal.table([{ header: "model" }, { header: "size", align: "right" }, { header: "note", paint: cell => `[${cell.trim()}]` }],
    [["org/a", "2.00 GB", "x"], ["org/longer-name", "10.00 GB", "yy"]]);
  expect(terminal.style.gradient("fast")).toBe("fast");
  expect(out.join("")).toBe("\n  LIBRARY\n  MODEL                SIZE  NOTE\n  org/a             2.00 GB  [x]\n  org/longer-name  10.00 GB  [yy]\n");
});
