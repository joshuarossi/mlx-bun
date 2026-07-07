// GENERATED — do not edit by hand.
// Source: src/web/src/*.ts (entrypoint main.ts). To regenerate:
//   bun scripts/build-web.ts
// tests/web-build.test.ts enforces that this file matches the source.
// src/web/src/api.ts
async function api(path, opts) {
  const { body, ...rest } = opts || {};
  const init = {
    headers: { "content-type": "application/json" },
    ...rest,
    ...body !== undefined ? { body: typeof body === "string" ? body : JSON.stringify(body) } : {}
  };
  const r = await fetch(path, init);
  const text = await r.text();
  let data;
  try {
    data = text ? JSON.parse(text) : {};
  } catch {
    data = { ok: false, error: text.slice(0, 400) || "HTTP " + r.status };
  }
  if (data && data.error && typeof data.error === "object") {
    const errObj = data.error;
    data.error = errObj.message || JSON.stringify(errObj).slice(0, 400);
  }
  if (!r.ok && data.ok === undefined)
    data = { ok: false, error: data.error || data.message || "HTTP " + r.status };
  return data;
}
function jobStream(jobId, handlers) {
  const es = new EventSource("/api/jobs/" + encodeURIComponent(jobId) + "/stream");
  es.onmessage = (ev) => {
    let e;
    try {
      e = JSON.parse(ev.data);
    } catch {
      return;
    }
    const fn = handlers[e.type];
    if (fn)
      fn(e);
  };
  es.addEventListener("end", () => es.close());
  es.onerror = () => {
    if (handlers.error)
      handlers.error();
  };
  return es;
}

