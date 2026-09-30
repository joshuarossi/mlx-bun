// The panel's stylesheet, injected once into the page's head. It uses the host page's design tokens (`--ink`, `--dim`,
// `--hairline`, `--card`, `--blue`, ...) so it follows the theme; the host supplies those and the base element styles.
export const STYLE = String.raw`
  /* ── the panel element is the page: sidebar and conversation side by side ── */
  mlx-chat-panel{display:flex;flex-direction:row;height:100%}
  /* ── base rules the panel shares with its host page (identical there; a standalone host has only these) ── */
  .grad{background-clip:text;-webkit-background-clip:text;color:transparent}
  .g-hero{background-image:linear-gradient(96deg,var(--orange) 0%,var(--pink) 30%,var(--purple) 62%,var(--blue) 100%)}
  .pill{display:inline-flex;align-items:center;gap:8px;
      border:1px solid var(--hairline);border-radius:999px;padding:6px 13px;
      font-size:12.5px;font-weight:600;color:var(--dim);letter-spacing:.01em;white-space:nowrap}
  .pill .dot{width:8px;height:8px;border-radius:50%;background:var(--dimmer);
      box-shadow:0 0 0 transparent;transition:all .4s}
  .pill.ok .dot{background:var(--green);box-shadow:0 0 11px var(--green)}
  .pill.ok{color:var(--ink)}
  .pill.bad .dot{background:var(--red);box-shadow:0 0 11px var(--red)}
  .pill.warn .dot{background:var(--orange);box-shadow:0 0 11px var(--orange)}
  .samplepop{position:absolute;bottom:calc(100% + 9px);right:0;z-index:40;width:300px;
      max-height:min(70vh,560px);overflow-y:auto;
      background:var(--popover-panel);border:1px solid var(--hairline);border-radius:13px;padding:13px 14px;
      backdrop-filter:blur(22px) saturate(1.3);-webkit-backdrop-filter:blur(22px) saturate(1.3);
      box-shadow:0 18px 50px rgba(0,0,0,.35);display:none;
      transform:translateY(4px);opacity:0;transition:opacity .16s var(--ease),transform .16s var(--ease)}
  .samplepop.open{display:block;transform:translateY(0);opacity:1}
  .samplepop h4{font-size:12px;font-weight:600;color:var(--dim);letter-spacing:.02em;
      text-transform:uppercase;margin:0}
  .mem-head{display:flex;align-items:center;gap:10px;padding:16px 18px;border-bottom:1px solid var(--hairline-soft);flex:0 0 auto}
  .mem-head h2{font-size:16px;font-weight:700;letter-spacing:-.01em;flex:1 1 auto}
  .mem-close{appearance:none;background:none;border:none;cursor:pointer;color:var(--dim);font-size:15px;
      width:30px;height:30px;border-radius:8px;transition:color .2s,background .2s;flex:0 0 auto}
  .mem-close:hover{color:var(--ink);background:var(--card-hover)}
  @keyframes fade{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}
  /* ── chat ── */
  #chat-think{display:none;cursor:pointer;gap:7px;padding:5px 11px;font-size:12px;user-select:none;-webkit-user-select:none;
      transition:color .22s var(--ease),border-color .22s var(--ease)}
  #chat-think .dot{width:7px;height:7px}
  #chat-think:hover{border-color:var(--hairline-strong)}
  #chat-think.think-on{color:var(--ink)}
  #chat-think.think-on .dot{background:var(--blue);box-shadow:0 0 11px var(--blue)}
  /* sampling disclosure: a small pill that opens a popover above the composer */
  #chat-sampling-wrap{position:relative;display:inline-flex}
  #chat-sampling{cursor:pointer;gap:6px;padding:5px 11px;font-size:12px;user-select:none;-webkit-user-select:none;
      transition:color .22s var(--ease),border-color .22s var(--ease)}
  #chat-sampling:hover{border-color:var(--hairline-strong);color:var(--ink)}
  #chat-sampling.on{color:var(--ink);border-color:var(--hairline-strong)}
  #chat-sampling.dirty .dot{background:var(--blue);box-shadow:0 0 11px var(--blue)}
  /* Distinct one-shot-armed dot state (task brief item 2) — orange/amber
       reads as "temporary/pending" against the plain blue "overridden"
       state, matching the same semantic the orange dot already carries
       elsewhere (.pill.warn) rather than inventing a new color meaning. */
  #chat-sampling.armed .dot{background:var(--orange);box-shadow:0 0 11px var(--orange);animation:pulse-armed 1.6s var(--ease) infinite}
  @media (prefers-reduced-motion:reduce){#chat-sampling.armed .dot{animation:none}}
  @keyframes pulse-armed{0%,100%{opacity:1}50%{opacity:.45}}
  #chat-sampling .dot{width:7px;height:7px}
  .samp-head-row{display:flex;align-items:center;justify-content:space-between;gap:8px;margin:0 0 10px}
  .samp-oneshot-chip{font:10.5px/1 var(--mono);color:var(--orange);background:rgba(255,159,10,.12);
      border:1px solid rgba(255,159,10,.3);border-radius:999px;padding:3px 8px;letter-spacing:.01em;white-space:nowrap}
  .samp-scope-row{display:flex;align-items:center;gap:9px;margin:0 0 12px;padding-bottom:11px;border-bottom:1px solid var(--hairline-soft)}
  .samp-scope-row label{font-size:12.5px;color:var(--ink);width:74px;flex:0 0 auto}
  .samp-scope-row select{flex:1 1 auto;background:var(--card);border:1px solid var(--hairline);border-radius:7px;
      color:var(--ink);font-size:12px;padding:5px 8px;cursor:pointer;appearance:none;-webkit-appearance:none;
      transition:border-color .18s var(--ease)}
  .samp-scope-row select:hover,.samp-scope-row select:focus{border-color:var(--hairline-strong)}
  .samprow{display:flex;align-items:center;gap:9px;margin:0 0 11px}
  .samprow label{font-size:12.5px;color:var(--ink);width:74px;flex:0 0 auto}
  .samprow input[type=range]{flex:1 1 auto;-webkit-appearance:none;appearance:none;height:4px;margin:0;
      border-radius:3px;background:rgba(255,255,255,.15);outline:none;cursor:pointer}
  .samprow input[type=range]::-webkit-slider-thumb{-webkit-appearance:none;appearance:none;width:15px;height:15px;
      border-radius:50%;background:var(--ink);border:0;box-shadow:0 1px 4px rgba(0,0,0,.5);cursor:pointer;
      transition:background .15s var(--ease)}
  .samprow input[type=range]:hover::-webkit-slider-thumb,
    .samprow input[type=range]:focus::-webkit-slider-thumb{background:var(--blue)}
  .samp-val{width:40px;flex:0 0 auto;text-align:right;font-family:var(--mono);font-size:12px;color:var(--ink)}
  .samp-val.auto{color:var(--dimmer)}
  .samp-num{width:74px;flex:0 0 auto;text-align:right;background:var(--card);border:1px solid var(--hairline);
      border-radius:6px;color:var(--ink);font-family:var(--mono);font-size:11.5px;padding:3px 6px}
  .samp-num.auto{color:var(--dimmer)}
  .samppop-foot{display:flex;justify-content:space-between;align-items:center;margin-top:3px}
  .samppop-foot .note{font-size:10.5px;color:var(--dimmer);line-height:1.3;flex:1 1 auto;padding-right:8px}
  .samppop-foot button{appearance:none;cursor:pointer;background:var(--card);border:1px solid var(--hairline);
      color:var(--dim);border-radius:8px;padding:5px 11px;font-size:11.5px;font-weight:600;flex:0 0 auto;
      transition:color .18s var(--ease),border-color .18s var(--ease)}
  .samppop-foot button:hover{color:var(--ink);border-color:var(--hairline-strong)}
  /* Advanced sampling disclosure — collapsed by default, same visual language
       as the primary rows so it doesn't read as a separate control system. */
  .samp-adv{margin:2px 0 12px}
  .samp-adv > summary{cursor:pointer;font-size:11.5px;font-weight:600;color:var(--dim);letter-spacing:.02em;
      text-transform:uppercase;list-style:none;padding:2px 0 8px;user-select:none;-webkit-user-select:none}
  .samp-adv > summary::-webkit-details-marker{display:none}
  .samp-adv > summary::before{content:"▸ ";display:inline-block;transition:transform .15s var(--ease)}
  .samp-adv[open] > summary::before{transform:rotate(90deg)}
  .samp-adv > summary:hover{color:var(--ink)}
  .samp-adv .seed-row{display:flex;align-items:center;gap:9px;margin:0 0 4px}
  .samp-adv .seed-row label{font-size:12.5px;color:var(--ink);width:74px;flex:0 0 auto}
  .samp-adv .seed-row input[type=text]{flex:1 1 auto;background:var(--card);border:1px solid var(--hairline);
      border-radius:6px;color:var(--ink);font-family:var(--mono);font-size:12px;padding:5px 8px}
  .samp-adv .seed-row input[type=text]::placeholder{color:var(--dimmer)}
  /* System prompt pill + popover — same chrome as
       #chat-sampling-wrap/.samplepop, just to its left in the hint row. */
  #chat-sysprompt-wrap{position:relative;display:inline-flex}
  #chat-sysprompt{cursor:pointer;gap:6px;padding:5px 11px;font-size:12px;user-select:none;-webkit-user-select:none;
      transition:color .22s var(--ease),border-color .22s var(--ease)}
  #chat-sysprompt:hover{border-color:var(--hairline-strong);color:var(--ink)}
  #chat-sysprompt.on{color:var(--ink);border-color:var(--hairline-strong)}
  #chat-sysprompt.dirty .dot{background:var(--purple);box-shadow:0 0 11px var(--purple)}
  #chat-sysprompt .dot{width:7px;height:7px}
  .sysprompt-pop{width:320px}
  #sysprompt-text{width:100%;resize:vertical;min-height:80px;background:var(--card);
      border:1px solid var(--hairline);border-radius:9px;color:var(--ink);
      font:12.5px/1.5 inherit;padding:9px 10px;margin:0 0 6px}
  #sysprompt-text::placeholder{color:var(--dimmer)}
  #sysprompt-text:focus{outline:none;border-color:var(--hairline-strong)}
  .sysprompt-foot-row{display:flex;justify-content:space-between;align-items:center;margin:0 0 10px}
  .sysprompt-foot-row .note{font-size:10.5px;color:var(--dimmer)}
  .sysprompt-foot-row button,.sysprompt-preset-row button{appearance:none;cursor:pointer;background:var(--card);
      border:1px solid var(--hairline);color:var(--dim);border-radius:8px;padding:5px 11px;font-size:11.5px;
      font-weight:600;flex:0 0 auto;transition:color .18s var(--ease),border-color .18s var(--ease)}
  .sysprompt-foot-row button:hover,.sysprompt-preset-row button:hover{color:var(--ink);border-color:var(--hairline-strong)}
  .sysprompt-presets{margin-top:12px;padding-top:12px;border-top:1px solid var(--hairline-soft)}
  .sysprompt-preset-row{display:flex;align-items:center;gap:6px;margin:0 0 6px}
  #sysprompt-preset-select{flex:1 1 auto;min-width:0;max-width:none;appearance:none;-webkit-appearance:none;
      cursor:pointer;background:var(--card);text-overflow:ellipsis}
  /* ─── Adapter routing table — same right-side
       overlay/panel/head/body chrome as the Memory panel (mem-overlay/
       mem-panel/mem-head/mem-body), new top-level ids since it's a distinct
       panel opened from the composer instead of the sidebar. ─── */
  #adapters-overlay{position:fixed;inset:var(--nav-h) 0 0 0;z-index:150;display:none;justify-content:flex-end;
      background:var(--overlay-scrim);backdrop-filter:blur(4px);-webkit-backdrop-filter:blur(4px)}
  #adapters-overlay.open{display:flex;animation:fade .22s var(--ease)}
  #adapters-panel{width:min(520px,100%);height:100%;background:var(--overlay-panel);border-left:1px solid var(--hairline);
      display:flex;flex-direction:column;box-shadow:-24px 0 60px rgba(0,0,0,.4)}
  #adapters-body{flex:1 1 auto;overflow-y:auto;padding:14px 18px 24px}
  .ad-empty{text-align:center;color:var(--dim);padding:50px 18px;font-size:13.5px;line-height:1.6}
  .ad-sec-title{font-size:10.5px;font-weight:600;letter-spacing:.1em;text-transform:uppercase;color:var(--dimmer);margin:0 0 9px}
  .ad-note{font-size:11.5px;color:var(--dim);line-height:1.5;margin:0 0 16px}
  .ad-row{display:flex;align-items:flex-start;gap:11px;padding:11px 12px;border-radius:12px;
      border:1px solid var(--hairline-soft);margin-bottom:9px;transition:border-color .15s var(--ease)}
  .ad-row.incompatible{opacity:.55}
  .ad-row.selected{border-color:rgba(10,132,255,.5);background:rgba(10,132,255,.06)}
  .ad-row-main{flex:1 1 auto;min-width:0}
  .ad-row-head{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
  .ad-row-id{font-size:13.5px;font-weight:600;color:var(--ink);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
  .ad-badge{font:10.5px var(--mono);letter-spacing:.02em;padding:2px 8px;border-radius:999px;border:1px solid var(--hairline);color:var(--dim);white-space:nowrap}
  .ad-badge.mounted{color:var(--green);border-color:rgba(48,209,88,.4)}
  .ad-badge.selected{color:var(--blue);border-color:rgba(10,132,255,.4)}
  .ad-meta{font-size:11.5px;color:var(--dimmer);margin-top:4px;display:flex;gap:10px;flex-wrap:wrap}
  .ad-meta b{color:var(--dim);font-weight:600;font-variant-numeric:tabular-nums}
  .ad-why{font-size:11px;color:var(--dimmer);margin-top:4px;font-style:italic}
  .ad-actions{display:flex;gap:6px;flex:0 0 auto;flex-wrap:wrap;align-items:center}
  .ad-actions button{appearance:none;cursor:pointer;background:var(--card);border:1px solid var(--hairline);
      color:var(--dim);border-radius:8px;padding:5px 11px;font-size:11.5px;font-weight:600;white-space:nowrap;
      transition:color .18s var(--ease),border-color .18s var(--ease),background .18s var(--ease)}
  .ad-actions button:hover:not(:disabled){color:var(--ink);border-color:var(--hairline-strong)}
  .ad-actions button:disabled{opacity:.4;cursor:default}
  .ad-actions button.primary{color:var(--ink);border-color:rgba(10,132,255,.5);background:rgba(10,132,255,.1)}
  .ad-actions label.ad-stack-chk{display:flex;align-items:center;gap:5px;font-size:11px;color:var(--dimmer);cursor:pointer;white-space:nowrap}
  .ad-actions label.ad-stack-chk input{width:auto;margin:0;accent-color:var(--blue)}
  .ad-stack-bar{display:flex;align-items:center;gap:8px;flex-wrap:wrap;padding:10px 12px;border-radius:12px;
      background:var(--card);border:1px solid var(--hairline);margin-bottom:14px}
  .ad-stack-bar .lbl{font-size:11.5px;color:var(--dim);flex:0 0 auto}
  .ad-stack-bar .expr{font:12px var(--mono);color:var(--ink);flex:1 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
  /* App-aware assistant spotlight ('02d723a:docs/design/web-chat-redesign.md' Appendix A,
       beat-matrix Axis 12) — NEVER-HIJACK overlay: pointer-events:none on the whole thing (the
       highlighted control stays clickable straight through the ring/popover),
       no focus trap, transform/opacity-only animation, auto-dismiss handled
       in assistant.ts. Positioned in fixed viewport coordinates by JS
       (getBoundingClientRect of the target), not CSS layout. */
  #assistant-spotlight{position:fixed;inset:0;z-index:95;pointer-events:none;
      opacity:0;transform:scale(.98);transition:opacity .22s var(--ease),transform .22s var(--ease)}
  #assistant-spotlight.show{opacity:1;transform:none}
  #assistant-spotlight .asr-ring{position:fixed;border-radius:12px;
      box-shadow:0 0 0 3px var(--blue),0 0 0 9999px rgba(0,0,0,.32),0 0 24px rgba(10,132,255,.5);
      transition:left .22s var(--ease),top .22s var(--ease),width .22s var(--ease),height .22s var(--ease)}
  #assistant-spotlight .asr-pop{position:fixed;max-width:min(320px,80vw);background:var(--overlay-panel);
      backdrop-filter:blur(20px);border:1px solid var(--hairline);border-radius:12px;padding:10px 14px;
      font-size:13px;line-height:1.4;box-shadow:0 16px 50px rgba(0,0,0,.35)}
  @media (prefers-reduced-motion:reduce){
      #assistant-spotlight{transition:opacity .01ms;transform:none}
      #assistant-spotlight .asr-ring{transition:none}
    }
  /* ═══════════════════ CHAT ═══════════════════ */
  #chat-main{flex:1;min-width:0;display:flex;flex-direction:column}
  /* recent-chats sidebar */
  #chat-sidebar{flex:0 0 252px;display:flex;flex-direction:column;gap:8px;padding:14px 12px;
      border-right:1px solid var(--hairline);overflow-y:auto;background:var(--card-2)}
  #chat-new{width:100%;text-align:left;padding:10px 13px;border-radius:11px;cursor:pointer;
      background:var(--card);border:1px solid var(--hairline);color:var(--ink);font-size:13.5px;font-weight:600;
      transition:background .15s,border-color .15s}
  #chat-new:hover{background:var(--card-hover);border-color:rgba(10,132,255,.5)}
  /* Session search — trivial client-side substring filter over titles.
       No server change: SessionListItem
       carries no preview text today, so title-only is the honest scope. */
  #chat-sess-search{width:100%;background:var(--card);border:1px solid var(--hairline);border-radius:10px;
      color:var(--ink);font-size:12.5px;padding:8px 11px;outline:none;transition:border-color .2s}
  #chat-sess-search:focus{border-color:rgba(10,132,255,.5)}
  #chat-sess-search::placeholder{color:var(--dimmer)}
  .sesslist{display:flex;flex-direction:column;gap:2px;margin-top:4px}
  .sess{position:relative;padding:9px 50px 9px 11px;border-radius:10px;cursor:pointer;border:1px solid transparent}
  .sess:hover{background:var(--card)}
  .sess.active{background:var(--card);border-color:var(--hairline)}
  .sess.sess-hidden{display:none}
  .sess .stitle{font-size:13px;color:var(--ink);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .sess .smeta{font-size:11px;color:var(--dim);margin-top:2px;display:flex;gap:5px;align-items:center;white-space:nowrap}
  .sess .sbtn{position:absolute;top:7px;width:20px;height:20px;border:none;background:transparent;color:var(--dim);
      cursor:pointer;border-radius:6px;opacity:0;font-size:12px;line-height:1;transition:opacity .12s,background .12s,color .12s}
  .sess:hover .sbtn{opacity:.85}
  .sess .sfork{right:28px}
  .sess .sdel{right:6px}
  .sess .sfork:hover{background:var(--card-hover);color:var(--ink);opacity:1}
  .sess .sdel:hover{background:rgba(255,69,58,.18);color:var(--red);opacity:1}
  .sessempty{color:var(--dim);font-size:12px;padding:8px 11px;line-height:1.5}
  /* ─── mobile drawer: the sidebar becomes a
       slide-over panel on narrow viewports instead of vanishing outright. ─── */
  @media (max-width:760px){
      #chat-sidebar{
        position:fixed;top:var(--nav-h);bottom:0;left:0;width:min(84vw,320px);z-index:120;
        border-right:1px solid var(--hairline);
        transform:translateX(-100%);transition:transform .28s var(--ease);
        box-shadow:0 0 0 rgba(0,0,0,0);
      }
      #chat-sidebar.drawer-open{transform:translateX(0);box-shadow:24px 0 60px rgba(0,0,0,.45)}
      #chat-drawer-backdrop{display:none;position:fixed;inset:var(--nav-h) 0 0 0;z-index:110;
        background:var(--overlay-scrim);backdrop-filter:blur(4px);-webkit-backdrop-filter:blur(4px)}
      #chat-drawer-backdrop.open{display:block;animation:fade .2s var(--ease)}
    }
  @media (max-width:760px) and (prefers-reduced-motion:reduce){
      #chat-sidebar{transition:none}
    }
  #chat-scroll{flex:1;overflow-y:auto}
  #chat-thread{max-width:840px;margin:0 auto;padding:30px 22px 16px;display:flex;flex-direction:column;gap:18px}
  .msg{display:flex;flex-direction:column;gap:6px;max-width:90%}
  .msg .who{font-size:11px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:var(--dimmer)}
  .msg .bubble{border-radius:16px;padding:13px 17px;line-height:1.6;word-break:break-word;overflow-wrap:anywhere}
  .msg.user{align-self:flex-end;align-items:flex-end}
  .msg.user .bubble{background:linear-gradient(120deg,rgba(10,132,255,.26),rgba(94,92,230,.26));border:1px solid rgba(10,132,255,.35)}
  .msg.assistant{align-self:flex-start;width:100%;max-width:840px}
  .msg.assistant .bubble{background:var(--card);border:1px solid var(--hairline)}
  .msg .meta{font-size:11.5px;color:var(--dimmer);font-variant-numeric:tabular-nums}
  .msg .meta b{color:var(--green);font-weight:600}
  /* Message actions: a quiet hover/focus row under each message,
       same visual language as the code-block copy button (.cbcopy) — dim by
       default, brightens on hover, never shouts. Kept visible via :focus-within
       too so keyboard users can tab to the buttons without hovering. */
  .msg-actions{display:flex;gap:6px;opacity:0;transition:opacity .15s;margin-top:2px}
  .msg:hover .msg-actions,.msg:focus-within .msg-actions,.msg-actions.pinned{opacity:1}
  .msg.user .msg-actions{align-self:flex-end}
  .maction{font:11px/1 var(--mono);color:var(--dim);background:transparent;border:1px solid var(--hairline);
      border-radius:6px;padding:4px 9px;cursor:pointer;transition:color .15s,border-color .15s}
  .maction:hover{color:var(--ink);border-color:var(--dim)}
  .maction:disabled{opacity:.4;cursor:default}
  .maction:disabled:hover{color:var(--dim);border-color:var(--hairline)}
  /* Edit-and-resend as sibling branch: ChatGPT/Claude's '< i/n >' linear
       toggle (a tree view is explicitly out of scope). Only
       rendered on the LAST user message, and only when count > 1. */
  .sib-toggle{display:flex;align-items:center;gap:5px;font:11px/1 var(--mono);color:var(--dimmer)}
  .sib-toggle button{background:transparent;border:1px solid var(--hairline);border-radius:6px;color:var(--dim);
      cursor:pointer;padding:2px 7px;line-height:1.4}
  .sib-toggle button:hover:not(:disabled){color:var(--ink);border-color:var(--dim)}
  .sib-toggle button:disabled{opacity:.35;cursor:default}
  .msg-edit-box{width:100%;box-sizing:border-box;background:var(--card-2);border:1px solid var(--hairline);
      border-radius:10px;padding:9px 11px;color:var(--ink);font:inherit;line-height:1.5;resize:vertical;min-height:44px}
  .msg-edit-actions{display:flex;gap:8px;margin-top:6px;justify-content:flex-end}
  .thinkbox{margin:0 0 12px;border:1px solid rgba(10,132,255,.18);border-radius:12px;background:rgba(10,132,255,.06);overflow:hidden}
  .thinkbox summary{cursor:pointer;padding:7px 10px;font-size:12px;font-weight:600;color:var(--dim);user-select:none}
  .thinkbody{padding:0 12px 10px;color:var(--dim);font-size:.92em;white-space:pre-wrap}
  .cursor{display:inline-block;width:8px;height:17px;vertical-align:-3px;border-radius:2px;
      background:linear-gradient(180deg,var(--pink),var(--purple));animation:blink 1s steps(2) infinite}
  @keyframes blink{50%{opacity:0}}
  /* tool cards */
  .tool{margin:10px 0;border:1px solid var(--hairline);border-radius:14px;overflow:hidden;background:var(--card-2)}
  .tool .thead{display:flex;align-items:center;gap:10px;padding:11px 15px;cursor:pointer;user-select:none;transition:background .2s}
  .tool .thead:hover{background:rgba(255,255,255,.04)}
  .tool .ticon{width:26px;height:26px;border-radius:8px;display:flex;align-items:center;justify-content:center;
      font-size:13px;background:rgba(94,92,230,.18);color:var(--cyan);flex:0 0 auto}
  .tool .tname{font:600 13.5px var(--mono);color:var(--ink)}
  .tool .targs{font:12px var(--mono);color:var(--dim);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;flex:1 1 auto}
  .tool .tstat{font-size:11px;font-weight:600;letter-spacing:.06em;text-transform:uppercase;flex:0 0 auto;display:flex;align-items:center;gap:6px}
  .tool .tstat .sdot{width:7px;height:7px;border-radius:50%}
  .tool.running .tstat{color:var(--cyan)}
  .tool.running .sdot{background:var(--cyan);box-shadow:0 0 8px var(--cyan);animation:blink 1.1s infinite}
  .tool.ok .tstat{color:var(--green)}
  .tool.ok .sdot{background:var(--green)}
  .tool.fail .tstat{color:var(--red)}
  .tool.fail .sdot{background:var(--red)}
  .tool .caret{color:var(--dimmer);transition:transform .25s var(--ease);flex:0 0 auto}
  .tool.open .caret{transform:rotate(90deg)}
  .tool .tbody{display:none;border-top:1px solid var(--hairline-soft);padding:12px 15px}
  .tool.open .tbody{display:block}
  .tool .blk{margin-bottom:10px}
  .tool .blk:last-child{margin-bottom:0}
  .tool .blbl{font-size:10.5px;font-weight:600;letter-spacing:.1em;text-transform:uppercase;color:var(--dimmer);margin-bottom:5px}
  .tool pre{background:var(--code-bg-soft);border-radius:9px;padding:10px 12px;overflow-x:auto;
      font:12px/1.55 var(--mono);color:rgba(245,245,247,.7);white-space:pre-wrap;word-break:break-word;max-height:260px;overflow-y:auto}
  /* approval dialog */
  .approval{margin:12px 0;border:1px solid rgba(255,159,10,.45);border-radius:16px;overflow:hidden;
      background:rgba(255,159,10,.06);animation:fade .4s var(--ease)}
  .approval .ahead{display:flex;align-items:center;gap:10px;padding:13px 16px;border-bottom:1px solid rgba(255,159,10,.25)}
  .approval .ahead .ai{width:28px;height:28px;border-radius:8px;display:flex;align-items:center;justify-content:center;
      background:rgba(255,159,10,.2);color:var(--orange);font-size:15px}
  .approval .ahead .at{font-weight:700;font-size:14px}
  .approval .ahead .as{font:12px var(--mono);color:var(--orange);margin-left:auto}
  .approval .abody{padding:13px 16px}
  .approval pre{background:var(--code-bg);color:var(--code-ink);border-radius:10px;padding:12px 14px;overflow-x:auto;
      font:12.5px/1.6 var(--mono);white-space:pre-wrap;word-break:break-word;max-height:280px;overflow-y:auto}
  .approval .diffadd{color:var(--green)}
  .approval .diffdel{color:var(--red)}
  .approval .actions{display:flex;gap:10px;padding:0 16px 15px}
  .approval .resolved{padding:11px 16px;font-size:13px;font-weight:600;display:flex;align-items:center;gap:8px}
  .approval .resolved.allow{color:var(--green)}
  .approval .resolved.deny{color:var(--red)}
  /* Editable arguments (LM Studio's pattern): pre-filled
       with the proposed args JSON; the diff (edit/write only) stays above as
       a read-only visual aid so large content edits don't only exist as raw
       JSON. Approve re-parses the textarea and ships the edited object. */
  .approval .a-diff{margin-bottom:10px}
  .approval textarea.a-args{width:100%;background:var(--code-bg);color:var(--code-ink);border:1px solid var(--hairline);
      border-radius:10px;padding:12px 14px;font:12.5px/1.6 var(--mono);resize:vertical;min-height:64px;max-height:280px}
  .approval textarea.a-args:focus{outline:none;border-color:var(--orange)}
  .approval .a-argerr{margin-top:8px;font-size:12px;color:var(--red)}
  .approval .a-always{display:flex;align-items:center;gap:9px;padding:0 16px 13px;font-size:12.5px;
      color:var(--dim);cursor:pointer;font-weight:500}
  .approval .a-always input{width:auto;margin:0;accent-color:var(--orange)}
  /* ─── Chat-with-files RAG v1 Sources panel ('02d723a:docs/design/web-chat-redesign.md' Appendix A,
       beat-matrix Axis 5) — deliberately close to the memchip's citation language above:
       a collapsed "Sources · K" line under the reply that expands to
       filename+snippet per retrieved chunk, plus [n] markers in the reply
       text rendered as small round citation buttons that jump to their row. */
  .sources{margin-top:11px;border:1px solid var(--hairline-soft);border-radius:12px;overflow:hidden;
      background:rgba(255,255,255,.03)}
  .sources summary{list-style:none;display:flex;align-items:center;gap:7px;padding:8px 13px;
      cursor:pointer;user-select:none;font-size:12.5px;font-weight:600;color:var(--dim)}
  .sources summary::-webkit-details-marker{display:none}
  .sources summary::before{content:"›";display:inline-block;color:var(--dimmer);
      transition:transform .2s var(--ease)}
  .sources[open] summary::before{transform:rotate(90deg)}
  .src-list{border-top:1px solid var(--hairline-soft);padding:9px 13px 11px;display:flex;flex-direction:column;gap:10px}
  .src-row{border-radius:9px;padding:7px 9px;transition:background .5s var(--ease)}
  .src-row.pulse{background:rgba(10,132,255,.16)}
  .src-n{font:700 11px var(--mono);color:var(--blue);margin-right:7px}
  .src-meta{display:inline-flex;align-items:baseline;gap:8px;flex-wrap:wrap}
  .src-file{font-size:12.5px;font-weight:600;color:var(--ink)}
  .src-range{font:11px var(--mono);color:var(--dimmer)}
  .src-snippet{margin-top:4px;font-size:12px;line-height:1.5;color:var(--dim);white-space:pre-wrap;word-break:break-word}
  /* [n] citation markers rendered inline in the assistant's reply text
       (markdown.ts's linkifyCitations) — small round buttons, never full-size
       links, so they read as footnote markers rather than ordinary hyperlinks. */
  :is(.bubble) .cite-mark{display:inline-flex;align-items:center;justify-content:center;
      min-width:16px;height:16px;padding:0 4px;margin:0 1px;border-radius:999px;border:none;
      background:rgba(10,132,255,.18);color:var(--blue);font:700 10px var(--mono);
      cursor:pointer;vertical-align:2px;line-height:1;transition:background .15s}
  :is(.bubble) .cite-mark:hover{background:rgba(10,132,255,.3)}
  @media (prefers-reduced-motion:reduce){.src-row{transition:none}.sources summary::before{transition:none}}
  /* chat hello / starters */
  #chat-hello{max-width:840px;margin:6vh auto 0;padding:0 22px;text-align:center}
  #chat-hello h1{font-size:clamp(34px,5vw,54px);font-weight:700;letter-spacing:-.03em;line-height:1.08}
  #chat-hello p{margin-top:13px;color:var(--dim);font-size:15.5px}
  #chat-hello .chips{display:flex;flex-wrap:wrap;gap:10px;justify-content:center;margin-top:28px}
  .chip{border:1px solid var(--hairline);background:var(--card);color:var(--dim);border-radius:999px;
      padding:9px 16px;font-size:13.5px;cursor:pointer;transition:all .25s var(--ease)}
  .chip:hover{color:var(--ink);border-color:var(--hairline-strong);background:var(--card-hover)}
  /* chat composer */
  #chat-foot{flex:0 0 auto;border-top:1px solid var(--hairline);padding:14px 22px 16px;
      background:var(--card-2);backdrop-filter:blur(16px)}
  .composer{max-width:840px;margin:0 auto}
  .queuebar{display:none;max-width:840px;margin:0 auto 10px;gap:8px;flex-wrap:wrap;font-size:12px;color:var(--dim)}
  .queuebar .qtag{display:inline-flex;align-items:center;gap:6px;border:1px solid var(--hairline);
      border-radius:999px;padding:4px 11px;background:var(--card)}
  .queuebar .qtag b{color:var(--ink);font-weight:600}
  .inputrow{display:flex;gap:10px;align-items:flex-end}
  #chat-box-wrap{position:relative;flex:1;min-width:0}
  #chat-box{width:100%;background:var(--card);border:1px solid var(--hairline);border-radius:16px;
      color:var(--ink);font:15px/1.5 inherit;padding:13px 16px;resize:none;outline:none;
      max-height:200px;min-height:50px;transition:border-color .25s;box-sizing:border-box}
  #chat-box:focus{border-color:rgba(10,132,255,.5)}
  /* Unified "#" retrieval mention picker — same
       floating-panel chrome as .samplepop, anchored above the textarea it
       types into instead of a pill. Zero layout shift: absolutely positioned,
       hidden by default, never reflows the composer underneath it. */
  .mentionpop{position:absolute;bottom:calc(100% + 8px);left:0;right:0;z-index:40;
      max-height:min(46vh,320px);overflow-y:auto;
      background:var(--popover-panel);border:1px solid var(--hairline);border-radius:13px;padding:6px;
      backdrop-filter:blur(22px) saturate(1.3);-webkit-backdrop-filter:blur(22px) saturate(1.3);
      box-shadow:0 18px 50px rgba(0,0,0,.35);display:none;
      transform:translateY(4px);opacity:0;transition:opacity .14s var(--ease),transform .14s var(--ease)}
  .mentionpop.open{display:block;transform:translateY(0);opacity:1}
  .mention-sec-title{font-size:10.5px;font-weight:600;color:var(--dimmer);letter-spacing:.04em;
      text-transform:uppercase;padding:7px 9px 4px}
  .mention-row{display:flex;align-items:center;gap:8px;padding:7px 9px;border-radius:9px;cursor:pointer}
  .mention-row:hover,.mention-row.active{background:var(--card-hover)}
  .mention-ico{font-size:12px;color:var(--dimmer);flex:0 0 auto}
  .mention-label{flex:1 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;
      font-size:13px;color:var(--ink)}
  .mention-tag{flex:0 0 auto;font-size:10px;color:var(--dimmer);text-transform:uppercase;letter-spacing:.03em}
  .mention-empty{padding:10px 9px;font-size:12px;color:var(--dim)}
  /* Pulse a file's attach-chip when it's selected from the mention picker
       (the file is already attached — this is the only feedback needed). */
  .attach-chip.pulse{animation:chippulse .5s var(--ease) 2}
  @keyframes chippulse{0%,100%{box-shadow:0 0 0 rgba(10,132,255,0)}50%{box-shadow:0 0 0 3px rgba(10,132,255,.45)}}
  @media (prefers-reduced-motion:reduce){.attach-chip.pulse{animation:none}}
  #chat-send{background:linear-gradient(120deg,var(--blue),var(--purple));color:#fff;
      border:none;border-radius:14px;height:50px;padding:0 22px;font:600 14px inherit;cursor:pointer;transition:filter .2s}
  #chat-send:hover{filter:brightness(1.14)}
  #chat-send:disabled{filter:grayscale(.8) brightness(.6);cursor:default}
  #chat-stop{display:none;background:var(--card);border:1px solid var(--hairline);color:var(--ink);
      border-radius:14px;height:50px;padding:0 20px;font:600 14px inherit;cursor:pointer}
  #chat-stop:hover{background:var(--card-hover)}
  /* Wrap + shrink rules (2026-07-06 jank fix): without flex-wrap/min-width:0
       the right pill cluster overflowed past the viewport edge at tablet
       widths ("no adapter" clipped). The status line ellipsizes first; the
       pills wrap to a second row before anything leaves the screen. */
  .chat-hint{max-width:840px;margin:8px auto 0;font-size:11.5px;color:var(--dimmer);display:flex;justify-content:space-between;gap:10px;flex-wrap:wrap}
  .chat-hint #chat-status-line{flex:1 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
  .chat-hint .hint-right{display:flex;gap:12px;align-items:center;flex-wrap:wrap;justify-content:flex-end;min-width:0}
  /* Native <select> in .pill clothes: reset the UA appearance and draw our
       own chevron — the stock arrow collided with the label text ("no adaptɘr"
       glyph pile-up), and long adapter ids now ellipsize instead of overflow. */
  #chat-adapter{appearance:none;-webkit-appearance:none;max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;
      padding-right:27px;cursor:pointer;
      background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='5' viewBox='0 0 8 5'%3E%3Cpath d='M1 1l3 3 3-3' fill='none' stroke='%23909098' stroke-width='1.4' stroke-linecap='round'/%3E%3C/svg%3E");
      background-repeat:no-repeat;background-position:right 11px center}
  /* perf strip — always-visible, quiet: replaces the old bare #chat-tps text
       with tok/s + TTFT + context-fill + (server-driven only) a lane badge. */
  #chat-perf{max-width:840px;margin:8px auto 0;display:flex;align-items:center;gap:14px;
      font:11px/1 var(--mono);letter-spacing:.01em;color:var(--dimmer);flex-wrap:wrap}
  #chat-perf .pf-item{white-space:nowrap}
  #chat-perf .pf-item b{color:var(--ink);font-weight:600}
  /* adapter chip — upgraded presentation over the bare <select>: current
       selection + specialty line, options grayed by /v1/adapters/available's
       compatible flag rather than hidden outright. */
  #chat-adapter option:disabled{color:var(--dimmer);font-style:italic}
  /* "manage adapters" gear beside the quick-switch <select> — opens the
       routing table (#adapters-overlay), same pill sizing as #chat-think. */
  #adapters-manage{appearance:none;-webkit-appearance:none;cursor:pointer;display:inline-flex;align-items:center;
      justify-content:center;width:27px;height:27px;border-radius:999px;background:var(--card);
      border:1px solid var(--hairline);color:var(--dim);font-size:12.5px;line-height:1;flex:0 0 auto;
      transition:color .18s var(--ease),border-color .18s var(--ease),background .18s var(--ease)}
  #adapters-manage:hover{color:var(--ink);background:var(--card-hover);border-color:var(--hairline-strong)}
  /* attach (+) button + attachment chips */
  #chat-attach-btn{flex:0 0 auto;width:50px;height:50px;border-radius:14px;background:var(--card);
      border:1px solid var(--hairline);color:var(--ink);font-size:23px;line-height:1;cursor:pointer;transition:background .15s,border-color .15s}
  #chat-attach-btn:hover{background:var(--card-hover);border-color:rgba(10,132,255,.5)}
  /* hold-to-talk mic (voice.ts) */
  #chat-mic-btn{flex:0 0 auto;width:50px;height:50px;border-radius:14px;background:var(--card);
      border:1px solid var(--hairline);color:var(--ink);font-size:20px;line-height:1;cursor:pointer;user-select:none;-webkit-user-select:none;transition:background .15s,border-color .15s}
  #chat-mic-btn:hover{background:var(--card-hover);border-color:rgba(10,132,255,.5)}
  #chat-mic-btn.recording{background:rgba(255,69,58,.18);border-color:rgba(255,69,58,.7);animation:micpulse 1s ease-in-out infinite}
  #chat-mic-btn.busy{opacity:.6;cursor:progress}
  @keyframes micpulse{0%,100%{box-shadow:0 0 0 0 rgba(255,69,58,.35)}50%{box-shadow:0 0 0 8px rgba(255,69,58,0)}}
  .attach-row{display:none;flex-wrap:wrap;gap:8px;max-width:840px;width:100%;margin:0 auto 8px}
  .attach-chip{display:flex;align-items:center;gap:7px;background:var(--card);border:1px solid var(--hairline);
      border-radius:10px;padding:5px 9px;font-size:12px;max-width:240px}
  .attach-chip img{width:34px;height:34px;object-fit:cover;border-radius:6px;display:block}
  .attach-chip .att-ico{font-size:16px}
  .attach-chip .att-name{white-space:nowrap;overflow:hidden;text-overflow:ellipsis;color:var(--ink)}
  .attach-chip .att-x{border:none;background:transparent;color:var(--dim);cursor:pointer;font-size:12px;line-height:1;padding:0 2px}
  .attach-chip .att-x:hover{color:var(--red)}
  /* Chat-with-files RAG v1 ('02d723a:docs/design/web-chat-redesign.md' Appendix A,
       beat-matrix Axis 5): shown on
       text-file chips once the attached set is large enough that only the
       most relevant chunks get sent per turn instead of the whole file
       (composer.ts's shouldRetrieve threshold) — transparency principle, the
       mode switch must be visible on the chip, not just in prompt content
       the user never sees. */
  .attach-chip .att-tag{flex:0 0 auto;font-size:9.5px;font-weight:600;letter-spacing:.04em;text-transform:uppercase;
      color:var(--purple);background:rgba(191,90,242,.14);border-radius:999px;padding:2px 7px}
  .composer.dragover{outline:2px dashed var(--blue);outline-offset:6px;border-radius:14px}
  .msg-atts{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:8px}
  .msg-att-img{max-width:220px;max-height:220px;border-radius:10px;display:block}
  .msg-att-file{display:inline-flex;align-items:center;gap:5px;font-size:12px;background:rgba(255,255,255,.08);border-radius:8px;padding:5px 10px}
  .msg.user .msg-text{white-space:pre-wrap;word-break:break-word}
  /* ── rendered markdown (the same rules the host page applies to the memory panel articles) ── */
  /* markdown-ish rendering — shared by chat bubbles AND the memory panel's
       article view (.mem-article-render renders vault/Reference docs through
       the same mdToHtml; without this scope the panel's code fences lost
       their header chrome — "shCopy" mash, 2026-07-07 visual QA). */
  .bubble p{margin:0 0 10px}
  .bubble p:last-child{margin-bottom:0}
  .bubble ul,.bubble ol{margin:0 0 10px;padding-left:22px}
  .bubble li{margin:3px 0}
  .bubble strong{font-weight:700;color:var(--ink)}
  .bubble em{font-style:italic}
  .bubble code{font-family:var(--mono);font-size:.86em;background:rgba(127,127,127,.18);padding:2px 7px;border-radius:6px}
  .bubble pre{background:var(--code-bg);color:var(--code-ink);border:1px solid var(--hairline-soft);border-radius:12px;
      padding:13px 15px;overflow-x:auto;margin:10px 0;font:12.5px/1.6 var(--mono)}
  .bubble pre code{background:none;padding:0;font-size:inherit;color:inherit}
  .bubble h1,.bubble h2,.bubble h3,.bubble h4,.bubble h5,.bubble h6{font-weight:700;margin:14px 0 7px;letter-spacing:-.01em;line-height:1.3}
  .bubble h1{font-size:1.28em}
  .bubble h2{font-size:1.16em}
  .bubble h3{font-size:1.06em}
  .bubble h4,.bubble h5,.bubble h6{font-size:1em;color:var(--dim)}
  .bubble h1:first-child,.bubble h2:first-child,.bubble h3:first-child{margin-top:0}
  .bubble a{color:var(--cyan);text-decoration:none;border-bottom:1px solid rgba(100,210,255,.34)}
  .bubble a:hover{border-bottom-color:var(--cyan)}
  .bubble del{opacity:.55}
  .bubble blockquote{margin:9px 0;padding:3px 14px;border-left:3px solid var(--hairline);color:var(--dim)}
  .bubble blockquote p:last-child{margin-bottom:0}
  .bubble hr{border:none;border-top:1px solid var(--hairline);margin:15px 0}
  .bubble li.task{list-style:none;margin-left:-18px}
  .bubble li.task input{margin-right:7px;accent-color:var(--blue);vertical-align:-1px}
  .bubble .md-tablewrap{overflow-x:auto;margin:11px 0}
  .bubble table.md-table{width:100%;border-collapse:collapse;font-size:.92em}
  .bubble table.md-table th,.bubble table.md-table td{border:1px solid var(--hairline-soft);padding:6px 11px;text-align:left}
  .bubble table.md-table th{background:rgba(255,255,255,.05);font-weight:600;color:var(--ink)}
  .bubble .codeblock{margin:11px 0;border:1px solid var(--hairline-soft);border-radius:12px;overflow:hidden;background:var(--code-bg);color:var(--code-ink)}
  .bubble .cbhead{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:5px 9px 5px 13px;background:rgba(255,255,255,.04);border-bottom:1px solid var(--hairline-soft)}
  .bubble .cblang{font:11px/1 var(--mono);color:rgba(245,245,247,.65);letter-spacing:.02em}
  .bubble .cbcopy{font:11px/1 var(--mono);color:rgba(245,245,247,.65);background:transparent;border:1px solid rgba(255,255,255,.2);border-radius:6px;padding:4px 10px;cursor:pointer;transition:color .15s,border-color .15s}
  .bubble .cbcopy:hover{color:var(--code-ink);border-color:rgba(255,255,255,.4)}
  .bubble .codeblock pre{margin:0;border:none;border-radius:0;background:transparent;color:inherit}
  /* Canvas v1 ('02d723a:docs/design/web-chat-redesign.md' Appendix A,
       beat-matrix Axis 2): Preview|Source toggle
       for html/svg fences, sharing .cbhead with the existing lang tag + Copy
       button. .cbhead keeps lang pinned left; the toggle+copy group sits
       right via margin-left:auto on the first right-side element instead of
       space-between, since space-between with 3 children would push the
       toggle to the dead center of the bar. */
  .bubble .cbhead{justify-content:flex-start}
  .bubble .cbtoggle{display:inline-flex;gap:2px;margin-left:auto;padding:2px;border-radius:7px;background:rgba(255,255,255,.05)}
  .bubble .cbview{font:11px/1 var(--mono);color:rgba(245,245,247,.55);background:transparent;border:none;
      border-radius:5px;padding:4px 9px;cursor:pointer;transition:color .15s,background .15s}
  .bubble .cbview:hover{color:var(--code-ink)}
  .bubble .cbview.active{color:var(--code-ink);background:rgba(255,255,255,.14)}
  /* has-canvas keeps Copy visually last, right after the toggle group. */
  .bubble .codeblock.has-canvas .cbcopy{margin-left:2px}
  .bubble .cbcanvas{position:relative;background:#fff}
  .bubble .cbframe{display:block;width:100%;height:420px;min-height:160px;max-height:80vh;
      border:none;resize:vertical;overflow:auto;background:#fff}
  /* No layout shift on toggle: pre and cbcanvas are simply swapped via
       [hidden] — the codeblock's own border/rounding stays put, and the
       iframe's own default height (420px) plus resize:vertical means the
       block doesn't jump when Preview first opens vs. later re-opens. */
`;
