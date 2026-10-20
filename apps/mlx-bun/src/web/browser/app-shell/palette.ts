// The app's command palette (Cmd/Ctrl+K): the shell's palette chrome over the app's searchable things. Commands call
// the chat panel's methods (new chat, thinking, export) and the app's own controls (memory, theme, developer tools,
// the shortcut sheet, settings). "Chats" lists the sidebar's rows; "In messages" asks the chat module's session
// search (`GET /api/sessions/search`): one server-side implementation, two presentations.
import { createApi } from "@mlx-bun/web-kit";
import { actionSection, createPalette, cycleTheme, fuzzyMatch, type Palette, type PaletteAction, type PaletteRow, type PaletteSection } from "@mlx-bun/web-shell";
import { chatPanel } from "./chat-panel";
import { currentRoute, isDeveloperMode, setDeveloperMode, shell } from "./shell";
import { openSettings } from "./settings";
import { openMemPanel } from "../memory-panel";

const api = createApi("/api/sessions");

/** The command list, independent of any live session data. Commands that only make sense on the chat page hide
 * elsewhere (matching the Cmd/Ctrl+Shift+O/C guards). */
export function commands(): PaletteAction[] {
  const onChat = () => currentRoute() === "chat";
  return [
    { label: "New chat", hint: "⌘⇧O", when: onChat, run() { chatPanel()?.newChat(); } },
    { label: "Toggle thinking", when: onChat, run() { chatPanel()?.toggleThinking(); } },
    { label: "Toggle theme", run() { cycleTheme(); } },
    { label: "Toggle developer tools", run() { setDeveloperMode(!isDeveloperMode()); } },
    { label: "Open memory", run() { void openMemPanel(); } },
    { label: "Open settings", run() { openSettings(); } },
    { label: "Browse models", run() { location.hash = "#/models"; } },
    { label: "Keyboard shortcuts", hint: "⌘/", run() { shell.shortcuts.toggle(); } },
    { label: "Export this chat", when: onChat, async run() { await chatPanel()?.exportActiveChat("md"); } },
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
    const answer = await api.get<{ results?: Array<{ sessionPath: string; sessionTitle: string; matches: Array<{ snippet: string }> }> }>("search?q=" + encodeURIComponent(query));
    if (answer.ok === false || !answer.results) return [];
    return answer.results.slice(0, 6).map((hit): PaletteRow => ({
      label: hit.sessionTitle, snippet: hit.matches[0]?.snippet || "", run() { chatPanel()?.openSession(hit.sessionPath); },
    }));
  },
};

export function createAppPalette(): Palette {
  return createPalette({ sections: [actionSection("Commands", commands), sessions, messages] });
}
