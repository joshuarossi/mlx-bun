// The panel's DOM builders: elements from a snapshot and from the benchmark history. Every string from the server goes
// in as a text node through the kit's `h`, never as markup, so a model id or a job message cannot inject anything.
import { bytes, h, ms, num, percent, rate, uptime, type Child } from "@mlx-bun/web-kit";
import type { BenchHistoryEntry, CacheMetrics, Distribution, MetricsSnapshot, ModelMetrics } from "../protocol";

const SVG = "http://www.w3.org/2000/svg";

/** A page section: its sentence-case heading (with an optional muted count) and its content. */
export function section(title: string, count: string | null, ...children: Child[]): HTMLElement {
  return h("section", { class: "section" }, h("h3", { class: "section-title" }, title, count ? h("span", { class: "count" }, count) : null), ...children);
}

/** A table whose first `textColumns` columns read left and the rest are right-aligned numbers. */
export function table(head: readonly string[], rows: readonly (readonly Child[])[], textColumns = 1): HTMLElement {
  const cls = (index: number) => index < textColumns ? (index === 0 ? "name" : undefined) : "num";
  return h("div", { class: "table-wrap" }, h("table", { class: "table" },
    h("thead", {}, h("tr", {}, ...head.map((name, index) => h("th", { class: index < textColumns ? undefined : "num", scope: "col" }, name)))),
    h("tbody", {}, ...rows.map(row => h("tr", {}, ...row.map((cell, index) => h("td", { class: cls(index) }, cell)))))));
}

/** A stat card: the figure (a unit after the last space is set smaller) over its label. */
function stat(value: string, label: string): HTMLElement {
  const space = value.lastIndexOf(" ");
  const figure = space > 0 && /[a-z]/i.test(value.slice(space + 1))
    ? h("b", {}, value.slice(0, space), " ", h("small", {}, value.slice(space + 1)))
    : h("b", {}, value);
  return h("div", { class: "card stat" }, figure, h("span", {}, label));
}

/** The placeholder before the first snapshot: skeleton stat cards and what the panel is waiting for. */
export function waitingSections(connected: boolean): HTMLElement {
  const placeholder = () => h("div", { class: "card stat loading", "aria-hidden": "true" }, h("b", { class: "skeleton" }, " "), h("span", { class: "skeleton" }, " "));
  return section("Serving", null,
    h("div", { class: "grid cols-4" }, placeholder(), placeholder(), placeholder(), placeholder()),
    h("p", { class: "card-note waiting" }, connected ? "Waiting for the first snapshot…" : "Not connected to a server yet."));
}

/** The live throughput as an inline SVG: a line over a faint wash, the latest sample marked with a dot. */
function sparkline(series: MetricsSnapshot["series"]): HTMLElement {
  if (!series.length) return h("p", { class: "card-note" }, "No samples yet. The chart fills in while requests decode.");
  const peak = Math.max(1, ...series.map(point => point.tokensPerSecond));
  const coords = series.map((point, index) => [series.length > 1 ? (100 * index) / (series.length - 1) : 0, 38 - (36 * point.tokensPerSecond) / peak] as const);
  const points = coords.map(([x, y]) => `${x.toFixed(2)},${y.toFixed(2)}`).join(" ");
  const svg = document.createElementNS(SVG, "svg");
  svg.setAttribute("viewBox", "0 0 100 40");
  svg.setAttribute("preserveAspectRatio", "none");
  svg.setAttribute("aria-hidden", "true");
  const shape = (tag: string, attributes: Record<string, string>) => {
    const node = document.createElementNS(SVG, tag);
    for (const [name, value] of Object.entries(attributes)) node.setAttribute(name, value);
    svg.append(node);
  };
  shape("line", { class: "base", x1: "0", y1: "40", x2: "100", y2: "40" });
  shape("polygon", { class: "area", points: `${coords[0]![0].toFixed(2)},40 ${points} ${coords.at(-1)![0].toFixed(2)},40` });
  shape("polyline", { class: "line", points });
  const [lastX, lastY] = coords.at(-1)!;
  const dot = h("span", { class: "spark-dot" });
  dot.style.left = `${lastX}%`;
  dot.style.top = `${(lastY / 40) * 100}%`;
  return h("div", { class: "spark", role: "img", "aria-label": `Throughput over the last ${series.length} samples; peak ${rate(peak)}` }, svg, dot);
}

function servingSection(snapshot: MetricsSnapshot): HTMLElement {
  const scheduler = snapshot.schedulers[0], series = snapshot.series, last = series.at(-1);
  const span = series.length > 1 ? (series.at(-1)!.at - series[0]!.at) / 1000 : 0;
  const peak = series.length ? Math.max(...series.map(point => point.tokensPerSecond)) : null;
  return section("Serving", null,
    h("div", { class: "grid cols-4" },
      stat(rate(last?.tokensPerSecond ?? scheduler?.tokensPerSecond ?? 0), "throughput"),
      stat(scheduler ? `${scheduler.active} / ${scheduler.capacity}` : "—", "batch rows"),
      stat(scheduler ? String(scheduler.queued) : "—", "queued"),
      stat(num(snapshot.requests.finished), "requests finished")),
    h("div", { class: "card spark-card" },
      h("div", { class: "card-head" }, h("span", { class: "card-title" }, "Throughput"),
        series.length ? h("span", { class: "card-note" }, `${span ? `Last ${uptime(span)}` : "Latest sample"} · peak ${rate(peak)}`) : null),
      sparkline(series)));
}

