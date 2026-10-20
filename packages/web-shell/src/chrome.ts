// The shell's chrome stylesheet: the layout (a navigation rail beside the page on wide screens, a top bar with the
// rail as a sheet below 760px), the tabs, the status strip the host fills, the dialogs, the toasts and the frame
// every module panel sits in. Written against the web kit's tokens; a host serves it after `TOKENS_CSS` and
// `BASE_CSS` (the app builds `/assets/app.css` from the three) or injects it. The panel frame's rules are also
// injected on first mount so a host that links nothing still gets a readable page.
/** The width below which the rail is a sheet: the stylesheet's media query, and the shell's, so they cannot drift. */
export const SHEET_MEDIA = "(max-width:760px)";

export const PANEL_FRAME_CSS = String.raw`
.shell-panel-scroll{height:100%;overflow-y:auto}
.shell-panel{max-width:var(--content-w);margin:0 auto;padding:28px 32px 96px;color:var(--ink)}
.shell-panel-title{font-size:var(--text-2xl);font-weight:650;letter-spacing:-.015em;line-height:1.2;margin:0 0 18px}
.shell-panel-note{color:var(--dim);font-size:var(--text-md)}
@media ${SHEET_MEDIA}{.shell-panel{padding:18px 16px 80px}.shell-panel-title{font-size:var(--text-xl)}}
`;

