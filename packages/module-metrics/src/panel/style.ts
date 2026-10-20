// The panel's own rules, after the kit's base vocabulary in its shadow root. Colours, type and motion are the tokens',
// which cascade in from the host page.
export const STYLE = String.raw`
:host{display:block;color:var(--ink);font-family:var(--font);font-size:var(--text-md);line-height:1.45}
.stream-notice{margin-bottom:16px}
.stream-notice:empty{display:none}
.stat.card{padding:14px 16px;min-width:0}
.stat b small{margin-left:0}
.stat.loading b{display:block;width:62%}
.stat.loading span{display:block;width:44%;margin-top:6px}
.waiting{margin-top:10px}

/* the throughput sparkline: a 2px accent line over a faint wash, the latest sample marked */
.spark-card{margin-top:12px}
.spark-card .card-head{flex-wrap:wrap}
.spark{position:relative;height:72px}
.spark svg{display:block;width:100%;height:100%;overflow:visible}
.spark .line{fill:none;stroke:var(--accent);stroke-width:2;stroke-linejoin:round;stroke-linecap:round;vector-effect:non-scaling-stroke}
.spark .area{fill:var(--accent);fill-opacity:.1;stroke:none}
.spark .base{stroke:var(--line);stroke-width:1;vector-effect:non-scaling-stroke}
.spark-dot{position:absolute;width:9px;height:9px;margin:-4.5px 0 0 -4.5px;border-radius:50%;background:var(--accent);box-shadow:0 0 0 2px var(--panel)}

/* tables sit in cards; the model column keeps its name on one line and the row scrolls on a narrow screen */
.table-card{padding:12px 6px 4px}
.table td{vertical-align:middle;white-space:nowrap}
.table td.name{font-weight:550}

/* caches: one card per model, a meter per cache */
.cache .card-title{font-size:var(--text-md);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.usage{margin-top:12px}
.usage:first-of-type{margin-top:4px}
.usage-head{display:flex;justify-content:space-between;gap:12px;font-size:var(--text-sm)}
.usage-head b{font-weight:550;color:var(--dim)}
.usage-head span{font-variant-numeric:tabular-nums}
.usage .meter{margin-top:7px}
.hit{margin-top:8px;font-size:var(--text-sm);color:var(--dim);font-variant-numeric:tabular-nums}
.section-note{margin-top:10px}

/* the benchmark card */
.bench-controls .select{width:auto;flex:0 1 340px;min-width:0}
.bench-job{max-width:100%}
.bench-job .text{overflow:hidden;text-overflow:ellipsis}
.bench .card-note{margin-top:10px}
.bench>.card-note:first-child{margin-top:0}
.bench .notice{margin-top:12px}
.bench-history{margin-top:16px;padding-top:14px;border-top:1px solid var(--line)}
.bench-history .table-wrap{margin:0 -12px}
.subhead{font-size:var(--text-sm);font-weight:600;color:var(--dim);margin-bottom:8px}
@media (max-width:760px){
  .bench-controls .select{flex:1 1 100%}
}
`;