// src/web/src/shell.ts
var $ = (id) => document.getElementById(id);
var gb = (b) => b == null ? "—" : (b / 2 ** 30).toFixed(2) + " GB";
var mb = (b) => b == null ? "—" : (b / 2 ** 20).toFixed(1) + " MB";
var num = (n) => n == null ? "—" : Math.round(n).toLocaleString();
function el(tag, cls, parent) {
  const e = document.createElement(tag);
  if (cls)
    e.className = cls;
  if (parent)
    parent.appendChild(e);
  return e;
}
function toast(msg, kind = "", ms = 4200) {
  const t = el("div", "toast " + kind, $("toasts"));
  t.textContent = msg;
  setTimeout(() => {
    t.style.transition = "opacity .4s,transform .4s";
    t.style.opacity = "0";
    t.style.transform = "translateY(10px)";
    setTimeout(() => t.remove(), 420);
  }, ms);
}
async function refreshHfGear() {
  try {
    const d = await api("/api/settings/hf-token");
    const saved = !!(d && d.ok && d.hasToken);
    $("nav-hf").classList.toggle("saved", saved);
    $("nav-hf").title = saved ? "Hugging Face token saved · click to replace" : "Hugging Face token settings";
    return saved;
  } catch {
    return false;
  }
}
var hfOverlayTrap = null;
function openHfSettings() {
  const ov = $("hf-overlay");
  ov.classList.add("open");
  if (hfOverlayTrap)
    hfOverlayTrap.capture();
  $("hf-token-input").value = "";
  $("hf-settings-msg").innerHTML = "";
  $("hf-state").textContent = "Checking for a saved token…";
  api("/api/settings/hf-token").then((d) => {
    const saved = !!(d && d.ok && d.hasToken);
    $("hf-state").innerHTML = saved ? "A write token is <strong>saved</strong>. Enter a new one below to replace it." : "No token saved yet. Add a write token to push models and datasets to the Hub.";
  }).catch(() => {
    $("hf-state").textContent = "Could not reach the server.";
  });
  setTimeout(() => $("hf-token-input").focus(), 50);
}
function closeHfSettings() {
  $("hf-overlay").classList.remove("open");
  if (hfOverlayTrap)
    hfOverlayTrap.restore();
}
async function saveHfToken() {
  const tokenInput = $("hf-token-input");
  const token = tokenInput.value.trim();
  const msg = $("hf-settings-msg");
  if (!token) {
    msg.innerHTML = '<div class="flash err">Enter a token first.</div>';
    return;
  }
  const btn = $("hf-save");
  btn.disabled = true;
  const d = await api("/api/settings/hf-token", { method: "POST", body: { token } }).catch(() => ({ ok: false, error: "request failed" }));
  btn.disabled = false;
  if (!d.ok) {
    msg.innerHTML = '<div class="flash err">' + escHtml(d.error || "could not save token") + "</div>";
    return;
  }
  msg.innerHTML = '<div class="flash ok">Token saved to <code>~/.mlx-bun/hf.json</code>.</div>';
  tokenInput.value = "";
  refreshHfGear();
  toast("Hugging Face token saved", "ok");
}
function escHtml(s) {
  return String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
}
async function pushToHub(panel, opts) {
  const { kind, job_id, source_path } = opts;
  panel.innerHTML = '<div class="pushpanel"><div class="flash"><span class="shimmer">checking Hugging Face token…</span></div></div>';
  const wrap = panel.firstChild;
  let hasToken = false;
  try {
    const s = await api("/api/settings/hf-token");
    hasToken = !!(s && s.ok && s.hasToken);
  } catch {}
  const renderForm = () => {
    wrap.innerHTML = (!hasToken ? '<div class="field"><label>Hugging Face write token</label>' + '<input type="password" class="p-token" placeholder="hf_…" autocomplete="off" spellcheck="false">' + '<div class="hint">A <strong>write</strong> token from huggingface.co/settings/tokens. Stored locally at <code>~/.mlx-bun/hf.json</code>.</div></div>' : "") + '<div class="field"><label>Repository id</label>' + '<input type="text" class="p-repo" placeholder="you/my-' + escHtml(kind === "dataset" ? "dataset" : "model") + '" autocomplete="off"></div>' + '<div class="field"><label class="chk"><input type="checkbox" class="p-priv">Private repository</label></div>' + '<div class="p-msg"></div>' + '<div class="btnrow" style="margin-top:6px"><button class="btn primary sm p-go">' + (hasToken ? "Push" : "Save token &amp; push") + "</button></div>";
    wrap.querySelector(".p-go").onclick = go;
    const focusEl = wrap.querySelector(hasToken ? ".p-repo" : ".p-token");
    if (focusEl)
      focusEl.focus();
  };
  async function go() {
    const msg = wrap.querySelector(".p-msg");
    const repo = (wrap.querySelector(".p-repo").value || "").trim();
    const priv = wrap.querySelector(".p-priv").checked;
    if (!repo) {
      msg.innerHTML = '<div class="flash err">Enter a repository id (e.g. <code>you/my-model</code>).</div>';
      return;
    }
    const btn = wrap.querySelector(".p-go");
    btn.disabled = true;
    if (!hasToken) {
      const token = (wrap.querySelector(".p-token").value || "").trim();
      if (!token) {
        msg.innerHTML = '<div class="flash err">Enter a write token first.</div>';
        btn.disabled = false;
        return;
      }
      const sv = await api("/api/settings/hf-token", { method: "POST", body: { token } }).catch(() => ({ ok: false, error: "request failed" }));
      if (!sv.ok) {
        msg.innerHTML = '<div class="flash err">' + escHtml(sv.error || "could not save token") + "</div>";
        btn.disabled = false;
        return;
      }
      hasToken = true;
      refreshHfGear();
    }
    msg.innerHTML = '<div class="flash"><span class="shimmer">pushing to ' + escHtml(repo) + "…</span></div>";
    const body = { repo_id: repo, private: priv };
    if (job_id != null)
      body.job_id = job_id;
    if (source_path != null)
      body.source_path = source_path;
    const d = await api("/api/" + kind + "/push", { method: "POST", body }).catch(() => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) {
      msg.innerHTML = '<div class="flash err">' + escHtml(d.error || "push failed") + "</div>";
      return;
    }
    const url = d.url || "https://huggingface.co/" + repo;
    wrap.innerHTML = '<div class="flash ok">Pushed to <a href="' + escHtml(url) + '" target="_blank" rel="noopener" style="text-decoration:underline">' + escHtml(url) + "</a></div>";
    toast("Pushed to Hugging Face", "ok");
  }
  renderForm();
}
function initHfSettings() {
  $("nav-hf").onclick = openHfSettings;
  $("hf-close").onclick = closeHfSettings;
  $("hf-save").onclick = saveHfToken;
  $("hf-overlay").addEventListener("click", (e) => {
    if (e.target === $("hf-overlay"))
      closeHfSettings();
  });
  $("hf-token-input").addEventListener("keydown", (e) => {
    if (e.key === "Enter")
      saveHfToken();
  });
  hfOverlayTrap = trapFocus($("hf-overlay"), () => $("hf-overlay").classList.contains("open"));
  refreshHfGear();
  initCodingToolsToggle();
}
var CODING_TOOLS_KEY = "mlxbun.codingTools";
function storedCodingToolsPreference() {
  return localStorage.getItem(CODING_TOOLS_KEY) === "1";
}
function setStoredCodingToolsPreference(on) {
  localStorage.setItem(CODING_TOOLS_KEY, on ? "1" : "0");
}
function renderCodingToolsState(active, pending) {
  const cb = $("settings-coding-tools");
  if (cb)
    cb.checked = pending;
  const note = $("settings-coding-tools-note");
  if (!note)
    return;
  if (pending && !active) {
    note.style.display = "";
    note.textContent = "Will apply starting with your next new chat (this chat keeps its current tools).";
  } else if (!pending && active) {
    note.style.display = "";
    note.textContent = "Turning this off won't remove tools from the CURRENT chat — start a new chat to fully disable.";
  } else {
    note.style.display = "none";
    note.textContent = "";
  }
}
function renderToolApprovals(tools, onForget) {
  const list = $("settings-approvals-list");
  if (!list)
    return;
  if (tools.length === 0) {
    list.innerHTML = '<div class="settings-approvals-empty">No tools are set to always-allow yet.</div>';
    return;
  }
  list.innerHTML = tools.map((t) => '<div class="settings-approval-row"><span class="satool">' + escHtml(t) + '</span><button class="saforget" data-tool="' + escHtml(t) + '">Forget</button></div>').join("");
  list.querySelectorAll(".saforget").forEach((btn) => {
    btn.onclick = () => onForget(btn.dataset.tool || "");
  });
}
function initCodingToolsToggle() {
  const cb = $("settings-coding-tools");
  if (!cb)
    return;
  cb.checked = storedCodingToolsPreference();
  cb.onchange = () => {
    const on = cb.checked;
    setStoredCodingToolsPreference(on);
    const setCodingTools = controllers.chat && controllers.chat.setCodingTools;
    if (setCodingTools)
      setCodingTools(on);
  };
}
function trapFocus(container, isOpen) {
  let lastFocused = null;
  const focusables = () => [...container.querySelectorAll('a[href],button:not([disabled]),textarea,input:not([disabled]),select,[tabindex]:not([tabindex="-1"])')].filter((e) => e.offsetParent !== null || e === document.activeElement);
  container.addEventListener("keydown", (e) => {
    const ke = e;
    if (ke.key !== "Tab" || !isOpen())
      return;
    const items = focusables();
    if (!items.length)
      return;
    const first = items[0], last = items[items.length - 1];
    if (ke.shiftKey && document.activeElement === first) {
      ke.preventDefault();
      last.focus();
    } else if (!ke.shiftKey && document.activeElement === last) {
      ke.preventDefault();
      first.focus();
    }
  });
  return {
    capture() {
      lastFocused = document.activeElement;
    },
    restore() {
      if (lastFocused && lastFocused.focus)
        lastFocused.focus();
      lastFocused = null;
    }
  };
}
var THEME_KEY = "mlxbun.theme";
var themeMedia = window.matchMedia("(prefers-color-scheme: light)");
function effectiveTheme(choice) {
  if (choice === "dark" || choice === "light")
    return choice;
  return themeMedia.matches ? "light" : "dark";
}
function applyTheme(choice) {
  document.documentElement.setAttribute("data-theme", effectiveTheme(choice));
  document.querySelectorAll("#theme-toggle button").forEach((b) => b.classList.toggle("active", b.dataset.themeChoice === choice));
}
function setTheme(choice) {
  localStorage.setItem(THEME_KEY, choice);
  applyTheme(choice);
}
function initTheme() {
  const saved = localStorage.getItem(THEME_KEY) || "auto";
  applyTheme(saved);
  document.querySelectorAll("#theme-toggle button").forEach((b) => b.addEventListener("click", () => setTheme(b.dataset.themeChoice || "auto")));
  themeMedia.addEventListener("change", () => {
    if ((localStorage.getItem(THEME_KEY) || "auto") === "auto")
      applyTheme("auto");
  });
}
var skTrap;
function openShortcutSheet() {
  skTrap.capture();
  $("shortcut-overlay").classList.add("open");
  $("nav-shortcuts").setAttribute("aria-expanded", "true");
  setTimeout(() => $("sk-close").focus(), 30);
}
function closeShortcutSheet() {
  $("shortcut-overlay").classList.remove("open");
  $("nav-shortcuts").setAttribute("aria-expanded", "false");
  skTrap.restore();
}
function initShortcutSheet() {
  skTrap = trapFocus($("shortcut-overlay"), () => $("shortcut-overlay").classList.contains("open"));
  const isMac = /Mac|iPhone|iPad/.test(navigator.platform || navigator.userAgent);
  document.querySelectorAll("#sk-mod-label, .sk-mod").forEach((e) => {
    e.textContent = isMac ? "⌘" : "Ctrl";
  });
  $("nav-shortcuts").onclick = () => {
    $("shortcut-overlay").classList.contains("open") ? closeShortcutSheet() : openShortcutSheet();
  };
  $("sk-close").onclick = closeShortcutSheet;
  $("shortcut-overlay").addEventListener("click", (e) => {
    if (e.target === $("shortcut-overlay"))
      closeShortcutSheet();
  });
}
var drawerTrap;
function openDrawer() {
  drawerTrap.capture();
  $("chat-sidebar").classList.add("drawer-open");
  $("chat-drawer-backdrop").classList.add("open");
  $("chat-hamburger").setAttribute("aria-expanded", "true");
  setTimeout(() => {
    const s = $("chat-sess-search");
    if (s)
      s.focus();
  }, 30);
}
function closeDrawer() {
  $("chat-sidebar").classList.remove("drawer-open");
  $("chat-drawer-backdrop").classList.remove("open");
  $("chat-hamburger").setAttribute("aria-expanded", "false");
  drawerTrap.restore();
}
function initDrawer() {
  drawerTrap = trapFocus($("chat-sidebar"), () => $("chat-sidebar").classList.contains("drawer-open"));
  $("chat-hamburger").onclick = () => {
    $("chat-sidebar").classList.contains("drawer-open") ? closeDrawer() : openDrawer();
  };
  $("chat-drawer-backdrop").addEventListener("click", closeDrawer);
}
var samplingPopoverClose = null;
function setSamplingPopoverClose(fn) {
  samplingPopoverClose = fn;
}
var memPanelClose = null;
function setMemPanelClose(fn) {
  memPanelClose = fn;
}
var adaptersPanelClose = null;
function setAdaptersPanelClose(fn) {
  adaptersPanelClose = fn;
}
var modelPopClose = null;
function setModelPopClose(fn) {
  modelPopClose = fn;
}
var sysPromptPopoverClose = null;
function setSysPromptPopoverClose(fn) {
  sysPromptPopoverClose = fn;
}
function closeTopOverlay() {
  if ($("shortcut-overlay").classList.contains("open")) {
    closeShortcutSheet();
    return true;
  }
  if ($("hf-overlay").classList.contains("open")) {
    closeHfSettings();
    return true;
  }
  const samplePop = $("chat-sampling-pop");
  if (samplePop && samplePop.classList.contains("open") && samplingPopoverClose) {
    samplingPopoverClose();
    return true;
  }
  const sysPop = $("chat-sysprompt-pop");
  if (sysPop && sysPop.classList.contains("open") && sysPromptPopoverClose) {
    sysPromptPopoverClose();
    return true;
  }
  const memOverlay = $("mem-overlay");
  if (memOverlay && memOverlay.classList.contains("open") && memPanelClose) {
    memPanelClose();
    return true;
  }
  const adaptersOverlay = $("adapters-overlay");
  if (adaptersOverlay && adaptersOverlay.classList.contains("open") && adaptersPanelClose) {
    adaptersPanelClose();
    return true;
  }
  const modelPop = $("model-pop");
  if (modelPop && modelPop.classList.contains("open") && modelPopClose) {
    modelPopClose();
    return true;
  }
  if ($("chat-sidebar").classList.contains("drawer-open")) {
    closeDrawer();
    return true;
  }
  return false;
}
function initGlobalKeydown() {
  document.addEventListener("keydown", (e) => {
    const mod = e.metaKey || e.ctrlKey;
    if (mod && e.key === "/") {
      e.preventDefault();
      $("shortcut-overlay").classList.contains("open") ? closeShortcutSheet() : openShortcutSheet();
      return;
    }
    if (mod && e.shiftKey && (e.key === "O" || e.key === "o")) {
      if (currentRoute() !== "chat")
        return;
      e.preventDefault();
      const newChat = controllers.chat && controllers.chat.newChat;
      newChat && newChat();
      return;
    }
    if (mod && e.shiftKey && (e.key === "C" || e.key === "c")) {
      if (currentRoute() !== "chat")
        return;
      e.preventDefault();
      const copyLastResponse = controllers.chat && controllers.chat.copyLastResponse;
      copyLastResponse && copyLastResponse();
      return;
    }
    if (e.shiftKey && e.key === "Escape") {
      if (currentRoute() !== "chat")
        return;
      e.preventDefault();
      $("chat-box").focus();
      return;
    }
    if (e.key === "Escape" && !e.shiftKey && !mod) {
      closeTopOverlay();
    }
  });
}
var DEV_KEY = "mlxbun.developer";
var DEV_TABS = ["quantize", "finetune", "dataset", "status", "curves", "routes"];
function hasExistingMlxbunState() {
  for (let i = 0;i < localStorage.length; i++) {
    const k = localStorage.key(i);
    if (k && k.startsWith("mlxbun.") && k !== DEV_KEY)
      return true;
  }
  return false;
}
function isDeveloperMode() {
  const saved = localStorage.getItem(DEV_KEY);
  if (saved != null)
    return saved === "1";
  const on = hasExistingMlxbunState();
  localStorage.setItem(DEV_KEY, on ? "1" : "0");
  return on;
}
function applyDeveloperMode(on) {
  document.querySelectorAll("nav .tab[data-dev]").forEach((t) => {
    if (t.dataset.tab === "routes" && t.dataset.routesUnavailable === "1") {
      t.style.display = "none";
      return;
    }
    t.style.display = on ? "" : "none";
  });
  const btn = $("nav-developer");
  if (btn)
    btn.setAttribute("aria-checked", on ? "true" : "false");
  const dot = document.getElementById("nav-developer-dot");
  if (dot)
    dot.classList.toggle("on", on);
  updateTabFades();
}
function setDeveloperMode(on) {
  localStorage.setItem(DEV_KEY, on ? "1" : "0");
  applyDeveloperMode(on);
}
function ensureDeveloperModeFor(route) {
  if (DEV_TABS.includes(route) && !isDeveloperMode())
    setDeveloperMode(true);
}
function initDeveloperToggle() {
  applyDeveloperMode(isDeveloperMode());
  const btn = $("nav-developer");
  if (btn)
    btn.onclick = () => setDeveloperMode(!isDeveloperMode());
}
async function initRoutesProbe() {
  const tab = document.querySelector('nav .tab[data-tab="routes"]');
  let ok = true;
  try {
    const r = await fetch("/dag", { method: "HEAD" });
    ok = r.ok;
  } catch {
    ok = false;
  }
  if (ok)
    return;
  if (tab) {
    tab.dataset.routesUnavailable = "1";
    tab.style.display = "none";
  }
  const section = $("s-routes");
  if (section) {
    section.innerHTML = '<div class="wrap" style="max-width:640px;margin:60px auto;text-align:center;color:var(--dim)">' + "<h2>Routes map unavailable</h2>" + "<p>The training/inference route diagram ships alongside the repo checkout " + "and isn't bundled into this build.</p></div>";
  }
  if (currentRoute() === "routes")
    location.replace("#/chat");
}
var ROUTES = ["chat", "quantize", "finetune", "dataset", "status", "routes"];
var inited = {};
var controllers = {};
function currentRoute() {
  const h = (location.hash || "").replace(/^#\/?/, "").split("?")[0] || "";
  return ROUTES.includes(h) ? h : "chat";
}
function router() {
  const route = currentRoute();
  ensureDeveloperModeFor(route);
  document.querySelectorAll("section[data-route]").forEach((s) => {
    const on = s.dataset.route === route;
    if (on && !s.classList.contains("active")) {
      s.classList.add("active");
      const c = controllers[route];
      if (c) {
        if (!inited[route]) {
          inited[route] = true;
          c.init && c.init();
        }
        c.enter && c.enter();
      }
    } else if (!on && s.classList.contains("active")) {
      s.classList.remove("active");
      const c = controllers[s.dataset.route];
      if (c && c.leave)
        c.leave();
    }
  });
  document.querySelectorAll("nav .tab").forEach((t) => t.classList.toggle("active", t.dataset.tab === route));
  $("bloom").style.opacity = route === "chat" ? "0.55" : "1";
  $("chat-hamburger").style.display = route === "chat" ? "" : "none";
  if (route !== "chat")
    closeDrawer();
}
function updateTabFades() {
  const t = $("tabs");
  const over = t.scrollWidth - t.clientWidth > 1;
  t.classList.toggle("fade-r", over && t.scrollLeft + t.clientWidth < t.scrollWidth - 1);
  t.classList.toggle("fade-l", over && t.scrollLeft > 1);
}
function initRouter() {
  window.addEventListener("hashchange", router);
  $("tabs").addEventListener("scroll", updateTabFades, { passive: true });
  window.addEventListener("resize", updateTabFades);
  updateTabFades();
}
var activeModelId = null;
function setConn(state, text) {
  const p = $("nav-conn");
  p.className = "pill " + (state || "");
  $("nav-conn-text").textContent = text;
}
var defaultHelloSub = null;
async function pollIdentity() {
  try {
    const [models, dl] = await Promise.all([
      fetch("/v1/models").then((r) => r.json()),
      fetch("/downloads").then((r) => r.json()).catch(() => ({ downloads: [] }))
    ]);
    activeModelId = models.data && models.data[0] ? models.data[0].id : null;
    $("nav-model").textContent = activeModelId || "no model";
    setConn("ok", "live · localhost");
    updateDownloadIndicator(dl && dl.downloads || []);
  } catch {
    $("nav-model").textContent = "server unreachable";
    setConn("bad", "unreachable — retrying");
  }
}
function updateDownloadIndicator(downloads) {
  const sub = $("chat-hello-sub");
  if (sub && defaultHelloSub === null)
    defaultHelloSub = sub.textContent;
  const incoming = downloads.find((d) => d.state === "active" && d.repoId !== activeModelId);
  const pill = $("nav-download");
  if (incoming) {
    const pct = incoming.totalBytes ? Math.floor((incoming.receivedBytes || 0) / incoming.totalBytes * 100) : 0;
    const name = incoming.repoId.split("/").pop();
    $("nav-download-text").textContent = "↓ " + name + " · " + pct + "%";
    pill.style.display = "";
    if (sub)
      sub.textContent = "You're on a small, fast starter model so you can chat right now — a more capable one (" + name + ") is downloading and takes over next launch. Ask me anything, or about mlx-bun itself.";
  } else {
    pill.style.display = "none";
    if (sub && defaultHelloSub !== null)
      sub.textContent = defaultHelloSub;
  }
}

// src/web/src/markdown.ts
var esc = (s) => String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
function mdSafeUrl(u) {
  const s = String(u).trim();
  return /^(https?:\/\/|mailto:|#|\/|\.{1,2}\/)/i.test(s) ? s : null;
}
function mdInline(t) {
  const codes = [];
  let src = String(t).replace(/(`+)([\s\S]+?)\1/g, (_m, _ticks, c) => {
    codes.push(c.replace(/^ | $/g, ""));
    return "\x00C" + (codes.length - 1) + "\x00";
  });
  let s = esc(src);
  s = s.replace(/\[([^\]]+)\]\(\s*([^)\s]+)(?:\s+&quot;[^)]*&quot;)?\s*\)/g, (m, text, url) => {
    const safe = mdSafeUrl(url);
    return safe ? '<a href="' + safe + '" target="_blank" rel="noopener noreferrer">' + text + "</a>" : m;
  });
  s = s.replace(/\*\*\*([^*]+)\*\*\*/g, "<strong><em>$1</em></strong>").replace(/\*\*([^*]+?)\*\*/g, "<strong>$1</strong>").replace(/(^|[^_\w])__([^_]+?)__(?![\w])/g, "$1<strong>$2</strong>").replace(/(^|[^*\w])\*([^*\s][^*]*?)\*/g, "$1<em>$2</em>").replace(/(^|[^_\w])_([^_\s][^_]*?)_(?![\w])/g, "$1<em>$2</em>").replace(/~~([^~]+?)~~/g, "<del>$1</del>");
  s = s.replace(/(^|[\s(])(https?:\/\/[^\s<)]+[^\s<).,;:!?'"])/g, (_m, pre, url) => pre + '<a href="' + url + '" target="_blank" rel="noopener noreferrer">' + url + "</a>");
  return s.replace(/ C(\d+) /g, (_m, i) => "<code>" + esc(codes[+i]) + "</code>");
}
function mdCodeBlock(lang, code) {
  const langClass = lang ? ' class="language-' + esc(lang) + '"' : "";
  return '<div class="codeblock"><div class="cbhead"><span class="cblang">' + esc(lang || "") + '</span><button class="cbcopy" type="button">Copy</button></div>' + "<pre><code" + langClass + ">" + esc(code) + "</code></pre></div>";
}
function mdTableSep(s) {
  return /^[\s|:-]+$/.test(s) && /-/.test(s) && /\|/.test(s);
}
function mdSplitRow(s) {
  return s.trim().replace(/^\|/, "").replace(/\|$/, "").split("|").map((c) => c.trim());
}
function mdBlockStart(s) {
  return /^\s*(`{3,}|~{3,})/.test(s) || /^(#{1,6})\s/.test(s) || /^\s*>/.test(s) || /^\s*[-*+]\s+/.test(s) || /^\s*\d+[.)]\s+/.test(s) || /^\s*([-*_])\s*(\1\s*){2,}$/.test(s);
}
function mdToHtml(src) {
  const lines = String(src).replace(/\r\n?/g, `
`).split(`
`);
  let html = "", i = 0, list = null;
  const closeList = () => {
    if (list) {
      html += "</" + list + ">";
      list = null;
    }
  };
  while (i < lines.length) {
    const ln = lines[i];
    const fence = ln.match(/^\s*(`{3,}|~{3,})\s*([\w+#.-]*)/);
    if (fence) {
      closeList();
      const tick = fence[1][0], lang = fence[2] || "", buf = [];
      const closeRe = new RegExp("^\\s*" + (tick === "`" ? "`{3,}" : "~{3,}") + "\\s*$");
      i++;
      while (i < lines.length && !closeRe.test(lines[i])) {
        buf.push(lines[i]);
        i++;
      }
      i++;
      html += mdCodeBlock(lang, buf.join(`
`));
      continue;
    }
    if (ln.includes("|") && i + 1 < lines.length && mdTableSep(lines[i + 1])) {
      closeList();
      const header = mdSplitRow(ln);
      const aligns = mdSplitRow(lines[i + 1]).map((c) => {
        const l = c.startsWith(":"), r = c.endsWith(":");
        return l && r ? "center" : r ? "right" : l ? "left" : "";
      });
      i += 2;
      const rows = [];
      while (i < lines.length && lines[i].includes("|") && lines[i].trim() !== "") {
        rows.push(mdSplitRow(lines[i]));
        i++;
      }
      const al = (k) => aligns[k] ? ' style="text-align:' + aligns[k] + '"' : "";
      let tbl = '<div class="md-tablewrap"><table class="md-table"><thead><tr>';
      header.forEach((c, k) => {
        tbl += "<th" + al(k) + ">" + mdInline(c) + "</th>";
      });
      tbl += "</tr></thead><tbody>";
      rows.forEach((r) => {
        tbl += "<tr>";
        for (let k = 0;k < header.length; k++)
          tbl += "<td" + al(k) + ">" + mdInline(r[k] || "") + "</td>";
        tbl += "</tr>";
      });
      html += tbl + "</tbody></table></div>";
      continue;
    }
    const h = ln.match(/^(#{1,6})\s+(.*)$/);
    if (h) {
      closeList();
      const n = h[1].length;
      html += "<h" + n + ">" + mdInline(h[2].replace(/\s+#+\s*$/, "")) + "</h" + n + ">";
      i++;
      continue;
    }
    if (/^\s*([-*_])\s*(\1\s*){2,}$/.test(ln)) {
      closeList();
      html += "<hr>";
      i++;
      continue;
    }
    if (/^\s*>/.test(ln)) {
      closeList();
      const buf = [];
      while (i < lines.length && /^\s*>/.test(lines[i])) {
        buf.push(lines[i].replace(/^\s*>\s?/, ""));
        i++;
      }
      html += "<blockquote>" + mdToHtml(buf.join(`
`)) + "</blockquote>";
      continue;
    }
    const task = ln.match(/^\s*[-*+]\s+\[([ xX])\]\s+(.*)$/);
    const ul = ln.match(/^\s*[-*+]\s+(.*)$/);
    const ol = ln.match(/^\s*\d+[.)]\s+(.*)$/);
    if (task) {
      if (list !== "ul") {
        closeList();
        html += "<ul>";
        list = "ul";
      }
      html += '<li class="task"><input type="checkbox" disabled' + (task[1].toLowerCase() === "x" ? " checked" : "") + "> " + mdInline(task[2]) + "</li>";
      i++;
      continue;
    }
    if (ul) {
      if (list !== "ul") {
        closeList();
        html += "<ul>";
        list = "ul";
      }
      html += "<li>" + mdInline(ul[1]) + "</li>";
      i++;
      continue;
    }
    if (ol) {
      if (list !== "ol") {
        closeList();
        html += "<ol>";
        list = "ol";
      }
      html += "<li>" + mdInline(ol[1]) + "</li>";
      i++;
      continue;
    }
    if (ln.trim() === "") {
      closeList();
      i++;
      continue;
    }
    closeList();
    const para = [ln];
    i++;
    while (i < lines.length && lines[i].trim() !== "" && !mdBlockStart(lines[i])) {
      para.push(lines[i]);
      i++;
    }
    html += "<p>" + para.map(mdInline).join("<br>") + "</p>";
  }
  closeList();
  return html;
}
function splitBlocks(src) {
  const lines = String(src).replace(/\r\n?/g, `
`).split(`
`);
  const blocks = [];
  let buf = [], i = 0;
  const flush = (done) => {
    if (buf.length) {
      blocks.push({ text: buf.join(`
`), done });
      buf = [];
    }
  };
  while (i < lines.length) {
    const ln = lines[i];
    const fence = ln.match(/^\s*(`{3,}|~{3,})/);
    if (fence) {
      flush(true);
      const tick = fence[1][0];
      const closeRe = new RegExp("^\\s*" + (tick === "`" ? "`{3,}" : "~{3,}") + "\\s*$");
      buf.push(ln);
      i++;
      let closed = false;
      while (i < lines.length) {
        buf.push(lines[i]);
        if (closeRe.test(lines[i])) {
          closed = true;
          i++;
          break;
        }
        i++;
      }
      flush(closed);
      continue;
    }
    if (ln.trim() === "") {
      flush(true);
      i++;
      continue;
    }
    buf.push(ln);
    i++;
  }
  flush(false);
  return blocks;
}
function renderBlocksIncremental(container, text, state) {
  const next = splitBlocks(text);
  const prev = state.blocks || [];
  for (let k = 0;k < next.length; k++) {
    const nb = next[k];
    const pb = prev[k];
    if (pb && pb.done && pb.text === nb.text && pb.node) {
      nb.node = pb.node;
      continue;
    }
    const node = pb && pb.node ? pb.node : document.createElement("div");
    node.className = "md-block" + (nb.done ? " done" : "");
    node.innerHTML = mdToHtml(nb.text);
    nb.node = node;
    if (!node.parentNode)
      container.appendChild(node);
    if (nb.done)
      highlightIn(node);
  }
  for (let k = next.length;k < prev.length; k++) {
    const pk = prev[k];
    if (pk && pk.node && pk.node.parentNode)
      pk.node.remove();
  }
  state.blocks = next;
}
function highlightIn(container) {
  if (typeof hljs === "undefined" || !container)
    return;
  const blocks = container.querySelectorAll("pre code");
  for (const block of blocks) {
    const el2 = block;
    if (el2.dataset.highlighted)
      continue;
    const hasLang = /\blanguage-/.test(el2.className);
    if (!hasLang && (el2.textContent || "").length > 20000)
      continue;
    try {
      hljs.highlightElement(el2);
    } catch {}
  }
}
function makeFrameScheduler(render, shouldStick, doStick) {
  let queued = false;
  return function schedule() {
    if (queued)
      return;
    queued = true;
    requestAnimationFrame(() => {
      queued = false;
      const stickAfter = shouldStick ? shouldStick() : false;
      render();
      if (stickAfter && doStick)
        doStick();
    });
  };
}
function renderSteps(container, names, cur) {
  container.innerHTML = names.map((n, i) => {
    const cls = i === cur ? "cur" : i < cur ? "done" : "";
    const arrow = i < names.length - 1 ? '<span class="arrow">&#8594;</span>' : "";
    return '<span class="s ' + cls + '"><span class="n">' + (i + 1) + "</span>" + esc(n) + "</span>" + arrow;
  }).join("");
}

// src/web/src/composer.ts
var MAX_TEXT_BYTES = 256 * 1024;
var TEXT_EXTS = /\.(txt|md|markdown|csv|tsv|json|jsonl|ya?ml|toml|ini|cfg|conf|log|xml|html?|css|scss|js|mjs|cjs|ts|tsx|jsx|py|rs|go|java|c|h|cpp|hpp|cc|cs|rb|php|sh|bash|zsh|fish|sql|swift|kt|lua|r|jl|tex|svg|env|gitignore|dockerfile|makefile)$/i;
function isTextFile(f) {
  if (f.type.startsWith("text/"))
    return true;
  if (/(json|xml|javascript|yaml|x-sh|x-toml|csv|markdown)/i.test(f.type))
    return true;
  return TEXT_EXTS.test(f.name || "");
}
function readDataUrl(file) {
  return new Promise((res, rej) => {
    const r = new FileReader;
    r.onerror = rej;
    r.onload = () => {
      const s = String(r.result);
      const i = s.indexOf(",");
      res(i >= 0 ? s.slice(i + 1) : s);
    };
    r.readAsDataURL(file);
  });
}
function readText(file) {
  return new Promise((res, rej) => {
    const r = new FileReader;
    r.onerror = rej;
    r.onload = () => res(String(r.result));
    r.readAsText(file);
  });
}

class ComposerState {
  attachments = [];
  visionCapable = false;
  thinkingCapable = false;
  thinkingOn = true;
  attachSeq = 0;
  sampling = {
    temperature: null,
    top_p: null,
    top_k: null,
    min_p: null,
    xtc_probability: null,
    xtc_threshold: null,
    repetition_penalty: null,
    repetition_context_size: null,
    presence_penalty: null,
    frequency_penalty: null,
    seed: null
  };
  genDefaults = { temperature: null, topP: null, topK: null };
  systemPrompt = null;
  recTemp() {
    return this.genDefaults.temperature != null ? this.genDefaults.temperature : this.thinkingOn ? 0.9 : 0.7;
  }
  recTopP() {
    return this.genDefaults.topP != null ? this.genDefaults.topP : 0.95;
  }
  recTopK() {
    return this.genDefaults.topK != null ? this.genDefaults.topK : 0;
  }
}
async function addFiles(state, files) {
  for (const f of files) {
    if (f.type.startsWith("image/")) {
      if (!state.visionCapable) {
        toast("This model can't see images — serve a vision-capable model (look for the vision tag in the Library).", "err");
        continue;
      }
      try {
        state.attachments.push({ id: ++state.attachSeq, kind: "image", name: f.name || "image", mimeType: f.type, data: await readDataUrl(f) });
      } catch {
        toast("Couldn't read " + (f.name || "image"), "err");
      }
    } else if (isTextFile(f)) {
      try {
        let text = await readText(f);
        const truncated = text.length > MAX_TEXT_BYTES;
        if (truncated)
          text = text.slice(0, MAX_TEXT_BYTES);
        state.attachments.push({ id: ++state.attachSeq, kind: "text", name: f.name || "file", text, truncated });
      } catch {
        toast("Couldn't read " + (f.name || "file"), "err");
      }
    } else {
      toast("Unsupported file type: " + (f.name || "file"), "err");
    }
  }
  renderAttachments(state);
}
function renderAttachments(state) {
  const box = $("chat-attach");
  box.innerHTML = "";
  box.style.display = state.attachments.length ? "flex" : "none";
  for (const a of state.attachments) {
    const chip = el("div", "attach-chip", box);
    chip.dataset.attId = String(a.id);
    if (a.kind === "image") {
      const im = el("img", "", chip);
      im.src = "data:" + a.mimeType + ";base64," + a.data;
      im.alt = a.name;
    } else
      el("span", "att-ico", chip).textContent = "\uD83D\uDCC4";
    el("span", "att-name", chip).textContent = a.name + (a.truncated ? " (truncated)" : "");
    const x = el("button", "att-x", chip);
    x.type = "button";
    x.textContent = "✕";
    x.onclick = () => {
      state.attachments = state.attachments.filter((z) => z.id !== a.id);
      renderAttachments(state);
    };
  }
}
function clearAttachments(state) {
  state.attachments = [];
  renderAttachments(state);
}
function buildMessageText(state, userText) {
  const files = state.attachments.filter((a) => a.kind === "text");
  if (!files.length)
    return userText;
  let pre = "";
  for (const a of files)
    pre += "Attached file: " + a.name + "\n```\n" + a.text + "\n```\n\n";
  return pre + userText;
}
function updateAttachHint(state) {
  const btn = $("chat-attach-btn");
  if (btn)
    btn.title = state.visionCapable ? "Attach files or images" : "Attach files (this model can't see images)";
}
function escHtml2(s) {
  return String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
}
function renderAdapterOptionsHtml(list) {
  return '<option value="">no adapter</option>' + list.map((a) => {
    const label = escHtml2(a.id) + (a.rank ? " · r" + escHtml2(a.rank) : "") + (a.mounted ? " · mounted" : "");
    if (a.compatible)
      return `<option value="${escHtml2(a.id)}" data-path="${escHtml2(a.path)}">${label}</option>`;
    const why = a.base_model ? `trained for ${escHtml2(a.base_model)}, not the currently-served model` : "not compatible with the currently-served model";
    return `<option value="${escHtml2(a.id)}" disabled title="${why}">${label} (incompatible)</option>`;
  }).join("");
}
async function refreshAdapters() {
  const sel = $("chat-adapter");
  if (!sel)
    return;
  let list = [];
  try {
    const d = await api("/v1/adapters/available");
    list = d.adapters || [];
  } catch {}
  const cur = sel.value;
  sel.innerHTML = renderAdapterOptionsHtml(list);
  if (cur && list.some((a) => a.id === cur))
    sel.value = cur;
}
async function onSelectAdapter(sel, send) {
  const id = sel.value;
  if (!id) {
    send({ type: "set_adapter", id: null });
    return;
  }
  const opt = sel.options[sel.selectedIndex];
  const path = opt && opt.getAttribute("data-path");
  if (path) {
    const r = await api("/v1/adapters", { method: "POST", body: { id, path } });
    if (r && (r.error || r.ok === false)) {
      toast("adapter: " + (r.error || "mount failed"), "err");
      sel.value = "";
      send({ type: "set_adapter", id: null });
      return;
    }
  }
  send({ type: "set_adapter", id });
  toast("adapter mounted — new turns start a fresh KV segment", "ok");
}
function updateThinkingToggle(state) {
  const b = $("chat-think");
  if (!b)
    return;
  b.style.display = state.thinkingCapable ? "inline-flex" : "none";
  b.classList.toggle("think-on", state.thinkingOn);
  b.title = state.thinkingOn ? "Reasoning on — click to answer directly" : "Reasoning off — click to let the model think";
  b.setAttribute("aria-pressed", String(state.thinkingOn));
  refreshSamplingRecs(state);
}
var SAMP_FIELDS = [
  { id: "samp-temp", field: "temperature", valId: "samp-temp-val", rec: (s) => s.recTemp(), fmt: (v) => v.toFixed(2) },
  { id: "samp-topp", field: "top_p", valId: "samp-topp-val", rec: (s) => s.recTopP(), fmt: (v) => v.toFixed(2) },
  { id: "samp-topk", field: "top_k", valId: "samp-topk-val", rec: (s) => s.recTopK(), fmt: (v) => v >= 1 ? String(Math.round(v)) : "off" }
];
var SAMP_ADV_FIELDS = [
  { id: "samp-minp", field: "min_p", valId: "samp-minp-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-xtcp", field: "xtc_probability", valId: "samp-xtcp-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-xtct", field: "xtc_threshold", valId: "samp-xtct-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-reppen", field: "repetition_penalty", valId: "samp-reppen-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-repctx", field: "repetition_context_size", valId: "samp-repctx-val", fmt: (v) => String(Math.round(v)) },
  { id: "samp-prespen", field: "presence_penalty", valId: "samp-prespen-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-freqpen", field: "frequency_penalty", valId: "samp-freqpen-val", fmt: (v) => v.toFixed(2) }
];
var SAMP_SLIDER_FIELDS = SAMP_FIELDS.concat(SAMP_ADV_FIELDS);
function refreshSamplingRecs(state) {
  for (const f of SAMP_FIELDS) {
    const slider = $(f.id), val = $(f.valId);
    if (!slider || !val)
      continue;
    const over = state.sampling[f.field];
    const v = over != null ? over : f.rec(state);
    slider.value = String(v);
    val.textContent = f.fmt(v);
    val.classList.toggle("auto", over == null);
  }
  for (const f of SAMP_ADV_FIELDS) {
    const slider = $(f.id), val = $(f.valId);
    if (!slider || !val)
      continue;
    const over = state.sampling[f.field];
    slider.value = String(over != null ? over : slider.min);
    val.textContent = over != null ? f.fmt(over) : "off";
    val.classList.toggle("auto", over == null);
  }
  const seedInput = $("samp-seed");
  if (seedInput)
    seedInput.value = state.sampling.seed != null ? String(state.sampling.seed) : "";
}
function onSlide(state, f, send) {
  const slider = $(f.id);
  if (!slider)
    return;
  const v = Number(slider.value);
  state.sampling[f.field] = v;
  const val = $(f.valId);
  if (val) {
    val.textContent = f.fmt(v);
    val.classList.remove("auto");
  }
  updateSamplingUi(state);
  pushSampling(state, send);
}
function onSeedInput(state, send) {
  const input = $("samp-seed");
  if (!input)
    return;
  const raw = input.value.trim();
  let seed = raw === "" ? null : Number(raw);
  if (seed != null && !Number.isFinite(seed))
    seed = null;
  state.sampling.seed = seed;
  updateSamplingUi(state);
  pushSampling(state, send);
}
function pushSampling(state, send) {
  send({ type: "set_sampling", ...state.sampling });
}
function updateSamplingUi(state) {
  const dirty = Object.values(state.sampling).some((v) => v != null);
  const pill = $("chat-sampling");
  if (pill) {
    pill.classList.toggle("dirty", dirty);
    pill.title = dirty ? "Sampling overridden — click to edit or reset" : "Sampling controls (temperature · top_p · top_k · Advanced)";
  }
}
function resetSampling(state, send) {
  for (const k of Object.keys(state.sampling))
    state.sampling[k] = null;
  refreshSamplingRecs(state);
  updateSamplingUi(state);
  pushSampling(state, send);
}
function initSampling(state, send) {
  const pill = $("chat-sampling"), pop = $("chat-sampling-pop");
  if (!pill || !pop)
    return;
  const trap = trapFocus(pop, () => pop.classList.contains("open"));
  const setOpen = (open) => {
    const was = pop.classList.contains("open");
    if (open === was)
      return;
    if (open)
      trap.capture();
    pop.classList.toggle("open", open);
    pill.classList.toggle("on", open);
    pill.setAttribute("aria-expanded", String(open));
    if (open)
      refreshSamplingRecs(state);
    else
      trap.restore();
  };
  setSamplingPopoverClose(() => setOpen(false));
  const toggle = () => setOpen(!pop.classList.contains("open"));
  pill.onclick = (e) => {
    e.stopPropagation();
    toggle();
  };
  pill.addEventListener("keydown", (e) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      toggle();
    }
  });
  pop.addEventListener("click", (e) => e.stopPropagation());
  document.addEventListener("click", () => setOpen(false));
  for (const f of SAMP_SLIDER_FIELDS) {
    const e = $(f.id);
    if (!e)
      continue;
    e.addEventListener("input", () => onSlide(state, f, send));
  }
  const seedInput = $("samp-seed");
  if (seedInput)
    seedInput.addEventListener("input", () => onSeedInput(state, send));
  const reset = $("samp-reset");
  if (reset)
    reset.onclick = (e) => {
      e.stopPropagation();
      resetSampling(state, send);
    };
  updateSamplingUi(state);
  refreshSamplingRecs(state);
}
var SYS_PROMPT_MAX = 4000;
var PRESETS_KEY = "mlxbun.presets";
function loadPresets() {
  try {
    const raw = localStorage.getItem(PRESETS_KEY);
    if (!raw)
      return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed))
      return [];
    return parsed.filter((p) => !!p && typeof p === "object" && typeof p.name === "string");
  } catch {
    return [];
  }
}
function savePresets(presets) {
  try {
    localStorage.setItem(PRESETS_KEY, JSON.stringify(presets));
  } catch {}
}
function presetFromState(name, state) {
  return { name, systemPrompt: state.systemPrompt, sampling: { ...state.sampling } };
}
function upsertPreset(presets, preset) {
  const i = presets.findIndex((p) => p.name === preset.name);
  if (i === -1)
    return [...presets, preset];
  const out = presets.slice();
  out[i] = preset;
  return out;
}
function removePreset(presets, name) {
  return presets.filter((p) => p.name !== name);
}
function applyPreset(state, preset, send) {
  state.systemPrompt = preset.systemPrompt ?? null;
  state.sampling = {
    temperature: null,
    top_p: null,
    top_k: null,
    min_p: null,
    xtc_probability: null,
    xtc_threshold: null,
    repetition_penalty: null,
    repetition_context_size: null,
    presence_penalty: null,
    frequency_penalty: null,
    seed: null,
    ...preset.sampling
  };
  refreshSystemPromptUi(state);
  pushSystemPrompt(state, send);
  refreshSamplingRecs(state);
  updateSamplingUi(state);
  pushSampling(state, send);
}
function pushSystemPrompt(state, send) {
  send({ type: "set_system_prompt", text: state.systemPrompt });
}
function refreshSystemPromptUi(state) {
  const ta = $("sysprompt-text");
  const count = $("sysprompt-count");
  const text = state.systemPrompt ?? "";
  if (ta && ta.value !== text)
    ta.value = text;
  if (count)
    count.textContent = text.length + " / " + SYS_PROMPT_MAX;
  const active = text.trim().length > 0;
  const pill = $("chat-sysprompt");
  if (pill) {
    pill.classList.toggle("dirty", active);
    pill.title = active ? "Custom system prompt active — click to edit or clear" : "System prompt (shapes how the assistant replies in this chat)";
  }
}
function onSystemPromptInput(state, send) {
  const ta = $("sysprompt-text");
  if (!ta)
    return;
  const text = ta.value.slice(0, SYS_PROMPT_MAX);
  if (text !== ta.value)
    ta.value = text;
  state.systemPrompt = text.length ? text : null;
  const count = $("sysprompt-count");
  if (count)
    count.textContent = text.length + " / " + SYS_PROMPT_MAX;
  const pill = $("chat-sysprompt");
  if (pill) {
    const active = text.trim().length > 0;
    pill.classList.toggle("dirty", active);
  }
  pushSystemPrompt(state, send);
}
function clearSystemPrompt(state, send) {
  state.systemPrompt = null;
  refreshSystemPromptUi(state);
  pushSystemPrompt(state, send);
}
function renderPresetOptionsHtml(presets) {
  return '<option value="">— presets —</option>' + presets.map((p) => `<option value="${escHtml2(p.name)}">${escHtml2(p.name)}</option>`).join("");
}
function renderPresetSelect() {
  const sel = $("sysprompt-preset-select");
  if (!sel)
    return;
  const cur = sel.value;
  sel.innerHTML = renderPresetOptionsHtml(loadPresets());
  if (cur && [...sel.options].some((o) => o.value === cur))
    sel.value = cur;
}
function initSystemPrompt(state, send) {
  const pill = $("chat-sysprompt"), pop = $("chat-sysprompt-pop");
  if (!pill || !pop)
    return;
  const trap = trapFocus(pop, () => pop.classList.contains("open"));
  const setOpen = (open) => {
    const was = pop.classList.contains("open");
    if (open === was)
      return;
    if (open)
      trap.capture();
    pop.classList.toggle("open", open);
    pill.classList.toggle("on", open);
    pill.setAttribute("aria-expanded", String(open));
    if (open) {
      refreshSystemPromptUi(state);
      renderPresetSelect();
    } else
      trap.restore();
  };
  setSysPromptPopoverClose(() => setOpen(false));
  const toggle = () => setOpen(!pop.classList.contains("open"));
  pill.onclick = (e) => {
    e.stopPropagation();
    toggle();
  };
  pill.addEventListener("keydown", (e) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      toggle();
    }
  });
  pop.addEventListener("click", (e) => e.stopPropagation());
  document.addEventListener("click", () => setOpen(false));
  const ta = $("sysprompt-text");
  if (ta)
    ta.addEventListener("input", () => onSystemPromptInput(state, send));
  const clearBtn = $("sysprompt-clear");
  if (clearBtn)
    clearBtn.onclick = (e) => {
      e.stopPropagation();
      clearSystemPrompt(state, send);
    };
  const presetSelect = $("sysprompt-preset-select");
  if (presetSelect)
    presetSelect.addEventListener("change", (e) => {
      e.stopPropagation();
      const name = presetSelect.value;
      if (!name)
        return;
      const preset = loadPresets().find((p) => p.name === name);
      if (preset) {
        applyPreset(state, preset, send);
        toast('Applied preset "' + name + '"', "ok");
      }
    });
  const saveBtn = $("sysprompt-preset-save");
  if (saveBtn)
    saveBtn.onclick = (e) => {
      e.stopPropagation();
      const name = (window.prompt("Save current system prompt + sampling as a preset named:") || "").trim();
      if (!name)
        return;
      const presets = upsertPreset(loadPresets(), presetFromState(name, state));
      savePresets(presets);
      renderPresetSelect();
      if (presetSelect)
        presetSelect.value = name;
      toast('Saved preset "' + name + '"', "ok");
    };
  const delBtn = $("sysprompt-preset-delete");
  if (delBtn)
    delBtn.onclick = (e) => {
      e.stopPropagation();
      const name = presetSelect?.value;
      if (!name) {
        toast("Select a preset to delete first", "err");
        return;
      }
      savePresets(removePreset(loadPresets(), name));
      renderPresetSelect();
      toast('Deleted preset "' + name + '"', "ok");
    };
  refreshSystemPromptUi(state);
}
function fmtTok(n) {
  if (n == null)
    return "—";
  if (n >= 1e6)
    return (n / 1e6).toFixed(1) + "M";
  if (n >= 1000)
    return (n / 1000).toFixed(n >= 1e4 ? 0 : 1) + "k";
  return String(n);
}
function renderContext(m) {
  const node = $("pf-fill");
  if (!node || !m.contextWindow)
    return;
  const pct = m.percent;
  const pctStr = pct == null ? "" : " (" + Math.round(pct) + "%)";
  node.textContent = "ctx " + fmtTok(m.tokens) + "/" + fmtTok(m.contextWindow) + pctStr;
  node.style.color = pct == null ? "var(--dimmer)" : pct >= 85 ? "var(--orange)" : pct >= 70 ? "var(--yellow)" : "var(--dimmer)";
}
var LANE_LABEL = { serial: "serial", "serial+spec": "spec-decode active", batched: "batched" };
var LANE_CLASS = { serial: "serial", "serial+spec": "spec", batched: "batched" };
function renderLane(lane) {
  const laneEl = $("pf-lane"), label = $("pf-lane-label");
  if (!laneEl || !label)
    return;
  if (!lane) {
    laneEl.style.display = "none";
    return;
  }
  laneEl.className = "pf-lane " + (LANE_CLASS[lane] || "");
  label.textContent = LANE_LABEL[lane] || lane;
  laneEl.style.display = "inline-flex";
}
function detectMentionQuery(text, caret) {
  if (caret < 0 || caret > text.length)
    return null;
  let i = caret - 1;
  while (i >= 0) {
    const ch = text[i];
    if (ch === "#") {
      const before = i > 0 ? text[i - 1] : "";
      if (/[A-Za-z0-9_]/.test(before))
        return null;
      return { hashIndex: i, query: text.slice(i + 1, caret) };
    }
    if (/\s/.test(ch))
      return null;
    i--;
  }
  return null;
}
var MAX_MENTION_FILE_RESULTS = 6;
var MAX_MENTION_ARTICLE_RESULTS = 8;
function filterFileMentions(attachments, query) {
  const q = query.trim().toLowerCase();
  const matches = attachments.filter((a) => !q || a.name.toLowerCase().includes(q));
  return matches.slice(0, MAX_MENTION_FILE_RESULTS).map((a) => ({ kind: "file", id: a.id, name: a.name }));
}
function buildMentionItems(fileMatches, articleNames) {
  const articles = articleNames.slice(0, MAX_MENTION_ARTICLE_RESULTS).map((name) => ({ kind: "article", name }));
  return [...fileMatches, ...articles];
}
function applyMention(text, q, item, caret) {
  const insertion = item.kind === "article" ? "[[" + item.name + "]] " : "";
  const before = text.slice(0, q.hashIndex);
  const after = text.slice(caret);
  const newText = before + insertion + after;
  return { text: newText, caret: before.length + insertion.length };
}
function escMention(s) {
  return escHtml2(s);
}
function renderMentionListHtml(items, selected, memoryEnabled) {
  if (!items.length) {
    return '<div class="mention-empty">' + (memoryEnabled ? "No matching files or memory articles." : "No matching attached files.") + "</div>";
  }
  let filesHtml = "", articlesHtml = "";
  items.forEach((item, i) => {
    const active = i === selected ? " active" : "";
    const row = item.kind === "file" ? '<div class="mention-row' + active + '" data-idx="' + i + '" role="option">' + '<span class="mention-ico" aria-hidden="true">\uD83D\uDCC4</span>' + '<span class="mention-label">' + escMention(item.name) + "</span>" + '<span class="mention-tag">attached</span></div>' : '<div class="mention-row' + active + '" data-idx="' + i + '" role="option">' + '<span class="mention-ico" aria-hidden="true">◆</span>' + '<span class="mention-label">' + escMention(item.name.replace(/_/g, " ")) + "</span>" + '<span class="mention-tag">memory</span></div>';
    if (item.kind === "file")
      filesHtml += row;
    else
      articlesHtml += row;
  });
  const sections = [];
  if (filesHtml)
    sections.push('<div class="mention-sec-title">Attached files</div>' + filesHtml);
  if (articlesHtml)
    sections.push('<div class="mention-sec-title">Memory</div>' + articlesHtml);
  return sections.join("");
}
function initMentionPicker(state, box, opts) {
  const pop = $("chat-mention-pop");
  if (!pop)
    return;
  let items = [];
  let selected = 0;
  let activeQuery = null;
  let memoryEnabled = true;
  let debounce;
  let searchSeq = 0;
  function render() {
    pop.innerHTML = renderMentionListHtml(items, selected, memoryEnabled);
    pop.querySelectorAll(".mention-row").forEach((row) => {
      row.addEventListener("mousedown", (e) => {
        e.preventDefault();
        const idx = Number(row.dataset.idx);
        if (Number.isFinite(idx))
          select(idx);
      });
    });
  }
  function close() {
    pop.classList.remove("open");
    activeQuery = null;
    items = [];
    selected = 0;
  }
  function select(idx) {
    const item = items[idx];
    if (!item || !activeQuery) {
      close();
      return;
    }
    if (item.kind === "file") {
      const att = state.attachments.find((a) => a.id === item.id);
      const q = activeQuery;
      const before = box.value.slice(0, q.hashIndex);
      const after = box.value.slice(box.selectionStart ?? box.value.length);
      box.value = before + after;
      box.selectionStart = box.selectionEnd = before.length;
      if (att)
        opts.onFileSelected(att);
    } else {
      const q = activeQuery;
      const caret = box.selectionStart ?? box.value.length;
      const result = applyMention(box.value, q, item, caret);
      box.value = result.text;
      box.selectionStart = box.selectionEnd = result.caret;
    }
    close();
    box.focus();
    box.dispatchEvent(new Event("input"));
  }
  async function runSearch(query) {
    const seq = ++searchSeq;
    if (!query.trim()) {
      updateItems([]);
      return;
    }
    try {
      const d = await api("/api/memory/search?q=" + encodeURIComponent(query));
      if (seq !== searchSeq)
        return;
      if (d.enabled === false) {
        memoryEnabled = false;
        updateItems([]);
        return;
      }
      if (d.ok === false) {
        updateItems([]);
        return;
      }
      updateItems((d.summaries || []).map((s) => s.article));
    } catch {
      if (seq !== searchSeq)
        return;
      updateItems([]);
    }
  }
  function updateItems(articleNames) {
    if (!activeQuery)
      return;
    const fileMatches = filterFileMentions(state.attachments, activeQuery.query);
    items = buildMentionItems(fileMatches, articleNames);
    selected = 0;
    render();
  }
  function openFor(q) {
    activeQuery = q;
    pop.classList.add("open");
    const fileMatches = filterFileMentions(state.attachments, q.query);
    items = buildMentionItems(fileMatches, []);
    selected = 0;
    render();
    clearTimeout(debounce);
    debounce = setTimeout(() => runSearch(q.query), 180);
  }
  box.addEventListener("input", () => {
    const caret = box.selectionStart ?? box.value.length;
    const q = detectMentionQuery(box.value, caret);
    if (!q) {
      close();
      return;
    }
    if (!activeQuery || activeQuery.hashIndex !== q.hashIndex) {
      openFor(q);
      return;
    }
    activeQuery = q;
    const fileMatches = filterFileMentions(state.attachments, q.query);
    items = buildMentionItems(fileMatches, items.filter((i) => i.kind === "article").map((i) => i.name));
    selected = 0;
    render();
    clearTimeout(debounce);
    debounce = setTimeout(() => runSearch(q.query), 180);
  });
  box.addEventListener("keydown", (e) => {
    if (!pop.classList.contains("open") || !items.length)
      return;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      selected = Math.min(selected + 1, items.length - 1);
      render();
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      selected = Math.max(selected - 1, 0);
      render();
    } else if (e.key === "Enter" || e.key === "Tab") {
      e.preventDefault();
      select(selected);
    } else if (e.key === "Escape") {
      e.preventDefault();
      close();
    }
  });
  box.addEventListener("blur", () => {
    setTimeout(() => {
      if (document.activeElement !== box)
        close();
    }, 120);
  });
}
function renderQueue(q) {
  const bar = $("chat-queue");
  const parts = [];
  const steering = q.steering || [];
  if (steering.length)
    parts.push('<span class="qtag">steering: <b>' + escHtml2(String(steering[steering.length - 1]).slice(0, 60)) + "</b></span>");
  for (const f of q.followUp || [])
    parts.push('<span class="qtag">queued: <b>' + escHtml2(String(f).slice(0, 60)) + "</b></span>");
  bar.innerHTML = parts.join("");
  bar.style.display = parts.length ? "flex" : "none";
}

