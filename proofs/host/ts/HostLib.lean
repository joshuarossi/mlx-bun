import host.ts.Link
import host.ts.Ast
namespace Host.Ts.HostLib
open Host.Ts
set_option maxRecDepth 100000

/-! # The JavaScript host library

Host modules of a process run, written in JavaScript over the Lean host
builtins (`HostBuiltins`) and host calls (`%` names, answered by the world
model of the run's `Ffi`), so a run's I/O and the host APIs it uses are
ordinary machine steps:

* `%host/globals`: `JSON.parse`/`stringify`, `RegExp` with the `String`
  methods taking patterns, `TextDecoder`/`TextEncoder`, `URL` (file URLs),
  `Date.UTC`, typed-array `from`, `process` (environment from the world's
  environment block), `Bun.file` (`exists`, `text`, `json`, `size`) and
  `Bun.CryptoHasher` (SHA-256). A driver imports it first.
* `node:fs` (existence, UTF-8 reads, sizes, descriptors), `node:path`,
  `node:os` (`totalmem`), `node:url`, `node:crypto` (`createHash("sha256")`).
* Stand-ins whose functions throw: `node:worker_threads` and the third-party
  packages on the import graph (`@huggingface/jinja`,
  `@huggingface/tokenizers`, `@mlc-ai/web-xgrammar`, `fast-png`). Their
  real module bodies are not run; a run that called one would throw.

The global `setImmediate` is not defined here: the interpreter makes it on a
read of the undefined global (`readVar`, `Machine.lean`) and runs its callback
as a macrotask (`ctlN .setImmediate`, `nextJob`). What is not modelled throws
an `Error` naming it (an undefined global a `ReferenceError`), so a completed
run never used it. -/

namespace Globals
def source : String := r##"import * as H from "%host";

JSON.parse = H.jsonParse;
JSON.stringify = H.jsonStringify;

// ---- regular expressions: the matcher is `H.regexExecAt` (bounds of the match and its groups)
function RegExp(pattern, flags) {
  if (pattern instanceof RegExp) { if (flags === undefined) flags = pattern.flags; pattern = pattern.source; }
  return H.regexNew(pattern === undefined ? "(?:)" : String(pattern), flags);
}
RegExp.prototype = H.RegExpProto;
H.RegExpProto.constructor = RegExp;
function groupsOf(m, str) {
  const gs = [];
  for (let k = 2; k < m.length; k += 2) gs.push(m[k] < 0 ? undefined : str.slice(m[k], m[k + 1]));
  return gs;
}
H.RegExpProto.exec = function exec(str) {
  str = String(str);
  const g = this.global || this.sticky;
  const start = g ? this.lastIndex : 0;
  if (start > str.length) { if (g) this.lastIndex = 0; return null; }
  const m = H.regexExecAt(this, str, start);
  if (m === null) { if (g) this.lastIndex = 0; return null; }
  if (g) this.lastIndex = m[1];
  const r = [str.slice(m[0], m[1]), ...groupsOf(m, str)];
  r.index = m[0];
  r.input = str;
  r.groups = undefined;
  return r;
};
H.RegExpProto.test = function test(str) { return this.exec(str) !== null; };
H.RegExpProto.toString = function toString() { return "/" + this.source + "/" + this.flags; };
globalThis.RegExp = RegExp;

const SP = String.prototype;
const strSplit = SP.split, strReplaceAll = SP.replaceAll;
function expand(rep, m, pos, str, groups) {
  let out = "";
  for (let i = 0; i < rep.length; i++) {
    const c = rep[i];
    if (c !== "$" || i + 1 >= rep.length) { out += c; continue; }
    const d = rep[i + 1];
    if (d === "$") { out += "$"; i++; }
    else if (d === "&") { out += m; i++; }
    else if (d === "`") { out += str.slice(0, pos); i++; }
    else if (d === "'") { out += str.slice(pos + m.length); i++; }
    else if (d >= "0" && d <= "9") {
      let n = Number(d), j = i + 2;
      if (j < rep.length && rep[j] >= "0" && rep[j] <= "9" && n * 10 + Number(rep[j]) <= groups.length) { n = n * 10 + Number(rep[j]); j++; }
      if (n >= 1 && n <= groups.length) { const g = groups[n - 1]; out += g === undefined ? "" : g; i = j - 1; }
      else out += c;
    } else out += c;
  }
  return out;
}
function reReplace(str, re, rep, all) {
  let out = "", last = 0, from = 0;
  while (from <= str.length) {
    const m = H.regexExecAt(re, str, from);
    if (m === null) break;
    const s = m[0], e = m[1], groups = groupsOf(m, str), matched = str.slice(s, e);
    const r = typeof rep === "function" ? String(rep(matched, ...groups, s, str)) : expand(String(rep), matched, s, str, groups);
    out += str.slice(last, s) + r;
    last = e;
    if (!all) break;
    from = e === s ? e + 1 : e;
  }
  if (re.global || re.sticky) re.lastIndex = 0;
  return out + str.slice(last);
}
function strReplace(str, pat, rep, all) {
  let out = "", last = 0, i = str.indexOf(pat);
  while (i >= 0) {
    out += str.slice(last, i) + (typeof rep === "function" ? String(rep(pat, i, str)) : expand(String(rep), pat, i, str, []));
    last = i + pat.length;
    if (!all) break;
    const rest = str.slice(last).indexOf(pat);
    i = rest < 0 ? -1 : last + (pat.length === 0 ? rest + 1 : rest);
    if (pat.length === 0 && i > str.length) break;
  }
  return out + str.slice(last);
}
SP.replace = function replace(pat, rep) {
  const str = String(this);
  return pat instanceof RegExp ? reReplace(str, pat, rep, pat.global) : strReplace(str, String(pat), rep, false);
};
SP.replaceAll = function replaceAll(pat, rep) {
  const str = String(this);
  if (pat instanceof RegExp) {
    if (!pat.global) throw new TypeError("replaceAll must be called with a global RegExp");
    return reReplace(str, pat, rep, true);
  }
  pat = String(pat);
  if (typeof rep !== "function" && !String(rep).includes("$") && pat.length > 0) return strReplaceAll.call(str, pat, rep);
  return strReplace(str, pat, rep, true);
};
SP.match = function match(re) {
  const str = String(this);
  if (!(re instanceof RegExp)) re = new RegExp(re);
  if (!re.global) return re.exec(str);
  const out = [];
  let from = 0;
  while (from <= str.length) {
    const m = H.regexExecAt(re, str, from);
    if (m === null) break;
    out.push(str.slice(m[0], m[1]));
    from = m[1] === m[0] ? m[1] + 1 : m[1];
  }
  re.lastIndex = 0;
  return out.length ? out : null;
};
SP.search = function search(re) {
  if (!(re instanceof RegExp)) re = new RegExp(re);
  const m = H.regexExecAt(re, String(this), 0);
  return m === null ? -1 : m[0];
};
SP.split = function split(sep, limit) {
  const str = String(this);
  if (!(sep instanceof RegExp)) return limit === undefined ? strSplit.call(str, sep) : strSplit.call(str, sep).slice(0, limit);
  if (str.length === 0) return H.regexExecAt(sep, str, 0) === null ? [str] : [];
  const out = [];
  let last = 0, from = 0;
  while (from < str.length) {
    const m = H.regexExecAt(sep, str, from);
    if (m === null || m[0] >= str.length) break;
    if (m[1] === m[0] && m[0] === last) { from = m[0] + 1; continue; }
    out.push(str.slice(last, m[0]), ...groupsOf(m, str));
    last = m[1];
    from = m[1] === m[0] ? m[1] + 1 : m[1];
  }
  out.push(str.slice(last));
  return limit === undefined ? out : out.slice(0, limit);
};

// ---- text
class TextDecoder {
  constructor(label) {
    if (label !== undefined && label !== "utf-8" && label !== "utf8") throw new Error("TextDecoder " + label + " is not modelled");
    this.encoding = "utf-8";
  }
  decode(view) { return H.utf8Decode(view); }
}
class TextEncoder {
  constructor() { this.encoding = "utf-8"; }
  encode(text) { return H.utf8Encode(text === undefined ? "" : String(text)); }
}
globalThis.TextDecoder = TextDecoder;
globalThis.TextEncoder = TextEncoder;

// ---- typed arrays
function typedFrom(src, f) { return new this(Array.from(src, f)); }
for (const C of [Int8Array, Uint8Array, Int16Array, Uint16Array, Int32Array, Uint32Array, Float32Array, Float64Array,
  BigInt64Array, BigUint64Array]) C.from = typedFrom;

// ---- file URLs
function normPath(p) {
  const trail = p.endsWith("/");
  const out = [];
  for (const seg of p.split("/")) {
    if (seg === "" || seg === ".") continue;
    if (seg === "..") out.pop(); else out.push(seg);
  }
  return "/" + out.join("/") + (trail && out.length ? "/" : "");
}
class URL {
  constructor(input, base) {
    input = String(input);
    if (input.startsWith("file://")) this.pathname = normPath(input.slice(7));
    else if (base !== undefined) {
      const b = base instanceof URL ? base.pathname : new URL(String(base)).pathname;
      const dir = b.slice(0, b.lastIndexOf("/") + 1);
      this.pathname = normPath(input.startsWith("/") ? input : dir + input);
    } else throw new TypeError("Invalid URL: " + input);
    this.protocol = "file:";
    this.href = "file://" + this.pathname;
  }
  toString() { return this.href; }
}
globalThis.URL = URL;

// ---- Date: UTC arithmetic only (days from the civil calendar)
function Date() { throw new Error("Date is not modelled"); }
Date.UTC = function UTC(y, m = 0, d = 1, h = 0, mi = 0, s = 0, ms = 0) {
  y = y + Math.floor(m / 12);
  m = ((m % 12) + 12) % 12;
  const yy = m < 2 ? y - 1 : y;
  const era = Math.floor(yy / 400);
  const yoe = yy - era * 400;
  const doy = Math.floor((153 * ((m + 10) % 12) + 2) / 5) + d - 1;
  const doe = yoe * 365 + Math.floor(yoe / 4) - Math.floor(yoe / 100) + doy;
  return (((era * 146097 + doe - 719468) * 24 + h) * 60 + mi) * 60000 + s * 1000 + ms;
};
globalThis.Date = Date;

// ---- Math: constants are the binary64 values the specification names; transcendental
// functions are the runtime's results (a platform fact table of the world model)
Math.PI = 3.141592653589793;
Math.E = 2.718281828459045;
Math.LN2 = 0.6931471805599453;
Math.LN10 = 2.302585092994046;
Math.LOG2E = 1.4426950408889634;
Math.LOG10E = 0.4342944819032518;
Math.SQRT2 = 1.4142135623730951;
Math.SQRT1_2 = 0.7071067811865476;
for (const f of ["log", "exp", "log2", "log10", "log1p", "expm1", "sin", "cos", "tan", "atan", "tanh", "cbrt"])
  Math[f] = function (x) { return H.math(f, Number(x)); };

// ---- process
const env = {};
const block = H.env();
if (block.length > 0)
  for (const line of block.split("\n")) { const i = line.indexOf("="); env[line.slice(0, i)] = line.slice(i + 1); }
const process = {
  env, platform: "darwin", arch: "arm64", argv: [], pid: 1, execPath: "/bun",
  versions: { bun: "1.3.0" },
  on() { return process; },
  once() { return process; },
  cwd() { return H.cwd(); },
  exit() { throw new Error("process.exit is not modelled"); },
};
globalThis.process = process;

// ---- Bun
class BunFile {
  constructor(path) { this.name = String(path); }
  get size() { const n = H.size(this.name); return n < 0 ? 0 : n; }
  async exists() { return H.exists(this.name) && !H.isdir(this.name); }
  async text() {
    if (!H.exists(this.name)) throw new Error("ENOENT: no such file or directory, open '" + this.name + "'");
    return H.text(this.name);
  }
  async json() { return JSON.parse(await this.text()); }
}
class CryptoHasher {
  #parts = [];
  constructor(algorithm) { if (algorithm !== "sha256") throw new Error("CryptoHasher " + algorithm + " is not modelled"); }
  update(data) {
    this.#parts.push(typeof data === "string" ? data : new Uint8Array(data.buffer, data.byteOffset, data.byteLength).slice());
    return this;
  }
  digest(encoding) {
    if (encoding !== "hex") throw new Error("CryptoHasher digest " + encoding + " is not modelled");
    return H.sha256(this.#parts);
  }
}
globalThis.Bun = {
  file(path) { return new BunFile(path); },
  CryptoHasher, env, version: "1.3.0",
  hash() { throw new Error("Bun.hash is not modelled"); },
  nanoseconds() { return 0; },
};
"##
source_parse source
source_ast
end Globals

namespace Fs
def source : String := r#"import * as H from "%host";
function enoent(p, op) {
  const e = new Error("ENOENT: no such file or directory, " + op + " '" + p + "'");
  e.code = "ENOENT";
  return e;
}
export function existsSync(p) { return H.exists(String(p)); }
export function readFileSync(p, options) {
  const enc = typeof options === "string" ? options : options && options.encoding;
  if (enc !== "utf8" && enc !== "utf-8") throw new Error("node:fs readFileSync without a utf8 encoding is not modelled");
  p = String(p);
  if (!H.exists(p) || H.isdir(p)) throw enoent(p, "open");
  return H.text(p);
}
export function statSync(p, options) {
  p = String(p);
  if (!H.exists(p)) { if (options && options.throwIfNoEntry === false) return undefined; throw enoent(p, "stat"); }
  const dir = H.isdir(p);
  return { size: dir ? 0 : H.size(p), isFile() { return !dir; }, isDirectory() { return dir; } };
}
export function openSync(p, flags) {
  if (flags !== undefined && flags !== "r") throw new Error("node:fs openSync for writing is not modelled");
  const fd = H.open(String(p));
  if (fd < 0) throw enoent(p, "open");
  return fd;
}
export function fstatSync(fd) { const size = H.fsize(fd); return { size, isFile() { return true; }, isDirectory() { return false; } }; }
export function closeSync(fd) { H.close(fd); }
function unmodelled(name) { return function () { throw new Error("node:fs " + name + " is not modelled"); }; }
export const readdirSync = unmodelled("readdirSync");
export const readSync = unmodelled("readSync");
export const writeSync = unmodelled("writeSync");
export const fsyncSync = unmodelled("fsyncSync");
export const renameSync = unmodelled("renameSync");
export const rmSync = unmodelled("rmSync");
export const appendFileSync = unmodelled("appendFileSync");
export const writeFileSync = unmodelled("writeFileSync");
export const mkdirSync = unmodelled("mkdirSync");
export const unlinkSync = unmodelled("unlinkSync");
"#
source_parse source
source_ast
end Fs

namespace Path
def source : String := r#"import * as H from "%host";
export const sep = "/";
export const delimiter = ":";
export function normalize(p) {
  if (p === "") return ".";
  const abs = p.startsWith("/"), trail = p.endsWith("/");
  const out = [];
  for (const seg of p.split("/")) {
    if (seg === "" || seg === ".") continue;
    if (seg === "..") { if (out.length > 0 && out[out.length - 1] !== "..") out.pop(); else if (!abs) out.push(".."); }
    else out.push(seg);
  }
  let r = out.join("/");
  if (abs) r = "/" + r;
  if (trail && r !== "/" && r !== "") r += "/";
  return r === "" ? "." : r;
}
export function join(...parts) {
  const ps = parts.filter(p => p !== "");
  return ps.length > 0 ? normalize(ps.join("/")) : ".";
}
function trimEnd(p) {
  let end = p.length;
  while (end > 1 && p[end - 1] === "/") end--;
  return p.slice(0, end);
}
function lastSlash(p) {
  for (let i = p.length - 1; i >= 0; i--) if (p[i] === "/") return i;
  return -1;
}
export function dirname(p) {
  if (p === "") return ".";
  p = trimEnd(p);
  const i = lastSlash(p);
  if (i < 0) return ".";
  if (i === 0) return "/";
  return trimEnd(p.slice(0, i));
}
export function basename(p, ext) {
  p = trimEnd(p);
  const b = p.slice(lastSlash(p) + 1);
  return ext !== undefined && b.endsWith(ext) && b !== ext ? b.slice(0, b.length - ext.length) : b;
}
export function extname(p) {
  const b = basename(p);
  let i = -1;
  for (let k = b.length - 1; k > 0; k--) if (b[k] === ".") { i = k; break; }
  return i < 0 ? "" : b.slice(i);
}
export function isAbsolute(p) { return p.startsWith("/"); }
export function resolve(...parts) {
  let r = "";
  for (let i = parts.length - 1; i >= 0 && !r.startsWith("/"); i--)
    if (parts[i] !== "") r = r === "" ? parts[i] : parts[i] + "/" + r;
  if (!r.startsWith("/")) r = H.cwd() + (r === "" ? "" : "/" + r);
  const n = normalize(r);
  return n.length > 1 && n.endsWith("/") ? n.slice(0, n.length - 1) : n;
}
export function relative(from, to) {
  const a = resolve(from).split("/").filter(s => s !== ""), b = resolve(to).split("/").filter(s => s !== "");
  let i = 0;
  while (i < a.length && i < b.length && a[i] === b[i]) i++;
  return [...a.slice(i).map(() => ".."), ...b.slice(i)].join("/");
}
export default { sep, delimiter, normalize, join, dirname, basename, extname, isAbsolute, resolve, relative };
"#
source_parse source
source_ast
end Path

namespace Os
def source : String := r#"import * as H from "%host";
export function totalmem() { return H.mem(); }
export function homedir() { return process.env.HOME; }
export function platform() { return "darwin"; }
export function arch() { return "arm64"; }
export default { totalmem, homedir, platform, arch };
"#
source_parse source
source_ast
end Os

namespace Url
def source : String := r#"export function fileURLToPath(u) {
  const s = typeof u === "string" ? u : u.href;
  if (!s.startsWith("file://")) throw new TypeError("The URL must be of scheme file");
  return s.slice(7);
}
export function pathToFileURL(p) { return new URL("file://" + p); }
"#
source_parse source
source_ast
end Url

namespace Crypto
def source : String := r#"export function createHash(algorithm) {
  const h = new Bun.CryptoHasher(algorithm);
  return { update(data) { h.update(data); return this; }, digest(encoding) { return h.digest(encoding); } };
}
"#
source_parse source
source_ast
end Crypto

