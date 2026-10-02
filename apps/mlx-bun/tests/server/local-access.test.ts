import { expect, test } from "bun:test";
import { hostname } from "node:os";
import { createLocalAccess } from "../../src/server/local-access";

const request = (headers: Record<string, string>, method = "GET", path = "/v1/models") =>
  new Request(`http://placeholder${path}`, { method, headers });
const noPage = () => false;
/** The status a request gets: 0 when the policy lets it through. */
const status = (bound: string | null | undefined, headers: Record<string, string>, method = "GET", page: (request: Request) => boolean = noPage) =>
  createLocalAccess(bound).check(request(headers, method), page)?.status ?? 0;

test("a loopback bind accepts loopback Hosts only, so a DNS-rebound name is refused", () => {
  for (const bound of [undefined, "127.0.0.1", "localhost", "::1"]) {
    expect(createLocalAccess(bound).exposed).toBe(false);
    for (const host of ["127.0.0.1:8080", "localhost:8080", "LOCALHOST:8080", "[::1]:8080", "127.0.0.2:8080", "localhost", "127.0.0.1:9000", "host.docker.internal:8080"])
      expect([bound, host, status(bound, { host })]).toEqual([bound, host, 0]);
    for (const host of ["evil.example:8080", "evil.example", "192.168.1.5:8080", "localhost.evil.example:8080", "user@localhost:8080", "localhost/x", "[::2]:8080", ""])
      expect([bound, host, status(bound, { host })]).toEqual([bound, host, 403]);
  }
  // A client that sends no Host is not a browser.
  expect(status(undefined, {})).toBe(0);
});

test("a non-loopback bind accepts that host beside loopback; a wildcard bind accepts IP literals and the machine name", () => {
  const lan = createLocalAccess("192.168.1.5");
  expect(lan.exposed).toBe(true);
  for (const host of ["192.168.1.5:8080", "127.0.0.1:8080", "localhost:8080"]) expect([host, status("192.168.1.5", { host })]).toEqual([host, 0]);
  for (const host of ["10.0.0.2:8080", "evil.example:8080"]) expect([host, status("192.168.1.5", { host })]).toEqual([host, 403]);
  expect(status("mac.example", { host: "MAC.example:8080" })).toBe(0);
  const machine = hostname().toLowerCase().replace(/\.local$/, "");
  for (const bound of [null, "0.0.0.0", "::"]) {
    expect(createLocalAccess(bound).exposed).toBe(true);
    for (const host of ["10.0.0.2:8080", "[fe80::1]:8080", "localhost:8080", `${machine}:8080`, `${machine}.local:8080`])
      expect([bound, host, status(bound, { host })]).toEqual([bound, host, 0]);
    expect(status(bound, { host: "evil.example:8080" })).toBe(403);
  }
});

test("an Origin must be the origin the request was sent to, on every method and the WebSocket handshake", () => {
  for (const method of ["GET", "POST", "PUT", "PATCH", "DELETE"]) {
    expect(status(undefined, { host: "127.0.0.1:8080", origin: "http://127.0.0.1:8080" }, method)).toBe(0);
    expect(status(undefined, { host: "localhost:8080", origin: "http://LOCALHOST:8080" }, method)).toBe(0);
    expect(status(undefined, { host: "[::1]:8080", origin: "http://[::1]:8080" }, method)).toBe(0);
    expect(status(undefined, { host: "localhost", origin: "http://localhost:80" }, method)).toBe(0);
    // Behind a TLS proxy that keeps the Host.
    expect(status(undefined, { host: "localhost", origin: "https://localhost" }, method)).toBe(0);
    for (const origin of ["http://evil.example", "http://localhost:3000", "http://127.0.0.1:8080.evil.example", "https://127.0.0.1:9443", "ws://127.0.0.1:8080", "null", "file://"])
      expect([method, origin, status(undefined, { host: "127.0.0.1:8080", origin }, method)]).toEqual([method, origin, 403]);
    // Another loopback name is another origin.
    expect(status(undefined, { host: "127.0.0.1:8080", origin: "http://localhost:8080" }, method)).toBe(403);
    expect(status(undefined, { origin: "http://127.0.0.1:8080" }, method)).toBe(403);
  }
  const refused = createLocalAccess(undefined).check(request({ host: "127.0.0.1:8080", origin: "http://evil.example" }, "POST"), noPage)!;
  return refused.json().then(body => expect(body).toEqual({ error: { message: "cross-origin request from http://evil.example refused", type: "forbidden", code: "cross_origin" } }));
});

test("Sec-Fetch-Site admits the app's own requests and typed URLs; another site may only navigate to a page of the web app", () => {
  const host = { host: "127.0.0.1:8080" };
  for (const site of ["same-origin", "none"]) expect(status(undefined, { ...host, "sec-fetch-site": site })).toBe(0);
  const page = (request: Request) => new URL(request.url).pathname === "/";
  const cross = (site: string, mode: string, path: string, method = "GET") =>
    createLocalAccess(undefined).check(request({ ...host, "sec-fetch-site": site, "sec-fetch-mode": mode }, method, path), page)?.status ?? 0;
  for (const site of ["cross-site", "same-site"]) {
    // A link from elsewhere still opens the app.
    expect(cross(site, "navigate", "/")).toBe(0);
    // A GET with side effects (synthesis, a benchmark task listing that spawns a process) is not a page: refused however it is requested.
    for (const path of ["/v1/memory/synthesize", "/api/benchmarks/tasks", "/v1/models"])
      for (const mode of ["navigate", "no-cors", "cors"]) expect([site, path, mode, cross(site, mode, path)]).toEqual([site, path, mode, 403]);
    expect(cross(site, "no-cors", "/")).toBe(403);
    expect(cross(site, "navigate", "/", "POST")).toBe(403);
  }
});
