// The panel's own rules, injected once into the page's head after the kit's base vocabulary, which the host page links
// (`.btn`, `.input`, `.select`, `.textarea`, `.tag`, `.dot`, `.notice`, `.empty`, `.skeleton`). Written against the
// kit's tokens only, so the panel follows the theme. The memory module styles what it draws into the panel (the
// sidebar entry, the consent card, the provenance chips); these rules only place them.
export const STYLE = String.raw`
/* ── the panel is the page: the recent chats beside the conversation ── */
mlx-chat-panel{display:flex;height:100%;min-width:0;background:var(--bg);color:var(--ink)}
@keyframes fade{from{opacity:0}to{opacity:1}}
@keyframes chat-pop-in{from{opacity:0;transform:translateY(4px)}to{opacity:1;transform:none}}
@keyframes chat-blink{50%{opacity:0}}
@keyframes chat-shimmer{from{background-position:200% 0}to{background-position:-200% 0}}
@keyframes chat-pulse{0%,100%{opacity:1}50%{opacity:.35}}

/* ── sidebar ── */
#chat-sidebar{flex:0 0 260px;display:flex;flex-direction:column;gap:10px;min-width:0;min-height:0;padding:14px 10px 10px;
  background:var(--bg);border-right:1px solid var(--line)}
#chat-new{justify-content:flex-start;width:100%}
.cs-search{position:relative}
.cs-search svg{position:absolute;left:9px;top:50%;width:14px;height:14px;transform:translateY(-50%);color:var(--dimmer);pointer-events:none}
#chat-sess-search{padding-left:29px}
#chat-sessions{flex:1 1 auto;min-height:0;overflow-y:auto;display:flex;flex-direction:column;gap:1px;margin:0 -4px;padding:0 4px}
.sess{position:relative;display:flex;align-items:center;gap:2px;min-width:0;border-radius:var(--radius-md);cursor:pointer;
  transition:background var(--fast) var(--ease)}
.sess:hover,.sess:focus-within{background:var(--raised)}
.sess.active{background:var(--raised);box-shadow:inset 2px 0 0 var(--accent)}
.sess.active .stitle{font-weight:600}
.sess.sess-hidden{display:none}
.sess .sopen{appearance:none;flex:1 1 auto;min-width:0;display:flex;flex-direction:column;gap:1px;padding:7px 10px;border:0;
  border-radius:var(--radius-md);background:none;color:inherit;font:inherit;text-align:left;cursor:pointer}
.sess .sopen:focus-visible{outline-offset:-2px}
.sess .stitle{display:block;font-size:var(--text-md);font-weight:550;color:var(--ink);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.sess .smeta{display:flex;gap:6px;font-size:var(--text-xs);color:var(--dim);font-variant-numeric:tabular-nums;white-space:nowrap;overflow:hidden}
.sess .smeta span+span::before{content:"·";margin-right:6px;color:var(--dimmer)}
.sess .sacts{position:absolute;top:50%;right:4px;display:flex;gap:0;padding-left:12px;transform:translateY(-50%);opacity:0;pointer-events:none;
  background:linear-gradient(to right,transparent,var(--raised) 12px);border-radius:var(--radius-sm);transition:opacity var(--fast) var(--ease)}
.sess:hover .sacts,.sess:focus-within .sacts{opacity:1;pointer-events:auto}
.sess .sbtn{width:26px;height:26px;color:var(--dim)}
.sess .sbtn svg{width:14px;height:14px}
.sess .sbtn:hover{background:var(--line-strong);color:var(--ink)}
.sess .sdel:hover{color:var(--bad);background:var(--bad-soft)}
.sessempty{color:var(--dim);font-size:var(--text-sm);line-height:1.5;padding:8px 10px}
.sess-msg-search{margin-top:6px;padding-top:6px;border-top:1px solid var(--line)}
.sess-msg-search-hdr{font-size:var(--text-xs);font-weight:600;color:var(--dimmer);padding:4px 10px}
.sess-msg-search-loading{padding:6px 10px;font-size:var(--text-sm)}
.sess-msg-hit{appearance:none;display:block;width:100%;padding:7px 10px;border:0;border-radius:var(--radius-md);background:none;color:inherit;
  font:inherit;text-align:left;cursor:pointer}
.sess-msg-hit:hover{background:var(--raised)}
.sess-msg-hit .stitle{display:block;font-size:var(--text-sm);font-weight:550;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.sess-msg-snippet{display:block;color:var(--dim);font-size:var(--text-xs);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;margin-top:2px}
.sess-msg-snippet mark{background:var(--warn-soft);color:inherit;border-radius:2px}
.sess-export-menu{position:fixed;z-index:950;min-width:180px;padding:4px;background:var(--panel);border:1px solid var(--line-strong);
  border-radius:var(--radius-md);box-shadow:var(--shadow-lg);animation:chat-pop-in var(--fast) var(--ease)}
.sess-export-item{appearance:none;display:block;width:100%;padding:7px 10px;border:0;border-radius:var(--radius-sm);background:none;color:var(--ink);
  font:inherit;font-size:var(--text-md);text-align:left;cursor:pointer}
.sess-export-item:hover,.sess-export-item:focus-visible{background:var(--raised)}
#chat-drawer-backdrop{display:none}

/* ── the conversation ── */
#chat-main{flex:1 1 auto;min-width:0;min-height:0;display:flex;flex-direction:column}
#chat-scroll{flex:1 1 auto;min-height:0;overflow-y:auto;overflow-x:hidden}
#chat-thread{max-width:780px;margin:0 auto;padding:28px 24px 12px;display:flex;flex-direction:column;gap:22px}
#chat-thread:empty{padding:0}

/* empty state: what answers, what to ask, and memory's offer */
#chat-hello{max-width:780px;margin:0 auto;padding:13vh 24px 24px}
.hello-title{font-size:var(--text-2xl);font-weight:650;letter-spacing:-.015em;line-height:1.2}
.hello-sub{margin-top:8px;color:var(--dim);font-size:var(--text-md);line-height:1.5}
.hello-sub b{color:var(--ink);font-weight:600;font-size:.95em}
.hello-note{margin-top:4px;color:var(--dimmer);font-size:var(--text-sm);font-variant-numeric:tabular-nums}
#chat-hello-chips{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;margin-top:22px}
#chat-hello-chips .chip{appearance:none;display:block;min-width:0;padding:10px 12px;border:1px solid var(--line);border-radius:var(--radius-md);
  background:var(--surface);color:var(--ink);font:inherit;font-size:var(--text-md);text-align:left;cursor:pointer;
  transition:border-color var(--fast) var(--ease),background var(--fast) var(--ease)}
#chat-hello-chips .chip:hover{border-color:var(--line-strong);background:var(--raised)}
#chat-consent:not(.show){display:none}
#chat-hello #chat-consent{max-width:none;margin:16px 0 0}

/* messages: the user's on a raised surface at the right, the assistant's on the page */
.msg{display:flex;flex-direction:column;gap:6px;min-width:0}
.msg .bubble{min-width:0;max-width:100%;font-size:var(--text-lg);line-height:1.6;overflow-wrap:anywhere}
.msg.user{align-self:flex-end;align-items:flex-end;max-width:min(82%,620px)}
.msg.user .bubble{padding:9px 14px;border-radius:var(--radius-lg);background:var(--raised)}
.msg.user .msg-text{white-space:pre-wrap}
.msg.assistant{align-self:stretch}
.msg .meta{font-size:var(--text-xs);color:var(--dimmer);font-variant-numeric:tabular-nums}
.msg .meta:empty{display:none}
.msg .meta-note{color:var(--warn)}
.msg-atts{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:8px}
.msg-att-img{display:block;max-width:220px;max-height:220px;border-radius:var(--radius-md)}
.msg-att-file{display:inline-flex;align-items:center;gap:6px;padding:4px 9px;border-radius:var(--radius-sm);background:var(--panel);font-size:var(--text-sm)}
.msg-att-file svg{width:14px;height:14px;color:var(--dim)}
.agent-error .notice{align-items:flex-start;font-size:var(--text-md)}
.agent-error .ai{display:inline-flex;color:var(--bad);margin-top:2px}
.agent-error .err-hint{color:var(--dim);font-size:var(--text-sm);margin-top:4px}

/* message actions: quiet until the message is hovered or focused (always shown without hover) */
.msg-actions{display:flex;gap:2px;margin-left:-6px;opacity:0;transition:opacity var(--fast) var(--ease)}
.msg.user .msg-actions{margin:0 -6px 0 0}
.msg:hover .msg-actions,.msg:focus-within .msg-actions,.msg.assistant:last-child .msg-actions{opacity:1}
@media (hover:none){.msg-actions{opacity:1}}
.maction{appearance:none;display:inline-flex;align-items:center;gap:5px;height:26px;padding:0 7px;border:0;border-radius:var(--radius-sm);
  background:none;color:var(--dim);font:inherit;font-size:var(--text-xs);font-weight:550;cursor:pointer;
  transition:background var(--fast) var(--ease),color var(--fast) var(--ease)}
.maction:hover{background:var(--raised);color:var(--ink)}
.maction svg{width:13px;height:13px}
.sib-toggle{display:flex;align-items:center;gap:2px;font-size:var(--text-xs);color:var(--dim)}
.sib-toggle .sib-prev svg{transform:rotate(180deg)}
.sib-toggle .btn{width:24px;height:24px}
.msg-edit-box{width:min(620px,78vw);min-height:64px;font-size:var(--text-lg)}
.msg-edit-actions{display:flex;justify-content:flex-end;gap:6px;margin-top:6px}

/* thinking: a quiet disclosure; its label shimmers while the reply streams */
.thinkbox{margin:0 0 10px}
.thinkbox summary{display:inline-flex;align-items:center;gap:5px;padding:2px 4px 2px 0;border-radius:var(--radius-sm);list-style:none;cursor:pointer;
  color:var(--dim);font-size:var(--text-sm);font-weight:550;user-select:none;-webkit-user-select:none}
.thinkbox summary::-webkit-details-marker{display:none}
.thinkbox summary:hover{color:var(--ink)}
.thinkbox summary svg{width:14px;height:14px;transition:transform var(--fast) var(--ease)}
.thinkbox[open] summary svg{transform:rotate(90deg)}
.thinkbox.live summary span{background:linear-gradient(90deg,var(--dim) 30%,var(--ink) 50%,var(--dim) 70%) 0 0/200% 100%;
  -webkit-background-clip:text;background-clip:text;color:transparent;animation:chat-shimmer 1.6s linear infinite}
.thinkbody{margin-top:6px;padding:2px 0 2px 12px;border-left:2px solid var(--line-strong);color:var(--dim);font-size:var(--text-md);
  line-height:1.55;white-space:pre-wrap;max-height:360px;overflow-y:auto}
.cursor{display:inline-block;width:7px;height:1.05em;margin-top:2px;vertical-align:-2px;border-radius:2px;background:var(--accent);
  animation:chat-blink 1s steps(2) infinite}

/* tool calls: one compact row each, expanding to arguments and result */
.tool{margin:8px 0;border:1px solid var(--line);border-radius:var(--radius-md);background:var(--surface);overflow:hidden;font-size:var(--text-sm)}
.tool .thead{appearance:none;display:flex;align-items:center;gap:8px;width:100%;min-width:0;padding:6px 8px 6px 10px;border:0;background:none;
  color:inherit;font:inherit;text-align:left;cursor:pointer}
.tool .thead:hover{background:var(--raised)}
.tool .thead:focus-visible{outline-offset:-2px}
.tool .ticon{display:inline-flex;flex:0 0 auto;color:var(--dimmer)}
.tool .ticon svg{width:14px;height:14px}
.tool .tname{flex:0 0 auto;max-width:45%;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font:600 var(--text-sm) var(--mono);color:var(--ink)}
.tool .targs{flex:1 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font:var(--text-sm) var(--mono);color:var(--dim)}
.tool .tstat{flex:0 0 auto}
.tool.running .tstat{background:var(--accent-soft);color:var(--accent)}
.tool.ok .tstat{background:var(--ok-soft);color:var(--ok)}
.tool.fail{border-color:var(--bad)}
.tool.fail .tstat{background:var(--bad-soft);color:var(--bad)}
.tool .caret{display:inline-flex;flex:0 0 auto;color:var(--dimmer);transition:transform var(--fast) var(--ease)}
.tool .caret svg{width:14px;height:14px}
.tool.open .caret{transform:rotate(90deg)}
.tool .tbody{display:none;padding:10px;border-top:1px solid var(--line)}
.tool.open .tbody{display:block}
.tool .blk+.blk{margin-top:10px}
.blbl{display:block;margin-bottom:5px;font-size:var(--text-xs);font-weight:600;color:var(--dim)}
.tool pre{max-height:260px;overflow:auto;padding:9px 11px;border-radius:var(--radius-sm);background:var(--code-bg);color:var(--code-ink);
  font:var(--text-xs)/1.55 var(--mono);white-space:pre-wrap;word-break:break-word}

/* approval: a warning notice with the arguments to edit before allowing */
.approval.notice{flex-direction:column;align-items:stretch;gap:10px;margin:10px 0;font-size:var(--text-md)}
.approval .ahead{display:flex;align-items:center;gap:8px;min-width:0}
.approval .ai{display:inline-flex;color:var(--warn)}
.approval .as{margin-left:auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.approval pre{max-height:280px;overflow:auto;margin:0 0 10px;padding:10px 12px;border-radius:var(--radius-sm);background:var(--code-bg);color:var(--code-ink);
  font:var(--text-sm)/1.6 var(--mono);white-space:pre-wrap;word-break:break-word}
.approval .diffadd{color:color-mix(in srgb,var(--ok) 55%,var(--code-ink))}
.approval .diffdel{color:color-mix(in srgb,var(--bad) 55%,var(--code-ink))}
.approval .a-args{min-height:64px;max-height:280px;background:var(--code-bg);color:var(--code-ink);border-color:var(--code-line)}
.approval .a-argerr{margin-top:6px;font-size:var(--text-sm);color:var(--bad)}
.approval .a-always{font-size:var(--text-sm);color:var(--dim)}
.approval .actions{display:flex;justify-content:flex-end;gap:6px;margin:0}
.approval .resolved{display:flex;align-items:center;gap:6px;font-size:var(--text-sm);font-weight:600}
.approval .resolved svg{width:15px;height:15px}
.approval .resolved.allow{color:var(--ok)}
.approval .resolved.deny{color:var(--bad)}

/* rendered markdown */
.bubble .atext>:first-child,.bubble .md-block:first-child>:first-child{margin-top:0}
.bubble p{margin:0 0 10px}
.bubble p:last-child{margin-bottom:0}
.bubble ul,.bubble ol{margin:0 0 10px;padding-left:22px}
.bubble li{margin:3px 0}
.bubble strong{font-weight:650}
.bubble h1,.bubble h2,.bubble h3,.bubble h4,.bubble h5,.bubble h6{margin:18px 0 8px;font-weight:650;letter-spacing:-.01em;line-height:1.3}
.bubble h1{font-size:1.3em}
.bubble h2{font-size:1.18em}
.bubble h3{font-size:1.06em}
.bubble h4,.bubble h5,.bubble h6{font-size:1em;color:var(--dim)}
.bubble a{color:var(--accent);text-decoration:underline;text-decoration-color:var(--accent-soft);text-underline-offset:2px}
.bubble a:hover{text-decoration-color:var(--accent)}
.bubble del{opacity:.6}
.bubble blockquote{margin:10px 0;padding:2px 14px;border-left:3px solid var(--line-strong);color:var(--dim)}
.bubble hr{margin:16px 0;border:0;border-top:1px solid var(--line)}
.bubble li.task{list-style:none;margin-left:-20px}
.bubble li.task input{margin-right:7px;vertical-align:-2px}
.bubble code{font-size:.86em}
.bubble pre{margin:10px 0;padding:12px 14px;overflow-x:auto;border-radius:var(--radius-md);background:var(--code-bg);color:var(--code-ink);font:var(--text-sm)/1.6 var(--mono)}
.bubble pre code{padding:0;background:none;font-size:inherit;color:inherit}
.bubble .md-tablewrap{margin:12px 0;overflow-x:auto}
.bubble table.md-table{width:100%;border-collapse:collapse;font-size:var(--text-md);font-variant-numeric:tabular-nums}
.bubble table.md-table th,.bubble table.md-table td{padding:7px 11px;border:1px solid var(--line);text-align:left}
.bubble table.md-table th{background:var(--panel);font-weight:600}
.bubble .codeblock{margin:12px 0;overflow:hidden;border:1px solid var(--code-line);border-radius:var(--radius-md);background:var(--code-bg);color:var(--code-ink)}
.bubble .cbhead{display:flex;align-items:center;gap:6px;min-height:34px;padding:4px 6px 4px 12px;border-bottom:1px solid var(--code-line)}
.bubble .cblang{margin-right:auto;font:var(--text-xs)/1 var(--mono);color:color-mix(in srgb,var(--code-ink) 60%,transparent)}
.bubble .cbtoggle{display:inline-flex;gap:2px;padding:2px;border-radius:var(--radius-sm);background:var(--code-line)}
.bubble .cbview,.bubble .cbcopy{appearance:none;height:24px;padding:0 9px;border:0;border-radius:5px;background:none;color:color-mix(in srgb,var(--code-ink) 60%,transparent);
  font:550 var(--text-xs)/1 var(--font);cursor:pointer;transition:background var(--fast) var(--ease),color var(--fast) var(--ease)}
.bubble .cbcopy{border:1px solid color-mix(in srgb,var(--code-ink) 18%,transparent)}
.bubble .cbview:hover,.bubble .cbcopy:hover{color:var(--code-ink);background:var(--code-line)}
.bubble .cbview.active{color:var(--code-ink);background:color-mix(in srgb,var(--code-ink) 16%,transparent)}
.bubble .codeblock pre{margin:0;border:0;border-radius:0;background:transparent}
/* the Preview renders content the model wrote, which assumes a white page in either theme */
.bubble .cbcanvas{position:relative;background:#fff}
.bubble .cbframe{display:block;width:100%;height:420px;min-height:160px;max-height:80vh;border:0;resize:vertical;overflow:auto;background:#fff}

/* citations and the Sources panel */
.bubble .cite-mark{display:inline-flex;align-items:center;justify-content:center;min-width:17px;height:17px;margin:0 1px;padding:0 4px;
  border:0;border-radius:999px;background:var(--accent-soft);color:var(--accent);font:650 10.5px/1 var(--font);vertical-align:2px;cursor:pointer}
.bubble .cite-mark:hover{background:var(--accent);color:var(--accent-ink)}
.sources{margin-top:12px;border:1px solid var(--line);border-radius:var(--radius-md);background:var(--surface);font-size:var(--text-sm)}
.sources summary{display:flex;align-items:center;gap:7px;padding:8px 12px;list-style:none;cursor:pointer;color:var(--dim);font-weight:600;user-select:none}
.sources summary::-webkit-details-marker{display:none}
.sources summary::before{content:"";width:6px;height:6px;border-right:1.5px solid currentColor;border-bottom:1.5px solid currentColor;
  transform:rotate(-45deg);transition:transform var(--fast) var(--ease)}
.sources[open] summary::before{transform:rotate(45deg)}
.src-list{display:flex;flex-direction:column;gap:6px;padding:8px 12px 10px;border-top:1px solid var(--line)}
.src-row{padding:6px 8px;border-radius:var(--radius-sm);transition:background var(--base) var(--ease)}
.src-row.pulse{background:var(--accent-soft)}
.src-n{margin-right:6px;font:650 var(--text-xs) var(--mono);color:var(--accent)}
.src-meta{display:inline-flex;align-items:baseline;gap:8px;flex-wrap:wrap}
.src-file{font-weight:600;color:var(--ink)}
.src-range{font:var(--text-xs) var(--mono);color:var(--dimmer)}
.src-snippet{margin-top:3px;color:var(--dim);line-height:1.5;white-space:pre-wrap;word-break:break-word}

/* ── the composer ── */
#chat-foot{flex:0 0 auto;padding:8px 24px 12px}
.composer{max-width:780px;margin:0 auto}
.queuebar{display:none;flex-wrap:wrap;gap:6px;margin:0 0 8px}
.queuebar .qtag{max-width:100%;overflow:hidden;text-overflow:ellipsis}
.queuebar .qtag b{font-weight:600;color:var(--ink)}
.attach-row{display:none;flex-wrap:wrap;gap:6px;margin:0 0 8px}
.attach-chip{display:flex;align-items:center;gap:7px;max-width:260px;padding:3px 3px 3px 8px;border:1px solid var(--line);border-radius:var(--radius-md);
  background:var(--surface);font-size:var(--text-sm)}
.attach-chip img{display:block;width:30px;height:30px;object-fit:cover;border-radius:var(--radius-sm)}
.attach-chip .att-ico{display:inline-flex;color:var(--dim)}
.attach-chip .att-ico svg{width:15px;height:15px}
.attach-chip .att-name{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.attach-chip .att-tag{flex:0 0 auto;height:20px}
.attach-chip .att-x{width:24px;height:24px;color:var(--dim)}
.attach-chip .att-x svg{width:13px;height:13px}
.attach-chip .att-x:hover{color:var(--bad)}
.attach-chip.pulse{animation:chat-pulse .5s var(--ease) 2;border-color:var(--accent)}
.composer-field{position:relative;border:1px solid var(--line-strong);border-radius:var(--radius-lg);background:var(--surface);box-shadow:var(--shadow);
  transition:border-color var(--fast) var(--ease),box-shadow var(--fast) var(--ease)}
.composer-field:focus-within{border-color:var(--accent);box-shadow:0 0 0 3px var(--accent-soft)}
.composer.dragover .composer-field{border-color:var(--accent);border-style:dashed}
#chat-box-wrap{position:relative}
#chat-box{display:block;width:100%;min-height:46px;max-height:200px;padding:12px 14px 2px;border:0;outline:0;resize:none;background:transparent;
  color:var(--ink);font:var(--text-lg)/1.5 var(--font)}
#chat-box::placeholder{color:var(--dimmer)}
#chat-box:focus-visible{outline:none}
.cf-row{display:flex;align-items:center;gap:2px;padding:4px 6px 6px}
.cf-row .spacer{flex:1 1 auto}
#chat-attach-btn,#chat-mic-btn{color:var(--dim)}
#chat-attach-btn:hover,#chat-mic-btn:hover{color:var(--ink)}
#chat-mic-btn{user-select:none;-webkit-user-select:none;touch-action:none}
#chat-mic-btn.recording{color:var(--bad);background:var(--bad-soft);animation:chat-pulse 1.1s var(--ease) infinite}
#chat-mic-btn.busy{opacity:.6;cursor:progress}
#chat-send,#chat-stop{gap:5px;padding:0 12px}
#chat-send svg,#chat-stop svg{width:14px;height:14px}

/* the # picker, above the message box */
.mentionpop{position:absolute;left:6px;right:6px;bottom:calc(100% + 8px);z-index:40;display:none;max-height:min(46vh,320px);overflow-y:auto;padding:4px;
  background:var(--panel);border:1px solid var(--line-strong);border-radius:var(--radius-md);box-shadow:var(--shadow-lg)}
.mentionpop.open{display:block;animation:chat-pop-in var(--fast) var(--ease)}
.mention-sec-title{padding:7px 9px 3px;font-size:var(--text-xs);font-weight:600;color:var(--dimmer)}
.mention-row{display:flex;align-items:center;gap:8px;padding:6px 9px;border-radius:var(--radius-sm);cursor:pointer}
.mention-row:hover,.mention-row.active{background:var(--raised)}
.mention-ico{display:inline-flex;flex:0 0 auto;color:var(--dim)}
.mention-ico svg{width:14px;height:14px}
.mention-label{flex:1 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:var(--text-md)}
.mention-tag{flex:0 0 auto;font-size:var(--text-xs);color:var(--dimmer)}
.mention-empty{padding:9px;font-size:var(--text-sm);color:var(--dim)}

/* the toolbar: Prompt, Sampling, the adapter, the adapters table and Thinking; popovers open above it */
.chat-toolbar{position:relative;display:flex;align-items:center;flex-wrap:wrap;gap:2px 4px;margin-top:6px}
.chat-toolbar .tb{gap:6px;padding:0 8px;color:var(--dim)}
.chat-toolbar .tb:hover,.chat-toolbar .tb.on,.chat-toolbar .tb[aria-pressed="true"]{color:var(--ink)}
.chat-toolbar .tb.on{background:var(--raised)}
.chat-toolbar .tb .dot{width:7px;height:7px}
#chat-sampling.armed .dot{animation:chat-pulse 1.6s var(--ease) infinite}
#chat-adapter{width:auto;max-width:210px;height:28px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;background-color:transparent;border-color:transparent;color:var(--dim)}
#chat-adapter:hover{border-color:var(--line-strong);color:var(--ink)}
#chat-adapter option:disabled{color:var(--dimmer)}
#adapters-manage{color:var(--dim)}
#adapters-manage svg{width:15px;height:15px}
.samplepop{position:absolute;left:0;bottom:calc(100% + 8px);z-index:40;display:none;width:min(340px,100%);max-height:min(70vh,560px);overflow-y:auto;
  padding:14px 16px;background:var(--panel);border:1px solid var(--line-strong);border-radius:var(--radius-lg);box-shadow:var(--shadow-lg);font-size:var(--text-md)}
.samplepop.open{display:block;animation:chat-pop-in var(--fast) var(--ease)}
.samplepop h4{margin:0;font-size:var(--text-sm);font-weight:600;color:var(--ink)}
.samplepop .note{font-size:var(--text-xs);color:var(--dim);line-height:1.45}
.samp-head-row{display:flex;align-items:center;justify-content:space-between;gap:8px;margin-bottom:10px}
.samp-scope-row,.samprow,.samp-adv .seed-row{display:flex;align-items:center;gap:10px;margin:0 0 10px}
.samp-scope-row{padding-bottom:10px;border-bottom:1px solid var(--line)}
.samp-scope-row label,.samprow label,.samp-adv .seed-row label{flex:0 0 88px;font-size:var(--text-sm);color:var(--ink)}
.samp-scope-row .select{flex:1 1 auto;width:auto}
.samprow input[type=range]{flex:1 1 auto;min-width:0}
.samp-val{flex:0 0 40px;text-align:right;font:var(--text-sm) var(--mono);font-variant-numeric:tabular-nums;color:var(--ink)}
.samp-val.auto{color:var(--dimmer)}
.samp-adv{margin:2px 0 12px}
.samp-adv>summary{display:inline-flex;align-items:center;gap:5px;padding:2px 0 8px;list-style:none;cursor:pointer;font-size:var(--text-sm);font-weight:600;color:var(--dim)}
.samp-adv>summary::-webkit-details-marker{display:none}
.samp-adv>summary:hover{color:var(--ink)}
.samp-adv>summary svg{width:13px;height:13px;transition:transform var(--fast) var(--ease)}
.samp-adv[open]>summary svg{transform:rotate(90deg)}
.samp-adv .seed-row .input{flex:1 1 auto;font-family:var(--mono)}
.samppop-foot{display:flex;align-items:center;justify-content:space-between;gap:10px;margin-top:4px}
.sysprompt-pop h4{margin-bottom:8px}
#sysprompt-text{min-height:110px;font-size:var(--text-md)}
.sysprompt-foot-row{display:flex;align-items:center;justify-content:space-between;margin:6px 0}
.sysprompt-foot-row .note{font-variant-numeric:tabular-nums}
.sysprompt-presets{margin-top:12px;padding-top:12px;border-top:1px solid var(--line)}
.sysprompt-preset-row{display:flex;align-items:center;gap:6px;margin:0 0 6px}
#sysprompt-preset-select{flex:1 1 auto;width:auto;min-width:0}

/* the quiet line under the composer: the connection, then the decode rate, first token and context fill */
.chat-meta{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:4px 14px;margin-top:4px;padding:0 4px;
  font-size:var(--text-xs);color:var(--dimmer);font-variant-numeric:tabular-nums}
.chat-conn{display:flex;align-items:center;gap:7px;flex:1 1 240px;min-width:0}
.chat-conn .dot{width:7px;height:7px}
#chat-status-line{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
#chat-perf{display:flex;gap:12px;flex:0 0 auto}
#chat-perf .pf-item:empty{display:none}
#chat-perf .pf-item.warn{color:var(--warn)}
#chat-perf .pf-item.bad{color:var(--bad)}

/* ── the adapter routing table, a sheet at the right ── */
#adapters-overlay{position:fixed;inset:0;z-index:150;display:none;justify-content:flex-end;background:var(--overlay)}
#adapters-overlay.open{display:flex;animation:fade var(--base) var(--ease)}
#adapters-panel{display:flex;flex-direction:column;width:min(520px,100%);height:100%;background:var(--panel);border-left:1px solid var(--line-strong);box-shadow:var(--shadow-lg)}
.ad-head{display:flex;align-items:center;gap:10px;padding:14px 16px;border-bottom:1px solid var(--line)}
.ad-head h2{flex:1 1 auto;margin:0;font-size:var(--text-lg);font-weight:650}
#adapters-body{flex:1 1 auto;overflow-y:auto;padding:14px 16px 24px}
.ad-note{margin:0 0 14px;font-size:var(--text-sm);color:var(--dim);line-height:1.5}
.ad-sec-title{margin:0 0 8px;font-size:var(--text-xs);font-weight:600;color:var(--dim)}
.ad-row{display:flex;align-items:flex-start;gap:10px;margin-bottom:8px;padding:10px 12px;border:1px solid var(--line);border-radius:var(--radius-md);background:var(--surface)}
.ad-row.incompatible .ad-row-main{opacity:.55}
.ad-row.selected{border-color:var(--accent);background:var(--accent-soft)}
.ad-row-main{flex:1 1 auto;min-width:0}
.ad-row-head{display:flex;align-items:center;gap:6px;flex-wrap:wrap}
.ad-row-id{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:var(--text-md);font-weight:600}
.ad-badge{display:inline-flex;align-items:center;height:20px;padding:0 7px;border-radius:999px;background:var(--raised);color:var(--dim);font-size:var(--text-xs);font-weight:600}
.ad-badge.mounted{background:var(--ok-soft);color:var(--ok)}
.ad-badge.selected{background:var(--accent-soft);color:var(--accent)}
.ad-meta{margin-top:3px;font-size:var(--text-xs);line-height:1.5;color:var(--dimmer)}
.ad-meta b{font-weight:600;color:var(--dim);font-variant-numeric:tabular-nums}
.ad-why{margin-top:3px;font-size:var(--text-xs);color:var(--dimmer)}
.ad-actions{display:flex;flex-wrap:wrap;align-items:center;gap:6px;flex:0 0 auto}
.ad-actions button{appearance:none;display:inline-flex;align-items:center;height:28px;padding:0 10px;border:1px solid var(--line-strong);border-radius:var(--radius-sm);
  background:var(--raised);color:var(--ink);font:inherit;font-size:var(--text-sm);font-weight:550;cursor:pointer;white-space:nowrap}
.ad-actions button:hover:not(:disabled){border-color:var(--dimmer)}
.ad-actions button.primary{background:var(--accent);border-color:var(--accent);color:var(--accent-ink)}
.ad-actions button:disabled{opacity:.5;cursor:default}
.ad-stack-chk{display:inline-flex;align-items:center;gap:5px;font-size:var(--text-xs);color:var(--dim);cursor:pointer}
.ad-stack-bar{display:flex;align-items:center;flex-wrap:wrap;gap:8px;margin-bottom:12px;padding:8px 10px;border:1px solid var(--line);border-radius:var(--radius-md);background:var(--surface)}
.ad-stack-bar .lbl{font-size:var(--text-sm);color:var(--dim)}
.ad-stack-bar .expr{flex:1 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font:var(--text-sm) var(--mono)}

/* ── the assistant's spotlight: never a modal (no focus trap, clicks pass through), gone on any input ── */
#assistant-spotlight{position:fixed;inset:0;z-index:95;pointer-events:none;opacity:0;transform:scale(.98);
  transition:opacity var(--base) var(--ease),transform var(--base) var(--ease)}
#assistant-spotlight.show{opacity:1;transform:none}
#assistant-spotlight .asr-ring{position:fixed;border-radius:var(--radius-md);box-shadow:0 0 0 3px var(--accent),0 0 0 9999px var(--overlay);
  transition:left var(--base) var(--ease),top var(--base) var(--ease),width var(--base) var(--ease),height var(--base) var(--ease)}
#assistant-spotlight .asr-pop{position:fixed;max-width:min(320px,80vw);padding:10px 14px;background:var(--panel);border:1px solid var(--line-strong);
  border-radius:var(--radius-md);box-shadow:var(--shadow-lg);color:var(--ink);font-size:var(--text-md);line-height:1.4}

/* ── narrow screens: the sidebar is a drawer behind the top bar's button ── */
@media (max-width:760px){
  #chat-sidebar{position:fixed;top:0;bottom:0;left:0;z-index:120;width:min(320px,86vw);padding-top:16px;background:var(--surface);
    border-right:1px solid var(--line-strong);transform:translateX(-100%);visibility:hidden;
    transition:transform var(--base) var(--ease),visibility 0s linear var(--base)}
  #chat-sidebar.drawer-open{transform:none;visibility:visible;box-shadow:var(--shadow-lg);transition:transform var(--base) var(--ease)}
  #chat-drawer-backdrop.open{display:block;position:fixed;inset:0;z-index:110;background:var(--overlay);animation:fade var(--fast) var(--ease)}
  .sess .sacts{position:static;transform:none;padding:0 4px 0 0;background:none;opacity:1;pointer-events:auto}
  #chat-adapter{max-width:150px}
  #chat-thread{padding:18px 16px 8px;gap:18px}
  #chat-hello{padding:8vh 16px 16px}
  #chat-hello-chips{grid-template-columns:minmax(0,1fr)}
  #chat-foot{padding:6px 10px 10px}
  .msg.user{max-width:88%}
  .msg .bubble{font-size:var(--text-md)}
  .samplepop{width:100%}
}

@media (prefers-reduced-motion:reduce){
  .cursor,.thinkbox.live summary span,#chat-sampling.armed .dot,#chat-mic-btn.recording,.attach-chip.pulse,
  .samplepop.open,.mentionpop.open,.sess-export-menu,#adapters-overlay.open,#chat-drawer-backdrop.open{animation:none}
  .thinkbox.live summary span{color:var(--dim);background:none}
  #chat-sidebar,#chat-sidebar.drawer-open,.sess,.sess .sacts,.msg-actions,.maction,.tool .caret,.thinkbox summary svg,.samp-adv>summary svg,
  .composer-field,.src-row,.sources summary::before,#assistant-spotlight,#assistant-spotlight .asr-ring{transition:none}
}
`;
