// SSRF/resource-exhaustion policy for remote image_url/audio_url fetches
// (src/media-fetch.ts). Model-free: the policy functions are pure, and the
// fetch-behavior tests (redirect re-validation, size cap, timeout) run
// against an in-process loopback server — no external network, no weights.

import { afterAll, describe, expect, test } from "bun:test";
import {
  checkMediaUrl,
  defaultMediaFetchPolicy,
  fetchMediaBytes,
  isBlockedAddress,
  type MediaFetchPolicy,
} from "../../src/media-fetch";
import { configureRuntime } from "../../src/runtime-config";

const DEFAULT: MediaFetchPolicy = {
  allowPrivate: false,
  timeoutMs: 10_000,
  maxBytes: 64 * 1024 * 1024,
  maxRedirects: 5,
};

describe("isBlockedAddress", () => {
  const blocked = [
    "127.0.0.1", "127.255.255.254", // loopback
    "10.0.0.1", "10.255.255.255", // 10/8
    "172.16.0.1", "172.31.255.255", // 172.16/12
    "192.168.1.1", // 192.168/16
    "169.254.169.254", // link-local (cloud metadata)
    "100.64.0.1", "100.127.255.255", // CGNAT 100.64/10
    "0.0.0.0", "0.1.2.3", // this-net
    "224.0.0.1", "255.255.255.255", // multicast / broadcast
    "::", "::1", // v6 unspecified / loopback
    "[::1]", // bracketed
    "fe80::1", "fe80::1%en0", // link-local (+ zone index)
    "fc00::1", "fd12:3456::1", // ULA
    "ff02::1", // multicast
    "::ffff:127.0.0.1", "::ffff:192.168.0.10", // v4-mapped dotted
    "::ffff:7f00:1", // v4-mapped hex (URL's canonical form)
    "64:ff9b::7f00:1", // NAT64 embedding loopback
    "not-an-ip", "", // unparseable — fail closed
  ];
  for (const a of blocked)
    test(`blocks ${JSON.stringify(a)}`, () => expect(isBlockedAddress(a)).toBe(true));

  const allowed = [
    "93.184.216.34", "8.8.8.8", // public v4
    "172.15.0.1", "172.32.0.1", // just outside 172.16/12
    "100.63.0.1", "100.128.0.1", // just outside CGNAT
    "9.255.255.255", "11.0.0.1", // just outside 10/8
    "2607:f8b0:4004::5", "2001:4860:4860::8888", // public v6
    "::ffff:8.8.8.8", // v4-mapped public
  ];
  for (const a of allowed)
    test(`allows ${a}`, () => expect(isBlockedAddress(a)).toBe(false));
});

describe("checkMediaUrl", () => {
  const check = (url: string, policy = DEFAULT) => checkMediaUrl(new URL(url), policy);

  test("public https/http pass", () => {
    expect(check("https://example.com/cat.png")).toBeNull();
    expect(check("http://example.com:8080/a.wav")).toBeNull();
  });

  test("non-http(s) schemes rejected regardless of policy", () => {
    expect(check("ftp://example.com/a.png")).toContain("unsupported url scheme");
    expect(check("file:///etc/passwd")).toContain("unsupported url scheme");
    expect(check("ftp://example.com/a.png", { ...DEFAULT, allowPrivate: true }))
      .toContain("unsupported url scheme");
  });

  test("localhost and loopback/private literals rejected by default", () => {
    expect(check("http://localhost:8080/x")).toContain("blocked by default");
    expect(check("http://sub.localhost/x")).toContain("blocked by default");
    expect(check("http://127.0.0.1/x")).toContain("blocked by default");
    expect(check("http://[::1]:9000/x")).toContain("blocked by default");
    expect(check("http://192.168.1.20/nas.jpg")).toContain("blocked by default");
    expect(check("http://169.254.169.254/latest/meta-data")).toContain("blocked by default");
  });

  test("numeric IPv4 forms are canonicalized by URL parsing and caught", () => {
    // WHATWG URL parses these host forms to 127.0.0.1
    expect(check("http://2130706433/x")).toContain("blocked by default");
    expect(check("http://0x7f000001/x")).toContain("blocked by default");
    expect(check("http://127.1/x")).toContain("blocked by default");
  });

  test("allowPrivate opens private destinations but not schemes", () => {
    const lan = { ...DEFAULT, allowPrivate: true };
    expect(check("http://localhost:8080/x", lan)).toBeNull();
    expect(check("http://192.168.1.20/nas.jpg", lan)).toBeNull();
    expect(check("http://[::1]/x", lan)).toBeNull();
  });

  test("DNS names pass the sync check (resolved addresses are checked async)", () => {
    expect(check("https://internal.corp/logo.png")).toBeNull();
  });
});

describe("defaultMediaFetchPolicy", () => {
  test("safe defaults; MLX_BUN_ALLOW_PRIVATE_MEDIA=1 flips allowPrivate", () => {
    const restoreDefault = configureRuntime({ MLX_BUN_ALLOW_PRIVATE_MEDIA: undefined });
    try {
      const p = defaultMediaFetchPolicy();
      expect(p.allowPrivate).toBe(false);
      expect(p.timeoutMs).toBe(10_000);
      expect(p.maxBytes).toBe(64 * 1024 * 1024);
      const restorePrivate = configureRuntime({ MLX_BUN_ALLOW_PRIVATE_MEDIA: "1" });
      try {
        expect(defaultMediaFetchPolicy().allowPrivate).toBe(true);
      } finally {
        restorePrivate();
      }
    } finally {
      restoreDefault();
    }
  });
});

