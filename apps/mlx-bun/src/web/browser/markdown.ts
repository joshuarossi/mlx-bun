// Built into apps/mlx-bun/dist/web/app.js by scripts/build-web.ts.
//
// What the app's own pages need from the hand-rolled markdown renderer: `esc`, the memory panel's article rendering
// (mdToHtml with its Canvas toggle) and the wizards' step indicator. The chat panel (`@mlx-bun/module-chat`) carries
// its own full renderer (streaming, citations, highlighting), as a self-contained panel does; the memory panel
// carries this one until memory becomes a module.

/** Escape the four HTML-significant characters. Used on every interpolation
 *  site across the app — the single discipline that keeps user/model text
 *  from ever being interpreted as markup. */
export const esc = (s: unknown): string =>
  String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string, string>)[c]!);

/** Allow only safe link targets (http/https/mailto/anchor/relative). */
export function mdSafeUrl(u: unknown): string | null {
  const s = String(u).trim();
  return /^(https?:\/\/|mailto:|#|\/|\.{1,2}\/)/i.test(s) ? s : null;
}

/** Inline markdown -> HTML. Escapes first, then shields code spans from
 *  further markup so backticked text is never mangled or unsafe. */
export function mdInline(t: unknown): string {
  const codes: string[] = [];
  // Pull code spans out first (any run of backticks), then escape the rest.
  let src = String(t).replace(/(`+)([\s\S]+?)\1/g, (_m, _ticks, c: string) => {
    codes.push(c.replace(/^ | $/g, ""));
    return "\0C" + (codes.length - 1) + "\0";
  });
  let s = esc(src);
  // [text](url "title") — title optional and ignored.
  s = s.replace(/\[([^\]]+)\]\(\s*([^)\s]+)(?:\s+&quot;[^)]*&quot;)?\s*\)/g, (m, text: string, url: string) => {
    const safe = mdSafeUrl(url);
    return safe ? '<a href="' + safe + '" target="_blank" rel="noopener noreferrer">' + text + "</a>" : m;
  });
  s = s
    .replace(/\*\*\*([^*]+)\*\*\*/g, "<strong><em>$1</em></strong>")
    .replace(/\*\*([^*]+?)\*\*/g, "<strong>$1</strong>")
    .replace(/(^|[^_\w])__([^_]+?)__(?![\w])/g, "$1<strong>$2</strong>")
    .replace(/(^|[^*\w])\*([^*\s][^*]*?)\*/g, "$1<em>$2</em>")
    .replace(/(^|[^_\w])_([^_\s][^_]*?)_(?![\w])/g, "$1<em>$2</em>")
    .replace(/~~([^~]+?)~~/g, "<del>$1</del>");
  // Autolink bare URLs that markdown didn't already wrap.
  s = s.replace(/(^|[\s(])(https?:\/\/[^\s<)]+[^\s<).,;:!?'"])/g,
    (_m, pre: string, url: string) => pre + '<a href="' + url + '" target="_blank" rel="noopener noreferrer">' + url + "</a>");
  return s.replace(/\0C(\d+)\0/g, (_m, i: string) => "<code>" + esc(codes[+i]) + "</code>");
}

/** Pure: does this fence's language tag qualify for the Canvas v1
 *  Preview|Source toggle? Only html/svg — js/ts/etc. fences never get a
 *  toggle (running arbitrary script output isn't the feature; rendering a
 *  markup/vector document is). Exported so apps/mlx-bun/tests/web/browser.test.ts can check
 *  the detection logic directly without a DOM. */
export function isCanvasFence(lang: string): boolean {
  return /^(html?|svg)$/i.test(lang.trim());
}

export function mdCodeBlock(lang: string, code: string): string {
  // language-<lang> on <code> is the de-facto convention hljs's own
  // language-detection-from-class reads (see highlightIn() below); an empty
  // fence info string just omits the class and highlightIn() skips it.
  const langClass = lang ? ' class="language-' + esc(lang) + '"' : "";
  const canvas = isCanvasFence(lang);
  // Canvas v1 (`02d723a:docs/design/web-chat-redesign.md` Appendix A,
  // beat-matrix Axis 2): a Preview|Source toggle
  // next to Copy for completed html/svg fences. The toggle markup is always
  // emitted for a qualifying fence (even while the block is still streaming
  // — mdCodeBlock only ever runs on a CLOSED fence per mdToHtml/splitBlocks,
  // so "qualifying" already implies "complete"); the iframe itself is never
  // created here — see wireCanvasToggle's lazy srcdoc creation below, so an
  // unopened Preview never executes model-generated script.
  const toggleHtml = canvas
    ? '<span class="cbtoggle" role="group" aria-label="View">' +
      '<button class="cbview cbview-source active" type="button" aria-pressed="true">Source</button>' +
      '<button class="cbview cbview-preview" type="button" aria-pressed="false">Preview</button>' +
      "</span>"
    : "";
  // The raw fence text (pre-escape) is stashed verbatim in a hidden <div>
  // sibling so wireCanvasToggle can read it back via .textContent (the
  // browser does entity-decoding for .textContent on ordinary elements, so
  // no manual unescape needed) without re-parsing the highlighted/escaped
  // <code> body. NOT a <script> tag: script/style are HTML "raw text"
  // elements whose content the parser does NOT entity-decode (textContent
  // would come back as the literal "&lt;h1&gt;" instead of "<h1>") — a plain
  // element sidesteps that without needing any special-case unescaping, and
  // `hidden` (not display:none, matching convention elsewhere in this file)
  // keeps it out of layout and never executed either way.
  const srcStash = canvas ? '<div class="cbsrc" hidden>' + esc(code) + "</div>" : "";
  return '<div class="codeblock' + (canvas ? " has-canvas" : "") + '"><div class="cbhead"><span class="cblang">' + esc(lang || "") +
    "</span>" + toggleHtml + '<button class="cbcopy" type="button">Copy</button></div>' +
    "<pre><code" + langClass + ">" + esc(code) + "</code></pre>" + srcStash +
    (canvas ? '<div class="cbcanvas" hidden></div>' : "") + "</div>";
}

/* ────────────────────────────────────────────────────────────────────
   CANVAS V1 (`02d723a:docs/design/web-chat-redesign.md` Appendix A,
   beat-matrix Axis 2 — "I miss optiq's Canvas"
   is a disallowed outcome): completed html/svg fenced code blocks get a
   Preview|Source toggle in the existing .cbhead bar. Preview renders the
   fence content in a sandboxed <iframe>.

   SECURITY: the iframe sandbox is `allow-scripts` ONLY — never
   `allow-same-origin` together with `allow-scripts`. Combining them would
   let a model-generated <script> read this iframe's effective origin,
   which the browser resolves to the PARENT document's origin for a
   srcdoc/about:blank frame with allow-same-origin — i.e. the sandboxed
   content could reach window.parent's DOM, localStorage, and the live
   WebSocket. allow-scripts alone keeps the frame in a unique opaque
   origin: scripts run, but same-origin-gated APIs (parent access,
   storage, cookies) are denied by the browser regardless of what the
   content tries. This is the one non-negotiable line in this feature.

   Lazy: the iframe element is only created on the first "Preview" click
   (never auto-run) — a model that emits an html fence should not get a
   free script execution just because a message rendered.
   ──────────────────────────────────────────────────────────────────── */

/** Wire the Preview/Source toggle + Copy button for every codeblock inside
 *  `container` via ONE delegated click listener — safe to call once on a
 *  stable ancestor (chat's `thread()` element, the memory panel's
 *  `mem-body`) whose innerHTML gets replaced/extended repeatedly; delegation
 *  means newly rendered codeblocks are wired for free, no per-render
 *  re-attachment needed. Copy-button wiring already lives inline in
 *  chat.ts's own delegated listener — this function only owns the Canvas
 *  toggle so it can be shared between chat.ts and memory-panel.ts without
 *  duplicating the Copy logic in two places. */
export function wireCanvasToggle(container: HTMLElement): void {
  container.addEventListener("click", (e) => {
    const btn = (e.target as HTMLElement).closest?.(".cbview") as HTMLElement | null;
    if (!btn || !container.contains(btn)) return;
    const block = btn.closest(".codeblock");
    if (!block) return;
    const showPreview = btn.classList.contains("cbview-preview");
    setCanvasView(block as HTMLElement, showPreview ? "preview" : "source");
  });
}

function setCanvasView(block: HTMLElement, view: "preview" | "source"): void {
  const sourceBtn = block.querySelector(".cbview-source");
  const previewBtn = block.querySelector(".cbview-preview");
  const pre = block.querySelector("pre");
  const canvasEl = block.querySelector(".cbcanvas") as HTMLElement | null;
  if (!sourceBtn || !previewBtn || !pre || !canvasEl) return;
  sourceBtn.classList.toggle("active", view === "source");
  sourceBtn.setAttribute("aria-pressed", String(view === "source"));
  previewBtn.classList.toggle("active", view === "preview");
  previewBtn.setAttribute("aria-pressed", String(view === "preview"));
  if (view === "source") {
    canvasEl.hidden = true;
    (pre as HTMLElement).hidden = false;
    return;
  }
  (pre as HTMLElement).hidden = true;
  canvasEl.hidden = false;
  // Lazy iframe creation: only build it the first time Preview is opened,
  // never on render. srcdoc (not src=data:) keeps everything same-tab, no
  // network hop, and no history entry.
  if (!canvasEl.querySelector("iframe")) {
    const srcEl = block.querySelector(".cbsrc");
    const code = srcEl ? srcEl.textContent || "" : "";
    const frame = document.createElement("iframe");
    frame.className = "cbframe";
    // allow-scripts ONLY — see the file-level comment above this section.
    frame.setAttribute("sandbox", "allow-scripts");
    frame.setAttribute("loading", "lazy");
    frame.title = "Canvas preview";
    // A neutral light background regardless of app theme: model-authored
    // HTML/SVG rarely sets its own background, and an unstyled fragment on
    // a dark app background reads as broken; a plain white canvas is the
    // one assumption that's safe for both arbitrary markup and dark/light
    // app themes alike (this iframe is content the model wrote, not app
    // chrome, so it doesn't need to follow the app's theme toggle).
    frame.srcdoc = code;
    canvasEl.appendChild(frame);
  }
}

function mdTableSep(s: string): boolean { return /^[\s|:-]+$/.test(s) && /-/.test(s) && /\|/.test(s); }
function mdSplitRow(s: string): string[] { return s.trim().replace(/^\|/, "").replace(/\|$/, "").split("|").map((c) => c.trim()); }
function mdBlockStart(s: string): boolean {
  return /^\s*(`{3,}|~{3,})/.test(s) || /^(#{1,6})\s/.test(s) || /^\s*>/.test(s) ||
    /^\s*[-*+]\s+/.test(s) || /^\s*\d+[.)]\s+/.test(s) || /^\s*([-*_])\s*(\1\s*){2,}$/.test(s);
}

/** Safe markdown renderer: code fences (w/ copy), headings, lists, task
 *  lists, tables, blockquotes, rules, links, emphasis, inline code. */
export function mdToHtml(src: unknown): string {
  const lines = String(src).replace(/\r\n?/g, "\n").split("\n");
  let html = "", i = 0, list: string | null = null;
  const closeList = () => { if (list) { html += "</" + list + ">"; list = null; } };

  while (i < lines.length) {
    const ln = lines[i]!;

    // fenced code block
    const fence = ln.match(/^\s*(`{3,}|~{3,})\s*([\w+#.-]*)/);
    if (fence) {
      closeList();
      const tick = fence[1]![0], lang = fence[2] || "", buf: string[] = [];
      const closeRe = new RegExp("^\\s*" + (tick === "`" ? "`{3,}" : "~{3,}") + "\\s*$");
      i++;
      while (i < lines.length && !closeRe.test(lines[i]!)) { buf.push(lines[i]!); i++; }
      i++; // consume closing fence (or run off the end mid-stream)
      html += mdCodeBlock(lang, buf.join("\n"));
      continue;
    }

    // GFM table: a row with pipes followed by a separator row
    if (ln.includes("|") && i + 1 < lines.length && mdTableSep(lines[i + 1]!)) {
      closeList();
      const header = mdSplitRow(ln);
      const aligns = mdSplitRow(lines[i + 1]!).map((c) => {
        const l = c.startsWith(":"), r = c.endsWith(":");
        return l && r ? "center" : r ? "right" : l ? "left" : "";
      });
      i += 2;
      const rows: string[][] = [];
      while (i < lines.length && lines[i]!.includes("|") && lines[i]!.trim() !== "") { rows.push(mdSplitRow(lines[i]!)); i++; }
      const al = (k: number) => (aligns[k] ? ' style="text-align:' + aligns[k] + '"' : "");
      let tbl = '<div class="md-tablewrap"><table class="md-table"><thead><tr>';
      header.forEach((c, k) => { tbl += "<th" + al(k) + ">" + mdInline(c) + "</th>"; });
      tbl += "</tr></thead><tbody>";
      rows.forEach((r) => {
        tbl += "<tr>";
        for (let k = 0; k < header.length; k++) tbl += "<td" + al(k) + ">" + mdInline(r[k] || "") + "</td>";
        tbl += "</tr>";
      });
      html += tbl + "</tbody></table></div>";
      continue;
    }

    // heading
    const h = ln.match(/^(#{1,6})\s+(.*)$/);
    if (h) { closeList(); const n = h[1]!.length; html += "<h" + n + ">" + mdInline(h[2]!.replace(/\s+#+\s*$/, "")) + "</h" + n + ">"; i++; continue; }

    // horizontal rule
    if (/^\s*([-*_])\s*(\1\s*){2,}$/.test(ln)) { closeList(); html += "<hr>"; i++; continue; }

    // blockquote (consecutive '>' lines, rendered recursively)
    if (/^\s*>/.test(ln)) {
      closeList();
      const buf: string[] = [];
      while (i < lines.length && /^\s*>/.test(lines[i]!)) { buf.push(lines[i]!.replace(/^\s*>\s?/, "")); i++; }
      html += "<blockquote>" + mdToHtml(buf.join("\n")) + "</blockquote>";
      continue;
    }

    // task list / unordered / ordered list items
    const task = ln.match(/^\s*[-*+]\s+\[([ xX])\]\s+(.*)$/);
    const ul = ln.match(/^\s*[-*+]\s+(.*)$/);
    const ol = ln.match(/^\s*\d+[.)]\s+(.*)$/);
    if (task) {
      if (list !== "ul") { closeList(); html += "<ul>"; list = "ul"; }
      html += '<li class="task"><input type="checkbox" disabled' + (task[1]!.toLowerCase() === "x" ? " checked" : "") + "> " + mdInline(task[2]!) + "</li>";
      i++; continue;
    }
    if (ul) { if (list !== "ul") { closeList(); html += "<ul>"; list = "ul"; } html += "<li>" + mdInline(ul[1]!) + "</li>"; i++; continue; }
    if (ol) { if (list !== "ol") { closeList(); html += "<ol>"; list = "ol"; } html += "<li>" + mdInline(ol[1]!) + "</li>"; i++; continue; }

    if (ln.trim() === "") { closeList(); i++; continue; }

    // paragraph: merge following plain lines (soft breaks -> <br>)
    closeList();
    const para = [ln];
    i++;
    while (i < lines.length && lines[i]!.trim() !== "" && !mdBlockStart(lines[i]!)) { para.push(lines[i]!); i++; }
    html += "<p>" + para.map(mdInline).join("<br>") + "</p>";
  }
  closeList();
  return html;
}

/** Render a step indicator into a container. names[], current index. */
export function renderSteps(container: HTMLElement, names: string[], cur: number): void {
  container.innerHTML = names.map((n, i) => {
    const cls = i === cur ? "cur" : (i < cur ? "done" : "");
    const arrow = i < names.length - 1 ? '<span class="arrow">&#8594;</span>' : "";
    return '<span class="s ' + cls + '"><span class="n">' + (i + 1) + "</span>" + esc(n) + "</span>" + arrow;
  }).join("");
}
