// The overlay's markup, its icons and its stylesheet. The panel renders into the light DOM, so the stylesheet is injected
// into the page once (`injectStyles`) and written against the web kit's tokens and base vocabulary, which the host page
// links. Besides the drawer it styles what memory draws into the chat panel's markup by id: the sidebar entry
// (`#chat-memory-entry`), the consent card (`#chat-consent`) and the provenance chips (`.memchip`) in the thread.

const svg = (paths: string, cls = ""): string =>
  `<svg${cls ? ` class="${cls}"` : ""} viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${paths}</svg>`;

/** Inline icons: the app runs offline, so no icon font or sprite is fetched. */
export const ICONS = {
  back: svg('<path d="m15 18-6-6 6-6"/>'),
  close: svg('<path d="M18 6 6 18M6 6l12 12"/>'),
  memory: (cls = "") => svg('<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/><path d="M9 7h7M9 11h5"/>', cls),
  article: svg('<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6M16 13H8M16 17H8M10 9H8"/>'),
  reference: svg('<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>'),
  commit: svg('<circle cx="12" cy="12" r="3"/><path d="M3 12h6M15 12h6"/>'),
  caret: (cls = "") => svg('<path d="m9 18 6-6-6-6"/>', cls),
} as const;

export const TEMPLATE = `<div id="mem-overlay">
  <div id="mem-panel" role="dialog" aria-modal="true" aria-labelledby="mem-title">
    <div class="mem-head">
      <button class="btn icon quiet" id="mem-back" type="button" aria-label="Back to the article list" title="Back to the article list">${ICONS.back}</button>
      <h2 id="mem-title">Memory</h2>
      <button class="btn icon quiet" id="mem-close" type="button" aria-label="Close memory" title="Close">${ICONS.close}</button>
    </div>
    <div class="mem-status" id="mem-status"></div>
    <div class="mem-body" id="mem-body"></div>
  </div>
</div>`;