// src/web/src/sessions.ts
function newSidebarState() {
  return { lastSessionItems: [] };
}
function relTime(ms) {
  if (!ms)
    return "";
  const s = (Date.now() - ms) / 1000;
  if (s < 60)
    return "just now";
  if (s < 3600)
    return Math.floor(s / 60) + "m ago";
  if (s < 86400)
    return Math.floor(s / 3600) + "h ago";
  if (s < 604800)
    return Math.floor(s / 86400) + "d ago";
  try {
    return new Date(ms).toLocaleDateString();
  } catch {
    return "";
  }
}
function esc2(s) {
  return String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
}
function renderSessions(state, items, activePath, cb) {
  state.lastSessionItems = items || [];
  const box = $("chat-sessions");
  if (!items || !items.length) {
    box.innerHTML = '<div class="sessempty">No saved chats yet. Your conversations are saved locally here.</div>';
    return;
  }
  box.innerHTML = "";
  for (const s of items) {
    const row = el("div", "sess" + (s.path === activePath ? " active" : ""), box);
    row.dataset.title = (s.title || "New chat").toLowerCase();
    row.innerHTML = '<div class="stitle">' + esc2(s.title || "New chat") + "</div>" + '<div class="smeta"><span>' + esc2(relTime(s.modified)) + "</span>" + (s.messageCount ? "<span>· " + s.messageCount + " msg" + (s.messageCount === 1 ? "" : "s") + "</span>" : "") + (s.forked ? "<span>· forked</span>" : "") + "</div>" + '<button class="sbtn sfork" title="New chat from here">⑂</button>' + '<button class="sbtn sdel" title="Delete chat">✕</button>';
    row.addEventListener("click", () => {
      cb.onOpen(s.path);
    });
    row.querySelector(".sfork").addEventListener("click", (e) => {
      e.stopPropagation();
      cb.onFork(s.path);
    });
    row.querySelector(".sdel").addEventListener("click", (e) => {
      e.stopPropagation();
      cb.onDelete(s.path);
    });
  }
  applySessSearch(state);
}
function applySessSearch(state) {
  const input = $("chat-sess-search");
  const q = input ? input.value.trim().toLowerCase() : "";
  const rows = $("chat-sessions").querySelectorAll(".sess");
  let anyVisible = false;
  rows.forEach((row) => {
    const match = !q || (row.dataset.title || "").includes(q);
    row.classList.toggle("sess-hidden", !match);
    if (match)
      anyVisible = true;
  });
  let empty = $("chat-sessions").querySelector(".sess-search-empty");
  if (q && !anyVisible && state.lastSessionItems.length) {
    if (!empty) {
      empty = el("div", "sessempty sess-search-empty", $("chat-sessions"));
    }
    empty.textContent = "No chats match “" + q + "”.";
  } else if (empty) {
    empty.remove();
  }
}
function newSiblingInfo() {
  return { entryId: null, index: 0, count: 0, siblingIds: [] };
}
function addMsgActions(m, text, opts, handlers) {
  const row = el("div", "msg-actions", m);
  const copyBtn = el("button", "maction", row);
  copyBtn.type = "button";
  copyBtn.textContent = "Copy";
  copyBtn.addEventListener("click", () => {
    if (!navigator.clipboard)
      return;
    navigator.clipboard.writeText(text || "").then(() => {
      copyBtn.textContent = "Copied";
      setTimeout(() => {
        copyBtn.textContent = "Copy";
      }, 1200);
    }).catch(() => {});
  });
  if (opts.regenerate) {
    const btn = el("button", "maction", row);
    btn.type = "button";
    btn.textContent = "Regenerate";
    btn.title = "Re-run this reply (keeps the old one on disk as a branch)";
    btn.addEventListener("click", () => {
      handlers.onRegenerate && handlers.onRegenerate();
    });
  }
  if (opts.edit) {
    const btn = el("button", "maction", row);
    btn.type = "button";
    btn.textContent = "Edit";
    btn.title = "Edit and resend — keeps the original as a numbered branch";
    btn.addEventListener("click", () => {
      handlers.onEdit && handlers.onEdit(m);
    });
  }
  return row;
}
function renderSiblingToggle(lastUserMsgEl, lastUserEntryId, siblingInfo, onSwitch) {
  if (!lastUserMsgEl)
    return;
  let box = lastUserMsgEl.querySelector(".sib-toggle");
  if (siblingInfo.count <= 1 || siblingInfo.entryId !== lastUserEntryId) {
    if (box)
      box.remove();
    return;
  }
  if (!box) {
    box = el("div", "sib-toggle", null);
    lastUserMsgEl.insertBefore(box, lastUserMsgEl.firstChild);
  }
  const { index, count } = siblingInfo;
  box.innerHTML = '<button class="sib-prev" type="button" ' + (index <= 1 ? "disabled" : "") + ">&lt;</button>" + "<span>" + index + "/" + count + "</span>" + '<button class="sib-next" type="button" ' + (index >= count ? "disabled" : "") + ">&gt;</button>";
  box.querySelector(".sib-prev").addEventListener("click", () => onSwitch(-1));
  box.querySelector(".sib-next").addEventListener("click", () => onSwitch(1));
}
function switchSiblingTarget(siblingInfo, delta) {
  const ids = siblingInfo.siblingIds || [];
  return ids[siblingInfo.index - 1 + delta] ?? null;
}

