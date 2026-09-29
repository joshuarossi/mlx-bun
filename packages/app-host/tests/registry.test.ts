import { expect, test } from "bun:test";
import { createRegistry } from "@mlx-bun/app-host";

const nav = (label: string) => ({ label, path: `/${label}` });

test("registrations list in order with their source, and end with their unsubscribe", () => {
  const host = createRegistry();
  const alpha = host.scoped("alpha", ["shell.nav"]), beta = host.scoped("beta", ["shell.nav", "shell.setting"]);
  const first = alpha.register("shell.nav", nav("one"));
  beta.register("shell.nav", nav("two"));
  expect(host.reader.list("shell.nav").map(entry => [entry.source, entry.contribution.label])).toEqual([["alpha", "one"], ["beta", "two"]]);
  expect(host.reader.list("shell.setting")).toEqual([]);
  first();
  first();
  expect(host.reader.list("shell.nav").map(entry => entry.source)).toEqual(["beta"]);
});

test("a module cannot register to a point it did not declare", () => {
  const registry = createRegistry().scoped("alpha", ["shell.nav"]);
  expect(() => registry.register("shell.setting", { key: "k", label: "", summary: "", type: "string" })).toThrow('module alpha did not declare "shell.setting"');
});

test("listeners hear adds, removals and a module's removal once, and a throwing listener never breaks the registrant", () => {
  const host = createRegistry();
  const alpha = host.scoped("alpha", ["shell.nav"]);
  let calls = 0;
  host.reader.onChange("shell.nav", () => { calls++; });
  host.reader.onChange("shell.nav", () => { throw new Error("listener"); });
  const stop = alpha.register("shell.nav", nav("one"));
  alpha.register("shell.nav", nav("two"));
  expect(calls).toBe(2);
  stop();
  expect(calls).toBe(3);
  host.removeSource("alpha");
  expect(calls).toBe(4);
  host.removeSource("alpha");
  expect(calls).toBe(4);
  expect(host.reader.list("shell.nav")).toEqual([]);
});
