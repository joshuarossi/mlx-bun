// Read xctrace exports without loading MLX or touching the GPU. Attribute one
// process only; another process must never fill its intentional warmup gap.
import { readFileSync } from "node:fs";
import { parseArgs } from "node:util";

interface Element { tag: string; attrs: Record<string, string>; children: Element[]; text: string }
const entities = (text: string) => text.replace(/&(quot|apos|lt|gt|amp);/g,
  (_, name: string) => ({ quot: '"', apos: "'", lt: "<", gt: ">", amp: "&" })[name]!);

/** The small table/reference subset xctrace emits, including shared id/ref cells. */
function table(source: string) {
  const root: Element = { tag: "root", attrs: {}, children: [], text: "" }, stack = [root], refs = new Map<string, Element>();
  for (const match of source.matchAll(/<[^>]+>|[^<]+/g)) {
    const token = match[0];
    if (token.startsWith("<?") || token.startsWith("<!")) continue;
    if (token.startsWith("</")) { stack.pop(); continue; }
    if (!token.startsWith("<")) { stack.at(-1)!.text += entities(token); continue; }
    const element: Element = { tag: /^<([^\s/>]+)/.exec(token)![1]!, children: [], text: "",
      attrs: Object.fromEntries([...token.matchAll(/([\w-]+)="([^"]*)"/g)].map(m => [m[1]!, entities(m[2]!)])) };
    stack.at(-1)!.children.push(element);
    if (element.attrs.id) refs.set(element.attrs.id, element);
    if (!token.endsWith("/>")) stack.push(element);
  }
  const all = (node: Element, tag: string): Element[] => node.children.flatMap(child =>
    [...(child.tag === tag ? [child] : []), ...all(child, tag)]);
  const schema = all(root, "schema");
  if (schema.length !== 1) throw new Error("export exactly one xctrace table per XML file");
  const names = schema[0]!.children.filter(c => c.tag === "col").map(c => c.children.find(n => n.tag === "mnemonic")!.text.trim());
  const resolve = (element: Element): Element => {
    const result = element.attrs.ref ? refs.get(element.attrs.ref) : element;
    if (!result) throw new Error("unresolved xctrace cell reference");
    return result;
  };
  const value = (element: Element) => { const e = resolve(element); return e.text.trim() || e.attrs.fmt || ""; };
  const fmt = (element: Element) => { const e = resolve(element); return e.attrs.fmt ?? value(e); };
  return all(root, "row").map(row => {
    const cells = Object.fromEntries(names.map((name, i) => [name, row.children[i]!]));
    const process = resolve(cells.process!);
    const pid = process.children.find(e => e.tag === "pid");
    if (!pid) throw new Error("xctrace process has no PID");
    const start = Number(value(cells.start!)) / 1e6, duration = Number(value(cells.duration!)) / 1e6;
    if (!Number.isFinite(start) || !Number.isFinite(duration) || duration < 0) throw new Error("invalid xctrace interval");
    return { pid: Number(value(pid)), process: fmt(cells.process!), start, duration,
      name: cells.name ? fmt(cells.name).replace(/ \(\d+\)$/, "") : "", state: cells.state ? fmt(cells.state) : "" };
  });
}
type Interval = { start: number; duration: number };
function busy(intervals: Interval[], start: number, end: number): number {
  let total = 0, previous = start;
  for (const interval of [...intervals].sort((a, b) => a.start - b.start)) {
    const a = Math.max(start, interval.start, previous), b = Math.min(end, interval.start + interval.duration);
    if (b > a) total += b - a;
    previous = Math.max(previous, b);
  }
  return total;
}

export function summarizeProfile(shaderXml: string, gpuXml: string, pid: number, forwards: number, gapMs = 1000) {
  if (!Number.isSafeInteger(pid) || pid <= 0 || !Number.isSafeInteger(forwards) || forwards <= 0 || gapMs <= 0)
    throw new Error("positive PID, forward count, and gap required");
  const shaders = table(shaderXml), gpu = table(gpuXml).filter(r => r.state === "Active");
  const own = gpu.filter(r => r.pid === pid).sort((a, b) => a.start - b.start);
  if (!own.length) throw new Error(`no active GPU intervals for PID ${pid}`);
  let start = own[0]!.start, previousEnd = start, foundGap = false;
  for (const interval of own) {
    if (interval.start - previousEnd > gapMs) { start = interval.start; foundGap = true; }
    previousEnd = Math.max(previousEnd, interval.start + interval.duration);
  }
  if (!foundGap) throw new Error("no profiling gap for the target PID; use --profile-gap-ms 1500");
  const end = previousEnd;
  const intersects = (r: Interval) => r.start < end && r.start + r.duration > start;
  const selected = shaders.filter(r => r.pid === pid && r.start >= start && r.start < end);
  if (!selected.length) throw new Error("no shader intervals in the target window");
  const byKernel = new Map<string, { intervals: number; ms: number }>();
  for (const row of selected) {
    const group = byKernel.get(row.name) ?? { intervals: 0, ms: 0 };
    group.intervals++; group.ms += row.duration; byKernel.set(row.name, group);
  }
  const otherPids = [...new Set(shaders.filter(r => r.pid !== pid && intersects(r)).map(r => r.pid))];
  return { pid, forwards, window: { startMs: start, endMs: end },
    wallMsPerForward: (end - start) / forwards, gpuActiveMsPerForward: busy(own, start, end) / forwards,
    overlappingShaderProcesses: otherPids.map(other => ({ pid: other, process: shaders.find(r => r.pid === other)!.process,
      activeMs: busy(gpu.filter(r => r.pid === other), start, end) })),
    kernels: [...byKernel].map(([name, g]) => ({ name, intervalsPerForward: g.intervals / forwards,
      msPerForward: g.ms / forwards })).sort((a, b) => b.msPerForward - a.msPerForward),
    note: "Shader intervals are profiler observations, not an operation-count or unprofiled-speed guarantee. Inspect overlap before attributing time.",
  };
}

if (import.meta.main) {
  const { values } = parseArgs({ options: { help: { type: "boolean" }, shaders: { type: "string" }, gpu: { type: "string" },
    pid: { type: "string" }, forwards: { type: "string" } } });
  if (values.help) console.log("CPU-only xctrace summary: --shaders /abs/shaders.xml --gpu /abs/gpu.xml --pid PID --forwards N\n" +
    "Export metal-shader-profiler-intervals and metal-gpu-intervals separately. Use the PID in forward-screen's report or xctrace's target TOC.");
  else {
    if (!values.shaders || !values.gpu || !values.pid || !values.forwards) throw new Error("use --help for required arguments");
    console.log(JSON.stringify(summarizeProfile(readFileSync(values.shaders, "utf8"), readFileSync(values.gpu, "utf8"),
      Number(values.pid), Number(values.forwards)), null, 2));
  }
}