// src/web/src/adapters-panel.ts
function fmtBytes(n) {
  if (n == null)
    return "—";
  if (n >= 2 ** 20)
    return (n / 2 ** 20).toFixed(1) + " MB";
  if (n >= 2 ** 10)
    return (n / 2 ** 10).toFixed(1) + " KB";
  return n + " B";
}

class AdaptersPanelState {
  available = [];
  mounted = new Map;
  selectedSpec = null;
  stackPicks = new Set;
}
var trap = null;
async function refreshAdaptersPanel(state, send) {
  const [availD, mountedD] = await Promise.all([
    api("/v1/adapters/available").catch(() => ({ ok: false })),
    api("/v1/adapters").catch(() => ({ ok: false }))
  ]);
  state.available = availD.adapters || [];
  const mountedList = mountedD.adapters || [];
  state.mounted = new Map(mountedList.map((a) => [a.id, a]));
  for (const id of [...state.stackPicks])
    if (!state.available.some((a) => a.id === id))
      state.stackPicks.delete(id);
  renderAdaptersBody(state, send);
}
function selectedIds(state) {
  const spec = state.selectedSpec;
  if (!spec)
    return new Set;
  return new Set(spec.split("+").map((s) => s.trim()).filter(Boolean));
}
function renderAdapterRow(a, opts) {
  const { mountedInfo, isSelected, stackPicked, stackModeOn } = opts;
  const rowClasses = ["ad-row"];
  if (!a.compatible)
    rowClasses.push("incompatible");
  if (isSelected)
    rowClasses.push("selected");
  const badges = [];
  if (mountedInfo)
    badges.push('<span class="ad-badge mounted">mounted</span>');
  if (isSelected)
    badges.push('<span class="ad-badge selected">selected</span>');
  const meta = [];
  if (a.base_model)
    meta.push("base <b>" + esc(a.base_model.split("/").pop()) + "</b>");
  if (a.rank)
    meta.push("rank <b>" + esc(a.rank) + "</b>");
  meta.push("disk <b>" + esc(fmtBytes(mountedInfo ? mountedInfo.size_bytes : null) === "—" ? "—" : fmtBytes(mountedInfo ? mountedInfo.size_bytes : null)) + "</b>");
  if (mountedInfo)
    meta.push("RAM <b>" + esc(fmtBytes(mountedInfo.ram_bytes)) + "</b>");
  const why = !a.compatible ? '<div class="ad-why">' + (a.base_model ? "trained for " + esc(a.base_model) + ", not the currently-served model" : "not compatible with the currently-served model") + "</div>" : "";
  const actions = [];
  if (a.compatible) {
    if (stackModeOn) {
      actions.push('<label class="ad-stack-chk"><input type="checkbox" class="ad-stack-pick" data-id="' + esc(a.id) + '"' + (stackPicked ? " checked" : "") + (!mountedInfo ? ' disabled title="mount first to stack it"' : "") + "> stack</label>");
    }
    if (!mountedInfo) {
      actions.push('<button type="button" class="ad-mount" data-id="' + esc(a.id) + '" data-path="' + esc(a.path) + '">Mount</button>');
    } else if (!isSelected) {
      actions.push('<button type="button" class="ad-select primary" data-id="' + esc(a.id) + '">Select</button>');
    } else {
      actions.push('<button type="button" class="ad-unselect" data-id="' + esc(a.id) + '">Unselect</button>');
    }
  }
  return '<div class="' + rowClasses.join(" ") + '" data-adapter-row="' + esc(a.id) + '">' + '<div class="ad-row-main">' + '<div class="ad-row-head"><span class="ad-row-id" title="' + esc(a.id) + '">' + esc(a.id) + "</span>" + badges.join("") + "</div>" + '<div class="ad-meta">' + meta.join(" · ") + "</div>" + why + "</div>" + '<div class="ad-actions">' + actions.join("") + "</div>" + "</div>";
}
function renderAdaptersBodyHtml(state) {
  if (!state.available.length) {
    return '<div class="ad-empty">No adapters found on disk yet.<br>' + "Fine-tune one in the Developer tab, or drop an adapter directory into " + "<code>~/.cache/mlx-bun/adapters</code>.</div>";
  }
  const selected = selectedIds(state);
  const stackModeOn = state.stackPicks.size > 0 || selected.size > 1;
  const rows = state.available.map((a) => renderAdapterRow(a, {
    mountedInfo: state.mounted.get(a.id),
    isSelected: selected.has(a.id),
    stackPicked: state.stackPicks.has(a.id),
    stackModeOn
  })).join("");
  const picks = [...state.stackPicks];
  const stackBar = picks.length ? '<div class="ad-stack-bar"><span class="lbl">Stack:</span><span class="expr">' + esc(picks.join(" + ")) + '</span><button type="button" id="ad-stack-apply" class="ad-actions-btn">Apply</button>' + '<button type="button" id="ad-stack-clear" class="ad-actions-btn">Clear</button></div>' : "";
  return '<div class="ad-note">Every adapter found on disk, mounted or not. Mounting loads it into ' + "memory (RAM cost shown once mounted); selecting makes it active for this chat's next turn " + "(a fresh KV segment). Tick two mounted adapters' “stack” boxes to compose them as " + "<code>a+b</code> — the server already supports it end to end.</div>" + stackBar + '<div class="ad-sec-title">On disk (' + state.available.length + ")</div>" + rows;
}
function renderAdaptersBody(state, send) {
  const body = $("adapters-body");
  if (!body)
    return;
  body.innerHTML = renderAdaptersBodyHtml(state);
  wireRowActions(state, send);
}
function wireRowActions(state, send) {
  const body = $("adapters-body");
  if (!body)
    return;
  body.querySelectorAll(".ad-mount").forEach((btn) => {
    btn.onclick = async () => {
      const id = btn.dataset.id, path = btn.dataset.path;
      btn.disabled = true;
      btn.textContent = "Mounting…";
      const r = await api("/v1/adapters", { method: "POST", body: { id, path } });
      if (r && (r.error || r.ok === false)) {
        toast("adapter: " + (r.error || "mount failed"), "err");
        btn.disabled = false;
        btn.textContent = "Mount";
        return;
      }
      toast("mounted " + id, "ok");
      await refreshAdaptersPanel(state, send);
    };
  });
  body.querySelectorAll(".ad-select").forEach((btn) => {
    btn.onclick = () => {
      const id = btn.dataset.id;
      state.selectedSpec = id;
      state.stackPicks.clear();
      send({ type: "set_adapter", id });
      const sel = $("chat-adapter");
      if (sel && [...sel.options].some((o) => o.value === id))
        sel.value = id;
      toast("adapter selected — new turns start a fresh KV segment", "ok");
      renderAdaptersBody(state, send);
    };
  });
  body.querySelectorAll(".ad-unselect").forEach((btn) => {
    btn.onclick = () => {
      state.selectedSpec = null;
      send({ type: "set_adapter", id: null });
      const sel = $("chat-adapter");
      if (sel)
        sel.value = "";
      renderAdaptersBody(state, send);
    };
  });
  body.querySelectorAll(".ad-stack-pick").forEach((chk) => {
    chk.onchange = () => {
      const id = chk.dataset.id;
      if (chk.checked)
        state.stackPicks.add(id);
      else
        state.stackPicks.delete(id);
      renderAdaptersBody(state, send);
    };
  });
  const apply = $("ad-stack-apply");
  if (apply)
    apply.onclick = () => {
      if (state.stackPicks.size < 2) {
        toast("stack needs at least two ticked adapters", "err");
        return;
      }
      const spec = [...state.stackPicks].join("+");
      state.selectedSpec = spec;
      send({ type: "set_adapter", id: spec });
      const sel = $("chat-adapter");
      if (sel)
        sel.value = "";
      toast("stacked " + spec + " — new turns start a fresh KV segment", "ok");
      renderAdaptersBody(state, send);
    };
  const clear = $("ad-stack-clear");
  if (clear)
    clear.onclick = () => {
      state.stackPicks.clear();
      renderAdaptersBody(state, send);
    };
}
function openPanel(state, send) {
  const ov = $("adapters-overlay");
  ov.classList.add("open");
  $("adapters-manage").setAttribute("aria-expanded", "true");
  if (trap)
    trap.capture();
  refreshAdaptersPanel(state, send);
}
function closeAdaptersPanel() {
  $("adapters-overlay").classList.remove("open");
  $("adapters-manage").setAttribute("aria-expanded", "false");
  if (trap)
    trap.restore();
}
function initAdaptersPanel(state, send) {
  const btn = $("adapters-manage");
  if (!btn)
    return;
  trap = trapFocus($("adapters-panel"), () => $("adapters-overlay").classList.contains("open"));
  btn.onclick = () => openPanel(state, send);
  const close = $("adapters-close");
  if (close)
    close.onclick = closeAdaptersPanel;
  $("adapters-overlay").addEventListener("click", (e) => {
    if (e.target === $("adapters-overlay"))
      closeAdaptersPanel();
  });
  setAdaptersPanelClose(closeAdaptersPanel);
}

