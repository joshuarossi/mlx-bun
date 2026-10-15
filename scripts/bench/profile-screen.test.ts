import { expect, test } from "bun:test";
import { summarizeProfile } from "./profile-screen";

function xml(shader: boolean, rows: Array<[number, number, number]>) {
  const names = ["start", "duration", shader ? "name" : "state", "process"];
  return `<table><schema>${names.map(n => `<col><mnemonic>${n}</mnemonic></col>`).join("")}</schema>` +
    rows.map(([start, duration, pid], i) => `<row><time>${start * 1e6}</time><duration>${duration * 1e6}</duration>` +
      (shader ? `<name>kernel (${i})</name>` : "<state>Active</state>") +
      `<process fmt="bun (${pid})"><pid>${pid}</pid></process></row>`).join("") + "</table>";
}

test("GPU attribution isolates the target PID even when another agent fills its warmup gap", () => {
  const gpu = xml(false, [[0, 10, 1], [20, 3900, 2], [1500, 10, 1], [1520, 10, 1], [3030, 100, 1],
    [1522, 5, 3], [3040, 50, 4]]);
  const shaders = xml(true, [[0, 10, 1], [20, 3900, 2], [1500, 4, 1], [1520, 6, 1], [3030, 100, 1]]);
  const result = summarizeProfile(shaders, gpu, 1, 2);
  expect(result.window.startMs).toBe(1500);
  expect(result.window.endMs).toBe(1530);
  expect(result.wallMsPerForward).toBe(15);
  expect(result.gpuActiveMsPerForward).toBe(10);
  expect(result.kernels).toEqual([{ name: "kernel", intervalsPerForward: 1, msPerForward: 5 }]);
  expect(result.overlappingShaderProcesses).toEqual([{ pid: 2, process: "bun (2)", activeMs: 30 }]);
  expect(result.overlappingGpuProcesses).toEqual([
    { pid: 2, process: "bun (2)", activeMs: 30 }, { pid: 3, process: "bun (3)", activeMs: 5 },
  ]);
});

test("profile summaries reject missing target data and missing profiling gaps", () => {
  const data = xml(false, [[0, 10, 1]]), shaders = xml(true, [[0, 10, 1]]);
  expect(() => summarizeProfile(shaders, data, 2, 1)).toThrow("no active GPU");
  expect(() => summarizeProfile(shaders, data, 1, 1)).toThrow("two profiling gaps");
  expect(() => summarizeProfile(shaders, xml(false, [[0, 10, 1], [1500, 10, 1]]), 1, 1)).toThrow("two profiling gaps");
  expect(() => summarizeProfile(shaders, data, 1, 0)).toThrow();
});

test("profile tables resolve shared id/ref cells and merge overlapping active intervals", () => {
  const columns = "<col><mnemonic>start</mnemonic></col><col><mnemonic>duration</mnemonic></col>" +
    "<col><mnemonic>state</mnemonic></col><col><mnemonic>process</mnemonic></col>";
  const gpu = `<table><schema>${columns}</schema><row><time>0</time><duration id="d">10000000</duration>` +
    `<state id="s">Active</state><process id="p" fmt="bun (1)"><pid>1</pid></process></row>` +
    `<row><time>1500000000</time><duration ref="d"/><state ref="s"/><process ref="p"/></row>` +
    `<row><time>1505000000</time><duration ref="d"/><state ref="s"/><process ref="p"/></row>` +
    `<row><time>3015000000</time><duration ref="d"/><state ref="s"/><process ref="p"/></row></table>`;
  expect(summarizeProfile(xml(true, [[1500, 5, 1]]), gpu, 1, 1).gpuActiveMsPerForward).toBe(15);
});
