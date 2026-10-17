import host.ts.Harness

/-! Kernel-checked unit runs of the semantics on small programs. -/

namespace Host.Ts.Tests.Snippet.Arith
open Host.Ts
def source : String := "const out = [1 + 2 * 3, 7 % 3, -7 % 3, 2 ** 10, (5 >>> 0), (-1 >>> 0), 0xff & 0x0f, Math.floor(-2.5), Math.ceil(2.1), Math.min(3, 1, 2), 0.1 + 0.2 === 0.30000000000000004];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 7, .num 1, .num (-1), .num 1024, .num 5, .num 4294967295, .num 15, .num (-3), .num 3, .num 1, .bool true])) = some true
end Host.Ts.Tests.Snippet.Arith

namespace Host.Ts.Tests.Snippet.Closures
open Host.Ts
def source : String := "function mk() { let c = 0; return () => ++c; } const f = mk(); f(); f(); const out = [f(), [1, 2, 3].map(x => x * 2)];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 3, .arr [.num 2, .num 4, .num 6]])) = some true
end Host.Ts.Tests.Snippet.Closures

namespace Host.Ts.Tests.Snippet.Private
open Host.Ts
def source : String := "class A { #x = 5; get x() { return this.#x; } inc() { this.#x++; return this; } } const out = new A().inc().inc().x;"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.num 7)) = some true
end Host.Ts.Tests.Snippet.Private

namespace Host.Ts.Tests.Snippet.Params
open Host.Ts
def source : String := "function f(a, b = 10, ...r) { return [a, b, r]; } const out = f(1, undefined, 3, 4);"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num 10, .arr [.num 3, .num 4]])) = some true
end Host.Ts.Tests.Snippet.Params

namespace Host.Ts.Tests.Snippet.Destructure
open Host.Ts
def source : String := "const [p, , q = 7, ...rest] = [1, 2, undefined, 4, 5]; const {x, y: {z} = {z: 9}} = {x: 3}; const out = [p, q, rest, x, z];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num 7, .arr [.num 4, .num 5], .num 3, .num 9])) = some true
end Host.Ts.Tests.Snippet.Destructure

namespace Host.Ts.Tests.Snippet.Loops
open Host.Ts
def source : String := "let s = 0; for (let i = 0; i < 10; i++) { if (i === 3) continue; if (i === 7) break; s += i; } let w = 0; while (w < 5) w++; const out = [s, w];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 18, .num 5])) = some true
end Host.Ts.Tests.Snippet.Loops

namespace Host.Ts.Tests.Snippet.Using
open Host.Ts
def source : String := "let log = []; { using a = { [Symbol.dispose]() { log.push('a'); } }; using b = { [Symbol.dispose]() { log.push('b'); } }; log.push('body'); } const out = log;"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.str ['b','o','d','y'], .str ['b'], .str ['a']])) = some true
end Host.Ts.Tests.Snippet.Using

namespace Host.Ts.Tests.Snippet.TryFinally
open Host.Ts
def source : String := "let r; try { throw new Error('boom'); } catch (e) { r = e.message; } finally { r += '!'; } const out = r;"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.str ['b','o','o','m','!'])) = some true
end Host.Ts.Tests.Snippet.TryFinally

namespace Host.Ts.Tests.Snippet.Super
open Host.Ts
def source : String := "class B { constructor(x) { this.x = x; } } class C extends B { y = 2; constructor() { super(40); } } const c = new C(); const out = [c.x, c.y];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 40, .num 2])) = some true
end Host.Ts.Tests.Snippet.Super

namespace Host.Ts.Tests.Snippet.Generators
open Host.Ts
def source : String := "function* g() { yield 1; const x = yield 2; return x * 10; } const it = g(); const out = [it.next().value, it.next().value, it.next(5).value, it.next().done];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num 2, .num 50, .bool true])) = some true
end Host.Ts.Tests.Snippet.Generators

namespace Host.Ts.Tests.Snippet.Async
open Host.Ts
def source : String := "const out = []; async function f(x) { out.push(x); const y = await x; out.push(y * 10); } f(1); f(2); out.push(0);"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num 2, .num 0, .num 10, .num 20])) = some true
end Host.Ts.Tests.Snippet.Async

namespace Host.Ts.Tests.Snippet.Optional
open Host.Ts
def source : String := "const o = {a: 1}; o.b ??= 2; o.a ||= 5; const f = (q) => q?.m?.(); const out = [o.a, o.b, o?.c?.d, typeof o, typeof nope, f(null), f({m: () => 9})];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num 2, .undef, .str ['o','b','j','e','c','t'], .str ['u','n','d','e','f','i','n','e','d'], .undef, .num 9])) = some true
end Host.Ts.Tests.Snippet.Optional

namespace Host.Ts.Tests.Snippet.Typed
open Host.Ts
def source : String := "const i = new Int32Array([1, -2, 3]); const dv = new DataView(new ArrayBuffer(4)); dv.setFloat32(0, 0.5, true); const out = [...i, i.length, dv.getUint32(0, true), (BigInt(5 >>> 0) & 0xffffffffn) | (1n << 32n)];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num (-2), .num 3, .num 3, .num 1056964608, .big 4294967301])) = some true
end Host.Ts.Tests.Snippet.Typed

namespace Host.Ts.Tests.Snippet.MapSet
open Host.Ts
def source : String := "const m = new Map([[1, 'a']]); m.set(2, 'b'); const s = new Set([1, 1, 2]); const out = [...m.keys(), m.get(2), m.size, s.size, `t${m.size}`];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num 2, .str ['b'], .num 2, .num 2, .str ['t','2']])) = some true
end Host.Ts.Tests.Snippet.MapSet


namespace Host.Ts.Tests.Snippet.ForAwait
open Host.Ts
def source : String := "const out = []; let closed = 0; async function* g() { try { yield 1; yield 2; yield 3; } finally { closed++; } } (async () => { for await (const x of g()) out.push(x); for await (const x of g()) { out.push(x * 10); break; } out.push(closed); })();"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num 2, .num 3, .num 10, .num 2])) = some true
end Host.Ts.Tests.Snippet.ForAwait

namespace Host.Ts.Tests.Snippet.AsyncDelegate
open Host.Ts
def source : String := "const out = []; async function* inner() { try { yield 1; yield 2; return 7; } finally { out.push('i'); } } async function* outer() { try { const r = yield* inner(); yield r; } finally { out.push('o'); } } (async () => { for await (const x of outer()) out.push(x); for await (const x of outer()) { out.push(x * 10); break; } })();"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num 2, .str ['i'], .num 7, .str ['o'], .num 10, .str ['i'], .str ['o']])) = some true
end Host.Ts.Tests.Snippet.AsyncDelegate

namespace Host.Ts.Tests.Snippet.Roots
open Host.Ts
/-- Bun's `Math.pow(x, -0.5)` is `1 / √x` (two roundings): 128 gives 0.08838834764831843, not the
correctly rounded 0.08838834764831845. -/
def source : String := "const out = [Math.pow(128, -0.5) === 0.08838834764831843, Math.pow(2, 0.5) === Math.sqrt(2), Math.sqrt(2) === 1.4142135623730951, Math.pow(-0, 0.5) === 0, 1 / Math.pow(0, -0.5)];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.bool true, .bool true, .bool true, .bool true, .num 0])) = some true
end Host.Ts.Tests.Snippet.Roots
