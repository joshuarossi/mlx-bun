// Unit tests for the pure helpers in src/web-tools.ts — HTML/text
// normalization, DuckDuckGo result parsing, and the weather/search
// formatters. No network: execute() paths are exercised live in the
// verify step, not here.

import { describe, expect, it } from "bun:test";
import {
  decodeEntities,
  extractTitle,
  fetchWebText,
  formatSearchResults,
  formatWeather,
  htmlToText,
  parseDuckDuckGoHtml,
  resolveDdgHref,
  stripTags,
  truncate,
  wmoCodeToText,
  type SearchResult,
} from "../src/web-tools";
import type {
  MediaFetchPolicy,
  RestrictedFetch,
  RestrictedFetchDependencies,
} from "../src/media-fetch";

describe("decodeEntities", () => {
  it("decodes named and numeric entities", () => {
    expect(decodeEntities("a &amp; b &lt;c&gt; &quot;d&quot; &#39;e&#39; &#x41;")).toBe('a & b <c> "d" \'e\' A');
  });
  it("leaves unknown entities untouched", () => {
    expect(decodeEntities("&unknownentity;")).toBe("&unknownentity;");
  });
});

describe("stripTags", () => {
  it("removes tags, decodes entities, collapses whitespace", () => {
    expect(stripTags("  <b>Hello</b>   &amp;   <i>world</i>  ")).toBe("Hello & world");
  });
});

describe("extractTitle", () => {
  it("pulls and cleans the document title", () => {
    expect(extractTitle("<html><head><title>My &amp; Page</title></head><body>x</body></html>")).toBe("My & Page");
  });
  it("returns undefined when there is no title", () => {
    expect(extractTitle("<html><body>no title</body></html>")).toBeUndefined();
  });
});

describe("htmlToText", () => {
  it("drops scripts/styles and keeps block structure as newlines", () => {
    const html =
      "<html><head><title>T</title></head><body>" +
      "<script>var x = 1 < 2;</script><style>.a{color:red}</style>" +
      "<h1>Heading</h1><p>First paragraph.</p><p>Second &amp; line.</p>" +
      "<ul><li>one</li><li>two</li></ul></body></html>";
    const text = htmlToText(html);
    expect(text).toContain("Heading");
    expect(text).toContain("First paragraph.");
    expect(text).toContain("Second & line.");
    expect(text).toContain("one");
    expect(text).toContain("two");
    // script/style contents must be gone
    expect(text).not.toContain("color:red");
    expect(text).not.toContain("var x");
    // block boundaries became line breaks
    expect(text.split("\n").length).toBeGreaterThan(1);
  });
  it("squeezes excessive blank lines", () => {
    expect(htmlToText("<p>a</p><p></p><p></p><p>b</p>")).not.toMatch(/\n{3,}/);
  });
});

describe("truncate", () => {
  it("leaves short text alone", () => {
    expect(truncate("hello", 10)).toBe("hello");
  });
  it("clamps long text with a marker", () => {
    const out = truncate("abcdefghij", 4);
    expect(out.startsWith("abcd")).toBe(true);
    expect(out).toContain("truncated");
  });
});

describe("wmoCodeToText", () => {
  it("maps known codes", () => {
    expect(wmoCodeToText(0)).toBe("clear sky");
    expect(wmoCodeToText(61)).toBe("slight rain");
    expect(wmoCodeToText(95)).toBe("thunderstorm");
  });
  it("describes unknown codes without throwing", () => {
    expect(wmoCodeToText(1234)).toContain("1234");
  });
});

describe("resolveDdgHref", () => {
  it("decodes the uddg redirect parameter", () => {
    expect(resolveDdgHref("//duckduckgo.com/l/?uddg=https%3A%2F%2Fexample.com%2Fa%3Fb%3D1&amp;rut=xyz")).toBe(
      "https://example.com/a?b=1",
    );
  });
  it("upgrades protocol-relative hrefs", () => {
    expect(resolveDdgHref("//example.com/x")).toBe("https://example.com/x");
  });
  it("passes through absolute hrefs", () => {
    expect(resolveDdgHref("https://example.com/")).toBe("https://example.com/");
  });
});

describe("parseDuckDuckGoHtml", () => {
  const fixture = `
    <div class="result results_links">
      <h2 class="result__title">
        <a rel="nofollow" class="result__a" href="//duckduckgo.com/l/?uddg=https%3A%2F%2Fexample.com%2Fone&amp;rut=a">First <b>Result</b></a>
      </h2>
      <a class="result__snippet" href="//x">Snippet <b>one</b> here.</a>
    </div>
    <div class="result results_links">
      <h2 class="result__title">
        <a rel="nofollow" class="result__a" href="//duckduckgo.com/l/?uddg=https%3A%2F%2Fexample.org%2Ftwo&amp;rut=b">Second Result</a>
      </h2>
      <a class="result__snippet" href="//y">Snippet two here.</a>
    </div>`;

  it("extracts titles, resolved urls, and snippets", () => {
    const results = parseDuckDuckGoHtml(fixture, 10);
    expect(results).toHaveLength(2);
    expect(results[0]).toEqual({ title: "First Result", url: "https://example.com/one", snippet: "Snippet one here." });
    expect(results[1]?.url).toBe("https://example.org/two");
    expect(results[1]?.title).toBe("Second Result");
  });

  it("honors the result limit", () => {
    expect(parseDuckDuckGoHtml(fixture, 1)).toHaveLength(1);
  });

  it("returns [] for a result-less page", () => {
    expect(parseDuckDuckGoHtml("<html><body>challenge page</body></html>", 5)).toEqual([]);
  });
});