// src/web/src/memory-panel.ts
async function getJson(path) {
  return api(path);
}
var cachedStatus = null;
async function fetchStatus(force = false) {
  if (cachedStatus && !force)
    return cachedStatus;
  const d = await getJson("/api/memory/status").catch(() => ({ ok: false, enabled: false }));
  cachedStatus = d;
  return d;
}
var panelTrap;
var currentView = { kind: "list" };
function isMemPanelOpen() {
  const ov = $("mem-overlay");
  return !!ov && ov.classList.contains("open");
}
function closeMemPanel() {
  $("mem-overlay").classList.remove("open");
  $("chat-memory-entry").setAttribute("aria-expanded", "false");
  panelTrap.restore();
}
async function openMemPanel(articleName) {
  panelTrap.capture();
  $("mem-overlay").classList.add("open");
  $("chat-memory-entry").setAttribute("aria-expanded", "true");
  if (articleName)
    await showArticle(articleName);
  else
    await showList();
  setTimeout(() => {
    const s = $("mem-search");
    if (s)
      s.focus();
  }, 30);
}
function setBack(show) {
  $("mem-back").classList.toggle("show", show);
}
function relDate(ms) {
  if (!ms)
    return "—";
  const days = (Date.now() - ms) / 86400000;
  if (days < 1)
    return "today";
  if (days < 2)
    return "yesterday";
  if (days < 30)
    return Math.floor(days) + "d ago";
  try {
    return new Date(ms).toLocaleDateString();
  } catch {
    return "—";
  }
}
function renderStatusStrip(st) {
  const lastArticle = st.recentArticles[0];
  $("mem-status").innerHTML = '<span class="mem-stat"><b>' + st.articleCount + "</b> article" + (st.articleCount === 1 ? "" : "s") + "</span>" + '<span class="mem-stat">last touched <b>' + esc(relDate(lastArticle && lastArticle.mtimeMs)) + "</b></span>" + '<span class="mem-stat">' + (st.isGitRepo ? "git-tracked" : "not a git repo") + "</span>";
}
function emptyVaultHtml(root) {
  return '<div class="mem-empty">' + "<p>No memory vault yet at <code>" + esc(root) + "</code>.</p>" + '<p style="margin-top:8px">Memory is a local, git-tracked wiki the assistant reads from (never writes to during chat) — nightly synthesis is what updates it.</p>' + '<div class="mcta"><button class="btn primary sm" id="mem-empty-init">Set up memory</button></div>' + "</div>";
}
function articleRowHtml(name, excerpt, icon = "\uD83D\uDCC4") {
  const display = name.startsWith("Reference/") ? name.slice("Reference/".length) : name;
  return '<div class="mem-art" data-article="' + esc(name) + '" tabindex="0" role="button">' + '<span class="mem-art-ico" aria-hidden="true">' + esc(icon) + "</span>" + '<div style="min-width:0;flex:1 1 auto">' + '<div class="mem-art-name">' + esc(display.replace(/_/g, " ")) + "</div>" + (excerpt ? '<div class="mem-art-excerpt">' + esc(excerpt) + "</div>" : "") + "</div></div>";
}
function wireArticleRows(container) {
  container.querySelectorAll(".mem-art").forEach((row) => {
    const open = () => {
      const name = row.dataset.article;
      if (name)
        showArticle(name);
    };
    row.addEventListener("click", open);
    row.addEventListener("keydown", (e) => {
      if (e.key === "Enter")
        open();
    });
  });
}
async function renderListBody() {
  const body = $("mem-body");
  const st = await fetchStatus();
  if (!st.enabled || !st.status) {
    body.innerHTML = emptyVaultHtml(st.root || "~/.mlx-bun/wiki");
    const btn = $("mem-empty-init");
    if (btn)
      btn.onclick = () => runInit(body);
    return;
  }
  renderStatusStrip(st.status);
  body.innerHTML = '<input type="search" id="mem-search" placeholder="Search articles…" aria-label="Search memory" autocomplete="off">' + '<div id="mem-list"></div>';
  await renderArticleLists("");
  const search = $("mem-search");
  let debounce;
  search.addEventListener("input", () => {
    clearTimeout(debounce);
    debounce = setTimeout(() => renderArticleLists(search.value.trim()), 180);
  });
}
async function renderArticleLists(query) {
  const listEl = $("mem-list");
  if (!query) {
    const d2 = await getJson("/api/memory/list").catch(() => ({ ok: false }));
    if (!d2.ok) {
      listEl.innerHTML = `<div class="mem-list-empty">Couldn't load the vault contents.</div>`;
      return;
    }
    const articles = d2.articles || [], reference = d2.reference || [];
    listEl.innerHTML = '<div class="mem-sec"><div class="mem-sec-title">Articles</div>' + (articles.length ? articles.map((a) => articleRowHtml(a)).join("") : '<div class="mem-list-empty">No articles yet — nightly synthesis writes here after a few conversations.</div>') + "</div>" + (reference.length ? '<div class="mem-sec"><div class="mem-sec-title">Reference</div>' + reference.map((r) => articleRowHtml(r, undefined, "\uD83D\uDCD8")).join("") + "</div>" : "");
    wireArticleRows(listEl);
    return;
  }
  const d = await getJson("/api/memory/search?q=" + encodeURIComponent(query)).catch(() => ({ ok: false }));
  if (!d.ok || !d.summaries || !d.summaries.length) {
    listEl.innerHTML = '<div class="mem-list-empty">No matches for “' + esc(query) + "”.</div>";
    return;
  }
  const hitsByArticle = new Map;
  for (const h of d.hits || [])
    if (!hitsByArticle.has(h.article))
      hitsByArticle.set(h.article, h);
  listEl.innerHTML = '<div class="mem-sec"><div class="mem-sec-title">' + d.summaries.length + " match" + (d.summaries.length === 1 ? "" : "es") + "</div>" + d.summaries.map((s) => articleRowHtml(s.article, hitsByArticle.get(s.article)?.excerpt, s.article.startsWith("Reference/") ? "\uD83D\uDCD8" : "\uD83D\uDCC4")).join("") + "</div>";
  wireArticleRows(listEl);
}
async function runInit(body) {
  body.innerHTML = '<div class="mem-empty"><p><span class="shimmer">setting up your local memory vault…</span></p></div>';
  const d = await api("/api/memory/init", { method: "POST" }).catch(() => ({ ok: false, error: "request failed" }));
  if (!d.ok) {
    toast("Couldn't set up memory: " + (d.error || "unknown error"), "err");
    cachedStatus = null;
    await renderListBody();
    return;
  }
  toast("Memory vault created", "ok");
  cachedStatus = null;
  await refreshSidebarEntry();
  await showList();
}
async function showList() {
  currentView = { kind: "list" };
  setBack(false);
  $("mem-title").textContent = "Memory";
  $("mem-body").scrollTop = 0;
  await renderListBody();
}
function linksLineHtml(outbound, inbound) {
  if (!outbound.length && !inbound.length)
    return "";
  const row = (label, names) => names.length ? '<div class="mem-links-row"><span class="lbl">' + label + "</span>" + names.map((n) => '<button class="mem-link-chip" type="button" data-article="' + esc(n) + '">' + esc(n.replace(/_/g, " ")) + "</button>").join("") + "</div>" : "";
  return '<div class="mem-links">' + row("links to", outbound) + row("linked from", inbound) + "</div>";
}
function wireLinkChips(container) {
  container.querySelectorAll(".mem-link-chip").forEach((btn) => {
    btn.addEventListener("click", () => {
      const name = btn.dataset.article;
      if (name)
        showArticle(name);
    });
  });
}
async function showArticle(name) {
  currentView = { kind: "article", name };
  setBack(true);
  const display = name.startsWith("Reference/") ? name.slice("Reference/".length) : name;
  $("mem-title").textContent = display.replace(/_/g, " ");
  const body = $("mem-body");
  body.innerHTML = '<p class="mem-list-empty"><span class="shimmer">loading article…</span></p>';
  body.scrollTop = 0;
  const [artRes, linksRes] = await Promise.all([
    getJson("/api/memory/article?name=" + encodeURIComponent(name)).catch(() => ({ ok: false })),
    getJson("/api/memory/links?name=" + encodeURIComponent(name)).catch(() => ({ ok: false }))
  ]);
  if (!artRes.ok || artRes.content == null) {
    body.innerHTML = `<div class="mem-list-empty">Couldn't load “` + esc(display) + "”.</div>";
    return;
  }
  body.innerHTML = '<div class="mem-art-head">' + '<div class="mem-art-tabs">' + '<button class="mem-art-tab active" id="mem-tab-view" type="button">Article</button>' + '<button class="mem-art-tab" id="mem-tab-history" type="button">History</button>' + "</div></div>" + '<div id="mem-art-view">' + '<div class="mem-article-render">' + mdToHtml(artRes.content) + "</div>" + linksLineHtml(linksRes.outbound || [], linksRes.inbound || []) + "</div>" + '<div id="mem-art-history" style="display:none"></div>';
  wireLinkChips(body);
  $("mem-tab-view").onclick = () => switchArticleTab("view");
  $("mem-tab-history").onclick = () => switchArticleTab("history", name);
}
async function switchArticleTab(tab, name) {
  $("mem-tab-view").classList.toggle("active", tab === "view");
  $("mem-tab-history").classList.toggle("active", tab === "history");
  $("mem-art-view").style.display = tab === "view" ? "" : "none";
  $("mem-art-history").style.display = tab === "history" ? "" : "none";
  if (tab === "history" && name)
    await renderHistoryPane(name);
}
async function renderHistoryPane(name) {
  const pane = $("mem-art-history");
  if (pane.dataset.loaded === name)
    return;
  pane.innerHTML = '<p class="mem-list-empty"><span class="shimmer">loading history…</span></p>';
  const d = await getJson("/api/memory/history?name=" + encodeURIComponent(name)).catch(() => ({ ok: false }));
  if (!d.ok || !d.entries) {
    pane.innerHTML = '<div class="mem-list-empty">No history available (not a git-tracked vault, or nothing committed yet).</div>';
    return;
  }
  if (!d.entries.length) {
    pane.innerHTML = '<div class="mem-list-empty">No commits touch this article yet.</div>';
    return;
  }
  pane.dataset.loaded = name;
  pane.innerHTML = d.entries.map((e) => '<div class="mem-hist-entry" data-hash="' + esc(e.hash) + '" tabindex="0" role="button">' + '<span class="mem-hist-subject">' + esc(e.subject || "(no subject)") + "</span>" + '<span class="mem-hist-date">' + esc(e.date) + "</span>" + '<span class="mem-hist-hash">' + esc(e.hash.slice(0, 7)) + "</span>" + "</div>").join("") + '<div class="mem-diff" id="mem-diff-body" style="display:none"></div>';
  pane.querySelectorAll(".mem-hist-entry").forEach((row) => {
    const open = async () => {
      pane.querySelectorAll(".mem-hist-entry").forEach((r) => r.classList.remove("active"));
      row.classList.add("active");
      const hash = row.dataset.hash;
      const diffEl = $("mem-diff-body");
      diffEl.style.display = "";
      diffEl.textContent = "loading diff…";
      const dr = await getJson("/api/memory/diff?name=" + encodeURIComponent(name) + "&rev=" + encodeURIComponent(hash)).catch(() => ({ ok: false }));
      diffEl.innerHTML = dr.ok && dr.diff ? diffToHtml(dr.diff) : `<span class="diffctx">Couldn't load this diff.</span>`;
    };
    row.addEventListener("click", open);
    row.addEventListener("keydown", (e) => {
      if (e.key === "Enter")
        open();
    });
  });
}
function diffToHtml(diff) {
  return diff.split(`
`).map((line) => {
    if (line.startsWith("+++") || line.startsWith("---"))
      return '<span class="diffctx">' + esc(line) + "</span>";
    if (line.startsWith("@@"))
      return '<span class="diffhunk">' + esc(line) + "</span>";
    if (line.startsWith("+"))
      return '<span class="diffadd">' + esc(line) + "</span>";
    if (line.startsWith("-"))
      return '<span class="diffdel">' + esc(line) + "</span>";
    return '<span class="diffctx">' + esc(line) + "</span>";
  }).join(`
`);
}
async function refreshSidebarEntry() {
  const st = await fetchStatus(true);
  const entry = $("chat-memory-entry");
  if (!st.ok || !st.enabled || !st.status) {
    entry.style.display = "";
    $("chat-memory-count").textContent = "set up";
    return;
  }
  entry.style.display = "";
  $("chat-memory-count").textContent = String(st.status.articleCount);
}
var MEMORY_CHIP_TOOL_NAMES = [
  "memory_resolve",
  "memory_category",
  "memory_read",
  "memory_section",
  "memory_links",
  "memory_infobox",
  "memory_list",
  "memory_status",
  "memory_search",
  "reference_search",
  "reference_read",
  "reference_list"
];
function isMemoryToolName(tool) {
  return MEMORY_CHIP_TOOL_NAMES.includes(tool);
}
function articleNameFromArgs(tool, args) {
  if (!args || typeof args !== "object")
    return null;
  const a = args;
  const cand = a.article ?? a.name ?? a.category ?? a.query;
  return typeof cand === "string" && cand.trim() ? cand.trim() : null;
}
function chipVerb(tool) {
  if (tool === "memory_search" || tool === "reference_search")
    return "searched";
  if (tool === "memory_links")
    return "traced links from";
  if (tool === "memory_list" || tool === "memory_status" || tool === "reference_list")
    return "checked";
  return "read";
}
function memoryToolChip(parent, tool, args) {
  const articleName = articleNameFromArgs(tool, args);
  const wrap = el("div", "memchip", parent);
  const label = articleName ? "<b>" + chipVerb(tool) + "</b> " + esc(articleName.replace(/_/g, " ")) : "<b>" + chipVerb(tool) + "</b> memory";
  wrap.innerHTML = '<div class="mchead"><span class="mcicon" aria-hidden="true">◆</span>' + '<span class="mclabel">' + label + "</span>" + '<span class="mccaret">›</span></div>' + '<div class="mcbody"><pre class="mcresult"></pre>' + (articleName ? '<button class="mcopen" type="button">Open in Memory</button>' : "") + "</div>";
  wrap.querySelector(".mchead").addEventListener("click", () => wrap.classList.toggle("open"));
  const openBtn = wrap.querySelector(".mcopen");
  if (openBtn && articleName)
    openBtn.onclick = (e) => {
      e.stopPropagation();
      openMemPanel(articleName);
    };
  const resultEl = wrap.querySelector(".mcresult");
  return {
    wrap,
    setResult(result) {
      const text = result != null ? typeof result === "string" ? result : JSON.stringify(result, null, 2) : "";
      resultEl.textContent = String(text).slice(-4000);
    }
  };
}
async function personalizeHeroChips() {
  const container = $("chat-hello-chips");
  if (!container)
    return;
  const extra = [];
  const st = await fetchStatus();
  if (st.ok && st.enabled && st.status && st.status.recentArticles.length) {
    const name = st.status.recentArticles[0].article;
    const display = name.replace(/_/g, " ");
    extra.push('<button class="chip" data-q="' + esc("What do you remember about " + display + "?") + '">Ask about ' + esc(display) + "</button>");
  }
  try {
    const d = await getJson("/v1/adapters/available");
    const compatible = (d.adapters || []).find((a) => a.compatible !== false);
    if (compatible) {
      extra.push('<button class="chip" data-q="' + esc("Can you try answering with the " + compatible.id + " adapter?") + '">Try the ' + esc(compatible.id) + " adapter</button>");
    }
  } catch {}
  if (!extra.length)
    return;
  container.insertAdjacentHTML("afterbegin", extra.join(""));
}
var CONSENT_DISMISSED_KEY = "mlxbun.memoryConsentDismissed";
function isConsentDismissed() {
  return localStorage.getItem(CONSENT_DISMISSED_KEY) === "1";
}
function dismissConsent() {
  localStorage.setItem(CONSENT_DISMISSED_KEY, "1");
  $("chat-consent").classList.remove("show");
}
async function maybeShowConsentCard() {
  const card = $("chat-consent");
  if (!card)
    return;
  if (isConsentDismissed())
    return;
  const st = await fetchStatus();
  if (st.ok && st.enabled)
    return;
  card.classList.add("show");
}
function wireConsentCard() {
  const skip = $("chat-consent-skip");
  const yes = $("chat-consent-yes");
  if (skip)
    skip.onclick = dismissConsent;
  if (yes)
    yes.onclick = async () => {
      yes.disabled = true;
      const d = await api("/api/memory/init", { method: "POST" }).catch(() => ({ ok: false, error: "request failed" }));
      yes.disabled = false;
      if (!d.ok) {
        toast("Couldn't set up memory: " + (d.error || "unknown error"), "err");
        return;
      }
      dismissConsent();
      cachedStatus = null;
      toast("Memory vault created", "ok");
      await refreshSidebarEntry();
      await openMemPanel();
    };
}
function initMemoryPanel() {
  panelTrap = trapFocus($("mem-overlay"), isMemPanelOpen);
  setMemPanelClose(closeMemPanel);
  const entry = $("chat-memory-entry");
  entry.onclick = () => openMemPanel();
  $("mem-close").onclick = closeMemPanel;
  $("mem-back").onclick = () => showList();
  $("mem-overlay").addEventListener("click", (e) => {
    if (e.target === $("mem-overlay"))
      closeMemPanel();
  });
  wireConsentCard();
  refreshSidebarEntry();
  personalizeHeroChips();
  maybeShowConsentCard();
}

