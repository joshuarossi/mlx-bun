import { describe, expect, test } from "bun:test";
import { handleStaticRoute, type StaticRouteAssets } from "../src/serve/static-routes";

const assets: StaticRouteAssets = {
  appPage: "<main>app</main>",
  appJs: "app()",
  hljsJs: "hljs()",
  hljsCss: ".hljs{}",
  manifest: "{}",
  iconSvg: "<svg/>",
  serviceWorker: "worker()",
  curvePage: "<main>curve</main>",
};

function route(path: string, method = "GET"): Response | null {
  const url = new URL(path, "http://localhost");
  return handleStaticRoute(url, new Request(url, { method }), assets);
}

describe("static route handler", () => {
  test("serves the application shell", async () => {
    const response = route("/")!;
    expect(response.status).toBe(200);
    expect(response.headers.get("content-type")).toBe("text/html; charset=utf-8");
    expect(await response.text()).toBe(assets.appPage);
  });

  test("preserves asset content types and cache policy", async () => {
    const response = route("/assets/app.js")!;
    expect(response.headers.get("content-type")).toBe("text/javascript; charset=utf-8");
    expect(response.headers.get("cache-control")).toBe("public, max-age=3600");
    expect(await response.text()).toBe(assets.appJs);

    const worker = route("/sw.js")!;
    expect(worker.headers.get("cache-control")).toBe("no-store");
  });

  test("redirects legacy pages into the hash router", () => {
    const response = route("/quantize")!;
    expect(response.status).toBe(302);
    expect(response.headers.get("location")).toBe("/#/quantize");
  });

  test("leaves other methods and paths to the remaining router", () => {
    expect(route("/", "POST")).toBeNull();
    expect(route("/v1/models")).toBeNull();
  });
});