namespace WorkerThreads
def source : String := r#"export class Worker { constructor() { throw new Error("node:worker_threads is not modelled"); } }
"#
source_parse source
source_ast
end WorkerThreads

namespace Jinja
def source : String := r#"export class Template { constructor() { throw new Error("@huggingface/jinja is not modelled"); } }
"#
source_parse source
source_ast
end Jinja

namespace Tokenizers
def source : String := r#"export class Tokenizer { constructor() { throw new Error("@huggingface/tokenizers is not modelled"); } }
"#
source_parse source
source_ast
end Tokenizers

namespace Xgrammar
def source : String := r#"export default {};
"#
source_parse source
source_ast
end Xgrammar

namespace FastPng
def source : String := r#"export function decode() { throw new Error("fast-png is not modelled"); }
"#
source_parse source
source_ast
end FastPng

/-- The library's user modules, by the specifiers they answer. -/
def mods : List UMod :=
  [⟨chars!"%host/globals", Globals.ast⟩, ⟨chars!"node:fs", Fs.ast⟩, ⟨chars!"node:path", Path.ast⟩,
   ⟨chars!"node:os", Os.ast⟩, ⟨chars!"node:url", Url.ast⟩, ⟨chars!"node:crypto", Crypto.ast⟩,
   ⟨chars!"node:worker_threads", WorkerThreads.ast⟩, ⟨chars!"@huggingface/jinja", Jinja.ast⟩,
   ⟨chars!"@huggingface/tokenizers", Tokenizers.ast⟩, ⟨chars!"@mlc-ai/web-xgrammar", Xgrammar.ast⟩,
   ⟨chars!"fast-png", FastPng.ast⟩]

