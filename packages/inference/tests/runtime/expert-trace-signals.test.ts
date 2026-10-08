// Needs the native runtime (the tracer imports the FFI). Importing the tracer
// must not install process signal handlers: applications own cancellation.
import { expect, test } from "bun:test";

test("importing the expert tracer installs no SIGINT or SIGTERM handler", async () => {
  const before = { int: process.listenerCount("SIGINT"), term: process.listenerCount("SIGTERM") };
  const tracer = await import("../../src/runtime/expert-trace");
  expect(tracer.isExpertTracing()).toBe(false);
  expect(process.listenerCount("SIGINT")).toBe(before.int);
  expect(process.listenerCount("SIGTERM")).toBe(before.term);
});
