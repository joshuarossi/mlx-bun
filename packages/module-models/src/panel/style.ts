// The panel's styles, inside its shadow root. Colors come from the host page's design tokens, which cascade in.
export const STYLE = `
:host{display:block;color:var(--ink,CanvasText);font:14px/1.45 system-ui,sans-serif}
section{margin:0 0 22px}
h3{margin:0 0 9px;font-size:10.5px;font-weight:600;letter-spacing:.1em;text-transform:uppercase;color:var(--dimmer,GrayText)}
.note{font-size:11.5px;color:var(--dim,GrayText);line-height:1.5;margin:0 0 12px}
.status{min-height:1.4em;font-size:12.5px;margin:0 0 12px;color:var(--dim,GrayText)}
.status.ok{color:var(--green,#16a34a)} .status.err{color:var(--red,#dc2626)}
input[type=search]{width:100%;box-sizing:border-box;background:var(--card,transparent);border:1px solid var(--hairline,#8885);border-radius:10px;
  color:var(--ink,CanvasText);font-size:12.5px;padding:9px 12px;outline:none;margin-bottom:10px}
input[type=search]:focus{border-color:rgba(10,132,255,.5)}
.hub-empty{color:var(--dim,GrayText);font-size:12.5px;padding:10px 4px;line-height:1.5}
.hub-row,.ad-row{display:flex;align-items:flex-start;gap:10px;padding:10px 11px;border-radius:12px;border:1px solid var(--hairline-soft,#8883);margin-bottom:8px}
.hub-row.serving{border-color:rgba(48,209,88,.35);background:rgba(48,209,88,.06)}
.hub-fit-dot{width:9px;height:9px;border-radius:50%;flex:0 0 auto;margin-top:5px}
.hub-fit-dot.green{background:var(--green,#16a34a);box-shadow:0 0 7px var(--green,#16a34a)}
.hub-fit-dot.yellow{background:var(--yellow,#ca8a04);box-shadow:0 0 7px var(--yellow,#ca8a04)}
.hub-fit-dot.red{background:var(--red,#dc2626)}
.hub-row-main,.ad-row-main{flex:1 1 auto;min-width:0}
.hub-row-name,.ad-row-id{font-size:13px;font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.hub-row-meta{font-size:11px;color:var(--dimmer,GrayText);margin-top:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.hub-serving-tag{font:10px var(--mono,monospace);color:var(--green,#16a34a);letter-spacing:.03em;margin-top:2px}
.hub-row-actions{flex:0 0 auto;display:flex;align-items:center;gap:6px}
button{appearance:none;cursor:pointer;background:var(--card,transparent);border:1px solid var(--hairline,#8885);color:var(--dim,GrayText);border-radius:8px;
  padding:5px 11px;font:inherit;font-size:11.5px;font-weight:600;white-space:nowrap}
button:hover:not(:disabled){color:var(--ink,CanvasText);border-color:rgba(10,132,255,.5);background:rgba(10,132,255,.08)}
button:disabled{opacity:.5;cursor:default}
.hub-dl-tag{font:11px var(--mono,monospace);color:var(--blue,#2563eb);white-space:nowrap}
.hub-dl-tag.done{color:var(--green,#16a34a)} .hub-dl-tag.error{color:var(--red,#dc2626)}
.restart{display:none;margin-bottom:16px;padding:12px 14px;border-radius:12px;background:rgba(10,132,255,.08);border:1px solid rgba(10,132,255,.3)}
.restart.show{display:block}
.restart p{font-size:12px;line-height:1.5;margin:0 0 8px}
.hub-cmd{display:flex;align-items:center;gap:8px;background:var(--code-bg-soft,#8881);border-radius:8px;padding:7px 10px;overflow-x:auto}
.hub-cmd code{font:12px var(--mono,monospace);white-space:nowrap;flex:1 1 auto}
.ad-badge{font:10.5px var(--mono,monospace);padding:2px 8px;border-radius:999px;border:1px solid rgba(48,209,88,.4);color:var(--green,#16a34a);margin-left:6px}
.ad-row.incompatible{opacity:.55}
.ad-meta{font-size:11.5px;color:var(--dimmer,GrayText);margin-top:4px}
.ad-meta b{color:var(--dim,GrayText);font-weight:600}
.ad-why{font-size:11px;color:var(--dimmer,GrayText);margin-top:4px;font-style:italic}
.offline{font-size:11.5px;color:var(--dim,GrayText);line-height:1.5;padding-top:14px;border-top:1px solid var(--hairline-soft,#8883)}
code{font-family:var(--mono,monospace)}
`;
