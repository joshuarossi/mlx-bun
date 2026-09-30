// The panel's markup: the recent-chats sidebar, the conversation and composer, the adapter routing table's overlay and
// the mobile drawer's backdrop. The ids are the panel's public surface for its host (the memory entry and consent
// card in the sidebar, the composer's controls) and for the assistant, which snapshots them. `data-spotlight`
// marks the controls the assistant can point at; `data-ui-chrome="content"` keeps the rendered conversation out of
// that snapshot, since an `a[href]` inside a message is untrusted content, not app chrome.
export const MARKUP = `
    <aside id="chat-sidebar">
      <button id="chat-new" data-spotlight="new-chat" title="Start a new chat (or type /new)">＋&nbsp; New chat</button>
      <input type="search" id="chat-sess-search" data-spotlight="session-search" placeholder="Search chats…" aria-label="Search chats" autocomplete="off">
      <div id="chat-sessions" class="sesslist"></div>
      <button id="chat-memory-entry" data-spotlight="memory-entry" type="button" style="display:none"
              aria-haspopup="dialog" aria-controls="mem-overlay" aria-expanded="false">
        <span class="mi" aria-hidden="true">◆</span>
        <span class="mt">Memory</span>
        <span class="mcount" id="chat-memory-count">—</span>
      </button>
    </aside>
    <div id="chat-main">
    <div id="chat-scroll">
      <div id="chat-hello">
        <h1>Local. Private. <span class="grad g-hero">Yours.</span></h1>
        <p id="chat-hello-sub">A full pi agent on this machine — local model, local tools, zero cloud. Every token below is generated here.</p>
        <div class="chips" id="chat-hello-chips">
          <button class="chip" data-q="What is mlx-bun and what can it do?">What is mlx-bun?</button>
          <button class="chip" data-q="How do I load a bigger or different model?">Load a bigger model</button>
          <button class="chip" data-q="Is this really private? Where does my data go?">Is this private?</button>
          <button class="chip" data-q="What can you help me with right now?">What can you do?</button>
        </div>
        <div id="chat-consent" role="group" aria-label="Memory setup">
          <span class="cc-icon" aria-hidden="true">◆</span>
          <span class="cc-text">Let mlx-bun remember what matters? Creates a local, git-tracked vault you can open anytime.</span>
          <span class="cc-actions">
            <button class="btn ghost sm" id="chat-consent-skip" type="button">Skip</button>
            <button class="btn primary sm" id="chat-consent-yes" type="button">Set up memory</button>
          </span>
        </div>
      </div>
      <div id="chat-thread" role="log" aria-live="polite" aria-atomic="false" data-ui-chrome="content"></div>
    </div>
    <div id="chat-foot">
      <div class="queuebar" id="chat-queue"></div>
      <div class="composer">
        <div id="chat-attach" class="attach-row"></div>
        <div class="inputrow">
          <button id="chat-attach-btn" class="iconbtn" title="Attach files or images" aria-label="Attach files">＋</button>
          <input type="file" id="chat-file-input" multiple style="display:none">
          <button id="chat-mic-btn" class="iconbtn" title="Hold to talk (Whisper)" aria-label="Hold to talk" style="display:none">🎙</button>
          <div id="chat-box-wrap">
            <textarea id="chat-box" data-spotlight="composer" rows="1" placeholder="Message the local agent…"></textarea>
            <div id="chat-mention-pop" class="mentionpop" role="listbox" aria-label="Attach a file or recall a memory"></div>
          </div>
          <button id="chat-stop" title="Abort the current turn">Stop</button>
          <button id="chat-send" data-spotlight="send">Send</button>
        </div>
        <div class="chat-hint">
          <span id="chat-status-line">Enter to send · Shift+Enter for a new line · type while it streams to steer</span>
          <span class="hint-right">
            <span id="chat-sysprompt-wrap">
              <span id="chat-sysprompt" data-spotlight="prompt-pill" class="pill" role="button" tabindex="0" aria-haspopup="true" aria-expanded="false"
                    title="System prompt (shapes how the assistant replies in this chat)"><span class="dot"></span>Prompt</span>
              <div id="chat-sysprompt-pop" class="samplepop sysprompt-pop" role="dialog" aria-label="System prompt">
                <h4>System prompt</h4>
                <textarea id="sysprompt-text" rows="6" maxlength="4000"
                  placeholder="e.g. Answer in French. Keep replies under 3 sentences. Prefer Python over JS."
                  aria-label="Custom system prompt"></textarea>
                <div class="sysprompt-foot-row">
                  <span class="note" id="sysprompt-count">0 / 4000</span>
                  <button id="sysprompt-clear" type="button">Clear</button>
                </div>
                <span class="note">Layered on top of the built-in assistant prompt — it doesn't replace mlx-bun's own
                  identity/tool guidance. Takes effect on your next message (not retroactively).</span>
                <div class="sysprompt-presets">
                  <h4>Presets</h4>
                  <div class="sysprompt-preset-row">
                    <select id="sysprompt-preset-select" class="pill" aria-label="Saved presets">
                      <option value="">— presets —</option>
                    </select>
                    <button id="sysprompt-preset-save" type="button" title="Save the current prompt + sampling as a named preset">Save</button>
                    <button id="sysprompt-preset-delete" type="button" title="Delete the selected preset">Delete</button>
                  </div>
                  <span class="note">A preset bundles this system prompt with the current Sampling settings — applying one sets both at once.</span>
                </div>
              </div>
            </span>
            <span id="chat-sampling-wrap">
              <span id="chat-sampling" data-spotlight="sampling-pill" class="pill" role="button" tabindex="0" aria-haspopup="true" aria-expanded="false"
                    title="Sampling controls (temperature · top_p · top_k)"><span class="dot"></span>Sampling</span>
              <div id="chat-sampling-pop" class="samplepop" role="dialog" aria-label="Sampling controls">
                <div class="samp-head-row">
                  <h4>Sampling</h4>
                  <span id="samp-oneshot-chip" class="samp-oneshot-chip" style="display:none">next msg only</span>
                </div>
                <div class="samp-scope-row">
                  <label for="samp-scope">Apply</label>
                  <select id="samp-scope" aria-label="Sampling scope">
                    <option value="session">this session</option>
                    <option value="next_turn">next message only</option>
                  </select>
                </div>
                <div class="samprow">
                  <label for="samp-temp">Temperature</label>
                  <input id="samp-temp" type="range" min="0" max="2" step="0.05" aria-label="Temperature">
                  <output id="samp-temp-val" class="samp-val auto">0.70</output>
                </div>
                <div class="samprow">
                  <label for="samp-topp">top_p</label>
                  <input id="samp-topp" type="range" min="0" max="1" step="0.01" aria-label="top_p">
                  <output id="samp-topp-val" class="samp-val auto">0.95</output>
                </div>
                <div class="samprow">
                  <label for="samp-topk">top_k</label>
                  <input id="samp-topk" type="range" min="0" max="100" step="1" aria-label="top_k">
                  <output id="samp-topk-val" class="samp-val auto">off</output>
                </div>
                <details class="samp-adv" id="samp-advanced">
                  <summary>Advanced</summary>
                  <div class="samprow">
                    <label for="samp-minp">min_p</label>
                    <input id="samp-minp" type="range" min="0" max="0.5" step="0.01" aria-label="min_p">
                    <output id="samp-minp-val" class="samp-val auto">off</output>
                  </div>
                  <div class="samprow">
                    <label for="samp-xtcp">XTC prob</label>
                    <input id="samp-xtcp" type="range" min="0" max="1" step="0.01" aria-label="XTC probability">
                    <output id="samp-xtcp-val" class="samp-val auto">off</output>
                  </div>
                  <div class="samprow">
                    <label for="samp-xtct">XTC thresh</label>
                    <input id="samp-xtct" type="range" min="0" max="1" step="0.01" aria-label="XTC threshold">
                    <output id="samp-xtct-val" class="samp-val auto">off</output>
                  </div>
                  <div class="samprow">
                    <label for="samp-reppen">repetition</label>
                    <input id="samp-reppen" type="range" min="1" max="2" step="0.01" aria-label="repetition penalty">
                    <output id="samp-reppen-val" class="samp-val auto">off</output>
                  </div>
                  <div class="samprow">
                    <label for="samp-repctx">rep. window</label>
                    <input id="samp-repctx" type="range" min="0" max="1024" step="16" aria-label="repetition context size">
                    <output id="samp-repctx-val" class="samp-val auto">off</output>
                  </div>
                  <div class="samprow">
                    <label for="samp-prespen">presence</label>
                    <input id="samp-prespen" type="range" min="-2" max="2" step="0.05" aria-label="presence penalty">
                    <output id="samp-prespen-val" class="samp-val auto">off</output>
                  </div>
                  <div class="samprow">
                    <label for="samp-freqpen">frequency</label>
                    <input id="samp-freqpen" type="range" min="-2" max="2" step="0.05" aria-label="frequency penalty">
                    <output id="samp-freqpen-val" class="samp-val auto">off</output>
                  </div>
                  <div class="seed-row">
                    <label for="samp-seed">seed</label>
                    <input id="samp-seed" type="text" inputmode="numeric" pattern="[0-9]*" placeholder="random" aria-label="seed">
                  </div>
                </details>
                <div class="samppop-foot">
                  <span class="note" id="samp-foot-note">Sliders default to this model's recommended values — temperature also follows the thinking toggle. Reset returns everything to defaults.</span>
                  <button id="samp-reset" type="button">Reset</button>
                </div>
              </div>
            </span>
            <select id="chat-adapter" data-spotlight="adapter-select" class="pill" title="LoRA adapter for this chat (none = base model)">
              <option value="">no adapter</option>
            </select>
            <button id="adapters-manage" type="button" title="Manage adapters — routing table, RAM cost, stacking"
                    aria-haspopup="dialog" aria-controls="adapters-overlay" aria-expanded="false">⚙</button>
            <span id="chat-think" class="pill" role="button" tabindex="0" title="Toggle the model's reasoning"><span class="dot"></span>Thinking</span>
          </span>
        </div>
        <div id="chat-perf">
          <span class="pf-item" id="pf-tps" title="Decode speed for the current/last turn"></span>
          <span class="pf-item" id="pf-ttft" title="Time to first token"></span>
          <span class="pf-item" id="pf-fill" title="Context window in use — auto-compacts before it fills"></span>
          </div>
      </div>
    </div>
    </div>
<div id="adapters-overlay">
  <div id="adapters-panel" role="dialog" aria-modal="true" aria-labelledby="adapters-title">
    <div class="mem-head">
      <h2 id="adapters-title">Adapters</h2>
      <button class="mem-close" id="adapters-close" aria-label="Close adapter routing table">✕</button>
    </div>
    <div class="mem-body" id="adapters-body"></div>
  </div>
</div>
<div id="chat-drawer-backdrop"></div>
`;
