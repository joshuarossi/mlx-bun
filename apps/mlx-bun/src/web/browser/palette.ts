// The app's command palette (Cmd/Ctrl+K): the shell's palette chrome (`@mlx-bun/web-shell`) over the app's
// searchable things. Commands call exported functions of the modules that own the behavior (newChat and
// copyLastResponse through the controllers registry, openMemPanel, the shell's theme, developer and
// shortcut controls; thinking-toggle reuses the real button's click handler). "Chats" lists the sidebar's rows and
// "In messages" delegates to the same GET /api/sessions/search endpoint the sidebar's search uses
// (apps/mlx-bun/src/chat/session-search.ts): one server-side implementation, two presentations.
import { actionSection, createPalette, cycleTheme, fuzzyMatch, type Palette, type PaletteAction, type PaletteRow, type PaletteSection } from "@mlx-bun/web-shell";
import { controllers, currentRoute, isDeveloperMode, setDeveloperMode, shell } from "./shell";
import { openSessionRowByPath, exportSession } from "./sessions";
import { openMemPanel } from "./memory-panel";
import { api } from "./api";

/** The command list, independent of any live session data. Session rows and message-search hits are their own
 * sections. Commands that only make sense on the chat page hide elsewhere (matching the Cmd/Ctrl+Shift+O/C guards). */
export function commands(): PaletteAction[] {
  const onChat = () => currentRoute() === "chat";
  return [
    {
      label: "New chat", hint: "⌘⇧O", when: onChat,
      run() { const fn = controllers.chat && controllers.chat.newChat as (() => void) | undefined; fn && fn(); },
    },
    {
      label: "Toggle thinking", when: onChat,
      run() { const btn = document.getElementById("chat-think"); if (btn) btn.click(); },
    },
    { label: "Toggle theme", run() { cycleTheme(); } },
    { label: "Toggle Developer mode", run() { setDeveloperMode(!isDeveloperMode()); } },
    { label: "Open Memory panel", run() { openMemPanel(); } },
    { label: "Browse models (Hub)", run() { location.hash = "#/models"; } },
    { label: "Open shortcut sheet", run() { shell.shortcuts.toggle(); } },
    {
      label: "Export this chat", when: onChat,
      async run() {
        const activeRow = document.querySelector<HTMLElement>("#chat-sessions .sess.active");
        if (!activeRow || !activeRow.dataset.path) return;
        const title = activeRow.querySelector(".stitle")?.textContent || "chat";
        await exportSession(activeRow.dataset.path, title, "md");
      },
    },
    // One entry per module panel the shell mounted.
    ...shell.panelTargets().map(({ id, title }): PaletteAction => ({ label: `Open ${title}`, run() { location.hash = "#/" + id; } })),
  ];
}

const sessions: PaletteSection = {
  title: "Chats",
  rows(query) {
    if (!query) return [];
    const out: PaletteRow[] = [];
    document.querySelectorAll<HTMLElement>("#chat-sessions .sess").forEach((row) => {
      const title = row.querySelector(".stitle")?.textContent || "New chat";
      const path = row.dataset.path;
      if (!path) return;
      if (fuzzyMatch(query, title)) out.push({ label: title, run() { openSessionRowByPath(path); } });
    });
    return out.slice(0, 6);
  },
};

const messages: PaletteSection = {
  title: "In messages",
  rows: () => [],
  async remote(query) {
    const d = await api("/api/sessions/search?q=" + encodeURIComponent(query)).catch(() => ({ ok: false } as { ok: boolean }));
    const body = d as { ok: boolean; results?: Array<{ sessionPath: string; sessionTitle: string; matches: Array<{ snippet: string }> }> };
    if (!body.ok || !body.results) return [];
    return body.results.slice(0, 6).map((r): PaletteRow => ({
      label: r.sessionTitle, snippet: r.matches[0]?.snippet || "", run() { openSessionRowByPath(r.sessionPath); },
    }));
  },
};

export function createAppPalette(): Palette {
  return createPalette({ sections: [actionSection("Commands", commands), sessions, messages] });
}
