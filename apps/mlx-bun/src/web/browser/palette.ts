// The app's command palette (Cmd/Ctrl+K): the shell's palette chrome (`@mlx-bun/web-shell`) over the app's
// searchable things. Commands call the chat panel's methods (new chat, thinking, export) and exported functions of the
// modules that own the behavior (openMemPanel/openHubPanel, the shell's theme, developer and shortcut controls).
// "Chats" lists the sidebar's rows and "In messages" delegates to the same GET /api/sessions/search endpoint the
// sidebar's search uses (`@mlx-bun/module-chat`'s session search): one server-side implementation, two presentations.
import { actionSection, createPalette, cycleTheme, fuzzyMatch, type Palette, type PaletteAction, type PaletteRow, type PaletteSection } from "@mlx-bun/web-shell";
import { chatPanel, currentRoute, isDeveloperMode, setDeveloperMode, shell } from "./shell";
import { openMemPanel } from "./memory-panel";
import { openHubPanel } from "./hub";
import { api } from "./api";

/** The command list, independent of any live session data. Session rows and message-search hits are their own
 * sections. Commands that only make sense on the chat page hide elsewhere (matching the Cmd/Ctrl+Shift+O/C guards). */
export function commands(): PaletteAction[] {
  const onChat = () => currentRoute() === "chat";
  return [
    {
      label: "New chat", hint: "⌘⇧O", when: onChat,
      run() { chatPanel()?.newChat(); },
    },
    {
      label: "Toggle thinking", when: onChat,
      run() { chatPanel()?.toggleThinking(); },
    },
    { label: "Toggle theme", run() { cycleTheme(); } },
    { label: "Toggle Developer mode", run() { setDeveloperMode(!isDeveloperMode()); } },
    { label: "Open Memory panel", run() { openMemPanel(); } },
    { label: "Browse models (Hub)", run() { openHubPanel(); } },
    { label: "Open shortcut sheet", run() { shell.shortcuts.toggle(); } },
    {
      label: "Export this chat", when: onChat,
      async run() { await chatPanel()?.exportActiveChat("md"); },
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
    for (const { title, path } of chatPanel()?.recentChats() ?? [])
      if (fuzzyMatch(query, title)) out.push({ label: title, run() { chatPanel()?.openSession(path); } });
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
      label: r.sessionTitle, snippet: r.matches[0]?.snippet || "", run() { chatPanel()?.openSession(r.sessionPath); },
    }));
  },
};

export function createAppPalette(): Palette {
  return createPalette({ sections: [actionSection("Commands", commands), sessions, messages] });
}