// src/web/src/chat.ts
function argSummary(args) {
  if (!args)
    return "";
  if (typeof args === "string")
    return args.slice(0, 120);
  const a = args;
  if (a.command || a.cmd)
    return String(a.command || a.cmd).slice(0, 120);
  if (a.file_path || a.path)
    return String(a.file_path || a.path).slice(0, 120);
  if (a.query || a.url || a.location)
    return String(a.query || a.url || a.location).slice(0, 120);
  const s = JSON.stringify(args);
  return s.length > 120 ? s.slice(0, 117) + "…" : s;
}
function prettyArgs(args) {
  if (args == null)
    return "";
  if (typeof args === "string")
    return args;
  try {
    return JSON.stringify(args, null, 2);
  } catch {
    return String(args);
  }
}
function diffView(args) {
  if (!args)
    return "";
  const a = args;
  if (a.old_string != null || a.new_string != null) {
    const o = String(a.old_string ?? "").split(`
`).map((l) => '<span class="diffdel">- ' + esc(l) + "</span>").join(`
`);
    const n = String(a.new_string ?? "").split(`
`).map((l) => '<span class="diffadd">+ ' + esc(l) + "</span>").join(`
`);
    return (a.file_path ? esc(a.file_path) + `

` : "") + o + (o && n ? `
` : "") + n;
  }
  if (a.content != null) {
    return (a.file_path ? esc(a.file_path) + `

` : "") + String(a.content).split(`
`).map((l) => '<span class="diffadd">+ ' + esc(l) + "</span>").join(`
`);
  }
  return esc(prettyArgs(args));
}
function createChatController() {
  let ws = null, connected = false, reconnectTimer, manualClose = false;
  let curAssistant = null;
  let turnActive = false;
  let currentSessionPath = null, pendingResumePath = null;
  const thread = () => $("chat-thread");
  const composer = new ComposerState;
  const sidebar = newSidebarState();
  const adaptersPanel = new AdaptersPanelState;
  function wsUrl() {
    const proto = location.protocol === "https:" ? "wss:" : "ws:";
    return proto + "//" + location.host + "/ws/chat";
  }
  function connect() {
    manualClose = false;
    pendingResumePath = currentSessionPath;
    try {
      ws = new WebSocket(wsUrl());
    } catch {
      scheduleReconnect();
      return;
    }
    ws.onopen = () => {
      connected = true;
      setChatStatus("connected");
    };
    ws.onclose = () => {
      connected = false;
      setChatStatus("disconnected");
      if (!manualClose)
        scheduleReconnect();
    };
    ws.onerror = () => {
      setChatStatus("error");
    };
    ws.onmessage = (ev) => {
      let m;
      try {
        m = JSON.parse(ev.data);
      } catch {
        return;
      }
      handle(m);
    };
  }
  function scheduleReconnect() {
    clearTimeout(reconnectTimer);
    reconnectTimer = setTimeout(() => {
      if (currentRoute() === "chat")
        connect();
    }, 2200);
  }
  function send(obj) {
    if (ws && ws.readyState === 1) {
      ws.send(JSON.stringify(obj));
      return true;
    }
    return false;
  }
  function setChatStatus(s) {
    const line = $("chat-status-line");
    if (s === "connected")
      line.textContent = "connected · type to send · Shift+Enter for newline · # attaches files or recalls memory";
    else if (s === "disconnected")
      line.textContent = "reconnecting to agent…";
    else if (s === "error")
      line.textContent = "connection error — retrying";
  }
  let lastUserMsgEl = null;
  let lastUserEntryId = null;
  let siblingInfo = newSiblingInfo();
  let lastAssistantMsgEl = null;
  function doRegenerate() {
    if (turnActive)
      return;
    if (!send({ type: "regenerate" })) {
      toast("Not connected to the agent yet.", "err");
      return;
    }
    if (lastAssistantMsgEl) {
      lastAssistantMsgEl.remove();
      lastAssistantMsgEl = null;
    }
  }
  function switchSiblingDir(delta) {
    const target = switchSiblingTarget(siblingInfo, delta);
    if (!target)
      return;
    send({ type: "switch_sibling", entryId: target });
  }
  function startEditLast(m) {
    if (turnActive)
      return;
    const bubble = m.querySelector(".bubble");
    const textEl = bubble.querySelector(".msg-text");
    if (!textEl)
      return;
    const original = textEl.textContent || "";
    const box = document.createElement("textarea");
    box.className = "msg-edit-box";
    box.value = original;
    const actions = el("div", "msg-edit-actions", null);
    const cancelBtn = el("button", "btn ghost sm", actions);
    cancelBtn.type = "button";
    cancelBtn.textContent = "Cancel";
    const sendBtn = el("button", "btn primary sm", actions);
    sendBtn.type = "button";
    sendBtn.textContent = "Send";
    textEl.replaceWith(box);
    box.after(actions);
    box.focus();
    box.setSelectionRange(box.value.length, box.value.length);
    const restore = () => {
      box.replaceWith(textEl);
      actions.remove();
    };
    const doSend = () => {
      const text = box.value.trim();
      if (!text)
        return;
      if (!send({ type: "edit_resend", text })) {
        toast("Not connected to the agent yet.", "err");
        return;
      }
      textEl.textContent = text;
      box.replaceWith(textEl);
      actions.remove();
      if (lastAssistantMsgEl) {
        lastAssistantMsgEl.remove();
        lastAssistantMsgEl = null;
      }
    };
    cancelBtn.onclick = restore;
    sendBtn.onclick = doSend;
    box.addEventListener("keydown", (e) => {
      if (e.key === "Escape") {
        e.preventDefault();
        restore();
      } else if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        doSend();
      }
    });
  }
  function addUserMsg(text, atts, opts) {
    const m = el("div", "msg user", thread());
    el("div", "who", m).textContent = "you";
    const bubble = el("div", "bubble", m);
    if (atts && atts.length) {
      const wrap = el("div", "msg-atts", bubble);
      for (const a of atts) {
        if (a.kind === "image") {
          const im = el("img", "msg-att-img", wrap);
          im.src = "data:" + a.mimeType + ";base64," + a.data;
          im.alt = a.name;
        } else {
          el("span", "msg-att-file", wrap).textContent = "\uD83D\uDCCE " + a.name;
        }
      }
    }
    if (text)
      el("div", "msg-text", bubble).textContent = text;
    if (opts.isLast) {
      lastUserMsgEl = m;
      lastUserEntryId = opts.entryId || null;
      addMsgActions(m, text, { edit: true }, { onEdit: startEditLast });
      renderSiblingToggle(lastUserMsgEl, lastUserEntryId, siblingInfo, switchSiblingDir);
    }
    stick(true);
  }
  function startAssistant() {
    $("chat-hello").style.display = "none";
    const m = el("div", "msg assistant", thread());
    el("div", "who", m).textContent = "local agent";
    const bubble = el("div", "bubble", m);
    const thinkBox = el("details", "thinkbox", bubble);
    thinkBox.open = false;
    el("summary", "", thinkBox).textContent = "Thinking";
    const thinkBody = el("div", "thinkbody", thinkBox);
    thinkBox.style.display = "none";
    const textNode = el("span", "atext", bubble);
    const cursor = el("span", "cursor", bubble);
    const meta = el("div", "meta", m);
    curAssistant = {
      m,
      bubble,
      thinkBox,
      thinkBody,
      textNode,
      cursor,
      meta,
      tools: new Map,
      text: "",
      thinking: "",
      t0: performance.now(),
      tFirst: 0,
      tokens: 0,
      blockState: { blocks: [] },
      scheduleText: () => {},
      scheduleThinking: () => {}
    };
    curAssistant.scheduleText = makeFrameScheduler(() => renderBlocksIncremental(curAssistant.textNode, curAssistant.text, curAssistant.blockState), atBottom, stick);
    curAssistant.scheduleThinking = makeFrameScheduler(() => {
      curAssistant.thinkBody.textContent = curAssistant.thinking;
    }, atBottom, stick);
    stick(true);
  }
  function ensureAssistant() {
    if (!curAssistant)
      startAssistant();
  }
  function appendDelta(delta) {
    ensureAssistant();
    const a = curAssistant;
    if (!a.tFirst)
      a.tFirst = performance.now();
    a.tokens++;
    a.text += delta;
    a.scheduleText();
    updateTps();
  }
  function appendThinkingDelta(delta) {
    ensureAssistant();
    const a = curAssistant;
    if (!a.tFirst)
      a.tFirst = performance.now();
    a.tokens++;
    a.thinking += delta;
    a.thinkBox.style.display = a.thinking.trim() ? "" : "none";
    a.scheduleThinking();
    updateTps();
  }
  function toolCard(callId, tool, args) {
    ensureAssistant();
    const a = curAssistant;
    let t = a.tools.get(callId);
    if (t)
      return t;
    if (isMemoryToolName(tool || "")) {
      const handle2 = memoryToolChip(a.bubble, tool, args);
      t = { kind: "memchip", wrap: handle2.wrap, handle: handle2, chunks: "" };
      a.tools.set(callId, t);
      stick();
      return t;
    }
    const wrap = el("div", "tool running open", a.bubble);
    wrap.innerHTML = '<div class="thead"><div class="ticon">⚙</div>' + '<span class="tname">' + esc(tool || "tool") + "</span>" + '<span class="targs">' + esc(argSummary(args)) + "</span>" + '<span class="tstat"><span class="sdot"></span><span class="slabel">running</span></span>' + '<span class="caret">›</span></div>' + '<div class="tbody">' + '<div class="blk"><div class="blbl">arguments</div><pre class="aargs">' + esc(prettyArgs(args)) + "</pre></div>" + '<div class="blk tresult" style="display:none"><div class="blbl">result</div><pre class="ares"></pre></div>' + "</div>";
    wrap.querySelector(".thead").addEventListener("click", () => wrap.classList.toggle("open"));
    t = {
      kind: "wrench",
      wrap,
      res: wrap.querySelector(".ares"),
      resBlk: wrap.querySelector(".tresult"),
      label: wrap.querySelector(".slabel"),
      chunks: ""
    };
    a.tools.set(callId, t);
    stick();
    return t;
  }
  function toolUpdate(callId, chunk) {
    const t = curAssistant && curAssistant.tools.get(callId);
    if (!t)
      return;
    t.chunks += chunk;
    if (t.kind === "memchip") {
      t.handle.setResult(t.chunks);
      if (atBottom())
        stick();
      return;
    }
    t.resBlk.style.display = "";
    t.res.textContent = t.chunks.slice(-8000);
    if (atBottom())
      stick();
  }
  function toolEnd(callId, ok, result) {
    const t = curAssistant && curAssistant.tools.get(callId);
    if (!t)
      return;
    if (t.kind === "memchip") {
      t.wrap.classList.toggle("fail", !ok);
      t.handle.setResult(result != null ? result : t.chunks);
      return;
    }
    t.wrap.classList.remove("running");
    t.wrap.classList.add(ok ? "ok" : "fail");
    t.label.textContent = ok ? "done" : "failed";
    const body = result != null ? typeof result === "string" ? result : JSON.stringify(result, null, 2) : t.chunks;
    if (body) {
      t.resBlk.style.display = "";
      t.res.textContent = String(body).slice(-12000);
    }
    if (!ok)
      t.wrap.classList.add("open");
  }
  function approvalCard(callId, tool, args) {
    ensureAssistant();
    const a = curAssistant;
    const wrap = el("div", "approval", a.bubble);
    const isBash = /bash|shell|exec|run/i.test(tool || "");
    const isEdit = /edit|write|patch|create/i.test(tool || "");
    const diffHtml = isEdit ? '<pre class="a-diff">' + diffView(args) + "</pre>" : "";
    const argsJson = prettyArgs(args);
    wrap.innerHTML = '<div class="ahead"><div class="ai">⚠</div><div class="at">Approval required</div>' + '<div class="as">' + esc(tool || "tool") + "</div></div>" + '<div class="abody">' + diffHtml + '<div class="blbl" style="margin-bottom:7px">' + (isBash ? "command (edit before approving if you like)" : isEdit ? "proposed change — arguments below, editable" : "arguments — editable before approving") + "</div>" + '<textarea class="a-args" spellcheck="false">' + esc(argsJson) + "</textarea>" + '<div class="a-argerr" style="display:none"></div>' + "</div>" + '<label class="chk a-always"><input type="checkbox" class="a-always-cb">Always allow ' + esc(tool || "this tool") + " (skip this card next time)</label>" + '<div class="actions">' + '<button class="btn ghost sm a-deny">Deny</button>' + '<button class="btn primary sm a-allow">Allow</button></div>';
    const textarea = wrap.querySelector(".a-args");
    const errEl = wrap.querySelector(".a-argerr");
    const alwaysCb = wrap.querySelector(".a-always-cb");
    const resolve = (decision) => {
      let editedArgs;
      if (decision === "allow") {
        const raw = textarea.value.trim();
        if (raw && raw !== argsJson.trim()) {
          try {
            const parsed = JSON.parse(raw);
            if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
              editedArgs = parsed;
            } else {
              errEl.textContent = "Arguments must be a JSON object — sending the original instead.";
              errEl.style.display = "";
            }
          } catch {
            errEl.textContent = "Could not parse the edited arguments as JSON — sending the original instead.";
            errEl.style.display = "";
          }
        }
      }
      send({ type: "approval", callId, decision, editedArgs, alwaysAllow: decision === "allow" && alwaysCb.checked });
      wrap.querySelector(".actions").remove();
      wrap.querySelector(".a-always")?.remove();
      const r = el("div", "resolved " + (decision === "allow" ? "allow" : "deny"), wrap);
      r.textContent = decision === "allow" ? editedArgs ? "✓ allowed (edited)" : "✓ allowed" : "✕ denied";
    };
    wrap.querySelector(".a-allow").onclick = () => resolve("allow");
    wrap.querySelector(".a-deny").onclick = () => resolve("deny");
    stick(true);
  }
  function showAgentError(message) {
    const m = el("div", "msg assistant", thread());
    el("div", "who", m).textContent = "local agent";
    const bubble = el("div", "bubble", m);
    bubble.innerHTML = '<strong style="color:var(--red)">Agent error</strong><br>' + esc(message || "unknown error");
    stick(true);
  }
  function finishStreaming(a) {
    if (!a)
      return;
    a.textNode.innerHTML = mdToHtml(a.text);
    highlightIn(a.textNode);
    a.thinkBody.textContent = a.thinking;
  }
  function clearRegenerateAffordance() {
    if (!lastAssistantMsgEl)
      return;
    const row = lastAssistantMsgEl.querySelector(".msg-actions");
    const btn = row && [...row.querySelectorAll(".maction")].find((b) => b.textContent === "Regenerate");
    if (btn)
      btn.remove();
  }
  function endTurn() {
    turnActive = false;
    if (curAssistant) {
      finishStreaming(curAssistant);
      curAssistant.cursor.remove();
      if (!curAssistant.text && !curAssistant.thinking && curAssistant.tools.size === 0) {
        curAssistant.m.remove();
      } else {
        clearRegenerateAffordance();
        addMsgActions(curAssistant.m, curAssistant.text, { regenerate: true }, { onRegenerate: doRegenerate });
        lastAssistantMsgEl = curAssistant.m;
      }
    }
    curAssistant = null;
    $("chat-send").disabled = false;
    $("chat-stop").style.display = "none";
    renderQueue({});
  }
  function updateTps() {
    const a = curAssistant;
    if (!a)
      return;
    const secs = (performance.now() - (a.tFirst || a.t0)) / 1000;
    if (a.tokens > 1 && secs > 0) {
      const tps = $("pf-tps");
      if (tps)
        tps.innerHTML = "<b style='color:var(--green)'>" + (a.tokens / secs).toFixed(1) + " tok/s</b>";
    }
    if (a.tFirst) {
      const ttft = $("pf-ttft");
      if (ttft)
        ttft.textContent = "TTFT " + Math.round(a.tFirst - a.t0) + "ms";
    }
  }
  function finalizeMeta() {
    const a = curAssistant;
    if (!a)
      return;
    const secs = (performance.now() - (a.tFirst || a.t0)) / 1000;
    if (a.tokens > 1 && secs > 0)
      a.meta.innerHTML = "<b>" + (a.tokens / secs).toFixed(1) + " tok/s</b> · " + a.tokens + " tokens · first token " + Math.round(a.tFirst - a.t0) + "ms";
  }
  function newChat() {
    if (!send({ type: "new_session" })) {
      toast("Not connected to the agent yet.", "err");
      return;
    }
    $("chat-box").focus();
    closeDrawer();
  }
  function renderAssistantStatic(item, opts) {
    const m = el("div", "msg assistant", thread());
    el("div", "who", m).textContent = "local agent";
    const bubble = el("div", "bubble", m);
    if (item.thinking && item.thinking.trim()) {
      const tb = el("details", "thinkbox", bubble);
      tb.open = false;
      el("summary", "", tb).textContent = "Thinking";
      el("div", "thinkbody", tb).textContent = item.thinking;
    }
    if (item.text) {
      const tn = el("span", "atext", bubble);
      tn.innerHTML = mdToHtml(item.text);
      highlightIn(tn);
    }
    for (const t of item.tools || []) {
      if (isMemoryToolName(t.name || "")) {
        const handle2 = memoryToolChip(bubble, t.name, t.args);
        if (t.result)
          handle2.setResult(t.result);
        continue;
      }
      const wrap = el("div", "tool ok", bubble);
      wrap.innerHTML = '<div class="thead"><div class="ticon">⚙</div>' + '<span class="tname">' + esc(t.name || "tool") + "</span>" + '<span class="targs">' + esc(argSummary(t.args)) + "</span>" + '<span class="tstat"><span class="sdot"></span><span class="slabel">done</span></span>' + '<span class="caret">›</span></div>' + '<div class="tbody">' + '<div class="blk"><div class="blbl">arguments</div><pre class="aargs">' + esc(prettyArgs(t.args)) + "</pre></div>" + (t.result ? '<div class="blk tresult"><div class="blbl">result</div><pre class="ares">' + esc(String(t.result).slice(-12000)) + "</pre></div>" : "") + "</div>";
      wrap.querySelector(".thead").addEventListener("click", () => wrap.classList.toggle("open"));
    }
    if (item.text) {
      addMsgActions(m, item.text, { regenerate: !!opts.isLast }, { onRegenerate: doRegenerate });
      if (opts.isLast)
        lastAssistantMsgEl = m;
    }
  }
  function renderHistory(items) {
    turnActive = false;
    curAssistant = null;
    $("chat-send").disabled = false;
    $("chat-stop").style.display = "none";
    renderQueue({});
    thread().innerHTML = "";
    lastUserMsgEl = null;
    lastAssistantMsgEl = null;
    if (!items || !items.length) {
      $("chat-hello").style.display = "";
      return;
    }
    $("chat-hello").style.display = "none";
    const lastUserIdx = items.map((it) => it.role).lastIndexOf("user");
    const lastAssistantIdx = items.map((it) => it.role).lastIndexOf("assistant");
    items.forEach((it, i) => {
      if (it.role === "user")
        addUserMsg(it.text, null, { isLast: i === lastUserIdx, entryId: it.entryId });
      else
        renderAssistantStatic(it, { isLast: i === lastAssistantIdx });
    });
    stick(true);
  }
  function handle(m) {
    switch (m.type) {
      case "ready":
        $("nav-model").textContent = m.model || $("nav-model").textContent || "no model";
        composer.visionCapable = !!m.vision;
        updateAttachHint(composer);
        composer.thinkingCapable = !!m.thinking;
        updateThinkingToggle(composer);
        composer.genDefaults = m.genDefaults || { temperature: null, topP: null, topK: null };
        refreshSamplingRecs(composer);
        if (composer.thinkingCapable)
          send({ type: "set_thinking", enabled: composer.thinkingOn });
        refreshAdapters();
        send({ type: "set_coding_tools", enabled: storedCodingToolsPreference() });
        if (pendingResumePath) {
          send({ type: "open_session", path: pendingResumePath });
          pendingResumePath = null;
        }
        break;
      case "coding_tools":
        renderCodingToolsState(m.active, m.pending);
        break;
      case "tool_approvals":
        renderToolApprovals(m.alwaysAllow, (tool) => forgetToolApproval(tool));
        break;
      case "history":
        renderHistory(m.items);
        break;
      case "sessions":
        currentSessionPath = m.activePath || null;
        renderSessions(sidebar, m.items, m.activePath, {
          onOpen: (path) => {
            send({ type: "open_session", path });
            closeDrawer();
          },
          onFork: (path) => send({ type: "fork_session", path }),
          onDelete: (path) => send({ type: "delete_session", path })
        });
        break;
      case "context":
        renderContext(m);
        break;
      case "siblings":
        siblingInfo = { entryId: m.entryId || null, index: m.index, count: m.count, siblingIds: m.siblingIds || [] };
        lastUserEntryId = siblingInfo.entryId;
        renderSiblingToggle(lastUserMsgEl, lastUserEntryId, siblingInfo, switchSiblingDir);
        break;
      case "turn_start":
        turnActive = true;
        startAssistant();
        $("chat-send").disabled = true;
        $("chat-stop").style.display = "block";
        break;
      case "text_delta":
        appendDelta(m.delta || "");
        break;
      case "thinking_delta":
        appendThinkingDelta(m.delta || "");
        break;
      case "tool_start":
        toolCard(m.callId, m.tool, m.args);
        break;
      case "tool_approval_request":
        approvalCard(m.callId, m.tool, m.args);
        break;
      case "tool_update":
        toolUpdate(m.callId, m.chunk || "");
        break;
      case "tool_end":
        toolEnd(m.callId, m.ok, m.result);
        break;
      case "turn_end":
        finalizeMeta();
        renderLane(m.lane);
        endTurn();
        break;
      case "queue_update":
        renderQueue(m);
        break;
      case "error":
        showAgentError(m.message || "agent error");
        toast(m.message || "agent error", "err");
        if (turnActive)
          endTurn();
        break;
    }
  }
  function submit() {
    const box = $("chat-box");
    const text = box.value.trim();
    const cmd = text.toLowerCase();
    if (cmd === "/reload" || cmd === "/new" || cmd === "/clear") {
      box.value = "";
      box.style.height = "auto";
      clearAttachments(composer);
      newChat();
      return;
    }
    if (!text && composer.attachments.length === 0)
      return;
    if (!connected) {
      toast("Not connected to the agent yet — reconnecting.", "err");
      return;
    }
    const imgs = composer.attachments.filter((a) => a.kind === "image").map((a) => ({ data: a.data, mimeType: a.mimeType }));
    const combined = buildMessageText(composer, text);
    addUserMsg(text, composer.attachments, { isLast: true });
    box.value = "";
    box.style.height = "auto";
    const frame = imgs.length ? { type: "prompt", text: combined, images: imgs } : { type: "prompt", text: combined };
    send(frame);
    clearAttachments(composer);
  }
  const scroll = () => $("chat-scroll");
  const atBottom = () => scroll().scrollHeight - scroll().scrollTop - scroll().clientHeight < 90;
  function stick(force) {
    if (force || atBottom())
      scroll().scrollTop = scroll().scrollHeight;
  }
  function copyLastResponse() {
    if (!lastAssistantMsgEl) {
      toast("No response to copy yet.", "err");
      return;
    }
    const btn = lastAssistantMsgEl.querySelector(".msg-actions .maction");
    if (btn)
      btn.click();
  }
  function setCodingTools(enabled) {
    send({ type: "set_coding_tools", enabled });
  }
  async function forgetToolApproval(tool) {
    const d = await api("/api/settings/tool-approvals", { method: "DELETE", body: { tool } }).catch(() => ({ ok: false, error: "request failed" }));
    if (!d.ok) {
      toast(d.error || "could not forget that tool", "err");
      return;
    }
    renderToolApprovals(d.alwaysAllow || [], (t) => forgetToolApproval(t));
    toast("Forgot “" + tool + "” — it will ask again next time", "ok");
  }
  return {
    init() {
      $("chat-send").onclick = submit;
      $("chat-new").onclick = newChat;
      $("chat-stop").onclick = () => {
        send({ type: "abort" });
        $("chat-stop").style.display = "none";
      };
      const thinkToggle = () => {
        composer.thinkingOn = !composer.thinkingOn;
        updateThinkingToggle(composer);
        send({ type: "set_thinking", enabled: composer.thinkingOn });
      };
      $("chat-think").onclick = thinkToggle;
      $("chat-think").addEventListener("keydown", (e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          thinkToggle();
        }
      });
      const adapterSel = $("chat-adapter");
      if (adapterSel)
        adapterSel.onchange = () => {
          adaptersPanel.selectedSpec = adapterSel.value || null;
          adaptersPanel.stackPicks.clear();
          onSelectAdapter(adapterSel, send);
        };
      initAdaptersPanel(adaptersPanel, send);
      initSampling(composer, send);
      initSystemPrompt(composer, send);
      refreshAdapters();
      const sessSearch = $("chat-sess-search");
      if (sessSearch)
        sessSearch.addEventListener("input", () => applySessSearch(sidebar));
      const box = $("chat-box");
      initMentionPicker(composer, box, {
        onFileSelected: (att) => {
          const chip = document.querySelector('.attach-chip[data-att-id="' + att.id + '"]');
          if (chip) {
            chip.scrollIntoView({ block: "nearest", behavior: "smooth" });
            chip.classList.add("pulse");
            setTimeout(() => chip.classList.remove("pulse"), 1000);
          }
        }
      });
      box.addEventListener("keydown", (e) => {
        if ($("chat-mention-pop").classList.contains("open"))
          return;
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          submit();
        }
      });
      box.addEventListener("input", () => {
        box.style.height = "auto";
        box.style.height = Math.min(box.scrollHeight, 200) + "px";
      });
      $("chat-hello-chips").addEventListener("click", (e) => {
        const chip = e.target.closest(".chip");
        if (!chip)
          return;
        $("chat-box").value = chip.dataset.q || "";
        submit();
      });
      initMemoryPanel();
      $("chat-attach-btn").onclick = () => $("chat-file-input").click();
      $("chat-file-input").addEventListener("change", (e) => {
        addFiles(composer, [...e.target.files || []]);
        e.target.value = "";
      });
      box.addEventListener("paste", (e) => {
        const items = e.clipboardData && e.clipboardData.items;
        if (!items)
          return;
        const files = [];
        for (const it of items)
          if (it.kind === "file") {
            const f = it.getAsFile();
            if (f)
              files.push(f);
          }
        if (files.length) {
          e.preventDefault();
          addFiles(composer, files);
        }
      });
      const composerEl = document.querySelector("#s-chat .composer");
      if (composerEl) {
        ["dragenter", "dragover"].forEach((ev) => composerEl.addEventListener(ev, (e) => {
          e.preventDefault();
          composerEl.classList.add("dragover");
        }));
        ["dragleave", "drop"].forEach((ev) => composerEl.addEventListener(ev, (e) => {
          e.preventDefault();
          const de = e;
          if (ev === "drop" && de.dataTransfer && de.dataTransfer.files.length)
            addFiles(composer, [...de.dataTransfer.files]);
          if (ev === "drop" || !composerEl.contains(de.relatedTarget))
            composerEl.classList.remove("dragover");
        }));
      }
      thread().addEventListener("click", (e) => {
        const target = e.target;
        const btn = target.closest && target.closest(".cbcopy");
        if (!btn)
          return;
        const code = btn.closest(".codeblock")?.querySelector("code");
        if (!code || !navigator.clipboard)
          return;
        navigator.clipboard.writeText(code.textContent || "").then(() => {
          btn.textContent = "Copied";
          setTimeout(() => {
            btn.textContent = "Copy";
          }, 1200);
        }).catch(() => {});
      });
    },
    enter() {
      if (!ws || ws.readyState > 1)
        connect();
      $("chat-box").focus();
      refreshAdapters();
    },
    leave() {},
    refreshAdapters,
    newChat,
    copyLastResponse,
    setCodingTools,
    forgetToolApproval
  };
}

