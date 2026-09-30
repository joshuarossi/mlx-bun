# @mlx-bun/web-shell

The web shell of mlx-bun applications (design: [Modular application](../../ARCHITECTURE.md#modular-application)):
navigation between pages, hash routing, theme, the Developer switch, the keyboard shortcut sheet, the Escape sweep over
open overlays, the command palette's chrome, and the mounting of module panels. It is browser code with no workspace
dependencies and touches no DOM until a host uses it, so the app's browser bundle and a native app's webview load the
same code. Importing the entry in Bun (package verification, an inventory) is safe.

## Host contract

The host page supplies the markup and the tokens; the shell drives them.

- `nav #tabs` holding `a.tab[data-tab]` (add `data-dev` for a developer tool), pages as `section[data-route]` inside
  `#app`, `#nav-developer` (with `#nav-developer-dot`), `#theme-toggle` buttons (`data-theme-choice`), the shortcut sheet
  (`#nav-shortcuts`, `#shortcut-overlay`, `#sk-close`) and `#toasts`.
- Design tokens on `:root` (`--ink`, `--dim`, `--hairline`, `--card`, `--blue`, ...), light values under
  `[data-theme="light"]`. The shell's panel frame maps them to the names panels use (`--text`, `--line`).
- Preferences are `localStorage` keys `mlxbun.theme` and `mlxbun.developer` (the developer switch defaults on, once,
  when any other `mlxbun.*` key exists, so a returning user keeps their tabs).

```ts
const shell = createShell({ routes: [{ id: "chat" }, { id: "status", developer: true }], home: "chat", onRoute });
shell.mountPanels(panels);            // a tab and a page per module panel
shell.overlays.add(...);              // what Escape closes, in priority order
shell.start({ palette, keys });       // theme, service worker, shortcut sheet, keys, hash routing, Developer switch
shell.controllers.chat = { init, enter, leave };
shell.navigate();
```

A controller's `init` runs once on a page's first visit, `enter` and `leave` on every show and hide.

## Panels

A module manifest's `panel` (`tag`, `title`, `path`) plus the `PanelConnection` the host built is a `ShellPanel`
(`@mlx-bun/app-core`'s `PanelSpec` is assignable). The host imports each panel's entry when it builds its bundle, which
defines the custom element; the shell adds a tab (a developer tool unless `developer: false`) and a page whose route is
the panel's path, creates the element on first visit, sets `connection`, and keeps it attached only while its page is
shown, so its streams stop when the user leaves. A tag that is not defined shows a note instead of failing. `panelsFromManifests`
builds the list from module manifests: `apiBase` is `/api/<id>`, `eventsUrl` the module's first server-sent `GET`
route (empty when it has none), and `developer` is the manifest panel's own (`developer: false` keeps a panel every
user needs, such as Models, out of the Developer switch). The app's build (`apps/mlx-bun/src/web/build.ts`) imports the panel entry and manifest of
each module its `package.json` lists that exports `./panel`, and hands the manifests to it.

## Palette

`createPalette({ sections })` is the overlay: sections of rows, each computed per keystroke, with an optional
`remote` lookup after a 200 ms debounce for queries of two or more characters. `actionSection` lists commands
(`when` hides a command on other pages, `fuzzyMatch` filters by subsequence). What is searchable belongs to the host.

## Tests

Model-free under happy-dom: the router and Developer switch, two fake panels mounted, the Escape sweep, theme, and the
palette's sections and remote lookups ([shell tests](tests/shell.test.ts)). The app's
[boot tests](../../apps/mlx-bun/tests/web/boot.test.ts) run its built bundle against `app.html`.
