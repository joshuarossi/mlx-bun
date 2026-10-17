import host.ts.Ast
namespace Host.Ts.Prelude

/-! # Builtins written in JavaScript

Builtins that call back into user code, as function declarations the
realm installs. Each follows the specification's algorithm for ordinary
(hole-free, non-proxy) receivers; `thisArg` arguments are rejected rather
than ignored. -/

def source : String := r#"function map(f, t) {
  if (t !== undefined) throw new TypeError("thisArg is not modelled");
  const n = this.length; const r = [];
  for (let i = 0; i < n; i++) r.push(f(this[i], i, this));
  return r;
}
function forEach(f, t) {
  if (t !== undefined) throw new TypeError("thisArg is not modelled");
  const n = this.length;
  for (let i = 0; i < n; i++) f(this[i], i, this);
}
function filter(f, t) {
  if (t !== undefined) throw new TypeError("thisArg is not modelled");
  const n = this.length; const r = [];
  for (let i = 0; i < n; i++) { const v = this[i]; if (f(v, i, this)) r.push(v); }
  return r;
}
function some(f, t) {
  if (t !== undefined) throw new TypeError("thisArg is not modelled");
  const n = this.length;
  for (let i = 0; i < n; i++) if (f(this[i], i, this)) return true;
  return false;
}
function every(f, t) {
  if (t !== undefined) throw new TypeError("thisArg is not modelled");
  const n = this.length;
  for (let i = 0; i < n; i++) if (!f(this[i], i, this)) return false;
  return true;
}
function find(f, t) {
  if (t !== undefined) throw new TypeError("thisArg is not modelled");
  const n = this.length;
  for (let i = 0; i < n; i++) { const v = this[i]; if (f(v, i, this)) return v; }
  return undefined;
}
function findIndex(f, t) {
  if (t !== undefined) throw new TypeError("thisArg is not modelled");
  const n = this.length;
  for (let i = 0; i < n; i++) if (f(this[i], i, this)) return i;
  return -1;
}
function reduce(f, ...init) {
  const n = this.length; let i = 0; let acc;
  if (init.length > 0) acc = init[0];
  else { if (n === 0) throw new TypeError("Reduce of empty array with no initial value"); acc = this[0]; i = 1; }
  for (; i < n; i++) acc = f(acc, this[i], i, this);
  return acc;
}
function flatMap(f, t) {
  if (t !== undefined) throw new TypeError("thisArg is not modelled");
  const n = this.length; const r = [];
  for (let i = 0; i < n; i++) {
    const v = f(this[i], i, this);
    if (Array.isArray(v)) { for (const x of v) r.push(x); } else r.push(v);
  }
  return r;
}
function sort(cmp) {
  const n = this.length;
  for (let i = 1; i < n; i++) {
    const v = this[i]; let j = i - 1;
    while (j >= 0) {
      const w = this[j];
      const c = cmp === undefined ? (String(w) > String(v) ? 1 : 0) : cmp(w, v);
      if (c > 0) { this[j + 1] = w; j--; } else break;
    }
    this[j + 1] = v;
  }
  return this;
}
function mapForEach(f) { for (const [k, v] of this) f(v, k, this); }
function setForEach(f) { for (const v of this) f(v, v, this); }
function from(x, f) {
  if (x === null || x === undefined) throw new TypeError("Array.from of nullish");
  const r = [];
  if (x[Symbol.iterator] === undefined) {
    const n = x.length;
    for (let i = 0; i < n; i++) r.push(f === undefined ? x[i] : f(x[i], i));
    return r;
  }
  let i = 0;
  for (const v of x) { r.push(f === undefined ? v : f(v, i)); i++; }
  return r;
}
function promiseFinally(f) {
  return this.then(v => Promise.resolve(f()).then(() => v), e => Promise.resolve(f()).then(() => { throw e; }));
}
"#

source_parse source
source_ast

end Host.Ts.Prelude