describe("fetchMediaBytes (no network)", () => {
  test("data: URLs decode locally, no policy applied", async () => {
    const bytes = new TextEncoder().encode("hello");
    const b64 = Buffer.from(bytes).toString("base64");
    expect(await fetchMediaBytes(`data:image/png;base64,${b64}`, "image", DEFAULT))
      .toEqual(bytes);
  });

  test("malformed data: URLs throw the original messages", async () => {
    expect(fetchMediaBytes("data:image/png", "image", DEFAULT))
      .rejects.toThrow("malformed data: URL");
    expect(fetchMediaBytes("data:image/png,notb64", "image", DEFAULT))
      .rejects.toThrow("data: URL must be base64");
  });

  test("non-http(s) schemes throw without any request", async () => {
    expect(fetchMediaBytes("ftp://example.com/a.png", "image", DEFAULT))
      .rejects.toThrow("unsupported");
    expect(fetchMediaBytes("not a url", "audio", DEFAULT))
      .rejects.toThrow("unsupported audio url scheme");
  });

  test("blocked destinations throw before any request is made", async () => {
    expect(fetchMediaBytes("http://169.254.169.254/latest/meta-data", "image", DEFAULT))
      .rejects.toThrow("blocked by default");
    expect(fetchMediaBytes("http://localhost:1/x.wav", "audio", DEFAULT))
      .rejects.toThrow("blocked by default");
  });
});

describe("fetchMediaBytes (loopback server)", () => {
  // allowPrivate lets the test reach its own loopback server; scheme,
  // redirect, timeout, and size-cap enforcement are unchanged by it.
  const LAN: MediaFetchPolicy = {
    allowPrivate: true,
    timeoutMs: 5_000,
    maxBytes: 50_000,
    maxRedirects: 2,
  };
  const payload = new Uint8Array(1024).fill(7);
  const big = new Uint8Array(200_000).fill(1);
  const server = Bun.serve({
    port: 0,
    hostname: "127.0.0.1",
    async fetch(req) {
      const path = new URL(req.url).pathname;
      if (path === "/ok") return new Response(payload);
      if (path === "/missing") return new Response("nope", { status: 404 });
      if (path === "/to-ftp")
        return new Response(null, { status: 302, headers: { location: "ftp://example.com/x" } });
      if (path === "/hop") // one extra hop before /ok — within maxRedirects
        return new Response(null, { status: 302, headers: { location: "/ok" } });
      if (path === "/via-hop")
        return new Response(null, { status: 302, headers: { location: "/hop" } });
      if (path === "/loop")
        return new Response(null, { status: 302, headers: { location: "/loop" } });
      if (path === "/big") return new Response(big);
      if (path === "/big-chunked") // no Content-Length — exercises the streaming counter
        return new Response(
          new ReadableStream({
            pull(c) {
              c.enqueue(big);
              c.close();
            },
          }),
        );
      if (path === "/slow") {
        await Bun.sleep(2_000);
        return new Response(payload);
      }
      return new Response("?", { status: 500 });
    },
  });
  const base = `http://127.0.0.1:${server.port}`;
  afterAll(() => server.stop(true));

  test("fetches bytes; redirect hops within the cap are followed", async () => {
    expect(await fetchMediaBytes(`${base}/ok`, "image", LAN)).toEqual(payload);
    expect(await fetchMediaBytes(`${base}/via-hop`, "image", LAN)).toEqual(payload);
  });

  test("non-2xx surfaces status", async () => {
    expect(fetchMediaBytes(`${base}/missing`, "image", LAN)).rejects.toThrow("404");
  });

  test("every redirect hop is re-validated (scheme change rejected)", async () => {
    expect(fetchMediaBytes(`${base}/to-ftp`, "image", LAN))
      .rejects.toThrow("unsupported url scheme");
  });

  test("redirect loops stop at maxRedirects", async () => {
    expect(fetchMediaBytes(`${base}/loop`, "image", LAN))
      .rejects.toThrow("more than 2 redirects");
  });

  test("size cap: Content-Length rejected up front, chunked while streaming", async () => {
    expect(fetchMediaBytes(`${base}/big`, "audio", LAN))
      .rejects.toThrow("exceeds the 0 MB limit"); // 50 kB cap rounds to 0 MB
    expect(fetchMediaBytes(`${base}/big-chunked`, "audio", LAN))
      .rejects.toThrow("exceeds the 0 MB limit");
  });

  test("wall-clock timeout aborts a stalled fetch with a clean message", async () => {
    const fast = { ...LAN, timeoutMs: 150 };
    expect(fetchMediaBytes(`${base}/slow`, "image", fast))
      .rejects.toThrow("timed out after 150 ms");
  });

  test("default policy blocks the loopback server outright", async () => {
    expect(fetchMediaBytes(`${base}/ok`, "image", DEFAULT))
      .rejects.toThrow("blocked by default");
  });
});