describe("formatSearchResults", () => {
  const results: SearchResult[] = [
    { title: "T1", url: "https://a.com", snippet: "snip 1" },
    { title: "T2", url: "https://b.com", snippet: "" },
  ];
  it("numbers results and includes urls + provider", () => {
    const out = formatSearchResults("cats", results, "DuckDuckGo");
    expect(out).toContain('"cats"');
    expect(out).toContain("DuckDuckGo");
    expect(out).toContain("1. T1");
    expect(out).toContain("https://a.com");
    expect(out).toContain("snip 1");
    expect(out).toContain("2. T2");
  });
  it("reports no results clearly", () => {
    expect(formatSearchResults("cats", [], "Brave")).toMatch(/no results/i);
  });
});

describe("formatWeather", () => {
  const place = { name: "Austin", latitude: 30.27, longitude: -97.74, country: "United States", admin1: "Texas" };
  const data = {
    current: { temperature_2m: 22, apparent_temperature: 23, relative_humidity_2m: 55, wind_speed_10m: 12, weather_code: 2 },
    daily: {
      time: ["2026-06-14", "2026-06-15"],
      weather_code: [1, 61],
      temperature_2m_max: [30, 28],
      temperature_2m_min: [20, 19],
      precipitation_probability_max: [10, 80],
    },
  };
  it("summarizes current conditions and the forecast", () => {
    const out = formatWeather(place, data, false);
    expect(out).toContain("Austin");
    expect(out).toContain("Texas");
    expect(out).toContain("Now:");
    expect(out).toContain("22°C");
    expect(out).toContain("partly cloudy");
    expect(out).toContain("Forecast:");
    expect(out).toContain("2026-06-15");
    expect(out).toContain("20–30°C");
    expect(out).toContain("precip 80%");
  });
  it("uses fahrenheit units when requested", () => {
    expect(formatWeather(place, data, true)).toContain("22°F");
  });
});

const RESTRICTED_WEB_POLICY: MediaFetchPolicy = {
  allowPrivate: false,
  timeoutMs: 1_000,
  maxBytes: 64,
  maxRedirects: 2,
};

function webFetchDependencies(
  fetch: RestrictedFetch,
  resolve: RestrictedFetchDependencies["resolve"] = async () => [
    { address: "93.184.216.34" },
  ],
): RestrictedFetchDependencies {
  return { fetch, resolve };
}

