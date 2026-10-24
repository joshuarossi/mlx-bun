import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { MossImageSchedule, parseMossImageScheduleConfig } from "../../src/models/moss-image/scheduler";

const schedule = new MossImageSchedule(parseMossImageScheduleConfig({}));

// MFLUX a3b21fcaa88726b2267bd42bfc2e2d722f7d5a47, NumPy 2.5.4.
// Its unchanged scheduler class ran on the CPU, replacing only the final
// mx.array constructor with identity on the completed NumPy float32 array.
// Source SHA-256: e1984c828d091cc636c4a8389220b60aa1e4ec97c9f93bfcb619f9119d238b7e.
test("the eight-step schedule stores the reference's float64-snapped levels and float32 timesteps", () => {
  const sigmas = schedule.sigmas(8);
  expect(Array.from(new Uint32Array(sigmas.buffer))).toEqual([
    1065353216, 1064816345, 1064111702, 1063188955, 1061846778,
    1059833512, 1055723094, 1019517862, 0,
  ]);
  const timesteps = Float32Array.from(sigmas.subarray(0, -1), sigma => schedule.timestep(sigma));
  expect(Array.from(new Uint32Array(timesteps.buffer))).toEqual([
    1148846080, 1148321792, 1147633664, 1146732544,
    1145421824, 1143455744, 1139245056, 1103101952,
  ]);
});

test.each([
  [50, "2ed93135638ad7ed93982ea8331a2f1e5226cdd56584bc4a9b37f3cbd861ae3c"],
  [218, "ca7b69a5e91b6409c01dfcb0646eda1867c249a147204d10902455a86300e70c"],
] as const)("all sigma and timestep words match the reference at %d steps", (steps, digest) => {
  const sigmas = schedule.sigmas(steps);
  const timesteps = Float32Array.from(sigmas.subarray(0, -1), sigma => schedule.timestep(sigma));
  expect(createHash("sha256").update(new Uint8Array(sigmas.buffer))
    .update(new Uint8Array(timesteps.buffer)).digest("hex")).toBe(digest);
});

test("duplicate snapped levels reject the request instead of silently reducing its step count", () => {
  expect(() => schedule.sigmas(219)).toThrow("only 218 distinct steps");
  expect(() => schedule.sigmas(1000)).toThrow("only 615 distinct steps");
  expect(Array.from(schedule.sigmas(1))).toEqual([1, 0]);
  expect(Array.from(schedule.sigmas(2))).toEqual([1, Math.fround(0.024), 0]);
});
