import { describe, expect, test } from "bun:test";
import {
  matchDiscoveryRoute,
  type DiscoveryRoute,
} from "../src/serve/discovery-routes";

const routes: Array<[string, string, DiscoveryRoute]> = [
  ["GET", "/library", "library"],
  ["GET", "/downloads", "downloads"],
  ["GET", "/v1", "api-index"],
  ["GET", "/health", "health"],
  ["GET", "/v1/models", "models"],
  ["GET", "/v1/models/local%2Fmodel", "models"],
];

describe("discovery route dispatch", () => {
  test.each(routes)("matches %s %s", (method, pathname, expected) => {
    expect(matchDiscoveryRoute(method, pathname)).toBe(expected);
  });

  test("rejects wrong methods and unrelated paths", () => {
    expect(matchDiscoveryRoute("POST", "/library")).toBeNull();
    expect(matchDiscoveryRoute("GET", "/v1/models-extra")).toBeNull();
  });
});
