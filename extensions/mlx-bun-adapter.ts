// mlx-bun LoRA adapter control for the Pi CLI — a Pi extension that ships with
// mlx-bun. Install by copying (or symlinking) this file into
// `~/.pi/agent/extensions/`, then `/reload` pi.
//
//   /adapter              list available + loaded adapters and the active one
//   /adapter <id>         mount (if needed) and activate <id> for this session
//   /adapter off          turn the adapter off (base model)
//
// Mechanism: the `before_provider_request` hook injects {"adapter": <id>} into
// the outgoing OpenAI-compatible payload — the same field a raw curl would send.
// Default is none (no injection → base model). This is the CLI twin of the web
// chat's adapter selector (src/pi-web.ts installAdapterHook); both lean on Pi's
// hook rather than any custom protocol. See docs/design/adapters-end-to-end.md.
//
// Points at the mlx-bun server via MLX_BUN_URL (default http://localhost:8090).

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const BASE = (process.env.MLX_BUN_URL ?? "http://localhost:8090")
  .replace(/\/+$/, "")
  .replace(/\/v1$/, "");

async function jget(path: string): Promise<any> {
  const r = await fetch(BASE + path, { headers: { "content-type": "application/json" } });
  return r.json();
}
async function jpost(path: string, body: unknown): Promise<any> {
  const r = await fetch(BASE + path, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });
  return r.json();
}

export default function (pi: ExtensionAPI) {
  let selected: string | null = null; // default none

  // Inject the active adapter into every outgoing provider request. Returning
  // undefined leaves the payload untouched (base model). Turn off with
  // `/adapter off` before switching to a non-mlx-bun model.
  pi.on("before_provider_request", (event) => {
    if (!selected) return undefined;
    const payload = event.payload as Record<string, unknown>;
    return { ...payload, adapter: selected };
  });

  pi.registerCommand("adapter", {
    description: "mlx-bun LoRA adapter: /adapter <id> | off | list",
    getArgumentCompletions: async (prefix: string) => {
      let ids: string[] = [];
      try {
        const d = await jget("/v1/adapters/available");
        ids = (d.adapters || []).map((a: any) => a.id);
      } catch {
        /* server down → just offer the verbs */
      }
      const opts = ["off", "list", ...ids];
      const f = opts.filter((o) => o.startsWith(prefix));
      return f.length ? f.map((v) => ({ value: v, label: v })) : null;
    },
    handler: async (args: string, ctx: any) => {
      const a = args.trim();

      if (a === "" || a === "list") {
        try {
          const avail = (await jget("/v1/adapters/available")).adapters || [];
          const loaded = new Set(((await jget("/v1/adapters")).adapters || []).map((m: any) => m.id));
          const lines = avail.map(
            (x: any) => `  ${x.id === selected ? "●" : "○"} ${x.id}${loaded.has(x.id) ? " (loaded)" : ""}`,
          );
          ctx.ui.notify(`adapters (active: ${selected ?? "none"}):\n${lines.join("\n") || "  (none found)"}`, "info");
        } catch (e: any) {
          ctx.ui.notify(`adapter list failed: ${e?.message ?? e}`, "error");
        }
        return;
      }

      if (a === "off" || a === "none") {
        selected = null;
        ctx.ui.notify("adapter off — base model", "info");
        return;
      }

      // Turn on: resolve the path, mount (idempotent server-side), then select.
      try {
        const avail = (await jget("/v1/adapters/available")).adapters || [];
        const match = avail.find((x: any) => x.id === a);
        if (!match) {
          ctx.ui.notify(`unknown adapter "${a}" — try /adapter list`, "error");
          return;
        }
        const r = await jpost("/v1/adapters", { id: a, path: match.path });
        if (r && (r.error || r.ok === false)) {
          ctx.ui.notify(`mount failed: ${r.error?.message ?? r.error ?? "?"}`, "error");
          return;
        }
        selected = a;
        ctx.ui.notify(`adapter on: ${a}`, "info");
      } catch (e: any) {
        ctx.ui.notify(`adapter error: ${e?.message ?? e}`, "error");
      }
    },
  });
}