// src/web/src/quantize.ts
var STEPS = ["Source", "Configure", "Run", "Done"];
function createQuantizeController() {
  let step = 0, bits = 4, gs = 64, mode = "uniform", bpw = 5, jobId = null, es = null, log = [];
  function show(n) {
    step = n;
    document.querySelectorAll("[data-qstep]").forEach((d) => d.style.display = +d.dataset.qstep === n ? "" : "none");
    renderSteps($("q-steps"), STEPS, n);
  }
  function seg(container, onPick) {
    container.querySelectorAll("button").forEach((b) => b.addEventListener("click", () => {
      container.querySelectorAll("button").forEach((x) => x.classList.remove("on"));
      b.classList.add("on");
      onPick(b.dataset.v || "", b);
    }));
  }
  async function resolveByName(name, relPath) {
    if (!name && !relPath)
      return;
    const out = $("q-inspect-out");
    out.innerHTML = '<div class="flash"><span class="shimmer">locating on disk…</span></div>';
    const d = await api("/api/quantize/resolve-folder", { method: "POST", body: { folder_name: name || "", rel_path: relPath || "" } }).catch(() => ({ ok: false, error: "request failed" }));
    if (!d.ok) {
      out.innerHTML = '<div class="flash err">' + esc(d.error || "could not locate this folder on the server") + "</div>";
      return;
    }
    $("q-model").value = d.path;
    inspect();
  }
  async function pickFolder() {
    if (window.showDirectoryPicker) {
      try {
        const handle = await window.showDirectoryPicker({ id: "mlx-models", mode: "read" });
        return resolveByName(handle.name);
      } catch {
        return;
      }
    }
    $("q-folder").click();
  }
  async function inspect() {
    const id = $("q-model").value.trim();
    if (!id) {
      toast("Enter a model id or path first.", "err");
      return;
    }
    const out = $("q-inspect-out");
    out.innerHTML = '<div class="flash"><span class="shimmer">inspecting…</span></div>';
    const btn = $("q-inspect");
    btn.disabled = true;
    const d = await api("/api/quantize/inspect", { method: "POST", body: { model_id: id } }).catch(() => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) {
      out.innerHTML = '<div class="flash err">' + esc(d.error || "could not inspect this model") + "</div>";
      return;
    }
    const supported = d.support === true;
    const cls = supported ? "ok" : "err";
    out.innerHTML = '<div class="flash ' + cls + '"><strong>' + esc(d.arch || d.model_id || id) + "</strong>" + (d.size_gb ? " · " + (+d.size_gb).toFixed(2) + " GB" : "") + " · " + (supported ? "supported" : "not quantizable") + "</div>" + '<div class="btnrow"><button class="btn primary" id="q-continue">Continue</button></div>';
    $("q-continue").onclick = () => show(1);
  }
  async function submit() {
    const id = $("q-model").value.trim();
    const btn = $("q-submit");
    btn.disabled = true;
    const body = { model_id: id, bits, group_size: gs };
    if (mode === "mixed") {
      body.target_bpw = bpw;
      body.candidate_bits = [4, 8];
    }
    const d = await api("/api/quantize/submit", { method: "POST", body }).catch(() => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) {
      toast(d.error || "could not start quantize", "err");
      return;
    }
    jobId = d.job_id || null;
    $("q-push-panel").innerHTML = "";
    $("q-out").textContent = d.output_dir || "";
    log = [];
    $("q-log").textContent = "";
    $("q-bar").style.width = "0%";
    $("q-pct").textContent = "0%";
    $("q-msg").textContent = "Starting…";
    show(2);
    attach(jobId);
  }
  function attach(id) {
    if (es)
      es.close();
    es = jobStream(id, {
      log: (e) => {
        log.push(e.line);
        $("q-log").textContent = log.slice(-200).join(`
`);
        $("q-log").scrollTop = $("q-log").scrollHeight;
      },
      stage: (e) => {
        if (e.progress != null) {
          const p = Math.round(e.progress * 100);
          $("q-bar").style.width = p + "%";
          $("q-pct").textContent = p + "%";
        }
        if (e.message)
          $("q-msg").textContent = e.message;
        if (e.stage === "done") {
          if (e.output_dir)
            $("q-out").textContent = e.output_dir;
          finish();
        }
      },
      done: () => finish(),
      failed: (e) => {
        $("q-msg").textContent = "Failed: " + (e.error || "unknown error");
        toast(e.error || "quantize failed", "err");
        es && es.close();
      }
    });
  }
  function finish() {
    $("q-bar").style.width = "100%";
    $("q-pct").textContent = "100%";
    es && es.close();
    show(3);
    if (controllers.status && controllers.status.refreshLibrary)
      controllers.status.refreshLibrary();
  }
  return {
    init() {
      show(0);
      $("q-inspect").onclick = inspect;
      $("q-model").addEventListener("keydown", (e) => {
        if (e.key === "Enter")
          inspect();
      });
      $("q-browse").onclick = pickFolder;
      $("q-folder").addEventListener("change", (e) => {
        const input = e.target;
        const f = input.files[0];
        input.value = "";
        if (f)
          resolveByName((f.webkitRelativePath || f.name).split("/")[0], f.webkitRelativePath || "");
      });
      const drop = $("q-drop");
      const hi = (on) => {
        drop.style.outline = on ? "2px dashed var(--blue)" : "";
        drop.style.outlineOffset = on ? "4px" : "";
      };
      ["dragenter", "dragover"].forEach((ev) => drop.addEventListener(ev, (e) => {
        e.preventDefault();
        hi(true);
      }));
      ["dragleave", "drop"].forEach((ev) => drop.addEventListener(ev, (e) => {
        e.preventDefault();
        hi(false);
        const de = e;
        if (ev !== "drop" || !de.dataTransfer)
          return;
        for (const it of [...de.dataTransfer.items || []]) {
          const en = it.webkitGetAsEntry && it.webkitGetAsEntry();
          if (en && en.isDirectory)
            return void resolveByName(en.name);
        }
        const f = de.dataTransfer.files && de.dataTransfer.files[0];
        if (f)
          resolveByName((f.webkitRelativePath || f.name).split("/")[0]);
      }));
      seg($("q-bits"), (v) => {
        bits = +v;
        $("q-bits-hint").textContent = v === "4" ? "4-bit · ~4× smaller than bf16 · the recommended default for local serving." : "8-bit · ~2× smaller than bf16 · highest fidelity quant.";
      });
      seg($("q-gs"), (v) => {
        gs = +v;
      });
      seg($("q-mode"), (v) => {
        mode = v;
        $("q-bpw-field").style.display = v === "mixed" ? "" : "none";
      });
      $("q-bpw").addEventListener("input", (e) => {
        bpw = +e.target.value;
        $("q-bpw-val").textContent = bpw.toFixed(1);
      });
      document.querySelectorAll("#s-quantize [data-qback]").forEach((b) => b.onclick = () => show(step - 1));
      $("q-submit").onclick = submit;
      $("q-push").onclick = () => pushToHub($("q-push-panel"), { kind: "quantize", job_id: jobId || undefined });
      $("q-again").onclick = () => {
        $("q-inspect-out").innerHTML = "";
        $("q-push-panel").innerHTML = "";
        show(0);
      };
    }
  };
}

// src/web/src/finetune.ts
var STEPS2 = ["Base", "Dataset", "Hyperparams", "Train", "Done"];
function createFinetuneController() {
  let step = 0, method = "sft", lrTouched = false, rankTouched = false, es = null, log = [];
  let datasetOk = false, adapterPath = "";
  const trainPts = [], valPts = [];
  function show(n) {
    step = n;
    document.querySelectorAll("[data-fstep]").forEach((d) => d.style.display = +d.dataset.fstep === n ? "" : "none");
    renderSteps($("f-steps"), STEPS2, n);
  }
  async function resolveBaseByName(name, relPath) {
    if (!name && !relPath)
      return;
    const d = await api("/api/model/resolve-folder", { method: "POST", body: { folder_name: name || "", rel_path: relPath || "" } }).catch(() => ({ ok: false, error: "request failed" }));
    if (!d.ok) {
      toast(d.error || "could not locate this folder", "err");
      return;
    }
    $("f-model").value = d.path;
  }
  async function pickBaseFolder() {
    if (window.showDirectoryPicker) {
      try {
        const h = await window.showDirectoryPicker({ id: "mlx-models", mode: "read" });
        return resolveBaseByName(h.name);
      } catch {
        return;
      }
    }
    $("f-folder").click();
  }
  async function inspectDataset() {
    const path = $("f-data").value.trim();
    if (!path) {
      toast("Enter a dataset directory.", "err");
      return;
    }
    const out = $("f-inspect-out");
    out.innerHTML = '<div class="flash"><span class="shimmer">inspecting…</span></div>';
    const d = await api("/api/finetune/inspect-dataset", { method: "POST", body: { path } }).catch(() => ({ ok: false, error: "request failed" }));
    if (!d.ok) {
      out.innerHTML = '<div class="flash err">' + esc(d.error || "could not read dataset") + "</div>";
      datasetOk = false;
      $("f-next1").disabled = true;
      return;
    }
    datasetOk = true;
    $("f-next1").disabled = false;
    out.innerHTML = '<div class="flash ok"><strong>' + num(d.n_train) + "</strong> train rows" + (d.n_valid ? " · <strong>" + num(d.n_valid) + "</strong> valid rows" : "") + (d.format ? " · format <strong>" + esc(d.format) + "</strong>" : "") + "</div>";
  }
  function setMethod(m) {
    method = m;
    $("f-method").querySelectorAll("button").forEach((b) => b.classList.toggle("on", b.dataset.v === m));
    $("f-dpo-extra").style.display = m === "dpo" ? "" : "none";
    $("f-orpo-extra").style.display = m === "orpo" ? "" : "none";
    $("f-method-hint").textContent = m === "dpo" ? "Direct Preference Optimization — data is {prompt, chosen, rejected}." : m === "orpo" ? "Odds Ratio Preference Optimization (reference-free) — data is {prompt, chosen, rejected}." : "Supervised fine-tuning — data is messages or prompt+completion.";
    if (!lrTouched)
      $("f-lr").value = String(m === "dpo" ? 0.00005 : m === "orpo" ? 0.00001 : 0.0002);
    if (!rankTouched)
      $("f-rank").value = String(m === "orpo" ? 16 : 8);
  }
  function collectHP() {
    const modules = $("f-modules").value.split(",").map((s) => s.trim()).filter(Boolean);
    const hp = {
      model_dir: $("f-model").value.trim(),
      data_dir: $("f-data").value.trim(),
      method,
      rank: +$("f-rank").value,
      scale: +$("f-scale").value,
      lora_dropout: +$("f-dropout").value,
      target_modules: modules,
      num_layers: +$("f-layers").value,
      iters: +$("f-iters").value,
      batch_size: +$("f-batch").value,
      learning_rate: +$("f-lr").value,
      max_seq_length: +$("f-seq").value
    };
    if (method === "dpo") {
      hp.dpo_beta = +$("f-beta").value;
      hp.dpo_lr_schedule = $("f-sched").value;
    }
    if (method === "orpo") {
      hp.orpo_lambda = +$("f-orpo-lambda").value;
      hp.orpo_lr_schedule = $("f-orpo-sched").value;
      const scopeBtn = $("f-orpo-scope").querySelector("button.on");
      hp.sft_scope = scopeBtn && scopeBtn.dataset.v || "full";
    }
    return hp;
  }
  async function submit() {
    const btn = $("f-submit");
    btn.disabled = true;
    const d = await api("/api/finetune/submit", { method: "POST", body: collectHP() }).catch(() => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) {
      toast(d.error || "could not start training", "err");
      return;
    }
    adapterPath = d.adapter_path || "";
    $("f-out").textContent = adapterPath;
    $("f-merge-out").innerHTML = $("f-exp-out").innerHTML = $("f-push-panel").innerHTML = "";
    trainPts.length = 0;
    valPts.length = 0;
    log = [];
    $("f-log").textContent = "";
    $("f-bar").style.width = "0%";
    $("f-pct").textContent = "0%";
    $("f-msg").textContent = "Starting…";
    $("f-step").textContent = $("f-loss").textContent = $("f-curlr").textContent = $("f-curtps").textContent = "—";
    drawChart();
    show(3);
    attach(d.job_id);
  }
  function attach(jobId) {
    if (es)
      es.close();
    es = jobStream(jobId, {
      log: (e) => {
        log.push(e.line);
        $("f-log").textContent = log.slice(-200).join(`
`);
        $("f-log").scrollTop = $("f-log").scrollHeight;
      },
      metric: (e) => {
        if (e.kind === "val") {
          valPts.push({ step: e.step, loss: e.loss });
          $("f-leg-val").style.display = "";
        } else {
          trainPts.push({ step: e.step, loss: e.loss });
          $("f-step").textContent = num(e.step);
          $("f-loss").textContent = e.loss != null ? e.loss.toFixed(4) : "—";
          if (e.learning_rate != null)
            $("f-curlr").textContent = e.learning_rate.toExponential(2);
          if (e.tokens_per_sec != null)
            $("f-curtps").textContent = e.tokens_per_sec.toFixed(1);
          if (e.progress != null) {
            const p = Math.round(e.progress * 100);
            $("f-bar").style.width = p + "%";
            $("f-pct").textContent = p + "%";
          }
          if (e.message)
            $("f-msg").textContent = e.message;
        }
        drawChart();
      },
      stage: (e) => {
        if (e.progress != null) {
          const p = Math.round(e.progress * 100);
          $("f-bar").style.width = p + "%";
          $("f-pct").textContent = p + "%";
        }
        if (e.message)
          $("f-msg").textContent = e.message;
        if (e.stage === "done") {
          if (e.adapter_path) {
            adapterPath = e.adapter_path;
            $("f-out").textContent = e.adapter_path;
          }
          finish();
        }
      },
      done: () => finish(),
      failed: (e) => {
        $("f-msg").textContent = "Failed: " + (e.error || "unknown error");
        toast(e.error || "training failed", "err");
        es && es.close();
      }
    });
  }
  function finish() {
    $("f-bar").style.width = "100%";
    $("f-pct").textContent = "100%";
    es && es.close();
    if (!adapterPath)
      adapterPath = ($("f-out").textContent || "").trim();
    const base = $("f-model").value.trim();
    $("f-merge-a").value = adapterPath;
    $("f-exp-base").value = base;
    $("f-exp-adapter").value = adapterPath;
    show(4);
    if (controllers.chat && controllers.chat.refreshAdapters)
      controllers.chat.refreshAdapters();
  }
  async function mergeAdapters() {
    const a = $("f-merge-a").value.trim(), b = $("f-merge-b").value.trim();
    const out = $("f-merge-out");
    if (!a || !b) {
      out.innerHTML = '<div class="flash err">Enter both adapter paths.</div>';
      return;
    }
    out.innerHTML = '<div class="flash"><span class="shimmer">merging…</span></div>';
    const btn = $("f-merge-go");
    btn.disabled = true;
    const d = await api("/api/finetune/merge", { method: "POST", body: { adapter_a: a, adapter_b: b } }).catch(() => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) {
      out.innerHTML = '<div class="flash err">' + esc(d.error || "merge failed") + "</div>";
      return;
    }
    const stats = d.stats && typeof d.stats === "object" ? Object.entries(d.stats).map(([k, v]) => esc(k) + " " + esc(v)).join(" · ") : d.stats ? esc(d.stats) : "";
    out.innerHTML = '<div class="flash ok">Merged → <code>' + esc(d.merged_path || "") + "</code>" + (stats ? "<br>" + stats : "") + "</div>";
    toast("Adapters merged", "ok");
  }
  async function exportModel() {
    const base = $("f-exp-base").value.trim(), adapter = $("f-exp-adapter").value.trim();
    const out = $("f-exp-out");
    if (!base || !adapter) {
      out.innerHTML = '<div class="flash err">Enter a base model and adapter path.</div>';
      return;
    }
    out.innerHTML = '<div class="flash"><span class="shimmer">exporting…</span></div>';
    const btn = $("f-exp-go");
    btn.disabled = true;
    const d = await api("/api/finetune/export", { method: "POST", body: { base_model: base, adapter_path: adapter } }).catch(() => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) {
      out.innerHTML = '<div class="flash err">' + esc(d.error || "export failed") + "</div>";
      return;
    }
    out.innerHTML = '<div class="flash ok">Exported → <code>' + esc(d.export_path || "") + "</code></div>";
    toast("Model exported", "ok");
  }
  function drawChart() {
    const svg = $("f-chart");
    const W = 600, H = 200, padL = 8, padR = 8, padT = 12, padB = 12;
    const all = trainPts.concat(valPts);
    if (!all.length) {
      svg.innerHTML = '<text x="300" y="104" text-anchor="middle" fill="var(--dimmer)" font-size="13">waiting for the first metric…</text>';
      return;
    }
    const losses = all.map((p) => p.loss).filter((x) => x != null && isFinite(x));
    let minL = Math.min(...losses), maxL = Math.max(...losses);
    if (minL === maxL) {
      minL -= 0.5;
      maxL += 0.5;
    }
    const range = maxL - minL || 1;
    const maxStep = Math.max(...all.map((p) => p.step || 0), 1);
    const xOf = (s) => padL + s / maxStep * (W - padL - padR);
    const yOf = (l) => padT + (1 - (l - minL) / range) * (H - padT - padB);
    const path = (pts, color, fillId) => {
      if (!pts.length)
        return "";
      const d = pts.map((p, i) => (i ? "L" : "M") + xOf(p.step).toFixed(1) + " " + yOf(p.loss ?? 0).toFixed(1)).join(" ");
      let out = '<path d="' + d + '" fill="none" stroke="' + color + '" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/>';
      const area = d + " L" + xOf(pts[pts.length - 1].step).toFixed(1) + " " + (H - padB) + " L" + xOf(pts[0].step).toFixed(1) + " " + (H - padB) + " Z";
      out = '<path d="' + area + '" fill="url(#' + fillId + ')" opacity="0.18"/>' + out;
      return out;
    };
    let grid = "";
    for (let i = 1;i < 4; i++) {
      const y = padT + i / 4 * (H - padT - padB);
      grid += '<line x1="0" y1="' + y.toFixed(1) + '" x2="' + W + '" y2="' + y.toFixed(1) + '" stroke="rgba(255,255,255,.06)" stroke-width="1"/>';
    }
    svg.innerHTML = "<defs>" + '<linearGradient id="gf-train" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#30d158"/><stop offset="1" stop-color="#30d158" stop-opacity="0"/></linearGradient>' + '<linearGradient id="gf-val" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#0a84ff"/><stop offset="1" stop-color="#0a84ff" stop-opacity="0"/></linearGradient>' + "</defs>" + grid + path(valPts, "#0a84ff", "gf-val") + path(trainPts, "#30d158", "gf-train");
  }
  return {
    init() {
      show(0);
      $("f-next0").onclick = () => {
        if (!$("f-model").value.trim()) {
          toast("Enter a base model path.", "err");
          return;
        }
        show(1);
      };
      $("f-browse").onclick = pickBaseFolder;
      $("f-folder").addEventListener("change", (e) => {
        const input = e.target;
        const f = input.files[0];
        input.value = "";
        if (f)
          resolveBaseByName((f.webkitRelativePath || f.name).split("/")[0], f.webkitRelativePath || "");
      });
      {
        const drop = $("f-drop");
        const hi = (on) => {
          drop.style.outline = on ? "2px dashed var(--blue)" : "";
          drop.style.outlineOffset = on ? "4px" : "";
        };
        ["dragenter", "dragover"].forEach((ev) => drop.addEventListener(ev, (e) => {
          e.preventDefault();
          hi(true);
        }));
        ["dragleave", "drop"].forEach((ev) => drop.addEventListener(ev, (e) => {
          e.preventDefault();
          hi(false);
          const de = e;
          if (ev !== "drop" || !de.dataTransfer)
            return;
          for (const it of [...de.dataTransfer.items || []]) {
            const en = it.webkitGetAsEntry && it.webkitGetAsEntry();
            if (en && en.isDirectory)
              return void resolveBaseByName(en.name);
          }
          const f = de.dataTransfer.files && de.dataTransfer.files[0];
          if (f)
            resolveBaseByName((f.webkitRelativePath || f.name).split("/")[0]);
        }));
      }
      $("f-inspect").onclick = inspectDataset;
      $("f-data").addEventListener("keydown", (e) => {
        if (e.key === "Enter")
          inspectDataset();
      });
      $("f-data").addEventListener("input", () => {
        datasetOk = false;
        $("f-next1").disabled = true;
        $("f-inspect-out").innerHTML = "";
      });
      $("f-next1").onclick = () => {
        if (datasetOk)
          show(2);
      };
      $("f-method").querySelectorAll("button").forEach((b) => b.onclick = () => setMethod(b.dataset.v));
      $("f-orpo-scope").querySelectorAll("button").forEach((b) => b.onclick = () => $("f-orpo-scope").querySelectorAll("button").forEach((x) => x.classList.toggle("on", x === b)));
      $("f-lr").addEventListener("input", () => {
        lrTouched = true;
      });
      $("f-rank").addEventListener("input", () => {
        rankTouched = true;
      });
      document.querySelectorAll("#s-finetune [data-fback]").forEach((b) => b.onclick = () => show(step - 1));
      $("f-submit").onclick = submit;
      $("f-merge-go").onclick = mergeAdapters;
      $("f-exp-go").onclick = exportModel;
      $("f-push").onclick = () => pushToHub($("f-push-panel"), { kind: "finetune", source_path: adapterPath || ($("f-out").textContent || "").trim() });
      $("f-again").onclick = () => {
        $("f-inspect-out").innerHTML = "";
        $("f-merge-out").innerHTML = $("f-exp-out").innerHTML = $("f-push-panel").innerHTML = "";
        show(0);
      };
    }
  };
}

