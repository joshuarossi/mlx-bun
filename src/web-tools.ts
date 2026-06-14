// mlx-bun web-tools — outward-facing capabilities for the web chat agent:
// web_search, web_fetch, and weather. These are pi custom tools (defineTool)
// registered alongside the built-in coding tools so the local model can pull
// in current, real-world information instead of only inspecting the machine.
//
// Design notes:
//  - Keyless by default. weather uses Open-Meteo (no key, no anti-bot),
//    web_fetch is a plain HTTP GET, and web_search defaults to DuckDuckGo's
//    keyless HTML endpoint. Setting TAVILY_API_KEY or BRAVE_API_KEY upgrades
//    web_search to that provider's JSON API (more reliable, ranked results).
//  - Non-mutating: none of these touch the user's filesystem, so the web
//    chat's approval gate auto-allows them (they're not in GATED_TOOLS).
//    They DO make outbound network requests — that's the one thing that
//    leaves the machine, and only when the user asks for live info.
//  - execute() never throws on a network/upstream failure: it returns the
//    error as tool text so the model can read it and adapt (retry, tell the
//    user, fall back) rather than the turn aborting.
//
// The pure helpers (htmlToText, wmoCodeToText, parseDuckDuckGoHtml, the
// formatters) are exported and unit-tested without touching the network.

import { defineTool, type ToolDefinition } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

/** Tool names, exported so pi-web can add them to its tool allowlist. */
export const WEB_TOOL_NAMES = ["web_search", "web_fetch", "weather"] as const;

/** Browser-ish UA: some endpoints (DuckDuckGo) serve a challenge to blanks. */
const USER_AGENT =
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 " +
  "(KHTML, like Gecko) Chrome/124.0 Safari/537.36";

const FETCH_TIMEOUT_MS = 20_000;
/** Cap on text returned to the model from a fetched page. */
const MAX_FETCH_CHARS = 12_000;
const DEFAULT_SEARCH_RESULTS = 5;
const MAX_SEARCH_RESULTS = 10;

// ---- low-level fetch helper ------------------------------------------

/** Combine the tool's abort signal with a wall-clock timeout. */
function withTimeout(signal: AbortSignal | undefined, ms: number): AbortSignal {
  const timeout = AbortSignal.timeout(ms);
  return signal ? AbortSignal.any([signal, timeout]) : timeout;
}

interface FetchResult {
  ok: boolean;
  status: number;
  finalUrl: string;
  contentType: string;
  text: string;
}

/** GET/POST a URL and read the body as text, with timeout + abort wiring. */
async function httpText(
  url: string,
  opts: { method?: string; headers?: Record<string, string>; body?: string; signal?: AbortSignal; timeoutMs?: number },
): Promise<FetchResult> {
  const res = await fetch(url, {
    method: opts.method ?? "GET",
    headers: { "user-agent": USER_AGENT, ...opts.headers },
    body: opts.body,
    redirect: "follow",
    signal: withTimeout(opts.signal, opts.timeoutMs ?? FETCH_TIMEOUT_MS),
  });
  const contentType = res.headers.get("content-type") ?? "";
  const text = await res.text();
  return { ok: res.ok, status: res.status, finalUrl: res.url || url, contentType, text };
}

/** Normalize anything thrown by fetch (timeout, DNS, abort) into a message. */
function describeFetchError(err: unknown): string {
  if (err instanceof Error) {
    if (err.name === "TimeoutError") return "request timed out";
    if (err.name === "AbortError") return "request was cancelled";
    return err.message;
  }
  return String(err);
}

// ---- pure helpers (unit-tested) --------------------------------------

const NAMED_ENTITIES: Record<string, string> = {
  amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " ", "#39": "'", "#34": '"',
};

/** Decode the handful of HTML entities that show up in scraped text. */
export function decodeEntities(s: string): string {
  return s.replace(/&(#x?[0-9a-fA-F]+|[a-zA-Z]+);/g, (whole, body: string) => {
    if (body[0] === "#") {
      const code = body[1] === "x" || body[1] === "X" ? parseInt(body.slice(2), 16) : parseInt(body.slice(1), 10);
      return Number.isFinite(code) ? String.fromCodePoint(code) : whole;
    }
    return NAMED_ENTITIES[body] ?? whole;
  });
}