export const STYLE = String.raw`
/* ── the drawer: the right-hand side of the page over a scrim; full width under the top bar on a narrow screen ── */
#mem-overlay{position:fixed;inset:0;z-index:150;display:none;background:var(--overlay)}
#mem-overlay.open{display:block;animation:mem-fade var(--fast) var(--ease)}
#mem-panel{position:fixed;top:0;right:0;bottom:0;width:min(480px,100%);display:flex;flex-direction:column;
  background:var(--panel);border-left:1px solid var(--line-strong);box-shadow:var(--shadow-lg);
  color:var(--ink);font-family:var(--font);font-size:var(--text-md);line-height:1.45;animation:mem-slide var(--base) var(--ease)}
@keyframes mem-fade{from{opacity:0}to{opacity:1}}
@keyframes mem-slide{from{transform:translateX(28px);opacity:.4}to{transform:none;opacity:1}}
.mem-head{display:flex;align-items:center;gap:6px;min-height:58px;padding:10px 12px 10px 20px;border-bottom:1px solid var(--line);flex:0 0 auto}
.mem-head.back{padding-left:12px}
.mem-head h2{flex:1 1 auto;min-width:0;font-size:var(--text-lg);font-weight:650;letter-spacing:-.01em;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
#mem-back{display:none}
#mem-back.show{display:inline-flex}
.mem-status{display:flex;align-items:center;gap:6px;flex-wrap:wrap;padding:10px 20px;border-bottom:1px solid var(--line);flex:0 0 auto}
.mem-status:empty,#mem-panel.reading .mem-status{display:none}
.mem-body{flex:1 1 auto;overflow-y:auto;overscroll-behavior:contain;padding:16px 20px 32px}
@media (max-width:760px){
  #mem-overlay{top:var(--topbar-h)}
  #mem-panel{top:var(--topbar-h);width:100%;border-left:0;box-shadow:none}
  .mem-head{padding-left:16px}
  .mem-status,.mem-body{padding-left:16px;padding-right:16px}
}

/* ── the list: search, then the articles and the reference docs ── */
.mem-search{margin-bottom:16px}
.mem-sec{margin-bottom:18px}
.mem-sec:last-child{margin-bottom:0}
.mem-sec-title{font-size:var(--text-sm);font-weight:600;letter-spacing:.02em;color:var(--dim);margin:0 0 8px;display:flex;align-items:center;gap:8px}
.mem-sec-title .count{font-weight:500;color:var(--dimmer)}
.mem-art,.mem-hist-entry{cursor:pointer;transition:background var(--fast) var(--ease)}
.mem-art:hover,.mem-hist-entry:hover{background:var(--raised)}
.mem-art:focus-visible,.mem-hist-entry:focus-visible{outline-offset:-2px}
.mem-art-ico{display:inline-flex;color:var(--dimmer);flex:0 0 auto}
.mem-art-go{display:inline-flex;color:var(--dimmer);flex:0 0 auto}
.mem-note{color:var(--dim);font-size:var(--text-sm);line-height:1.5;padding:4px 0}
.mem-note.bad{color:var(--bad)}
.mem-loading{display:flex;flex-direction:column;gap:10px;padding:6px 0}
.mem-loading .skeleton{height:12px}
.mem-loading .skeleton:nth-child(1){width:62%}
.mem-loading .skeleton:nth-child(2){width:88%}
.mem-loading .skeleton:nth-child(3){width:74%}
.mem-empty{margin-top:12px}
.mem-empty p{max-width:44ch;margin:0 auto}
.mem-empty .notice{margin-top:14px;text-align:left}

/* ── an article: Article and History as a segmented control, the rendered page, its links ── */
.mem-tabs{margin-bottom:16px}
.mem-article-render{font-size:var(--text-md);line-height:1.65;color:var(--ink);overflow-wrap:anywhere}
.mem-article-render h1,.mem-article-render h2,.mem-article-render h3,.mem-article-render h4{font-weight:650;letter-spacing:-.01em;line-height:1.3;margin:18px 0 8px}
.mem-article-render h1{font-size:var(--text-xl)}
.mem-article-render h2{font-size:var(--text-lg)}
.mem-article-render h3,.mem-article-render h4{font-size:var(--text-md)}
.mem-article-render>:first-child{margin-top:0}
.mem-article-render p{margin:0 0 10px}
.mem-article-render ul,.mem-article-render ol{margin:0 0 10px;padding-left:22px}
.mem-article-render li{margin:3px 0}
.mem-article-render li.task{list-style:none;margin-left:-20px}
.mem-article-render li.task input{margin-right:7px;vertical-align:-2px}
.mem-article-render strong{font-weight:650}
.mem-article-render del{opacity:.6}
.mem-article-render a{color:var(--accent)}
.mem-article-render blockquote{margin:10px 0;padding:2px 14px;border-left:3px solid var(--line-strong);color:var(--dim)}
.mem-article-render hr{border:0;border-top:1px solid var(--line);margin:16px 0}
.mem-article-render code{font-size:.88em}
.mem-article-render .md-tablewrap{overflow-x:auto;margin:12px 0}
.mem-article-render table.md-table{width:100%;border-collapse:collapse;font-size:var(--text-sm);font-variant-numeric:tabular-nums}
.mem-article-render table.md-table th,.mem-article-render table.md-table td{border-top:1px solid var(--line);padding:7px 10px;text-align:left;vertical-align:top}
.mem-article-render table.md-table th{border-top:0;font-size:var(--text-xs);font-weight:600;color:var(--dim)}
.mem-article-render .codeblock{margin:12px 0;border:1px solid var(--code-line);border-radius:var(--radius-md);overflow:hidden;background:var(--code-bg);color:var(--code-ink)}
.mem-article-render .cbhead{display:flex;align-items:center;gap:6px;padding:5px 8px 5px 12px;border-bottom:1px solid var(--code-line)}
.mem-article-render .cblang{font:var(--text-xs)/1 var(--mono);opacity:.6;margin-right:auto}
.mem-article-render .cbtoggle{display:inline-flex;gap:2px}
.mem-article-render .cbcopy,.mem-article-render .cbview{appearance:none;font:var(--text-xs)/1 var(--mono);color:inherit;opacity:.7;background:transparent;
  border:1px solid var(--code-line);border-radius:var(--radius-sm);padding:4px 9px;cursor:pointer;transition:opacity var(--fast) var(--ease)}
.mem-article-render .cbview{border-color:transparent}
.mem-article-render .cbcopy:hover,.mem-article-render .cbview:hover,.mem-article-render .cbview.active{opacity:1}
.mem-article-render .cbview.active{background:var(--code-line)}
.mem-article-render .codeblock pre{margin:0;padding:12px 14px;overflow-x:auto;font:var(--text-sm)/1.6 var(--mono);background:none;color:inherit}
.mem-article-render .codeblock code{background:none;padding:0;color:inherit;font-size:inherit}
/* A canvas preview renders model-written HTML or SVG, which rarely sets a background: it gets a plain white page in
   both themes, as content rather than chrome. */
.mem-article-render .cbcanvas{background:#fff}
.mem-article-render .cbframe{display:block;width:100%;height:360px;min-height:160px;max-height:70vh;border:0;resize:vertical;background:#fff}
.mem-links{display:flex;flex-direction:column;gap:8px;margin-top:18px;padding-top:14px;border-top:1px solid var(--line)}
.mem-links-row{display:flex;flex-wrap:wrap;gap:6px;align-items:center}
.mem-links-row .lbl{font-size:var(--text-xs);font-weight:600;color:var(--dimmer);margin-right:2px}
button.mem-link-chip{appearance:none;border:0;cursor:pointer;transition:background var(--fast) var(--ease),color var(--fast) var(--ease)}
button.mem-link-chip:hover{background:var(--accent-soft);color:var(--accent)}

/* ── history: the commits that touched the article, and one commit's diff on the code surface ── */
.mem-hist-subject{white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.mem-hist-hash{font-family:var(--mono)}
.mem-hist-ico{display:inline-flex;color:var(--dimmer);flex:0 0 auto}
.mem-diff{margin-top:12px;background:var(--code-bg);color:var(--code-ink);border:1px solid var(--code-line);border-radius:var(--radius-md);
  padding:10px 0;font:var(--text-xs)/1.6 var(--mono);white-space:pre-wrap;word-break:break-word;max-height:420px;overflow-y:auto}
.mem-diff span{display:block;padding:0 14px}
.mem-diff .diffctx{opacity:.7}
.mem-diff .diffhunk{opacity:.55}
.mem-diff .diffadd{background:var(--ok-soft);color:color-mix(in srgb,var(--ok) 62%,var(--code-ink))}
.mem-diff .diffdel{background:var(--bad-soft);color:color-mix(in srgb,var(--bad) 62%,var(--code-ink))}

/* ── the chat sidebar's entry: a quiet row with the article count ── */
#chat-memory-entry{appearance:none;display:flex;align-items:center;gap:10px;width:100%;margin-top:auto;padding:7px 10px;border:0;border-radius:var(--radius-md);
  background:none;color:var(--dim);font:inherit;font-size:var(--text-md);font-weight:550;text-align:left;cursor:pointer;
  transition:background var(--fast) var(--ease),color var(--fast) var(--ease)}
#chat-memory-entry:hover,#chat-memory-entry[aria-expanded="true"]{background:var(--raised);color:var(--ink)}
#chat-memory-entry .mi{display:inline-flex;justify-content:center;width:16px;flex:0 0 auto;color:var(--accent)}
#chat-memory-entry svg{width:16px;height:16px}
#chat-memory-entry .mt{flex:1 1 auto;min-width:0}
#chat-memory-count{display:inline-flex;align-items:center;height:20px;padding:0 7px;border-radius:999px;background:var(--raised);color:var(--dim);
  font-family:var(--font);font-size:var(--text-xs);font-weight:600;font-variant-numeric:tabular-nums;flex:0 0 auto}
#chat-memory-entry:hover #chat-memory-count,#chat-memory-entry[aria-expanded="true"] #chat-memory-count{background:var(--panel)}

/* ── the provenance chip: a compact row (what memory was read) that opens to the result ── */
.memchip{display:block;width:fit-content;max-width:100%;margin:8px 0;border-radius:999px;background:var(--accent-soft);color:var(--ink);font-size:var(--text-sm)}
.memchip.open{width:auto;border-radius:var(--radius-md)}
.memchip .mchead{appearance:none;display:flex;align-items:center;gap:7px;width:100%;min-width:0;height:28px;padding:0 10px;border:0;border-radius:inherit;
  background:none;color:inherit;font:inherit;text-align:left;cursor:pointer}
.memchip .mcicon{width:14px;height:14px;flex:0 0 auto;color:var(--accent)}
.memchip .mclabel{flex:1 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--dim)}
.memchip .mclabel b{color:var(--ink);font-weight:600}
.memchip .mccaret{width:14px;height:14px;flex:0 0 auto;color:var(--dimmer);transition:transform var(--fast) var(--ease)}
.memchip.open .mccaret{transform:rotate(90deg)}
.memchip .mcbody{display:none;padding:2px 10px 10px}
.memchip.open .mcbody{display:block}
.memchip .mcresult{margin:0 0 8px;max-height:200px;padding:10px 12px;border:1px solid var(--code-line);border-radius:var(--radius-sm);
  background:var(--code-bg);color:var(--code-ink);font:var(--text-xs)/1.6 var(--mono);white-space:pre-wrap;word-break:break-word;overflow-y:auto}
.memchip.fail{background:var(--bad-soft)}
.memchip.fail .mcicon{color:var(--bad)}

/* ── the consent card in the chat's greeting: an offer, never a modal ── */
#chat-consent{display:none;align-items:center;gap:10px 12px;flex-wrap:wrap;max-width:640px;margin:22px auto 0;padding:10px 12px;text-align:left;
  border:1px solid var(--line-strong);border-radius:var(--radius-md);background:var(--surface);color:var(--dim);font-size:var(--text-md);line-height:1.45}
#chat-consent.show{display:flex}
#chat-consent .cc-icon{display:inline-flex;flex:0 0 auto;color:var(--accent)}
#chat-consent .cc-icon svg{width:16px;height:16px}
#chat-consent .cc-text{flex:1 1 260px;min-width:0}
#chat-consent .cc-text b{color:var(--ink);font-weight:600}
#chat-consent .cc-actions{display:flex;gap:6px;flex:0 0 auto;margin-left:auto}

@media (prefers-reduced-motion:reduce){
  #mem-overlay.open,#mem-panel{animation:none}
  .mem-art,.mem-hist-entry,#chat-memory-entry,.memchip .mccaret,button.mem-link-chip,.mem-article-render .cbcopy,.mem-article-render .cbview{transition:none}
}
`;