// src/web/src/dataset.ts
var STEPS3 = ["Template", "Inputs", "Generate", "Done"];
function createDatasetController() {
  let step = 0, templates = [], selected = null, jobId = null, es = null, log = [];
  function show(n) {
    step = n;
    document.querySelectorAll("[data-dstep]").forEach((d) => d.style.display = +d.dataset.dstep === n ? "" : "none");
    renderSteps($("d-steps"), STEPS3, n);
  }
  async function loadTemplates() {
    const grid = $("d-templates");
    grid.innerHTML = Array.from({ length: 4 }, () => '<div class="card" style="height:130px"><div class="shimmer" style="height:18px;width:50%;margin-bottom:12px"></div><div class="shimmer" style="height:13px;width:90%;margin-bottom:6px"></div><div class="shimmer" style="height:13px;width:70%"></div></div>').join("");
    const d = await api("/api/dataset/templates").catch(() => ({ templates: null }));
    templates = d.templates || [];
    if (!templates.length) {
      grid.innerHTML = `<div class="empty" style="grid-column:1/-1"><h3>No templates available</h3><p>The server didn't return any dataset templates. Make sure the server is running.</p></div>`;
      return;
    }
    const ordered = templates.slice().sort((a, b) => (a.needs_llm ? 1 : 0) - (b.needs_llm ? 1 : 0));
    grid.innerHTML = ordered.map((t) => '<div class="card" data-tid="' + esc(t.id) + '" style="cursor:pointer;display:flex;flex-direction:column;gap:8px">' + '<div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">' + '<h3 style="margin:0;font-size:16px;font-weight:700;letter-spacing:-.01em;color:var(--ink);text-transform:none">' + esc(t.label || t.id) + "</h3>" + (t.needs_llm ? '<span class="pill warn" style="padding:3px 9px;font-size:11px"><span class="dot"></span>uses local model</span>' : "") + (t.output_format ? '<span class="soon" style="color:var(--dim)">' + esc(t.output_format) + "</span>" : "") + "</div>" + '<p style="color:var(--dim);font-size:13.5px;line-height:1.5;margin:0">' + esc(t.description || "") + "</p>" + "</div>").join("");
    grid.querySelectorAll("[data-tid]").forEach((c) => c.onclick = () => selectTemplate(templates.find((t) => t.id === c.dataset.tid)));
  }
  function selectTemplate(t) {
    selected = t;
    $("d-form-title").textContent = t.label || t.id;
    $("d-form-desc").textContent = t.description || "";
    const form = $("d-form");
    form.innerHTML = (t.fields || []).map((f) => {
      const lbl = esc(f.label || f.name) + (f.required ? " *" : "");
      const ph = f.hint ? ' placeholder="' + esc(f.hint) + '"' : "";
      const dv = f.default != null ? f.default : "";
      let ctrl;
      if (f.type === "textarea")
        ctrl = '<textarea data-fld="' + esc(f.name) + '"' + ph + ">" + esc(dv) + "</textarea>";
      else if (f.type === "number")
        ctrl = '<input type="number" data-fld="' + esc(f.name) + '" value="' + esc(dv) + '"' + ph + ">";
      else
        ctrl = '<input type="text" data-fld="' + esc(f.name) + '" value="' + esc(dv) + '"' + ph + ">";
      return '<div class="field"><label>' + lbl + "</label>" + ctrl + (f.hint ? '<div class="hint">' + esc(f.hint) + "</div>" : "") + "</div>";
    }).join("");
    show(1);
  }
  async function submit() {
    if (!selected)
      return;
    const inputs = {};
    $("d-form").querySelectorAll("[data-fld]").forEach((i) => {
      inputs[i.dataset.fld] = i.type === "number" ? i.value === "" ? null : +i.value : i.value;
    });
    const body = { template_id: selected.id, inputs };
    if (selected.needs_llm && activeModelId)
      body.model_name = activeModelId;
    const btn = $("d-submit");
    btn.disabled = true;
    const d = await api("/api/dataset/submit", { method: "POST", body }).catch(() => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) {
      toast(d.error || "could not start generation", "err");
      return;
    }
    jobId = d.job_id || null;
    $("d-push-panel").innerHTML = "";
    $("d-out").textContent = d.output_dir || "";
    log = [];
    $("d-log").textContent = "";
    $("d-bar").style.width = "0%";
    $("d-pct").textContent = "0%";
    $("d-msg").textContent = "Starting…";
    $("d-ntrain").textContent = $("d-nvalid").textContent = "—";
    show(2);
    attach(jobId);
  }
  function attach(id) {
    if (es)
      es.close();
    es = jobStream(id, {
      log: (e) => {
        log.push(e.line);
        $("d-log").textContent = log.slice(-200).join(`
`);
        $("d-log").scrollTop = $("d-log").scrollHeight;
      },
      stage: (e) => {
        if (e.progress != null) {
          const p = Math.round(e.progress * 100);
          $("d-bar").style.width = p + "%";
          $("d-pct").textContent = p + "%";
        }
        if (e.message)
          $("d-msg").textContent = e.message;
        if (e.n_train != null)
          $("d-ntrain").textContent = num(e.n_train);
        if (e.n_valid != null)
          $("d-nvalid").textContent = num(e.n_valid);
        if (e.stage === "done") {
          if (e.output_dir)
            $("d-out").textContent = e.output_dir;
          finish(e);
        }
      },
      done: (e) => finish(e),
      failed: (e) => {
        $("d-msg").textContent = "Failed: " + (e.error || "unknown error");
        toast(e.error || "generation failed", "err");
        es && es.close();
      }
    });
  }
  function finish(e) {
    $("d-bar").style.width = "100%";
    $("d-pct").textContent = "100%";
    es && es.close();
    if (e && e.n_train != null)
      $("d-ntrain").textContent = num(e.n_train);
    if (e && e.n_valid != null)
      $("d-nvalid").textContent = num(e.n_valid);
    show(3);
  }
  return {
    init() {
      show(0);
      loadTemplates();
      document.querySelectorAll("#s-dataset [data-dback]").forEach((b) => b.onclick = () => show(0));
      $("d-submit").onclick = submit;
      $("d-push").onclick = () => pushToHub($("d-push-panel"), { kind: "dataset", job_id: jobId || undefined });
      $("d-again").onclick = () => {
        selected = null;
        $("d-push-panel").innerHTML = "";
        show(0);
      };
    }
  };
}

// src/web/src/status.ts
function createStatusController() {
  let timer = null, libTimer = null, fitLoaded = false;
  const dlRates = {};
  async function tick() {
    try {
      const [stats, models] = await Promise.all([
        fetch("/stats").then((r) => r.json()),
        fetch("/v1/models").then((r) => r.json())
      ]);
      const m = models.data && models.data[0];
      $("st-model-id").textContent = m && m.id || "—";
      const a = stats.admission || {};
      $("st-model-meta").textContent = num(m && m.context_window) + " token window · weights " + gb(a.weights_bytes);
      $("st-safe-ctx").textContent = num(a.max_safe_context);
      $("st-weights").textContent = gb(a.weights_bytes);
      $("st-usable").textContent = gb(a.usable_bytes);
      $("st-budget").textContent = a.memory_budget_bytes ? gb(a.memory_budget_bytes) : "off";
      $("st-mem-bar").style.width = a.usable_bytes ? Math.min(100, 100 * a.weights_bytes / a.usable_bytes) + "%" : "0%";
      const pc = stats.prompt_cache || {};
      const lookups = (pc.hits || 0) + (pc.misses || 0);
      $("st-pc-hits").textContent = lookups ? Math.round(100 * pc.hits / lookups) + "%" : "no lookups";
      $("st-pc-entries").textContent = num(pc.entries);
      $("st-pc-bytes").textContent = mb(pc.bytes) + " / " + mb(pc.max_bytes);
      $("st-pc-bar").style.width = pc.max_bytes ? Math.min(100, 100 * pc.bytes / pc.max_bytes) + "%" : "0%";
      const rs = stats.response_store || {};
      $("st-rs-entries").textContent = num(rs.entries);
      $("st-rs-bytes").textContent = mb(rs.bytes) + " / " + mb(rs.max_bytes);
      $("st-rs-ttl").textContent = rs.ttl_ms ? rs.ttl_ms / 60000 + " min" : "—";
      $("st-rs-bar").style.width = rs.max_bytes ? Math.min(100, 100 * rs.bytes / rs.max_bytes) + "%" : "0%";
      const kv = stats.kv_quant || {};
      $("st-kv-mode").innerHTML = "<code>" + esc(kv.mode || "—") + "</code>";
      const att = kv.attention;
      $("st-kv-layers").innerHTML = Object.entries(kv.layers || {}).map(([k, v]) => '<div class="kv"><b>' + esc(k) + ' layers</b><span class="num">' + esc(v) + "</span></div>").join("") + (att ? '<div class="kv"><b>attention</b><span class="num">' + esc(att.global) + " global · " + esc(att.sliding_window) + " sliding</span></div>" : "");
      await loadDownloads();
      if (!fitLoaded) {
        await loadFit();
        await loadLibrary();
      }
      if (stats.server && stats.server.started_at) {
        const up = (Date.now() - stats.server.started_at) / 1000;
        $("st-uptime").textContent = up < 90 ? Math.round(up) + "s" : up < 5400 ? Math.round(up / 60) + "m" : (up / 3600).toFixed(1) + "h";
      }
      $("st-updated").textContent = new Date().toLocaleTimeString();
    } catch {}
  }
  async function loadDownloads() {
    let downloads;
    try {
      ({ downloads } = await fetch("/downloads").then((r) => r.json()));
    } catch {
      return;
    }
    const card = $("st-dl-card");
    if (!downloads || downloads.length === 0) {
      card.style.display = "none";
      return;
    }
    card.style.display = "";
    const order = downloads.slice().sort((a, b) => (a.state === "active" ? 0 : 1) - (b.state === "active" ? 0 : 1) || b.startedAt - a.startedAt);
    $("st-dl-list").innerHTML = order.map((d) => {
      const pct = d.totalBytes ? Math.min(100, 100 * d.receivedBytes / d.totalBytes) : 0;
      let detail, barCls = "";
      if (d.state === "active") {
        let bps = d.bytesPerSec || 0;
        if (!bps) {
          const prev = dlRates[d.repoId], now = performance.now();
          if (prev && now > prev.t)
            bps = (d.receivedBytes - prev.bytes) / ((now - prev.t) / 1000);
          dlRates[d.repoId] = { bytes: d.receivedBytes, t: now };
        }
        const speed = bps > 0 ? " · " + mb(bps) + "/s · ~" + Math.max(1, Math.round((d.totalBytes - d.receivedBytes) / bps / 60)) + " min left" : "";
        detail = gb(d.receivedBytes) + " / " + gb(d.totalBytes) + " · " + pct.toFixed(0) + "%" + speed + (d.currentFile ? " · <code>" + esc(d.currentFile) + "</code>" : "");
        barCls = "warm";
      } else if (d.state === "done") {
        detail = gb(d.totalBytes) + ' · <span style="color:var(--green);font-weight:600">complete</span>';
      } else {
        detail = '<span style="color:var(--red);font-weight:600">error</span> · ' + esc(d.error || "");
      }
      return '<div style="padding:10px 0">' + '<div class="kv" style="border:none"><b>' + esc(d.repoId) + "</b>" + '<span class="num">' + d.filesDone + "/" + d.filesTotal + " files</span></div>" + '<div style="font-size:13.5px;color:var(--dim)" class="num">' + detail + "</div>" + '<div class="meter ' + barCls + '"><i style="width:' + pct + '%"></i></div></div>';
    }).join("");
  }
  async function loadLibrary() {
    let models;
    try {
      ({ models } = await fetch("/library").then((r) => r.json()));
    } catch {
      return;
    }
    if (!models)
      return;
    $("st-lib-body").innerHTML = models.slice().sort((a, b) => (b.serving ? 1 : 0) - (a.serving ? 1 : 0) || b.size_bytes - a.size_bytes).map((m) => {
      const a = m.assessment;
      let status;
      if (m.serving)
        status = '<span style="color:var(--blue);font-weight:700">SERVING</span>';
      else if (!m.supported)
        status = '<span style="color:var(--dimmer)">unsupported (' + esc(m.model_type) + ")</span>";
      else if (a && a.fits)
        status = '<span style="color:var(--green);font-weight:600">fits</span>';
      else
        status = '<span style="color:var(--red);font-weight:600">too big</span>';
      const safeCtx = m.supported && a && (a.max_safe_context ?? 0) > 0 ? num(a.max_safe_context) : "—";
      return "<tr" + (m.serving ? ' class="you"' : "") + "><td>" + esc(m.repo_id) + (m.vision ? ' · <span style="color:var(--dim)">vision</span>' : "") + '</td><td class="num">' + gb(m.size_bytes) + "</td><td>" + status + "</td>" + '<td class="num">' + safeCtx + "</td>" + '<td class="num">' + (m.supported && a && a.fits ? (a.predicted_decode_tps ?? 0).toFixed(0) + " tok/s" : "—") + "</td></tr>";
    }).join("");
  }
  async function loadFit() {
    let f;
    try {
      f = await fetch("/fit").then((r2) => r2.json());
    } catch {
      return;
    }
    fitLoaded = true;
    const r = f.report || {};
    if (f.measured_decode_tps) {
      $("st-tps").textContent = f.measured_decode_tps.toFixed(1);
      $("st-tps").closest(".card").querySelector("h3").textContent = "Decode · measured";
      $("st-tps-cap").textContent = "mlx-bun benchmark on this machine · predicted " + (f.typical_decode_tps || 0).toFixed(1) + " at " + num(f.typical_context_tokens) + " ctx";
    } else if (f.typical_decode_tps) {
      $("st-tps").textContent = f.typical_decode_tps.toFixed(1);
      $("st-tps-cap").textContent = "at " + num(f.typical_context_tokens) + " context · " + (r.predicted_decode_tps || 0).toFixed(1) + " tok/s at the " + num(f.context_tokens) + " max (full-KV reads)";
    } else {
      $("st-tps").textContent = (r.predicted_decode_tps || 0).toFixed(1);
    }
    $("st-m-ram").textContent = gb(f.machine && f.machine.ram_bytes);
    $("st-m-bw").textContent = (f.machine && f.machine.bandwidth_gbs || "—") + " GB/s";
    $("st-m-fits").innerHTML = r.fits ? '<span style="color:var(--green);font-weight:700">FITS</span>' : '<span style="color:var(--red);font-weight:700">DOES NOT FIT</span>';
    $("st-fit-ctx").textContent = num(f.context_tokens);
    $("st-f-weights").textContent = gb(r.weights_bytes);
    $("st-f-kv").textContent = gb(r.kv_bytes);
    $("st-f-transient").textContent = gb(r.transient_bytes);
    $("st-f-total").textContent = gb(r.total_bytes) + " / " + gb(r.usable_bytes);
    $("st-fit-bar").style.width = r.usable_bytes ? Math.min(100, 100 * (r.total_bytes ?? 0) / r.usable_bytes) + "%" : "0%";
    $("st-sku-ctx").textContent = num(f.sku_matrix_ctx);
    const myRam = Math.round((f.machine && f.machine.ram_bytes || 0) / 2 ** 30);
    const myChip = f.machine && f.machine.chip || null;
    const rows = f.sku_matrix || [];
    let youIdx = rows.findIndex((row) => myChip && row.sku === myChip && row.ram_gb === myRam);
    if (youIdx < 0 && myChip) {
      let best = Infinity;
      rows.forEach((row, i) => {
        if (row.sku === myChip && Math.abs(row.ram_gb - myRam) < best) {
          best = Math.abs(row.ram_gb - myRam);
          youIdx = i;
        }
      });
    }
    if (youIdx < 0)
      youIdx = rows.findIndex((row) => row.ram_gb === myRam);
    $("st-sku-body").innerHTML = rows.map((row, i) => {
      const you = i === youIdx;
      const dimCls = row.fits ? "num" : "num fit-no";
      return "<tr" + (you ? ' class="you"' : "") + "><td>" + esc(row.sku) + (you ? " · <b>this machine</b>" : "") + '</td><td class="num">' + row.ram_gb + " GB</td>" + '<td class="' + (row.fits ? "fit-yes" : "fit-no") + '">' + (row.fits ? "fits" : "no") + "</td>" + '<td class="' + dimCls + '">' + (row.max_context > 0 ? num(row.max_context) : "0 — weights alone don’t fit") + "</td>" + '<td class="' + dimCls + '">' + (row.decode_tps > 0 ? "~" + row.decode_tps.toFixed(0) + " tok/s" : "—") + "</td></tr>";
    }).join("");
  }
  return {
    init() {
      const page = $("status-page");
      requestAnimationFrame(() => page.classList.add("lit"));
      page.classList.add("lit");
    },
    enter() {
      tick();
      timer = setInterval(tick, 2000);
      loadLibrary();
      libTimer = setInterval(loadLibrary, 15000);
    },
    leave() {
      if (timer)
        clearInterval(timer);
      timer = null;
      if (libTimer)
        clearInterval(libTimer);
      libTimer = null;
    },
    refreshLibrary: loadLibrary
  };
}

// src/web/src/model-picker.ts
function gb2(n) {
  return (n / 2 ** 30).toFixed(1) + " GB";
}
function fitVerdict(a) {
  if (!a)
    return null;
  if (!a.fits)
    return "red";
  return a.predicted_decode_tps >= 10 ? "green" : "yellow";
}
function pickModel(models) {
  return [...models].sort((a, b) => {
    if (a.serving !== b.serving)
      return a.serving ? -1 : 1;
    if (a.supported !== b.supported)
      return a.supported ? -1 : 1;
    return a.repo_id.localeCompare(b.repo_id);
  });
}
function renderRow(m) {
  const verdict = fitVerdict(m.assessment);
  const dot = verdict ? '<span class="mp-fit-dot ' + verdict + '" aria-hidden="true"></span>' : '<span class="mp-fit-dot" aria-hidden="true" style="background:var(--dimmer)"></span>';
  const name = m.repo_id.split("/").pop() || m.repo_id;
  const quant = m.quant_bits ? m.quant_bits + "-bit" : "unquantized";
  const metaBits = [gb2(m.size_bytes), quant];
  if (m.vision)
    metaBits.push("vision");
  if (!m.supported)
    metaBits.push("unsupported model family");
  const tpsBit = m.assessment && m.assessment.fits ? m.assessment.predicted_decode_tps.toFixed(0) + " tok/s predicted" : m.assessment ? "doesn't fit this Mac's memory" : "fit unknown";
  const servingTag = m.serving ? '<div class="mp-serving-tag">● currently serving</div>' : "";
  const cmd = "mlx-bun serve " + m.repo_id;
  const cmdRow = m.serving || !m.supported ? "" : '<div class="mp-cmd"><code>' + esc(cmd) + '</code><button type="button" class="mp-copy" data-cmd="' + esc(cmd) + '">Copy</button></div>';
  return '<div class="mp-row' + (m.serving ? " serving" : "") + '">' + dot + '<div class="mp-main">' + '<div class="mp-name" title="' + esc(m.repo_id) + '">' + esc(name) + "</div>" + '<div class="mp-meta">' + esc(metaBits.join(" · ")) + " · " + esc(tpsBit) + "</div>" + servingTag + cmdRow + "</div>" + "</div>";
}
function renderModelPopBodyHtml(models) {
  if (!models.length) {
    return '<div class="mp-empty">No models downloaded yet. Use <code>mlx-bun get &lt;repo-id&gt;</code> to fetch one.</div>';
  }
  const rows = pickModel(models).map(renderRow).join("");
  return rows + '<div class="mp-foot-note">Fit is predicted for THIS Mac (src/fit.ts), not a generic guess. ' + "Switching the served model restarts the process — there's no live " + "in-process swap yet (that's a Phase 3 Hub feature); copy the command " + "above and restart.</div>";
}
async function refreshModelPop() {
  const body = $("model-pop-body");
  if (!body)
    return;
  body.innerHTML = '<div class="mp-empty">Loading…</div>';
  try {
    const d = await api("/library");
    const models = d.models || [];
    body.innerHTML = renderModelPopBodyHtml(models);
    body.querySelectorAll(".mp-copy").forEach((btn) => {
      btn.onclick = () => {
        const cmd = btn.dataset.cmd || "";
        if (navigator.clipboard) {
          navigator.clipboard.writeText(cmd).then(() => {
            const prev = btn.textContent;
            btn.textContent = "Copied";
            setTimeout(() => {
              btn.textContent = prev;
            }, 1200);
          }).catch(() => {});
        }
      };
    });
  } catch {
    body.innerHTML = '<div class="mp-empty">Could not reach the server.</div>';
  }
}
var modelPopOpen = false;
function setModelPopOpen(open) {
  if (open === modelPopOpen)
    return;
  modelPopOpen = open;
  $("model-pop").classList.toggle("open", open);
  $("nav-model").setAttribute("aria-expanded", String(open));
  if (open)
    refreshModelPop();
}
function closeModelPop() {
  setModelPopOpen(false);
}
function initModelPicker() {
  const btn = $("nav-model");
  if (!btn)
    return;
  btn.onclick = (e) => {
    e.stopPropagation();
    setModelPopOpen(!modelPopOpen);
  };
  $("model-pop").addEventListener("click", (e) => e.stopPropagation());
  document.addEventListener("click", () => setModelPopOpen(false));
  setModelPopClose(closeModelPop);
}

// src/web/src/main.ts
initHfSettings();
initTheme();
initShortcutSheet();
initDrawer();
initModelPicker();
initGlobalKeydown();
initRouter();
initDeveloperToggle();
controllers.chat = createChatController();
controllers.quantize = createQuantizeController();
controllers.finetune = createFinetuneController();
controllers.dataset = createDatasetController();
controllers.status = createStatusController();
if (!location.hash)
  location.replace("#/chat");
router();
pollIdentity();
setInterval(pollIdentity, 4000);
initRoutesProbe();