/** Strip all HTML tags from a fragment and decode entities (single-line). */
export function stripTags(html: string): string {
  return decodeEntities(html.replace(/<[^>]*>/g, "")).replace(/\s+/g, " ").trim();
}

/** Extract the <title> of an HTML document, if any. */
export function extractTitle(html: string): string | undefined {
  const m = html.match(/<title[^>]*>([\s\S]*?)<\/title>/i);
  return m ? stripTags(m[1] ?? "") : undefined;
}

/**
 * Reduce an HTML document to readable plain text: drop script/style/head,
 * turn block-level boundaries into newlines, strip remaining tags, decode
 * entities, and collapse runaway whitespace.
 */
export function htmlToText(html: string): string {
  let s = html
    .replace(/<!--[\s\S]*?-->/g, "")
    .replace(/<(script|style|noscript|template|svg)[^>]*>[\s\S]*?<\/\1>/gi, "")
    .replace(/<head[^>]*>[\s\S]*?<\/head>/gi, "");
  // Block-level close/break tags become newlines so structure survives.
  s = s.replace(/<\/(p|div|section|article|li|ul|ol|tr|h[1-6]|header|footer|nav|blockquote)>/gi, "\n");
  s = s.replace(/<br\s*\/?>/gi, "\n");
  s = s.replace(/<[^>]+>/g, "");
  s = decodeEntities(s);
  // Collapse spaces/tabs, trim each line, squeeze blank-line runs.
  s = s.replace(/[ \t\f\v]+/g, " ");
  s = s.split("\n").map((line) => line.trim()).join("\n");
  s = s.replace(/\n{3,}/g, "\n\n");
  return s.trim();
}

/** Clamp text to a max length, appending a clear truncation marker. */
export function truncate(text: string, max: number): string {
  if (text.length <= max) return text;
  return text.slice(0, max) + `\n\n…[truncated ${text.length - max} more characters]`;
}

/** WMO weather interpretation codes (Open-Meteo) → human description. */
export function wmoCodeToText(code: number): string {
  const map: Record<number, string> = {
    0: "clear sky", 1: "mainly clear", 2: "partly cloudy", 3: "overcast",
    45: "fog", 48: "depositing rime fog",
    51: "light drizzle", 53: "moderate drizzle", 55: "dense drizzle",
    56: "light freezing drizzle", 57: "dense freezing drizzle",
    61: "slight rain", 63: "moderate rain", 65: "heavy rain",
    66: "light freezing rain", 67: "heavy freezing rain",
    71: "slight snowfall", 73: "moderate snowfall", 75: "heavy snowfall",
    77: "snow grains",
    80: "slight rain showers", 81: "moderate rain showers", 82: "violent rain showers",
    85: "slight snow showers", 86: "heavy snow showers",
    95: "thunderstorm", 96: "thunderstorm with slight hail", 99: "thunderstorm with heavy hail",
  };
  return map[code] ?? `unknown (code ${code})`;
}

export interface SearchResult {
  title: string;
  url: string;
  snippet: string;
}

/** Resolve a DuckDuckGo redirect href (//duckduckgo.com/l/?uddg=…) to the real URL. */
export function resolveDdgHref(href: string): string {
  const decoded = decodeEntities(href);
  const m = decoded.match(/[?&]uddg=([^&]+)/);
  if (m && m[1]) {
    try {
      return decodeURIComponent(m[1]);
    } catch {
      return decoded;
    }
  }
  return decoded.startsWith("//") ? "https:" + decoded : decoded;
}

/**
 * Parse the result list out of html.duckduckgo.com/html/ output. Pairs each
 * result anchor (title + href) with the following snippet anchor by order.
 * Returns [] when the page carries no results (e.g. a challenge/empty page).
 */