section
variable {S : Type}

/-- `%host`: the host builtins and host calls the library uses. -/
def hostMod : HMod S := ⟨chars!"%host", do
  let rp ← newObj (.obj aObjectProto)
  let call (n : String) : B S Val := mkFn (.host .call) [.str (strOf ("%" ++ n))]
  pure [(chars!"jsonParse", ← mkFn (.host .jsonParse)), (chars!"jsonStringify", ← mkFn (.host .jsonStringify)),
    (chars!"utf8Decode", ← mkFn (.host .utf8Decode)), (chars!"utf8Encode", ← mkFn (.host .utf8Encode)),
    (chars!"sha256", ← mkFn (.host .sha256)), (chars!"regexExecAt", ← mkFn (.host .regexExecAt)),
    (chars!"regexNew", ← mkFn (.host .regexNew) [.obj rp]), (chars!"RegExpProto", .obj rp),
    (chars!"env", ← call "env"), (chars!"cwd", ← call "cwd"), (chars!"mem", ← call "mem"),
    (chars!"exists", ← call "exists"), (chars!"isdir", ← call "isdir"), (chars!"text", ← call "text"),
    (chars!"size", ← call "size"), (chars!"open", ← call "open"), (chars!"fsize", ← call "fsize"),
    (chars!"close", ← call "close"), (chars!"math", ← call "math")]⟩

