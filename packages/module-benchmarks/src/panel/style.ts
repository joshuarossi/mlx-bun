// The panel's own rules, after the kit's base vocabulary in its shadow root. Colours, type and motion are the tokens',
// which cascade in from the host page.
export const STYLE = String.raw`
:host{display:block;color:var(--ink);font-family:var(--font);font-size:var(--text-md);line-height:1.45}
.load-notice{margin-bottom:16px}

/* the task list: one check row per task, its reason underneath when it cannot run as asked */
.tasks{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:4px 16px;margin:2px 0 16px}
.task{display:flex;align-items:flex-start;gap:9px;padding:6px 0;cursor:pointer;min-width:0}
.task input{margin-top:3px;flex:0 0 auto}
.task-main{display:flex;flex-direction:column;min-width:0}
.task-name{font-weight:550;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.task .hint{font-size:var(--text-sm);color:var(--dim);line-height:1.4}
.task.unavailable{cursor:default}
.task.unavailable .task-name{color:var(--dim)}
.task.unavailable .hint{color:var(--warn)}
.tasks.loading .skeleton{width:70%;margin:6px 0}

.run-field{margin-bottom:0}
.run-field .row{flex-wrap:nowrap}
.run-field .input{flex:1 1 auto;width:auto;min-width:0}
.job{margin-top:14px}
.job .progress-meta span:first-child{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;min-width:0}
.job .progress-meta span:last-child{flex:0 0 auto}
.evaluate .card-note{margin-top:12px}
.card .notice{margin-top:12px}

.table-card{padding:12px 6px 4px}
.table td{vertical-align:middle;white-space:nowrap}
.table td.name{font-weight:550}

.compare-row{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr) auto;gap:10px;align-items:end}
.compare-row .field{margin:0}
.compare-result{margin-top:14px;display:flex;flex-direction:column;gap:12px}
.compare-result .notice{margin-top:0}
.compare-result .table-wrap{margin:0 -12px}
.compare-result .log{max-height:360px}
@media (max-width:760px){
  .compare-row{grid-template-columns:minmax(0,1fr)}
  .run-field .row{flex-wrap:wrap}
  .run-field .btn{flex:1 1 100%}
}
`;
