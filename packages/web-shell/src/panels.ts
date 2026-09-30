// Module panels: each installed module's web panel is a self-contained custom element (`mlx-<id>-panel`) that
// receives a `PanelConnection` and imports nothing outside its module. The host imports each panel's entry when it
// builds its browser bundle (that defines the element) and hands the shell one `ShellPanel` per panel; the shell
// gives it a navigation tab and a page, creates the element on first visit, and keeps it connected only while its
// page is shown.
import { el, injectStyles } from "./dom";

/** What a panel is told about its backend: the same shape as `@mlx-bun/app-core`'s `PanelConnection`. */
export interface PanelConnection {
  /** Absolute or origin-relative base of `/api/<module id>`. */
  readonly apiBase: string;
  /** Server-sent stream the panel follows. */
  readonly eventsUrl: string;
  /** Optional presentation supplied by the embedding host. */
  readonly ui?: {
    notify?(message: string, kind?: "ok" | "err"): void;
    publish?(container: HTMLElement, source: { kind: "quantize" | "finetune" | "dataset"; job_id?: string; source_path?: string }): void | Promise<void>;
    modelId?(): string | undefined;
    catalogChanged?(): void;
  };

}

/** One panel to mount: a module manifest's `panel` (`tag`, `title`, `path`; `@mlx-bun/app-core`'s `PanelSpec` is
 * assignable) plus the connection the host built for it. */
export interface ShellPanel {
  /** Custom element tag, `mlx-<module id>-panel`. */
  readonly tag: string;
  readonly title: string;
  /** Declared shell route: one lowercase kebab-case segment. */
  readonly path: string;
  readonly connection: PanelConnection;
  /** Listed among the developer tools (hidden until the Developer switch is on). Default true. */
  readonly developer?: boolean;
}

/** The element as the shell sees it. */
export type PanelElement = HTMLElement & { connection?: PanelConnection };

/** The parts of a module manifest the shell reads (`@mlx-bun/app-core`'s `AppModule` is assignable). */
export interface PanelManifest {
  readonly id: string;
  readonly panel?: { readonly tag: string; readonly title: string; readonly path: string };
  readonly routes?: readonly { readonly method: string; readonly path: string; readonly response: string; readonly mount?: string }[];
}

/** The panels of the given module manifests, each connected to its module's routes: `apiBase` is `/api/<id>` and
 * `eventsUrl` the module's first server-sent `GET` route (empty when it serves none). Modules without a panel are skipped. */
export function panelsFromManifests(manifests: readonly PanelManifest[]): ShellPanel[] {
  return manifests.flatMap((module): ShellPanel[] => {
    if (!module.panel) return [];
    const stream = module.routes?.find(route => route.method === "GET" && route.response === "sse" && route.mount !== "root");
    return [{ tag: module.panel.tag, title: module.panel.title, path: module.panel.path,
      connection: { apiBase: `/api/${module.id}`, eventsUrl: stream ? `/api/${module.id}${stream.path}` : "" } }];
  });
}

/** The route id of a panel: its path without the leading slash. */
export function panelRouteId(panel: Pick<ShellPanel, "path">): string {
  return panel.path.replace(/^\/+/, "");
}

const STYLE = `
/* The frame every module panel sits in. Panels style themselves inside their shadow root from the tokens below, which
   this frame maps from the host page's design tokens (--ink, --hairline, ...). */
.shell-panel-scroll{height:100%;overflow-y:auto}
.shell-panel{max-width:1180px;margin:0 auto;padding:46px 28px 120px;
  --text:var(--ink,CanvasText);--line:var(--hairline,rgba(128,128,128,.3))}
.shell-panel-title{font-size:clamp(26px,3.6vw,46px);font-weight:700;letter-spacing:-.026em;line-height:1.06;margin-bottom:26px}
.shell-panel-body{background:var(--card,transparent);border:1px solid var(--hairline,rgba(128,128,128,.3));
  border-radius:20px;padding:22px 24px}
.shell-panel-note{color:var(--dim,GrayText);font-size:14px}
@media (max-width:760px){.shell-panel{padding:34px 18px 100px}}
`;

/** Builds a panel's tab and page (the page's section is not attached to the outlet here) and returns the pieces the
 * router needs. */
export function buildPanelPage(panel: ShellPanel): { id: string; tab: HTMLAnchorElement; section: HTMLElement; controller: { enter(): void; leave(): void } } {
  injectStyles("mlxbun-shell-panel-style", STYLE);
  const id = panelRouteId(panel);
  const tab = document.createElement("a");
  tab.className = "tab";
  tab.href = "#/" + id;
  tab.dataset.tab = id;
  if (panel.developer !== false) tab.dataset.dev = "";
  tab.textContent = panel.title;

  const section = document.createElement("section");
  section.dataset.route = id;
  section.id = "s-" + id;
  const scroll = el("div", "shell-panel-scroll", section);
  const page = el("div", "shell-panel", scroll);
  const title = el("h2", "shell-panel-title", page);
  title.textContent = panel.title;
  const body = el("div", "shell-panel-body", page);

  let element: PanelElement | undefined;
  return {
    id, tab, section,
    controller: {
      enter() {
        if (!element) {
          if (!customElements.get(panel.tag)) {
            const note = el("p", "shell-panel-note", body);
            note.textContent = `This build does not include the ${panel.title} panel (<${panel.tag}> is not defined).`;
            return;
          }
          element = document.createElement(panel.tag) as PanelElement;
          element.connection = panel.connection;
        }
        body.append(element);
      },
      leave() { element?.remove(); },
    },
  };
}