describe("fetchWebText restricted transport", () => {
  it("rejects loopback and private literals before fetch", async () => {
    let fetchCalls = 0;
    const dependencies = webFetchDependencies(async () => {
      fetchCalls++;
      return new Response("secret");
    });

    for (const url of [
      "http://127.0.0.1/api/settings/hf-token",
      "http://169.254.169.254/latest/meta-data",
      "http://192.168.1.1/admin",
      "http://[::1]/private",
    ]) {
      await expect(
        fetchWebText(url, undefined, {
          policy: RESTRICTED_WEB_POLICY,
          dependencies,
        }),
      ).rejects.toThrow(/url rejected|blocked by default/);
    }
    expect(fetchCalls).toBe(0);
  });

  it("rejects a hostname when DNS returns any private address", async () => {
    let fetchCalls = 0;
    const dependencies = webFetchDependencies(
      async () => {
        fetchCalls++;
        return new Response("secret");
      },
      async () => [
        { address: "93.184.216.34" },
        { address: "10.0.0.8" },
      ],
    );

    await expect(
      fetchWebText("https://public-looking.test/data", undefined, {
        policy: RESTRICTED_WEB_POLICY,
        dependencies,
      }),
    ).rejects.toThrow(/resolves to 10\.0\.0\.8/);
    expect(fetchCalls).toBe(0);
  });

  it("revalidates a public-to-private redirect before the second request", async () => {
    const requested: string[] = [];
    const dependencies = webFetchDependencies(async (input) => {
      requested.push(String(input));
      return new Response(null, {
        status: 302,
        headers: { location: "http://127.0.0.1/api/settings/hf-token" },
      });
    });

    await expect(
      fetchWebText("https://public.test/start", undefined, {
        policy: RESTRICTED_WEB_POLICY,
        dependencies,
      }),
    ).rejects.toThrow(/127\.0\.0\.1/);
    expect(requested).toEqual(["https://93.184.216.34/start"]);
  });

  it("dials the checked address instead of re-resolving the hostname", async () => {
    let resolveCalls = 0;
    let requested = "";
    let init: BunFetchRequestInit | undefined;
    const dependencies = webFetchDependencies(
      async (input, requestInit) => {
        requested = String(input);
        init = requestInit;
        return new Response("pinned");
      },
      async () => {
        resolveCalls++;
        return [{ address: resolveCalls === 1 ? "93.184.216.34" : "127.0.0.1" }];
      },
    );

    const result = await fetchWebText("https://public.test/article", undefined, {
      policy: RESTRICTED_WEB_POLICY,
      dependencies,
    });

    expect(resolveCalls).toBe(1);
    expect(requested).toBe("https://93.184.216.34/article");
    expect(new Headers(init?.headers).get("host")).toBe("public.test");
    expect(init?.tls?.serverName).toBe("public.test");
    expect(result.finalUrl).toBe("https://public.test/article");
  });

  it("stops redirect chains at the configured cap", async () => {
    let fetchCalls = 0;
    const dependencies = webFetchDependencies(async () => {
      fetchCalls++;
      return new Response(null, {
        status: 302,
        headers: { location: `/hop-${fetchCalls}` },
      });
    });

    await expect(
      fetchWebText("https://public.test/start", undefined, {
        policy: RESTRICTED_WEB_POLICY,
        dependencies,
      }),
    ).rejects.toThrow("more than 2 redirects");
    expect(fetchCalls).toBe(3);
  });

  it("cancels a chunked response as soon as it crosses the byte cap", async () => {
    let canceled = false;
    const body = new ReadableStream<Uint8Array>({
      pull(controller) {
        controller.enqueue(new Uint8Array(30));
      },
      cancel() {
        canceled = true;
      },
    });
    const dependencies = webFetchDependencies(async () =>
      new Response(body, { headers: { "content-type": "text/plain" } })
    );

    await expect(
      fetchWebText("https://public.test/chunked", undefined, {
        policy: RESTRICTED_WEB_POLICY,
        dependencies,
      }),
    ).rejects.toThrow("response exceeds");
    expect(canceled).toBe(true);
  });

  it("returns normal text with final metadata and preserves request headers", async () => {
    let init: BunFetchRequestInit | undefined;
    const dependencies = webFetchDependencies(async (_input, requestInit) => {
      init = requestInit;
      return new Response("hello, public web", {
        headers: { "content-type": "text/plain; charset=utf-8" },
      });
    });

    const result = await fetchWebText("https://public.test/article", undefined, {
      policy: RESTRICTED_WEB_POLICY,
      dependencies,
    });

    expect(result).toEqual({
      ok: true,
      status: 200,
      finalUrl: "https://public.test/article",
      contentType: "text/plain; charset=utf-8",
      text: "hello, public web",
    });
    expect(init?.redirect).toBe("manual");
    expect(new Headers(init?.headers).get("accept")).toContain("text/html");
    expect(new Headers(init?.headers).get("user-agent")).toContain("Mozilla");
  });

  it("applies one wall-clock timeout to the restricted fetch", async () => {
    let fetchSignal: AbortSignal | undefined;
    const dependencies = webFetchDependencies(async (_input, init) => {
      fetchSignal = init?.signal ?? undefined;
      return await new Promise<Response>((_resolve, reject) => {
        const signal = init?.signal;
        if (!signal) return;
        const rejectAbort = () => reject(signal.reason);
        if (signal.aborted) rejectAbort();
        else signal.addEventListener("abort", rejectAbort, { once: true });
      });
    });

    await expect(
      fetchWebText("https://public.test/slow", undefined, {
        policy: { ...RESTRICTED_WEB_POLICY, timeoutMs: 20 },
        dependencies,
      }),
    ).rejects.toThrow("timed out after 20 ms");
    expect(fetchSignal?.reason).toMatchObject({ name: "TimeoutError" });
  });

  it("combines caller cancellation with the transport timeout", async () => {
    const controller = new AbortController();
    let fetchSignal: AbortSignal | undefined;
    const dependencies = webFetchDependencies(async (_input, init) => {
      fetchSignal = init?.signal ?? undefined;
      return await new Promise<Response>((_resolve, reject) => {
        const signal = init?.signal;
        if (!signal) return;
        const rejectAbort = () => reject(signal.reason);
        if (signal.aborted) rejectAbort();
        else signal.addEventListener("abort", rejectAbort, { once: true });
      });
    });

    const pending = fetchWebText(
      "https://public.test/slow",
      controller.signal,
      { policy: RESTRICTED_WEB_POLICY, dependencies },
    );
    await Promise.resolve();
    controller.abort();

    await expect(pending).rejects.toMatchObject({ name: "AbortError" });
    expect(fetchSignal?.aborted).toBe(true);
  });
});