export function parseDuckDuckGoHtml(html: string, limit: number): SearchResult[] {
  const results: SearchResult[] = [];
  const linkRe = /<a[^>]*class="[^"]*result__a[^"]*"[^>]*href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/gi;
  const snippetRe = /<a[^>]*class="[^"]*result__snippet[^"]*"[^>]*>([\s\S]*?)<\/a>/gi;
  const snippets: string[] = [];
  let sm: RegExpExecArray | null;
  while ((sm = snippetRe.exec(html)) !== null) snippets.push(stripTags(sm[1] ?? ""));
  let lm: RegExpExecArray | null;
  let i = 0;
  while ((lm = linkRe.exec(html)) !== null && results.length < limit) {
    const url = resolveDdgHref(lm[1] ?? "");
    const title = stripTags(lm[2] ?? "");
    if (!title || !url) {
      i++;
      continue;
    }
    results.push({ title, url, snippet: snippets[i] ?? "" });
    i++;
  }
  return results;
}

/** Render a result list as numbered Markdown for the model. */
export function formatSearchResults(query: string, results: SearchResult[], provider: string): string {
  if (results.length === 0) {
    return `No results found for "${query}" (via ${provider}).`;
  }
  const lines = results.map((r, idx) => {
    const head = `${idx + 1}. ${r.title}\n   ${r.url}`;
    return r.snippet ? `${head}\n   ${r.snippet}` : head;
  });
  return `Search results for "${query}" (via ${provider}):\n\n${lines.join("\n\n")}`;
}

// ---- weather: Open-Meteo geocode + forecast --------------------------

interface GeoPlace {
  name: string;
  latitude: number;
  longitude: number;
  country?: string;
  admin1?: string;
}

/** Format an Open-Meteo forecast response into a compact human summary. */
export function formatWeather(place: GeoPlace, data: unknown, fahrenheit: boolean): string {
  const d = data as {
    current?: {
      temperature_2m?: number;
      apparent_temperature?: number;
      relative_humidity_2m?: number;
      wind_speed_10m?: number;
      weather_code?: number;
    };
    daily?: { time?: string[]; weather_code?: number[]; temperature_2m_max?: number[]; temperature_2m_min?: number[]; precipitation_probability_max?: number[] };
  };
  const tUnit = fahrenheit ? "°F" : "°C";
  const wUnit = fahrenheit ? "mph" : "km/h";
  const where = [place.name, place.admin1, place.country].filter(Boolean).join(", ");
  const lines: string[] = [`Weather for ${where}:`];

  const cur = d.current;
  if (cur?.temperature_2m != null) {
    const desc = cur.weather_code != null ? `, ${wmoCodeToText(cur.weather_code)}` : "";
    const parts = [`${Math.round(cur.temperature_2m)}${tUnit}${desc}`];
    if (cur.apparent_temperature != null) parts.push(`feels like ${Math.round(cur.apparent_temperature)}${tUnit}`);
    if (cur.relative_humidity_2m != null) parts.push(`humidity ${Math.round(cur.relative_humidity_2m)}%`);
    if (cur.wind_speed_10m != null) parts.push(`wind ${Math.round(cur.wind_speed_10m)} ${wUnit}`);
    lines.push(`Now: ${parts.join(", ")}.`);
  }

  const daily = d.daily;
  if (daily?.time?.length) {
    lines.push("");
    lines.push("Forecast:");
    for (let i = 0; i < daily.time.length; i++) {
      const code = daily.weather_code?.[i];
      const hi = daily.temperature_2m_max?.[i];
      const lo = daily.temperature_2m_min?.[i];
      const pop = daily.precipitation_probability_max?.[i];
      const desc = code != null ? wmoCodeToText(code) : "";
      const range = hi != null && lo != null ? `${Math.round(lo)}–${Math.round(hi)}${tUnit}` : "";
      const rain = pop != null ? `, precip ${pop}%` : "";
      lines.push(`- ${daily.time[i]}: ${[range, desc].filter(Boolean).join(", ")}${rain}`);
    }
  }
  return lines.join("\n");
}

