import { describe, expect, test } from "bun:test";
import {
  matchAuxiliaryRoute,
  type AuxiliaryRoute,
} from "../../src/serve/aux-routes";

const routes: Array<[string, string, AuxiliaryRoute]> = [
  ["GET", "/api/memory/status", "memory-status"],
  ["GET", "/api/memory/list", "memory-list"],
  ["GET", "/api/memory/search", "memory-search"],
  ["GET", "/api/memory/article", "memory-article"],
  ["GET", "/api/memory/links", "memory-links"],
  ["GET", "/api/memory/history", "memory-history"],
  ["GET", "/api/memory/diff", "memory-diff"],
  ["POST", "/api/memory/init", "memory-init"],
  ["GET", "/v1/memory/synthesize", "memory-synthesize"],
  ["GET", "/api/hub/local", "hub-local"],
  ["GET", "/api/hub/search", "hub-search"],
  ["POST", "/api/hub/download", "hub-download"],
  ["POST", "/api/hub/serve", "hub-serve"],
  ["GET", "/api/sessions/search", "sessions-search"],
  ["GET", "/api/sessions/export", "sessions-export"],
];

describe("auxiliary route dispatch", () => {
  test.each(routes)("matches %s %s", (method, pathname, expected) => {
    expect(matchAuxiliaryRoute(method, pathname)).toBe(expected);
  });

  test("rejects wrong methods and unrelated paths", () => {
    expect(matchAuxiliaryRoute("POST", "/api/memory/status")).toBeNull();
    expect(matchAuxiliaryRoute("GET", "/v1/models")).toBeNull();
  });
});
