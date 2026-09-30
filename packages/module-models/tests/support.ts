// Fakes shared by the module's tests: the catalog, the model host (with a leaseable `adapters` operation), storage and the events bus.
import { mkdirSync } from "node:fs";
import { join } from "node:path";
import type { AdapterOperation, AppEvent, CatalogEntry, EventBus, ModelCatalog, ModelHost, ModelLease, MountedAdapter, ResidentModel, StorageService } from "@mlx-bun/app-core";
import type { ModelsModuleOptions } from "../src";

const unused = (what: string) => async (): Promise<never> => { throw new Error(`${what} is unused`); };

/** A catalog over fixed entries; every other member is unused unless overridden. */
export function fakeCatalog(entries: readonly CatalogEntry[] = [], overrides: Partial<ModelCatalog> = {}): ModelCatalog {
  return {
    async list(filter) { return entries.filter(entry => !filter?.kind ? entry.kind === "model" : entry.kind === filter.kind); },
    async resolve(id) { return entries.find(entry => entry.id === id); },
    find: unused("find"), pickDefault: unused("pickDefault"), estimate: unused("estimate"),
    async locate() { return undefined; },
    register: unused("register"), rescan: async () => 0, download: unused("download"),
    startDownload() { throw new Error("startDownload is unused"); }, downloads: () => [],
    canPublish: () => false, publish: unused("publish"),
    ...overrides,
  };
}

export const resident = (id: string, extra: Partial<ResidentModel> = {}): ResidentModel =>
  ({ id, role: "primary", state: "ready", operations: ["generate"], bytes: 1, pinned: false, leases: 0, lastUsedAt: 0, ...extra });

/** A model host serving `served`, whose leases carry `adapters`. `events` records acquire and release. */
export function fakeHost(options: { served?: string; adapters?: AdapterOperation; residents?: ResidentModel[]; events?: string[]; overrides?: Partial<ModelHost> } = {}): ModelHost {
  const served = "served" in options ? options.served : "org/served", events = options.events ?? [];
  return {
    policy: { budgetBytes: 0, pinned: [], idleUnloadSec: 0 },
    async acquire(id): Promise<ModelLease> {
      events.push(`acquire ${id}`);
      return { model: resident(id), loadMs: 0, operations: options.adapters ? { adapters: options.adapters } : {}, release() { events.push(`release ${id}`); } };
    },
    async defaultFor(operation) { return operation === "generate" ? served : undefined; },
    plan: unused("plan"), serve: unused("serve"), unload: unused("unload"), pin() {}, unpin() {},
    resident: () => options.residents ?? (served ? [resident(served)] : []),
    stats: () => ({ resident: true, loads: 1, unloads: 0, lastLoadMs: 0, idleUnloadSec: null }),
    ...options.overrides,
  };
}

/** Entries as the host declares them: a directory for each key, created on first ask. */
export function fakeStorage(root: string): StorageService {
  return { path: key => { const path = join(root, key); mkdirSync(path, { recursive: true }); return path; } };
}

/** A bus that delivers at once, so a test sees the effect of a publish without waiting. */
export function syncEvents(): EventBus & { published: AppEvent[] } {
  const handlers = new Set<{ types: readonly string[] | "*"; handler: (event: AppEvent) => void }>();
  const published: AppEvent[] = [];
  return { published,
    publish(event) { published.push(event); for (const entry of handlers) if (entry.types === "*" || entry.types.includes(event.type)) entry.handler(event); },
    subscribe(types, handler) { const entry = { types, handler }; handlers.add(entry); return () => { handlers.delete(entry); }; } };
}

export const entry = (id: string, extra: Partial<CatalogEntry> = {}): CatalogEntry =>
  ({ id, kind: "model", directory: `/models/${id}`, bytes: 1000, operations: ["generate"], modelType: "qwen3", ...extra });

export const mounted = (id: string, extra: Partial<MountedAdapter> = {}): MountedAdapter =>
  ({ id, path: `/adapters/${id}`, rank: 2, scale: 1, sizeBytes: 100, mountedLayers: 2, ramBytes: 80, ...extra });

export const request = (path: string, init?: RequestInit) => new Request(`http://localhost${path}`, init);
export const postJson = (path: string, body: unknown, signal?: AbortSignal) =>
  request(path, { method: "POST", headers: { "content-type": "application/json" }, body: typeof body === "string" ? body : JSON.stringify(body), ...(signal ? { signal } : {}) });

export type Seams = ModelsModuleOptions;

// ---------------------------------------------------------------- verbs

import type { CliInvocation, CliTerminal } from "@mlx-bun/app-core";
import { parseVerb } from "@mlx-bun/app-services/verbs";
import { manifest } from "../src/manifest";

/** What a verb wrote: its stdout and stderr, and the terminal calls (steps, boxes, headings and table rows) in order. */
export interface Console { out: string[]; err: string[]; steps: string[]; boxes: string[][]; tables: string[][][]; headings: string[] }

/** The verb's invocation as the host builds it: values parsed from the manifest, an identity-styled terminal that records what it was asked to draw. */
export function invoke(name: (typeof manifest.verbs)[number]["name"], args: string[], signal: AbortSignal = new AbortController().signal): { invocation: CliInvocation; console: Console } {
  const spec = manifest.verbs.find(verb => verb.name === name)!;
  const console: Console = { out: [], err: [], steps: [], boxes: [], tables: [], headings: [] };
  const terminal: CliTerminal = {
    step: text => { console.steps.push(`start:${text}`); return { update: next => { console.steps.push(`update:${next}`); }, done: next => { console.steps.push(`done:${next ?? text}`); }, fail: next => { console.steps.push(`fail:${next ?? text}`); } }; },
    box: lines => { console.boxes.push([...lines]); },
    heading: text => { console.headings.push(text); },
    table: (columns, rows) => { console.tables.push([columns.map(column => column.header), ...rows.map(row => [...row])]); },
    style: { dim: t => t, bold: t => t, green: t => t, accent: t => t, url: t => t, gradient: t => t },
  };
  const parsed = parseVerb("mlx-bun", spec as never, args);
  return { console, invocation: { ...parsed, stdout: text => { console.out.push(text); }, stderr: text => { console.err.push(text); }, terminal, signal } };
}