const STATE_TAG: Readonly<Record<ModelMetrics["state"], string>> = { resident: "tag ok", loading: "tag accent", failed: "tag bad", unloaded: "tag" };

function modelsSection(models: readonly ModelMetrics[]): HTMLElement {
  if (!models.length) return section("Models", null, h("div", { class: "empty" }, "No model has loaded since this server started."));
  return section("Models", String(models.length), h("div", { class: "card table-card" },
    table(["model", "state", "load", "unload", "swap", "weights", "KV", "prefix cache"], models.map(model => [
      model.model, h("span", { class: STATE_TAG[model.state] ?? "tag", title: model.lastError ?? undefined }, model.state),
      ms(model.lastLoadMs), ms(model.lastUnloadMs), ms(model.lastSwapMs), bytes(model.weightsBytes), bytes(model.kvBytes), bytes(model.prefixCacheBytes)]), 2)));
}

/** One cache's use against its capacity, with a meter when the capacity is known. */
function usage(label: string, used: number, capacity: number | null, ...after: Child[]): HTMLElement {
  const fraction = capacity ? Math.max(0, Math.min(1, used / capacity)) : null;
  let meter: HTMLElement | null = null;
  if (fraction !== null) {
    const fill = h("i");
    fill.style.width = `${fraction * 100}%`;
    meter = h("div", { class: fraction >= 0.9 ? "meter warn" : "meter", role: "meter", "aria-label": label, "aria-valuemin": 0, "aria-valuemax": 100, "aria-valuenow": Math.round(fraction * 100) }, fill);
  }
  return h("div", { class: "usage" },
    h("div", { class: "usage-head" }, h("b", {}, label), h("span", {}, capacity ? `${bytes(used)} of ${bytes(capacity)}` : bytes(used))), meter, ...after);
}

function cacheCard(cache: CacheMetrics): HTMLElement | null {
  if (!cache.prefix && !cache.kv) return null;
  const prefix = cache.prefix, lookups = prefix ? prefix.hits + prefix.misses : 0;
  return h("div", { class: "card cache" },
    h("div", { class: "card-title", title: cache.model }, cache.model),
    prefix ? usage("Prefix cache", prefix.bytes, prefix.capacityBytes,
      h("p", { class: "hit" }, lookups ? `Hit rate ${percent(prefix.hitRate)} (${num(prefix.hits)} of ${num(lookups)} lookups)` : "No lookups yet")) : null,
    cache.kv ? usage("Batch KV", cache.kv.bytes, cache.kv.capacityBytes) : null);
}

function cachesSection(snapshot: MetricsSnapshot): HTMLElement {
  const cards = snapshot.caches.map(cacheCard).filter((card): card is HTMLElement => card !== null);
  const window = snapshot.requests.window;
  return section("Caches", null,
    cards.length ? h("div", { class: "grid cols-2" }, ...cards) : h("p", { class: "card-note" }, "No model has reported cache usage yet."),
    h("p", { class: "card-note section-note" }, `Prompt tokens served from cache over the last ${window.count} requests: ${percent(window.cachedPromptShare)}`));
}

const dist = (value: Distribution | null, format: (n: number) => string): [string, string, string] =>
  value ? [format(value.p50), format(value.p95), format(value.max)] : ["—", "—", "—"];

function timingsSection(snapshot: MetricsSnapshot): HTMLElement {
  const window = snapshot.requests.window;
  if (!window.count) return section("Request timings", null, h("p", { class: "card-note" }, "No request has finished yet. Timings appear after the first one."));
  const row = (label: string, value: Distribution | null, format: (n: number) => string) => [label, ...dist(value, format)];
  return section("Request timings", `last ${window.count} ${window.count === 1 ? "request" : "requests"}`, h("div", { class: "card table-card" },
    table(["", "p50", "p95", "max"], [
      row("queue wait", window.queueMs, ms), row("time to first token", window.ttftMs, ms), row("prefill", window.prefillTokensPerSecond, rate),
      row("decode", window.decodeTokensPerSecond, rate), row("total", window.totalMs, ms)])));
}

/** Everything the stream drives, redrawn on each snapshot. */
export function liveSections(snapshot: MetricsSnapshot): HTMLElement {
  return h("div", {}, servingSection(snapshot), modelsSection(snapshot.models), cachesSection(snapshot), timingsSection(snapshot));
}

/** The finished bench-serve runs, newest first. */
export function benchHistoryTable(history: readonly BenchHistoryEntry[]): HTMLElement {
  return table(["run", "when", "result", "cells", "best decode"], history.slice(0, 8).map(entry => [
    entry.profile, entry.startedAt.replace("T", " ").slice(0, 16),
    h("span", { class: entry.complete ? "tag ok" : "tag bad", title: entry.problems.join("; ") || undefined }, entry.complete ? "complete" : "incomplete"),
    String(entry.cells.filter(cell => cell.status === "measured").length),
    rate(Math.max(0, ...entry.cells.map(cell => cell.decodeTokensPerSecond ?? 0)) || null)]), 3);
}
