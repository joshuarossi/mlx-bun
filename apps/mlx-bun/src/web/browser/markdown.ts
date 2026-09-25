// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// The hand-rolled markdown renderer + streaming block-memoization +
// syntax-highlighting glue. Behavior-identical port of the original inline
// <script> in app.html. This module is the streaming-parity oracle for
// tests/using/web-app.test.ts: renderBlocksIncremental fed char-by-char must
// converge to the exact same innerHTML as one-shot mdToHtml.

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
 *  markup/vector document is). Exported so tests/using/web-app.test.ts can check
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
  // Canvas v1 (plan §9 Phase 3, beat matrix Axis 2): a Preview|Source toggle
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
   CANVAS V1 (plan §9 Phase 3, beat matrix Axis 2 — "I miss optiq's Canvas"
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

/** Capture which Canvas-eligible codeblocks (in document order) are
 *  currently showing Preview, keyed by their positional index within
 *  `container` — NOT by fence content, since two identical fences would
 *  collide on a content key and streamed text can still be mutating right
 *  up to the caller's re-render. Positional index is stable across a
 *  finishStreaming-style "replace innerHTML with a fresh render of the
 *  same final text" pass because mdToHtml walks the same fences in the
 *  same order both times. Returns an empty array cheaply when nothing is
 *  in Preview (the common case) — callers should skip the restore pass
 *  entirely when the array is empty. */
export function captureCanvasViewStates(container: HTMLElement): number[] {
  const previewIdx: number[] = [];
  const blocks = container.querySelectorAll(".codeblock.has-canvas");
  blocks.forEach((block, i) => {
    if (block.querySelector(".cbview-preview")?.classList.contains("active")) previewIdx.push(i);
  });
  return previewIdx;
}

/** Inverse of captureCanvasViewStates: re-apply Preview to the codeblocks
 *  at the given positional indices after a full re-render replaced the
 *  container's innerHTML (which always resets every qualifying fence back
 *  to its default Source view — see mdCodeBlock). A no-op for any index
 *  past the end of the freshly rendered set (final text had fewer
 *  qualifying fences than the mid-stream snapshot did — nothing sensible
 *  to restore, so it's silently skipped rather than throwing). */
export function restoreCanvasViewStates(container: HTMLElement, previewIdx: readonly number[]): void {
  if (!previewIdx.length) return;
  const blocks = container.querySelectorAll(".codeblock.has-canvas");
  for (const i of previewIdx) {
    const block = blocks[i] as HTMLElement | undefined;
    if (block) setCanvasView(block, "preview");
  }
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

/* ────────────────────────────────────────────────────────────────────
   CHAT-WITH-FILES RAG v1 — [n] citation markers (plan §9 Phase 3, beat
   matrix Axis 5): when a turn's prompt carried retrieved chunks
   (composer.ts's buildMessageText, retrieval-mode branch), the model is
   asked to cite them inline as `[n]`. This turns each SURVIVING `[n]`
   marker in the assistant's rendered HTML into a clickable superscript
   link that expands/scrolls the Sources panel (chat.ts) — but ONLY when a
   citation map for that exact n was actually attached to this message
   (never linkify `[n]` in an ordinary reply, e.g. "see note [1] below" in
   a message with no attachments at all — that would be a false citation).
   ──────────────────────────────────────────────────────────────────── */

/** Pure: rewrite bracketed `[n]` markers in already-rendered HTML text into
 *  clickable citation links, but only for n's present in `validNs` — every
 *  other `[...]` run (including `[n]` for an n outside the cited set) is
 *  left untouched. Operates on HTML (post mdToHtml/mdInline), not raw
 *  markdown source, so it must NOT rewrite inside tag markup — an `<a
 *  href="...[1]...">` (a URL that happens to contain a literal "[1]" in its
 *  path, or any other attribute value) would otherwise get a `<button>`
 *  spliced into the middle of the attribute string, corrupting the tag.
 *  Splits the string on tag boundaries first and only replaces `[n]` runs
 *  in the text-node segments between tags. */
export function linkifyCitations(html: string, validNs: ReadonlySet<number>): string {
  if (!validNs.size) return html;
  const replaceMarkers = (text: string): string =>
    text.replace(/\[(\d{1,3})\]/g, (m, d: string) => {
      const n = Number(d);
      if (!validNs.has(n)) return m;
      return '<button type="button" class="cite-mark" data-cite="' + n + '" aria-label="Source ' + n + '">' + n + "</button>";
    });
  // Split into alternating [text, tag, text, tag, ...] segments — capturing
  // group in split() keeps the tag delimiters in the output array — and
  // only rewrite the (even-indexed) text segments.
  return html.split(/(<[^>]*>)/g).map((seg, i) => (i % 2 === 0 ? replaceMarkers(seg) : seg)).join("");
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

/* ────────────────────────────────────────────────────────────────────
   STREAMING BLOCK MEMOIZATION  (plan §5.3, §2.2 #7)
   ────────────────────────────────────────────────────────────────────
   Naively doing `textNode.innerHTML = mdToHtml(fullText)` on every token
   is O(n^2) over a response: every delta re-parses and re-renders the
   *entire* message from scratch, and innerHTML-replace also blows away
   and recreates every DOM node (losing e.g. text selection) each time.

   The fix, ported from the Streamdown/t3.chat "block memoization"
   pattern into this vanilla renderer: split accumulated text at stable
   block boundaries (blank lines; a fenced code block counts as one
   block and only becomes "stable" once its closing fence has arrived).
   Every block except the last is done streaming and gets parsed with
   mdToHtml exactly ONCE — its DOM node is then left completely alone.
   Only the last ("live tail") block gets re-parsed on each delta, and
   even that is throttled to once per animation frame so a burst of
   fast tokens (e.g. spec-decode) coalesces into one reflow instead of
   one per token.

   INVARIANT (this is the correctness test for this whole scheme, and the
   thing tests/using/web-app.test.ts's streaming-parity fixtures check): the
   memoized incremental render must be pixel-for-pixel/byte-for-byte
   identical to a single `mdToHtml(fullText)` pass once the message is
   complete. We guarantee this by (a) never touching a block's DOM once
   it's marked done, using the same mdToHtml on that exact substring
   that a full pass would have used, and (b) doing one full non-
   memoized mdToHtml(fullText) pass at turn-end (see finishStreaming in
   chat.ts) to paper over any edge case where incremental block splitting
   disagrees with whole-text parsing (e.g. a list that only "closes"
   because a later blank line arrives, or a paragraph the tail-block
   join glued differently than the full parse would). That final pass
   is the ground truth; the incremental renders are a fast-path
   approximation of it while streaming is in flight. */

export interface MdBlock {
  text: string;
  done: boolean;
  node?: HTMLElement;
}

export interface BlockState {
  blocks: MdBlock[];
}

/** Split text into blocks at blank lines. A fenced code block (opened by
 *  a ``` or ~~~ fence) is always kept as a single block and is only
 *  "closed" (safe to memoize) once its matching closing fence has been
 *  seen — while the fence is still open we keep extending the same
 *  block on every call, exactly like mdToHtml's own fence scanner does.
 *  Returns [{text, done}]; every element except possibly the last has
 *  done:true (the last block is "done" too if the text itself ends
 *  with a blank line — i.e. the block truly can't grow anymore given
 *  what's arrived so far). */
export function splitBlocks(src: unknown): MdBlock[] {
  const lines = String(src).replace(/\r\n?/g, "\n").split("\n");
  const blocks: MdBlock[] = [];
  let buf: string[] = [], i = 0;
  const flush = (done: boolean) => { if (buf.length) { blocks.push({ text: buf.join("\n"), done }); buf = []; } };

  while (i < lines.length) {
    const ln = lines[i]!;
    const fence = ln.match(/^\s*(`{3,}|~{3,})/);
    if (fence) {
      // A fence starts a code block: flush whatever came before it as its
      // own (done) block, then greedily consume lines until the matching
      // closing fence — the whole fenced region is one block.
      flush(true);
      const tick = fence[1]![0];
      const closeRe = new RegExp("^\\s*" + (tick === "`" ? "`{3,}" : "~{3,}") + "\\s*$");
      buf.push(ln); i++;
      let closed = false;
      while (i < lines.length) {
        buf.push(lines[i]!);
        if (closeRe.test(lines[i]!)) { closed = true; i++; break; }
        i++;
      }
      flush(closed); // still-open fence -> not done; more deltas may extend it
      continue;
    }
    if (ln.trim() === "") { flush(true); i++; continue; }
    buf.push(ln); i++;
  }
  // Trailing buffered lines with no closing blank line yet: this is the
  // live tail, not done — it may still grow on the next delta.
  flush(false);
  return blocks;
}

/**
 * Incrementally (re)render an accumulated markdown string into `container`
 * using block memoization. `state` is a small cache object stashed on the
 * caller (e.g. `a.blockState`) shaped `{ blocks: [{text, done, node}] }`,
 * created fresh per message. Completed blocks whose text hasn't changed
 * since last render are left untouched (their DOM node is reused as-is);
 * only new/changed/live-tail blocks get an mdToHtml call.
 *
 * Completed block nodes get `class="md-block done"` and, once rendered,
 * have any fenced code inside them run through highlightIn() (syntax
 * highlighting only ever touches finished blocks — never the streaming
 * live tail, to avoid re-highlighting on every token).
 */
export function renderBlocksIncremental(container: HTMLElement, text: string, state: BlockState): void {
  const next = splitBlocks(text);
  const prev = state.blocks || [];

  for (let k = 0; k < next.length; k++) {
    const nb = next[k]!;
    const pb = prev[k];
    if (pb && pb.done && pb.text === nb.text && pb.node) {
      // Unchanged completed block: reuse the existing node untouched.
      nb.node = pb.node;
      continue;
    }
    // (Re)render this block. Reuse the DOM node in place if one already
    // exists at this index (keeps node identity stable across re-renders
    // of the live tail instead of thrashing the DOM), otherwise create it.
    const node = pb && pb.node ? pb.node : document.createElement("div");
    node.className = "md-block" + (nb.done ? " done" : "");
    node.innerHTML = mdToHtml(nb.text);
    nb.node = node;
    if (!node.parentNode) container.appendChild(node);
    if (nb.done) highlightIn(node);
  }
  // Drop any now-stale trailing nodes (text shrank — shouldn't normally
  // happen during streaming, but keep the DOM honest if it ever does).
  for (let k = next.length; k < prev.length; k++) {
    const pk = prev[k];
    if (pk && pk.node && pk.node.parentNode) pk.node.remove();
  }
  state.blocks = next;
}

/* ────────────────────────────────────────────────────────────────────
   SYNTAX HIGHLIGHTING (plan §5.3/§7)
   ────────────────────────────────────────────────────────────────────
   Vendored highlight.js (src/web/vendor/hljs.js, no CDN — see that file's
   header) applied to fenced code blocks. mdCodeBlock() above stamps
   `class="language-<fence-info-string>"` onto the <code> element when the
   fence declares one (```ts, ```python, ...); highlight.js reads that class
   itself (its own `language-xxx` convention), so no lookup table is needed
   here — an empty/unrecognized language just falls through to hljs's
   plaintext handling.

   Called from exactly three places, matching the plan's "block completion
   + final full-render pass" instruction:
     1. renderBlocksIncremental(), only on blocks freshly marked `done`
        (the live streaming tail is never highlighted — that would mean
        re-highlighting on every token, the same O(n^2) shape the block-
        memoization pass just fixed).
     2. finishStreaming() in chat.ts, the end-of-turn full mdToHtml pass
        (ground truth — catches any block whose "done" transition happened
        without a fresh render, e.g. the last block if it ends exactly on
        a blank line).
     3. renderAssistantStatic() in chat.ts, for replayed history.
   Idempotent via hljs's own `data-highlighted` marker (set on the <code>
   element after its first highlightElement() call) — highlightElement()
   itself throws "Element previously highlighted" if called twice on the
   same node without clearing that marker, so we check for it explicitly
   rather than relying on the library to no-op. */

/** The vendored highlight.js global (src/web/vendor/hljs.js), loaded via a
 *  plain <script defer src="/assets/hljs.js">, not an ES module — so it's
 *  a `window` global, not an import. Declared loosely (not the full hljs
 *  typing) since this app only calls the one method. */
declare const hljs: { highlightElement(el: Element): void } | undefined;

export function highlightIn(container: HTMLElement | null): void {
  if (typeof hljs === "undefined" || !container) return;
  const blocks = container.querySelectorAll("pre code");
  for (const block of blocks) {
    const el = block as HTMLElement;
    if (el.dataset.highlighted) continue; // already done — idempotent
    // Skip auto-detect on huge blocks: hljs's language guesser runs every
    // registered grammar against the text, which is fine for a fenced
    // ```lang block (single grammar) but expensive with no declared
    // language on a very large block. A declared language always runs
    // (fixed grammar, no guessing), regardless of size.
    const hasLang = /\blanguage-/.test(el.className);
    if (!hasLang && (el.textContent || "").length > 20_000) continue;
    try { hljs!.highlightElement(el); } catch { /* leave as plain text */ }
  }
}

/** rAF-throttle `render` so a burst of calls within one frame collapses into
 *  a single DOM update. `shouldStick`/`doStick` (both optional) let a caller
 *  autoscroll correctly across the coalesced burst: `shouldStick` is sampled
 *  fresh at the START of each queued frame (i.e. right before `render` runs,
 *  against whatever scrollHeight the LAST completed render left behind —
 *  never the stale pre-burst height a synchronous caller-side check would
 *  see), and `doStick` runs immediately after `render` grows the DOM in that
 *  same frame, so the pin decision and the scroll it acts on are always the
 *  correct before/after pair regardless of how many calls got coalesced. */
export function makeFrameScheduler(render: () => void, shouldStick?: () => boolean, doStick?: () => void): () => void {
  let queued = false;
  return function schedule() {
    if (queued) return;
    queued = true;
    requestAnimationFrame(() => {
      queued = false;
      const stickAfter = shouldStick ? shouldStick() : false;
      render();
      if (stickAfter && doStick) doStick();
    });
  };
}

/** Render a step indicator into a container. names[], current index. */
export function renderSteps(container: HTMLElement, names: string[], cur: number): void {
  container.innerHTML = names.map((n, i) => {
    const cls = i === cur ? "cur" : (i < cur ? "done" : "");
    const arrow = i < names.length - 1 ? '<span class="arrow">&#8594;</span>' : "";
    return '<span class="s ' + cls + '"><span class="n">' + (i + 1) + "</span>" + esc(n) + "</span>" + arrow;
  }).join("");
}
