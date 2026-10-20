// The panel's own rules, after the kit's base vocabulary in its shadow root. Colours and sizes are the tokens', which cascade in.
export const STYLE = String.raw`
:host{display:block}
.status:empty,.restart:not(.show){display:none}
.status,.restart{margin-bottom:14px}
.restart{flex-direction:column;align-items:stretch;gap:8px}
.restart p{margin:0}
.hub-cmd{display:flex;align-items:center;gap:8px;background:var(--code-bg);color:var(--code-ink);border-radius:var(--radius-sm);padding:7px 10px;overflow-x:auto}
.hub-cmd code{font:var(--text-sm) var(--mono);white-space:nowrap;flex:1 1 auto;background:none;padding:0;color:inherit}
.serving{display:flex;flex-direction:column;gap:6px}
.serving-head{display:flex;align-items:center;gap:10px;flex-wrap:wrap}
.serving-name{font-size:var(--text-lg);font-weight:600;letter-spacing:-.01em;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;min-width:0}
.serving.none .serving-name{font-family:var(--font)}
.serving-meta{color:var(--dim);font-size:var(--text-sm);font-variant-numeric:tabular-nums}
.serving-beside{display:flex;align-items:center;gap:6px;flex-wrap:wrap;color:var(--dim);font-size:var(--text-sm);margin-top:4px}
.hub-fit-dot{margin-top:1px}
.hub-row.is-serving{background:var(--ok-soft)}
.hub-row-name .tag,.ad-row-head .tag{vertical-align:middle;margin-left:6px}
.ad-row.incompatible .list-name,.ad-row.incompatible .list-meta{opacity:.55}
.ad-meta b{color:var(--dim);font-weight:600}
.ad-why{font-size:var(--text-xs);color:var(--dimmer);margin-top:3px}
.search{margin-bottom:10px}
.offline{margin-top:10px}
.list.skeletons .list-row{min-height:54px}
`;
