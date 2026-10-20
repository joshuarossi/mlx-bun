// The push-to-Hub flow a job panel's "Publish" host hook renders inline in its done step: make sure a write token is
// saved, take a repository id and visibility, post to the module's push route, show the result.
import { createApi, errorOf, esc } from "@mlx-bun/web-kit";
import { toast } from "@mlx-bun/web-shell";
import { refreshHfState } from "./settings";

export interface PushToHubOpts {
  kind: "quantize" | "finetune" | "dataset";
  job_id?: string;
  source_path?: string;
}

const api = createApi("/api/settings");

export async function pushToHub(container: HTMLElement, opts: PushToHubOpts): Promise<void> {
  const { kind, job_id, source_path } = opts;
  container.innerHTML = '<div class="pushpanel"><p class="muted"><span class="skeleton">Checking for a Hugging Face token…</span></p></div>';
  const wrap = container.firstElementChild as HTMLElement;
  let hasToken = false;
  const state = await api.get<{ hasToken?: boolean }>("hf-token");
  hasToken = state.ok !== false && !!state.hasToken;

  const renderForm = () => {
    wrap.innerHTML =
      (!hasToken
        ? '<div class="field"><label for="p-token">Hugging Face write token</label>' +
          '<input class="input" id="p-token" type="password" placeholder="hf_…" autocomplete="off" spellcheck="false">' +
          '<div class="hint">A write token from huggingface.co/settings/tokens, stored at <code>~/.mlx-bun/hf.json</code>.</div></div>'
        : "") +
      '<div class="field"><label for="p-repo">Repository id</label>' +
        '<input class="input" id="p-repo" type="text" placeholder="you/my-' + esc(kind === "dataset" ? "dataset" : "model") + '" autocomplete="off"></div>' +
      '<label class="check"><input type="checkbox" class="p-priv">Private repository</label>' +
      '<div class="p-msg" style="margin-top:10px"></div>' +
      '<div class="row" style="margin-top:12px"><button class="btn primary p-go" type="button">' + (hasToken ? "Push" : "Save token and push") + "</button></div>";
    (wrap.querySelector(".p-go") as HTMLButtonElement).onclick = () => { void go(); };
    (wrap.querySelector<HTMLElement>(hasToken ? "#p-repo" : "#p-token"))?.focus();
  };

  async function go(): Promise<void> {
    const message = wrap.querySelector(".p-msg") as HTMLElement;
    const repo = ((wrap.querySelector("#p-repo") as HTMLInputElement).value || "").trim();
    const isPrivate = (wrap.querySelector(".p-priv") as HTMLInputElement).checked;
    if (!repo) { message.innerHTML = '<div class="notice bad" role="alert">Enter a repository id, such as <code>you/my-model</code>.</div>'; return; }
    const button = wrap.querySelector(".p-go") as HTMLButtonElement;
    button.disabled = true;
    if (!hasToken) {
      const token = ((wrap.querySelector("#p-token") as HTMLInputElement).value || "").trim();
      if (!token) { message.innerHTML = '<div class="notice bad" role="alert">Enter a write token first.</div>'; button.disabled = false; return; }
      const saved = await api.post("hf-token", { token });
      if (!saved.ok) { message.innerHTML = '<div class="notice bad" role="alert">' + esc(errorOf(saved, "could not save the token")) + "</div>"; button.disabled = false; return; }
      hasToken = true;
      void refreshHfState();
    }
    message.innerHTML = '<p class="muted"><span class="skeleton">Pushing to ' + esc(repo) + "…</span></p>";
    const body: Record<string, unknown> = { repo_id: repo, private: isPrivate };
    if (job_id != null) body.job_id = job_id;
    if (source_path != null) body.source_path = source_path;
    const answer = await api.post<{ url?: string }>(`/api/${kind}/push`, body);
    button.disabled = false;
    if (!answer.ok) { message.innerHTML = '<div class="notice bad" role="alert">' + esc(errorOf(answer, "push failed")) + "</div>"; return; }
    const url = answer.url || ("https://huggingface.co/" + repo);
    wrap.innerHTML = '<div class="notice ok" role="status">Pushed to <a href="' + esc(url) + '" target="_blank" rel="noopener">' + esc(url) + "</a></div>";
    toast("Pushed to Hugging Face", "ok");
  }

  renderForm();
}
