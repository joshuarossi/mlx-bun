// The module's static manifest: plain data, read by hosts and documentation generators without
// loading a model or native code (this file imports only types). `index.ts` adds `activate`.
import type { AppModule } from "@mlx-bun/app-core";

export const manifest = {
  id: "chat",
  title: "Chat",
  summary: "The default assistant: a Pi agent over the served model, on a WebSocket per browser tab, with recent chats, tool approvals, and the tools other modules contribute.",
  requires: ["modelHost", "storage", "registry"],
  // Session routes keep their shipped paths: the browser and external tools read them at `/api/sessions/*`, the settings at `/api/settings/tool-approvals`.
  routes: [
    { id: "sessions-search", method: "GET", path: "/api/sessions/search", summary: "Search saved chats by title and content (`q`); read-only", response: "json", mount: "root" },
    { id: "sessions-export", method: "GET", path: "/api/sessions/export", summary: "One saved chat's raw entries (`path`, under the session directory); read-only", response: "json", mount: "root" },
    { id: "approvals", method: "GET", path: "/api/settings/tool-approvals", summary: "The tools the user chose to always allow", response: "json", mount: "root" },
    { id: "approvals-revoke", method: "DELETE", path: "/api/settings/tool-approvals", summary: "Forget one always-allow choice (`tool` in the JSON body)", response: "json", mount: "root" },
  ],
  sockets: [
    { id: "chat", path: "/ws/chat", summary: "One chat session per connection: prompts, streamed tokens, tool cards and approvals, saved-chat management", mount: "root" },
  ],
  storage: [
    { key: "sessions", path: "sessions", kind: "directory", purpose: "Saved chats, one Pi JSONL file each (also read by the memory pipeline)" },
    { key: "agent", path: "pi-sessions", kind: "directory", purpose: "The Pi agent's own directory" },
    { key: "approvals", path: "tool-approvals.json", kind: "file", purpose: "Tools the user chose to always allow, mode 0600" },
  ],
  panel: { tag: "mlx-chat-panel", entry: "@mlx-bun/module-chat/panel", title: "Chat", path: "/chat", workspace: true },
} as const satisfies Omit<AppModule<"modelHost" | "storage" | "registry">, "activate">;