/-- `bun:ffi` with `CString` reading native memory. -/
def bunFfiL : HMod S := ⟨chars!"bun:ffi", do
  let dlopen ← mkFn (.ffi .dlopen)
  let ptr ← mkFn (.ffi .ptr)
  let toAB ← mkFn (.ffi .toArrayBuffer)
  let u64 ← mkFn (.ffi .readU64)
  let u32 ← mkFn (.ffi .readU32)
  let i32 ← mkFn (.ffi .readI32)
  let f32 ← mkFn (.ffi .readF32)
  let rp ← mkFn (.ffi .readPtr)
  let read ← objOf [(chars!"u64", u64), (chars!"u32", u32), (chars!"i32", i32), (chars!"f32", f32), (chars!"ptr", rp)]
  let types ← objOf (ffiTypes.map fun n => (n, .str n))
  let jscb ← ctorFn (.ffi .jsCallback) aJsCallbackProto
  let cstr ← mkFn (.host .cstring)
  pure [(chars!"dlopen", dlopen), (chars!"ptr", ptr), (chars!"toArrayBuffer", toAB), (chars!"read", read),
    (chars!"FFIType", types), (chars!"JSCallback", .obj jscb), (chars!"CString", cstr)]⟩

/-- A text module (`import x from "…" with { type: "text" }`): its default export is the file's text. -/
def textMod (path text : List Char) : HMod S := ⟨path, pure [(chars!"default", .str text)]⟩

def hosts : List (HMod S) := [hostMod, bunFfiL, asyncHooks]

end

end Host.Ts.HostLib