async function geocode(name: string, signal: AbortSignal | undefined): Promise<GeoPlace | undefined> {
  const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(name)}&count=1&language=en&format=json`;
  const res = await httpText(url, { signal });
  if (!res.ok) return undefined;
  const json = JSON.parse(res.text) as { results?: GeoPlace[] };
  return json.results?.[0];
}

// ---- web_search providers --------------------------------------------

async function searchTavily(query: string, count: number, signal: AbortSignal | undefined, apiKey: string): Promise<SearchResult[]> {
  const res = await httpText("https://api.tavily.com/search", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ api_key: apiKey, query, max_results: count, search_depth: "basic" }),
    signal,
  });
  if (!res.ok) throw new Error(`Tavily returned HTTP ${res.status}`);
  const json = JSON.parse(res.text) as { results?: Array<{ title?: string; url?: string; content?: string }> };
  return (json.results ?? []).slice(0, count).map((r) => ({ title: r.title ?? r.url ?? "", url: r.url ?? "", snippet: r.content ?? "" }));
}

async function searchBrave(query: string, count: number, signal: AbortSignal | undefined, apiKey: string): Promise<SearchResult[]> {
  const url = `https://api.search.brave.com/res/v1/web/search?q=${encodeURIComponent(query)}&count=${count}`;
  const res = await httpText(url, { headers: { "x-subscription-token": apiKey, accept: "application/json" }, signal });
  if (!res.ok) throw new Error(`Brave returned HTTP ${res.status}`);
  const json = JSON.parse(res.text) as { web?: { results?: Array<{ title?: string; url?: string; description?: string }> } };
  return (json.web?.results ?? []).slice(0, count).map((r) => ({ title: r.title ?? r.url ?? "", url: r.url ?? "", snippet: stripTags(r.description ?? "") }));
}

async function searchDuckDuckGo(query: string, count: number, signal: AbortSignal | undefined): Promise<SearchResult[]> {
  const url = `https://html.duckduckgo.com/html/?q=${encodeURIComponent(query)}`;
  const res = await httpText(url, { headers: { accept: "text/html" }, signal });
  if (!res.ok) throw new Error(`DuckDuckGo returned HTTP ${res.status}`);
  return parseDuckDuckGoHtml(res.text, count);
}

/** Pick the search backend from env; returns the provider label too. */
function resolveSearchProvider(): { name: string; run: (q: string, n: number, s: AbortSignal | undefined) => Promise<SearchResult[]> } {
  const tavily = process.env.TAVILY_API_KEY;
  if (tavily) return { name: "Tavily", run: (q, n, s) => searchTavily(q, n, s, tavily) };
  const brave = process.env.BRAVE_API_KEY;
  if (brave) return { name: "Brave", run: (q, n, s) => searchBrave(q, n, s, brave) };
  return { name: "DuckDuckGo", run: searchDuckDuckGo };
}

// ---- tool definitions ------------------------------------------------

function textResult(text: string): { content: [{ type: "text"; text: string }]; details: Record<string, never> } {
  return { content: [{ type: "text", text }], details: {} };
}

const webSearchTool = defineTool({
  name: "web_search",
  label: "Web Search",
  description:
    "Search the web for current, real-world information (news, facts, docs, anything that changes over time or that you don't already know). " +
    "Returns a ranked list of result titles, URLs, and snippets. Follow up with web_fetch to read a result in full.",
  parameters: Type.Object({
    query: Type.String({ description: "The search query." }),
    count: Type.Optional(Type.Number({ description: `Number of results to return (default ${DEFAULT_SEARCH_RESULTS}, max ${MAX_SEARCH_RESULTS}).` })),
  }),
  execute: async (_id, params, signal) => {
    const query = params.query.trim();
    if (!query) return textResult("web_search needs a non-empty query.");
    const count = Math.max(1, Math.min(MAX_SEARCH_RESULTS, Math.round(params.count ?? DEFAULT_SEARCH_RESULTS)));
    const provider = resolveSearchProvider();
    try {
      const results = await provider.run(query, count, signal);
      if (results.length === 0 && provider.name === "DuckDuckGo") {
        return textResult(
          `No results for "${query}". DuckDuckGo (the keyless default) may be rate-limiting; ` +
            `set TAVILY_API_KEY or BRAVE_API_KEY for a reliable search backend.`,
        );
      }
      return textResult(formatSearchResults(query, results, provider.name));
    } catch (err) {
      return textResult(`Web search failed (${provider.name}): ${describeFetchError(err)}`);
    }
  },
});