export const SHELL_CSS = String.raw`
html,body{height:100%}
body{margin:0;background:var(--bg);color:var(--ink);font-family:var(--font);font-size:var(--text-md);line-height:1.45;
  -webkit-font-smoothing:antialiased;overflow:hidden}
::selection{background:var(--accent-soft)}

/* ── layout: rail + page ── */
#shell{display:grid;grid-template-columns:var(--rail-w) minmax(0,1fr);grid-template-rows:100%;height:100%}
#topbar{display:none}
#nav{display:flex;flex-direction:column;gap:4px;min-height:0;padding:14px 10px 12px;background:var(--surface);border-right:1px solid var(--line);overflow-y:auto}
#nav .brand{display:flex;align-items:center;gap:9px;padding:4px 10px 14px;font-size:var(--text-lg);font-weight:650;letter-spacing:-.01em;color:var(--ink);text-decoration:none}
#nav .brand:hover{text-decoration:none}
.brand-mark{width:22px;height:22px;flex:0 0 auto;border-radius:6px;background:var(--accent);color:var(--accent-ink);display:inline-flex;align-items:center;justify-content:center;font:650 11px/1 var(--mono)}
#tabs{display:flex;flex-direction:column;gap:2px}
.tab{display:flex;align-items:center;gap:10px;padding:7px 10px;border-radius:var(--radius-md);color:var(--dim);font-size:var(--text-md);font-weight:550;
  text-decoration:none;white-space:nowrap;transition:background var(--fast) var(--ease),color var(--fast) var(--ease)}
.tab:hover{color:var(--ink);background:var(--raised);text-decoration:none}
.tab.active{color:var(--ink);background:var(--accent-soft)}
.tab:focus-visible{outline-offset:-2px}
.tab svg{width:16px;height:16px;flex:0 0 auto;opacity:.85}
.tab.active svg{opacity:1;color:var(--accent)}
.tabs-group{margin:14px 10px 4px;font-size:var(--text-xs);font-weight:600;letter-spacing:.04em;color:var(--dimmer)}
.nav-foot{margin-top:auto;display:flex;flex-direction:column;gap:2px;padding-top:12px}
.nav-item{appearance:none;display:flex;align-items:center;gap:10px;width:100%;padding:7px 10px;border:0;border-radius:var(--radius-md);background:none;
  color:var(--dim);font-size:var(--text-md);font-weight:550;text-align:left;cursor:pointer;transition:background var(--fast) var(--ease),color var(--fast) var(--ease)}
.nav-item:hover{color:var(--ink);background:var(--raised)}
.nav-item svg{width:16px;height:16px;flex:0 0 auto;opacity:.85}
.nav-item kbd{margin-left:auto;font:500 var(--text-xs) var(--mono);color:var(--dimmer)}
#nav-developer .nd-dot{margin-left:auto;width:30px;height:18px;border-radius:999px;background:var(--line-strong);position:relative;flex:0 0 auto;transition:background var(--fast) var(--ease)}
#nav-developer .nd-dot::after{content:"";position:absolute;top:2px;left:2px;width:14px;height:14px;border-radius:50%;background:#fff;transition:transform var(--fast) var(--ease)}
#nav-developer .nd-dot.on{background:var(--accent)}
#nav-developer .nd-dot.on::after{transform:translateX(12px)}
#nav-developer[aria-checked="true"]{color:var(--ink)}

/* ── the status strip: what is served, whether the server answers, what is downloading ── */
.status-strip{display:flex;flex-direction:column;gap:6px;margin:8px 0 10px;padding:10px 10px 9px;border-radius:var(--radius-md);background:var(--panel);border:1px solid var(--line)}
.status-strip .model{appearance:none;display:block;width:100%;padding:0;border:0;background:none;text-align:left;cursor:pointer;
  font:600 var(--text-sm)/1.35 var(--mono);color:var(--ink);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.status-strip .model:hover{color:var(--accent)}
.status-strip .model.none{color:var(--dim);font-family:var(--font);font-weight:550}
.status-line{display:flex;align-items:center;gap:7px;font-size:var(--text-xs);color:var(--dim);min-width:0}
.status-line .dot{flex:0 0 auto}
.status-line span{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.status-line.bad{color:var(--bad)}
.status-line.warn{color:var(--warn)}
.status-line .meter{flex:1 1 40px;margin:0;height:3px}
#topbar .status-strip{margin:0;padding:0;border:0;background:none;flex-direction:row;align-items:center;gap:8px;min-width:0}
#topbar .status-strip .model{font-size:var(--text-xs);max-width:40vw;text-align:right}
#topbar .status-strip .status-line span:not(.dot){display:none}
#topbar .status-line .meter{display:none}

/* ── the page ── */
#app{position:relative;min-width:0;min-height:0;overflow:hidden;background:var(--bg)}
section[data-route]{display:none;position:absolute;inset:0;min-width:0}
section[data-route].active{display:block;animation:shell-page-in var(--fast) var(--ease)}
@keyframes shell-page-in{from{opacity:0}to{opacity:1}}

/* ── narrow screens: top bar, the rail as a sheet ── */
#nav-backdrop{position:fixed;inset:0;z-index:110;background:var(--overlay);display:none}
#nav-backdrop.open{display:block}
@media ${SHEET_MEDIA}{
  #shell{grid-template-columns:minmax(0,1fr);grid-template-rows:var(--topbar-h) minmax(0,1fr)}
  #topbar{display:flex;align-items:center;gap:8px;padding:0 10px;background:var(--surface);border-bottom:1px solid var(--line);min-width:0}
  #topbar .brand{font-weight:650;color:var(--ink);text-decoration:none;font-size:var(--text-lg);letter-spacing:-.01em;margin-right:auto}
  /* Closed, the rail is off-screen and hidden, so its links leave the tab order; visibility flips after the slide. */
  #nav{position:fixed;top:0;bottom:0;left:0;width:min(300px,86vw);z-index:120;transform:translateX(-100%);visibility:hidden;
    transition:transform var(--base) var(--ease),visibility 0s var(--base);border-right:1px solid var(--line-strong)}
  #nav.open{transform:none;visibility:visible;transition:transform var(--base) var(--ease),visibility 0s;box-shadow:var(--shadow-lg)}
}
@media (min-width:761px){#nav-menu,#nav-backdrop,#chat-hamburger{display:none!important}}

/* ── dialogs: settings, the shortcut sheet ── */
.dialog-backdrop{position:fixed;inset:0;z-index:200;display:none;align-items:flex-start;justify-content:center;padding:8vh 16px 16px;background:var(--overlay)}
.dialog-backdrop.open{display:flex;animation:shell-page-in var(--fast) var(--ease)}
.dialog{width:min(540px,100%);max-height:84vh;overflow-y:auto;background:var(--panel);border:1px solid var(--line-strong);border-radius:var(--radius-lg);
  box-shadow:var(--shadow-lg);padding:20px 22px 22px}
.dialog-head{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:16px}
.dialog-title{font-size:var(--text-xl);font-weight:650;letter-spacing:-.01em}
.dialog-section{padding:16px 0;border-top:1px solid var(--line)}
.dialog-section:first-of-type{border-top:0;padding-top:0}
.dialog-section h3{font-size:var(--text-sm);font-weight:600;color:var(--dim);margin:0 0 10px}
.dialog-section .hint{color:var(--dim);font-size:var(--text-sm);line-height:1.5}
.dialog-note{font-size:var(--text-sm);color:var(--warn);margin-top:8px;line-height:1.5}
.sk-row{display:flex;align-items:center;justify-content:space-between;gap:14px;padding:8px 0;border-top:1px solid var(--line)}
.sk-row:first-of-type{border-top:0}
.sk-desc{font-size:var(--text-md)}
.sk-keys{display:flex;gap:4px;flex:0 0 auto}
.sk-key{font:600 var(--text-xs)/1 var(--mono);color:var(--ink);background:var(--raised);border:1px solid var(--line-strong);border-radius:5px;padding:4px 7px;min-width:22px;text-align:center}

/* ── toasts ── */
#toasts{position:fixed;bottom:20px;left:50%;transform:translateX(-50%);z-index:300;display:flex;flex-direction:column;gap:8px;align-items:center;pointer-events:none;max-width:min(560px,92vw)}
.toast{background:var(--panel);color:var(--ink);border:1px solid var(--line-strong);border-radius:var(--radius-md);padding:10px 14px;font-size:var(--text-md);
  box-shadow:var(--shadow);animation:toast-in var(--base) var(--ease);transition:opacity var(--base) var(--ease),transform var(--base) var(--ease)}
.toast.err{border-color:var(--bad)} .toast.ok{border-color:var(--ok)}
.toast.leaving{opacity:0;transform:translateY(8px)}
@keyframes toast-in{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:none}}

@media (prefers-reduced-motion:reduce){
  #nav,.tab,.nav-item,.toast,section[data-route].active,.dialog-backdrop.open{transition:none;animation:none}
}
` + PANEL_FRAME_CSS;
