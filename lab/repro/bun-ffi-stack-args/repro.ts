// Bun 1.3.14 macOS arm64: bun:ffi writes each STACK argument to its own
// 8-byte slot; the Apple arm64 ABI packs sub-8-byte stack args at natural
// size. Any signature whose 9th+ int-class args include a sub-8-byte type
// followed by more args gets shifted garbage in the callee.
//
// Build: cc -dynamiclib -o repro.dylib repro.c
// Run:   bun repro.ts
//
// conv2d_echo(int64* res, u64, u64, int, int, int, int, int, int, int, u64)
// Registers hold res..dilation_0 (8 args). Stack (Apple natural packing):
//   dilation_1 @ sp+0 (4B) | groups @ sp+4 (4B) | stream @ sp+8 (8B)
// Bun writes: dilation_1 @ sp+0, groups @ sp+8, stream @ sp+16
// → callee reads groups=0 (high half of slot 0), stream=<groups value>.
import { dlopen, ptr } from "bun:ffi";

const { symbols: C } = dlopen(new URL("repro.dylib", import.meta.url).pathname, {
  conv2d_echo: {
    args: ["ptr","u64","u64","i32","i32","i32","i32","i32","i32","i32","u64"],
    returns: "i32",
  },
});
const res = new BigInt64Array(10);
C.conv2d_echo(ptr(res), 111n, 222n, 2, 3, 4, 5, 6, 7, 8, 999n);
const got = Array.from(res).map(Number);
const want = [111, 222, 2, 3, 4, 5, 6, 7, 8, 999];
console.log("got :", got.join(","));
console.log("want:", want.join(","));
console.log(got.join(",") === want.join(",") ? "OK" : "CORRUPTED (bug present)");