const webFetchTool = defineTool({
  name: "web_fetch",
  label: "Fetch URL",
  description:
    "Fetch a URL and return its contents as readable text (HTML pages are stripped to plain text). " +
    "Use this to read a web page, article, or API/JSON endpoint — e.g. after web_search, or when the user gives you a link.",
  parameters: Type.Object({
    url: Type.String({ description: "The absolute http(s) URL to fetch." }),
  }),
  execute: async (_id, params, signal) => {
    let url = params.url.trim();
    if (!/^https?:\/\//i.test(url)) url = "https://" + url;
    try {
      const res = await httpText(url, { headers: { accept: "text/html,application/json,text/plain,*/*" }, signal });
      const header = `Fetched ${res.finalUrl} (HTTP ${res.status})`;
      if (!res.ok) return textResult(`${header}\n\n${truncate(htmlToText(res.text), 2_000)}`);
      const isHtml = /text\/html|application\/xhtml/i.test(res.contentType);
      if (isHtml) {
        const title = extractTitle(res.text);
        const body = truncate(htmlToText(res.text), MAX_FETCH_CHARS);
        return textResult(`${header}${title ? `\nTitle: ${title}` : ""}\n\n${body}`);
      }
      const isTextual = /text\/|application\/(json|xml|javascript|x-ndjson)|\+json|\+xml/i.test(res.contentType) || res.contentType === "";
      if (!isTextual) {
        return textResult(`${header}\n\nContent-Type ${res.contentType || "unknown"} is not text; not displaying ${res.text.length} bytes of binary data.`);
      }
      return textResult(`${header}\n\n${truncate(res.text, MAX_FETCH_CHARS)}`);
    } catch (err) {
      return textResult(`Failed to fetch ${url}: ${describeFetchError(err)}`);
    }
  },
});

const weatherTool = defineTool({
  name: "weather",
  label: "Weather",
  description:
    "Get current weather conditions and a short forecast for a place. Accepts a city/place name (e.g. 'Austin', 'Paris, France', 'Tokyo'). " +
    "No API key required.",
  parameters: Type.Object({
    location: Type.String({ description: "City or place name to look up." }),
    unit: Type.Optional(Type.String({ description: "Temperature unit: 'celsius' or 'fahrenheit' (default celsius)." })),
  }),
  execute: async (_id, params, signal) => {
    const location = params.location.trim();
    if (!location) return textResult("weather needs a location.");
    const fahrenheit = params.unit === "fahrenheit";
    try {
      const place = await geocode(location, signal);
      if (!place) return textResult(`Couldn't find a place named "${location}".`);
      const params2 = new URLSearchParams({
        latitude: String(place.latitude),
        longitude: String(place.longitude),
        current: "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m",
        daily: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max",
        timezone: "auto",
        forecast_days: "3",
      });
      if (fahrenheit) {
        params2.set("temperature_unit", "fahrenheit");
        params2.set("wind_speed_unit", "mph");
      }
      const res = await httpText(`https://api.open-meteo.com/v1/forecast?${params2.toString()}`, { signal });
      if (!res.ok) return textResult(`Weather lookup failed: Open-Meteo returned HTTP ${res.status}.`);
      return textResult(formatWeather(place, JSON.parse(res.text), fahrenheit));
    } catch (err) {
      return textResult(`Weather lookup failed: ${describeFetchError(err)}`);
    }
  },
});

/** All web tools, ready to pass to createAgentSession({ customTools }). */
export function createWebTools(): ToolDefinition[] {
  return [webSearchTool, webFetchTool, weatherTool];
}
