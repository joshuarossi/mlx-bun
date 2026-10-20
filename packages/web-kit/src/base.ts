// The component vocabulary every panel and the host page share, written against the tokens: controls, fields,
// cards, tables, notices, progress, the step rail and the empty state. A panel puts it in its shadow root's
// `<style>` before its own rules (`BASE_CSS + ownCss`); the host page links the same text once for light-DOM
// panels and its own chrome. Nothing here selects `:root` or `body`, so it applies the same inside a shadow root.
export const BASE_CSS = String.raw`
*,*::before,*::after{box-sizing:border-box}
h1,h2,h3,h4,p,ul,ol,pre,figure{margin:0}
button,input,select,textarea{font:inherit;color:inherit}
a{color:var(--accent);text-decoration:none}
a:hover{text-decoration:underline}
code,kbd,.mono{font-family:var(--mono)}
code{font-size:.92em;background:var(--raised);padding:1px 6px;border-radius:var(--radius-sm)}
.num{font-variant-numeric:tabular-nums}
.muted{color:var(--dim)}
.faint{color:var(--dimmer)}
.sr-only{position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0}
:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
::-webkit-scrollbar{width:10px;height:10px}
::-webkit-scrollbar-thumb{background:var(--scrollbar);border-radius:6px;border:2px solid transparent;background-clip:content-box}
::-webkit-scrollbar-track{background:transparent}

/* page structure inside a panel or a host page */
.page{max-width:var(--content-w);margin:0 auto;padding:28px 32px 96px}
.page-head{display:flex;align-items:flex-end;justify-content:space-between;gap:16px;flex-wrap:wrap;margin-bottom:22px}
.page-title{font-size:var(--text-2xl);font-weight:650;letter-spacing:-.015em;line-height:1.2}
.page-lead{color:var(--dim);font-size:var(--text-md);line-height:1.5;margin-top:4px;max-width:70ch}
.section{margin:0 0 28px}
.section-title{font-size:var(--text-sm);font-weight:600;letter-spacing:.02em;color:var(--dim);margin:0 0 10px;display:flex;align-items:center;gap:10px}
.section-title .count{font-weight:500;color:var(--dimmer)}
.stack{display:flex;flex-direction:column;gap:10px}
.row{display:flex;align-items:center;gap:10px;flex-wrap:wrap}
.row.between{justify-content:space-between}
.grid{display:grid;gap:12px}
.grid.cols-2{grid-template-columns:repeat(auto-fit,minmax(260px,1fr))}
.grid.cols-3{grid-template-columns:repeat(auto-fit,minmax(200px,1fr))}
.grid.cols-4{grid-template-columns:repeat(auto-fit,minmax(160px,1fr))}
.toolbar{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.spacer{flex:1 1 auto}

/* cards and lists */
.card{background:var(--panel);border:1px solid var(--line);border-radius:var(--radius-lg);padding:16px 18px}
.card.quiet{background:var(--surface)}
.card-head{display:flex;align-items:baseline;justify-content:space-between;gap:12px;margin-bottom:10px}
.card-title{font-size:var(--text-lg);font-weight:600;letter-spacing:-.01em}
.card-note{color:var(--dim);font-size:var(--text-sm);line-height:1.5}
.list{display:flex;flex-direction:column;border:1px solid var(--line);border-radius:var(--radius-lg);background:var(--panel);overflow:hidden}
.list-row{display:flex;align-items:center;gap:12px;padding:11px 14px;border-top:1px solid var(--line);min-width:0}
.list-row:first-child{border-top:0}
.list-row.selected{background:var(--accent-soft)}
.list-main{flex:1 1 auto;min-width:0}
.list-name{font-size:var(--text-md);font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.list-meta{color:var(--dim);font-size:var(--text-sm);margin-top:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.list-actions{display:flex;align-items:center;gap:6px;flex:0 0 auto}
.kv{display:flex;justify-content:space-between;gap:12px;padding:6px 0;font-size:var(--text-md);border-top:1px solid var(--line)}
.kv:first-child{border-top:0}
.kv b{font-weight:500;color:var(--dim)}
.kv span{font-variant-numeric:tabular-nums}
.stat{display:flex;flex-direction:column;gap:2px}
.stat b{font-size:var(--text-2xl);font-weight:650;letter-spacing:-.02em;font-variant-numeric:tabular-nums;line-height:1.15}
.stat b small{font-size:var(--text-sm);font-weight:500;color:var(--dim);margin-left:5px;letter-spacing:0}
.stat span{color:var(--dim);font-size:var(--text-sm)}

/* tables */
.table{width:100%;border-collapse:collapse;font-size:var(--text-md);font-variant-numeric:tabular-nums}
.table th,.table td{text-align:left;padding:9px 12px;border-top:1px solid var(--line);vertical-align:top}
.table thead th{border-top:0;font-size:var(--text-xs);font-weight:600;letter-spacing:.03em;color:var(--dim);padding-top:0}
.table td.num,.table th.num{text-align:right;white-space:nowrap}
.table tr.selected td{background:var(--accent-soft)}
.table-wrap{overflow-x:auto}

/* controls */
.btn{appearance:none;display:inline-flex;align-items:center;justify-content:center;gap:7px;cursor:pointer;
  height:34px;padding:0 14px;border-radius:var(--radius-md);border:1px solid var(--line-strong);background:var(--raised);
  color:var(--ink);font-size:var(--text-md);font-weight:550;white-space:nowrap;transition:background var(--fast) var(--ease),border-color var(--fast) var(--ease),color var(--fast) var(--ease)}
.btn:hover{border-color:var(--dimmer)}
.btn.primary{background:var(--accent);border-color:var(--accent);color:var(--accent-ink)}
.btn.primary:hover{filter:brightness(1.08)}
.btn.quiet{background:transparent;border-color:transparent;color:var(--dim)}
.btn.quiet:hover{background:var(--raised);color:var(--ink)}
.btn.danger{color:var(--bad)}
.btn.danger:hover{background:var(--bad-soft);border-color:var(--bad)}
.btn.sm{height:28px;padding:0 10px;font-size:var(--text-sm);border-radius:var(--radius-sm)}
.btn.icon{width:34px;padding:0}
.btn.icon.sm{width:28px}
.btn:disabled{opacity:.5;cursor:default;filter:none}
.btn svg{width:16px;height:16px;flex:0 0 auto}
.input,.select,.textarea{width:100%;background:var(--surface);border:1px solid var(--line-strong);border-radius:var(--radius-md);
  color:var(--ink);font-size:var(--text-md);line-height:1.4;padding:8px 11px;outline:none;transition:border-color var(--fast) var(--ease)}
.input::placeholder,.textarea::placeholder{color:var(--dimmer)}
.input:focus,.select:focus,.textarea:focus{border-color:var(--accent);box-shadow:0 0 0 3px var(--accent-soft)}
.input[aria-invalid="true"],.textarea[aria-invalid="true"]{border-color:var(--bad)}
.textarea{min-height:88px;resize:vertical}
.textarea.mono{font-family:var(--mono);font-size:var(--text-sm)}
.select{appearance:none;cursor:pointer;padding-right:30px;
  background-image:url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath fill='none' stroke='%238a929d' stroke-width='1.6' d='M1 1.5l5 5 5-5'/%3E%3C/svg%3E");
  background-repeat:no-repeat;background-position:right 10px center}
.select.sm,.input.sm{padding:4px 8px;font-size:var(--text-sm);border-radius:var(--radius-sm)}
.select.sm{padding-right:26px}
input[type=range]{width:100%;accent-color:var(--accent);cursor:pointer;height:22px;margin:0}
input[type=checkbox],input[type=radio]{accent-color:var(--accent);width:15px;height:15px;margin:0}
.field{display:flex;flex-direction:column;gap:6px;margin-bottom:16px}
.field>label{font-size:var(--text-sm);font-weight:600;color:var(--ink)}
.field .hint{font-size:var(--text-sm);color:var(--dim);line-height:1.45}
.field.inline{flex-direction:row;align-items:center;gap:10px}
.check{display:inline-flex;align-items:center;gap:9px;font-size:var(--text-md);cursor:pointer}
.seg{display:inline-flex;background:var(--surface);border:1px solid var(--line-strong);border-radius:var(--radius-md);padding:2px;gap:2px}
.seg button{appearance:none;background:none;border:0;cursor:pointer;color:var(--dim);font-size:var(--text-sm);font-weight:550;
  padding:6px 12px;border-radius:calc(var(--radius-md) - 3px);transition:background var(--fast) var(--ease),color var(--fast) var(--ease)}
.seg button.on,.seg button[aria-pressed="true"],.seg button[aria-checked="true"]{background:var(--raised);color:var(--ink);box-shadow:0 1px 2px rgba(0,0,0,.2)}
.seg button:hover:not(.on){color:var(--ink)}
.switch{appearance:none;cursor:pointer;width:34px;height:20px;border-radius:999px;background:var(--line-strong);border:0;position:relative;
  transition:background var(--fast) var(--ease);flex:0 0 auto;padding:0}
.switch::after{content:"";position:absolute;top:2px;left:2px;width:16px;height:16px;border-radius:50%;background:#fff;transition:transform var(--fast) var(--ease)}
.switch[aria-checked="true"]{background:var(--accent)}
.switch[aria-checked="true"]::after{transform:translateX(14px)}

/* status and feedback */
.dot{display:inline-block;width:8px;height:8px;border-radius:50%;background:var(--dimmer);flex:0 0 auto}
.dot.ok{background:var(--ok)} .dot.warn{background:var(--warn)} .dot.bad{background:var(--bad)} .dot.accent{background:var(--accent)}
.dot.live{box-shadow:0 0 0 3px var(--ok-soft)}
.tag{display:inline-flex;align-items:center;gap:6px;height:22px;padding:0 8px;border-radius:999px;font-size:var(--text-xs);font-weight:600;
  letter-spacing:.01em;background:var(--raised);color:var(--dim);white-space:nowrap}
.tag.ok{background:var(--ok-soft);color:var(--ok)} .tag.warn{background:var(--warn-soft);color:var(--warn)} .tag.bad{background:var(--bad-soft);color:var(--bad)}
.tag.accent{background:var(--accent-soft);color:var(--accent)}
.notice{display:flex;gap:10px;align-items:flex-start;border:1px solid var(--line-strong);border-radius:var(--radius-md);padding:10px 12px;
  font-size:var(--text-md);line-height:1.45;background:var(--surface)}
.notice.ok{border-color:var(--ok);background:var(--ok-soft)} .notice.warn{border-color:var(--warn);background:var(--warn-soft)} .notice.bad{border-color:var(--bad);background:var(--bad-soft)}
.notice b{font-weight:600}
.notice .actions{margin-left:auto;display:flex;gap:6px;flex:0 0 auto}
.progress{height:6px;border-radius:3px;background:var(--raised);overflow:hidden}
.progress i{display:block;height:100%;width:0;border-radius:3px;background:var(--accent);transition:width var(--base) var(--ease)}
.progress.ok i{background:var(--ok)} .progress.warn i{background:var(--warn)} .progress.bad i{background:var(--bad)}
.progress-meta{display:flex;justify-content:space-between;gap:12px;font-size:var(--text-sm);color:var(--dim);margin-top:6px;font-variant-numeric:tabular-nums}
.meter{height:4px;border-radius:2px;background:var(--raised);overflow:hidden;margin-top:10px}
.meter i{display:block;height:100%;width:0;background:var(--accent);transition:width var(--base) var(--ease)}
.meter.warn i{background:var(--warn)} .meter.ok i{background:var(--ok)} .meter.bad i{background:var(--bad)}
.skeleton{display:inline-block;height:1em;min-width:3em;border-radius:var(--radius-sm);background:linear-gradient(90deg,var(--raised) 25%,var(--line-strong) 50%,var(--raised) 75%);
  background-size:200% 100%;animation:kit-shimmer 1.3s linear infinite;color:transparent}
@keyframes kit-shimmer{from{background-position:200% 0}to{background-position:-200% 0}}
.empty{text-align:center;color:var(--dim);padding:36px 20px;border:1px dashed var(--line-strong);border-radius:var(--radius-lg);font-size:var(--text-md);line-height:1.5}
.empty h3{font-size:var(--text-lg);font-weight:600;color:var(--ink);margin-bottom:6px}
.empty .actions{margin-top:14px;display:flex;justify-content:center;gap:8px}
.log{background:var(--code-bg);color:var(--code-ink);border:1px solid var(--code-line);border-radius:var(--radius-md);padding:12px 14px;
  max-height:320px;overflow-y:auto;font:var(--text-xs)/1.6 var(--mono);white-space:pre-wrap;word-break:break-word}
.log:empty::before{content:"Waiting for output…";color:var(--dimmer)}

/* the step rail of a job wizard: the number only marks a real sequence */
.steps{display:flex;gap:4px;flex-wrap:wrap;margin:0 0 20px}
.step{display:inline-flex;align-items:center;gap:8px;padding:6px 10px 6px 6px;border-radius:999px;font-size:var(--text-sm);font-weight:550;color:var(--dimmer)}
.step .n{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:50%;border:1px solid var(--line-strong);font-size:var(--text-xs);font-variant-numeric:tabular-nums}
.step.current{color:var(--ink);background:var(--raised)}
.step.current .n{background:var(--accent);border-color:var(--accent);color:var(--accent-ink)}
.step.done{color:var(--dim)}
.step.done .n{background:var(--ok-soft);border-color:transparent;color:var(--ok)}

@media (max-width:760px){
  .page{padding:18px 16px 80px}
  .page-title{font-size:var(--text-xl)}
  .list-row{flex-wrap:wrap}
  .list-actions{width:100%;justify-content:flex-end}
}
@media (prefers-reduced-motion:reduce){
  .skeleton{animation:none}
  .btn,.input,.select,.textarea,.progress i,.meter i,.switch,.switch::after,.seg button{transition:none}
}
`;
