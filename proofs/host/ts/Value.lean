import host.ts.Syntax
import host.ts.Number
import host.ts.Heap
namespace Host.Ts

/-! # Runtime values, heap objects and machine state

Numbers are `NumV`: an inline binary64 constant, or a reference into a
number table kept by a *number server* outside the machine state
(`Free`). The machine never inspects a referenced number; it asks the
server, so the same machine runs concretely (the table holds binary64
values) or symbolically (the table holds expressions over symbolic
positions), and the simulation theorem is a fact about servers alone. -/

/-- Number operations a server performs on referenced numbers. All are
total on binary64 (`F64`), so a symbolic expression always denotes. -/
inductive NBin where
  | add | sub | mul | div | rem | min | max
  | band | bor | bxor | shl | shr | ushr
deriving DecidableEq, Repr

inductive NUn where
  | neg | floor | ceil | trunc | f32 | int32 | uint32 | uint8 | uint16 | int8 | int16
deriving DecidableEq, Repr

inductive NTest where | lt | le | eq | truthy
deriving DecidableEq, Repr

inductive NumV where
  | lit (x : F64)
  | ref (i : Nat)
deriving DecidableEq, Repr

namespace F64
def int32Op (f : Int → Int → Int) (x y : F64) : F64 := F64.ofInt (F64.toInt32 (F64.ofInt (f (toInt32 x) (toInt32 y))))

def bin : NBin → F64 → F64 → F64
  | .add, x, y => add x y
  | .sub, x, y => sub x y
  | .mul, x, y => mul x y
  | .div, x, y => div x y
  | .rem, x, y => rem x y
  | .min, x, y => min x y
  | .max, x, y => max x y
  | .band, x, y => ofInt (toInt32 (ofNat (Nat.land (toUint32 x) (toUint32 y))))
  | .bor, x, y => ofInt (toInt32 (ofNat (Nat.lor (toUint32 x) (toUint32 y))))
  | .bxor, x, y => ofInt (toInt32 (ofNat (Nat.xor (toUint32 x) (toUint32 y))))
  | .shl, x, y => ofInt (toInt32 (ofNat ((toUint32 x <<< (toUint32 y % 32)) % 2 ^ 32)))
  | .shr, x, y => ofInt ((toInt32 x) / ((2 ^ (toUint32 y % 32) : Nat) : Int))
  | .ushr, x, y => ofNat (toUint32 x >>> (toUint32 y % 32))

def un : NUn → F64 → F64
  | .neg, x => neg x
  | .floor, x => floor x
  | .ceil, x => ceil x
  | .trunc, x => trunc x
  | .f32, x => toF32 x
  | .int32, x => ofInt (toInt32 x)
  | .uint32, x => ofNat (toUint32 x)
  | .uint8, x => ofNat (toUint8 x)
  | .uint16, x => ofNat (toUint16 x)
  | .int8, x => let u := toUint8 x; ofInt (bif Nat.blt u 128 then (u : Int) else (u : Int) - 256)
  | .int16, x => let u := toUint16 x; ofInt (bif Nat.blt u 32768 then (u : Int) else (u : Int) - 65536)

def test : NTest → F64 → F64 → Bool
  | .lt, x, y => lt x y
  | .le, x, y => le x y
  | .eq, x, y => eq x y
  | .truthy, x, _ => truthy x
end F64

/-! ## The number-server protocol -/

/-- A machine computation that may ask a number server. `fail` is a stuck
model (unsupported construct or exhausted fuel), never a JS exception. -/
inductive Free (α : Type) where
  | pure (a : α)
  | fail (msg : String)
  | bin (op : NBin) (a b : NumV) (k : Nat → Free α)
  | un (op : NUn) (a : NumV) (k : Nat → Free α)
  | test (op : NTest) (a b : NumV) (k : Bool → Free α)
  | conc (a : NumV) (k : F64 → Free α)

namespace Free
def bind {α β : Type} : Free α → (α → Free β) → Free β
  | pure a, f => f a
  | fail m, _ => fail m
  | bin op a b k, f => bin op a b fun i => bind (k i) f
  | un op a k, f => un op a fun i => bind (k i) f
  | test op a b k, f => test op a b fun r => bind (k r) f
  | conc a k, f => conc a fun x => bind (k x) f

end Free

/-- The machine's monad: continuation-passing over `Free`. `bind` is
β-reduction, so machine code never recurses over request trees in the
kernel; `run` yields the request tree a server interprets. -/
def M (α : Type) : Type 1 := (β : Type) → (α → Free β) → Free β

namespace M
def pure {α : Type} (a : α) : M α := fun _ k => k a
def bind {α β : Type} (m : M α) (f : α → M β) : M β := fun γ k => m γ fun a => f a γ k
def fail {α : Type} (msg : String) : M α := fun _ _ => .fail msg
def bin {α : Type} (op : NBin) (a b : NumV) (k : Nat → M α) : M α := fun γ c => .bin op a b fun i => k i γ c
def un {α : Type} (op : NUn) (a : NumV) (k : Nat → M α) : M α := fun γ c => .un op a fun i => k i γ c
def test {α : Type} (op : NTest) (a b : NumV) (k : Bool → M α) : M α := fun γ c => .test op a b fun r => k r γ c
def conc {α : Type} (a : NumV) (k : F64 → M α) : M α := fun γ c => .conc a fun x => k x γ c
def run {α : Type} (m : M α) : Free α := m α .pure
end M

/-! ## Values -/

abbrev Env := List (Name × Nat)

/-- Well-known symbols. -/
def symIterator : Nat := 0
def symAsyncIterator : Nat := 1
def symDispose : Nat := 2
def symAsyncDispose : Nat := 3
/-- Marks a `setImmediate` macrotask: a `then_` job whose rejection handler is this symbol
(well-known ids 4…15 are never values; `Symbol()` allocates ids from 16). -/
def symMacro : Nat := 4

inductive PKey where
  | str (s : List Char)
  | sym (i : Nat)

/-- Memory a `bun:ffi` pointer names: a JS `ArrayBuffer`, or native memory
(region `r` of the FFI model). -/
inductive Mem where
  | js (buf : Nat)
  | ext (r : Nat)

inductive Val where
  | undef | null
  | bool (b : Bool)
  | num (x : NumV)
  | big (i : Int)
  | str (s : List Char)
  | sym (i : Nat)
  | obj (a : Nat)
  /-- A `bun:ffi` pointer; a number in Bun, opaque here. -/
  | ptr (m : Mem) (off : Nat)

instance : Inhabited Val := ⟨.undef⟩

inductive PropV where
  | data (v : Val) (writable enumerable : Bool)
  | acc (get set : Val) (enumerable : Bool)

abbrev Props := List (PKey × PropV)

inductive EltK where | i8 | u8 | i16 | u16 | i32 | u32 | f32 | f64 | i64 | u64

def EltK.size : EltK → Nat
  | .i8 | .u8 => 1 | .i16 | .u16 => 2 | .i32 | .u32 | .f32 => 4 | .f64 | .i64 | .u64 => 8

def EltK.code : EltK → Nat
  | .i8 => 0 | .u8 => 1 | .i16 => 2 | .u16 => 3 | .i32 => 4 | .u32 => 5 | .f32 => 6 | .f64 => 7 | .i64 => 8 | .u64 => 9

/-- Element value stored in a buffer: a number (already converted to the
element type) or a bigint (already wrapped). -/
inductive Cell where
  | num (x : NumV)
  | big (i : Int)

/-- A buffer byte: concrete, or byte `i` of an element written as kind `k`.
Reading `k` at the element's offset returns the element without
encoding, so symbolic elements survive a round trip. -/
inductive Byte where
  | lit (b : Nat)
  | part (k : EltK) (c : Cell) (i : Nat)

inductive Abrupt where
  | throw (v : Val)
  | ret (v : Val)
  | brk (l : Option Name)
  | cont (l : Option Name)

/-- Normal or abrupt completion, saved across `finally` and disposal. -/
inductive Comp where
  | normal (v : Val)
  | abrupt (a : Abrupt)

/-- An instance member the constructor installs, in order. -/
inductive InstMember where
  | field (k : PKey) (init : Option Expr)
  | privField (brand : Nat) (n : Name) (init : Option Expr)
  | privMethod (brand : Nat) (n : Name) (p : PropV)

/-- What a function boundary does with the body's completion. -/
inductive Boundary where
  | call
  /-- Base constructor: the object unless the body returns an object. -/
  | ctor (this : Val)
  /-- Derived constructor: `this` lives in the cell. -/
  | derived (thisCell : Nat)
  | async (promise : Nat)
  | gen (g : Nat)

inductive IterSrc where
  /-- Array, typed array or string by live index (`%ArrayIteratorPrototype%`). -/
  | index (v : Val) (i : Nat)
  /-- Iterator protocol: iterator object and its `next`. -/
  | proto (it next : Val)

/-- Binding of a pattern: initialize cells (`init`) or assign references. -/
inductive BindMode where
  | init
  | assign

/-! ## Builtins, by group (small enumerations keep kernel dispatch cheap) -/

inductive ObjN where
  | keys | entries | values | freeze | hasOwn | fromEntries | assign | getPrototypeOf | protoHasOwn
  | protoToString | isFrozen
inductive ArrN where
  | isArray | push | pop | slice | at | includes | indexOf | join | fill | concat | splice | reverse
  | shift | unshift | lastIndexOf | ctor
inductive IterN where
  | values | keys | entries | next | self
inductive MathN where
  | floor | ceil | min | max | pow | trunc | sqrt | round | abs | fround | sign
inductive NumN where
  | number | isSafeInteger | isInteger | isFinite | isNaN | bigint | string | boolean | numToString
  | bigToString | symbol | parseInt | parseFloat
inductive StrN where
  | slice | startsWith | endsWith | includes | indexOf | split | trim | toLowerCase | toUpperCase
  | replace | padStart | charCodeAt | at | toString | concat | substring
inductive Str2N where
  | raw | repeat | padEnd | trimEnd | trimStart | replaceAll | lastIndexOf | fromCharCode
inductive ErrN where
  | error | typeError | rangeError | referenceError | suppressed | toString
inductive MapN where
  | ctor | get | set | has | delete | clear | keys | values | entries | weakCtor
inductive SetN where
  | ctor | add | has | delete | clear | values
inductive BufN where
  | typedCtor | arrayBuffer | dataView | getU32 | setF32 | getF32 | setU32 | getBigU64 | setBigU64
  | getI32 | setI32 | taSlice | taSubarray | taFill | taSet | bufferFrom
inductive FnN where
  | call | apply | bind | reflectGet | reflectHas | reflectApply | perfNow | finRegCtor | finRegister
  | finUnregister | consoleLog | jsonStringify | noop
inductive CtlN where
  | genNext | genReturn | genThrow | agenNext | agenReturn | agenThrow | promiseCtor | promiseResolve
  | promiseReject | promiseThen | promiseCatch | resolveFn | rejectFn | alsCtor | alsRun | alsGetStore
  /-- `setImmediate(cb)`: queue `cb()` as a macrotask. -/
  | setImmediate
inductive FfiN where
  | dlopen | ptr | readU64 | readU32 | readI32 | readPtr | readF32 | toArrayBuffer | symbol | jsCallback
  | cstring | close
  /-- A native call waiting for a `JSCallback` it invoked. -/
  | callbackRet

/-- Host builtins (`HostBuiltins`): JSON, UTF-8, SHA-256, regular expressions,
C strings, and calls into the host world model. -/
inductive HostN where
  | jsonParse | jsonStringify | utf8Decode | utf8Encode | sha256 | regexNew | regexExecAt | cstring
  /-- A call into the host world (`Ffi.call` with the captured name). -/
  | call

inductive Native where
  | obj (f : ObjN) | arr (f : ArrN) | iter (f : IterN) | math (f : MathN) | num (f : NumN)
  | str (f : StrN) | str2 (f : Str2N) | err (f : ErrN) | map (f : MapN) | set (f : SetN)
  | buf (f : BufN) | fn (f : FnN) | ctl (f : CtlN) | ffi (f : FfiN) | host (f : HostN)

/-- Calls in progress: `kind` 0 call, 1 construct, 2 `super(...)`. -/
inductive CallF where
  /-- Callee evaluated; `this` is undefined. -/
  | callee (args : List Elem) (env : Env) (opt : Bool)
  | member (k : PKey) (args : List Elem) (env : Env) (optObj optCall : Bool)
  | index (k : Expr) (args : List Elem) (env : Env) (optObj optCall : Bool)
  | indexK (o : Val) (args : List Elem) (env : Env) (optCall : Bool)
  | priv (brand : Nat) (n : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
  /-- Method value obtained for receiver `this`. -/
  | method (this : Val) (args : List Elem) (env : Env) (optCall : Bool)
  | args (kind : Nat) (fn this : Val) (acc : List Val) (rest : List Elem) (env : Env)
  /-- A spread argument's iterable evaluated. -/
  | spread (kind : Nat) (fn this : Val) (acc : List Val) (rest : List Elem) (env : Env)
  | newCallee (args : List Elem) (env : Env)

/-- Expression frames. -/
inductive ExprF where
  | unary (op : UnOp)
  | binL (op : BinOp) (b : Expr) (env : Env)
  | binR (op : BinOp) (a : Val)
  | logL (op : LogOp) (b : Expr) (env : Env)
  | cond (a b : Expr) (env : Env)
  | seq (b : Expr) (env : Env)
  | member (k : PKey) (opt : Bool)
  | indexL (k : Expr) (env : Env) (opt : Bool)
  | indexR (o : Val)
  | priv (brand : Nat) (n : Name) (opt : Bool)
  | chain
  /-- Discard the received value, produce `v`. -/
  | const (v : Val)
  | typeof

/-- Literal frames: arrays, objects, templates. -/
inductive LitF where
  | array (acc : List Val) (rest : List Elem) (env : Env)
  | spread (acc : List Val) (rest : List Elem) (env : Env)
  | object (o : Nat) (rest : List Property) (env : Env)
  | objKey (o : Nat) (p : Property) (rest : List Property) (env : Env)
  | objVal (o : Nat) (k : PKey) (rest : List Property) (env : Env)
  | objSpread (o : Nat) (rest : List Property) (env : Env)
  | tmpl (acc : List Char) (quasis : List (List Char)) (subs : List Expr) (env : Env)
  | tagged (tag : Val) (quasis : List (List Char)) (acc : List Val) (subs : List Expr) (env : Env)

/-- Assignment and update frames. A target is `.var n env`, a property
`(o, k)` or a private name `(o, brand, n)`. -/
inductive Target where
  | var (n : Name) (env : Env)
  | prop (o : Val) (k : PKey)
  | priv (o : Val) (brand : Nat) (n : Name)

inductive AsgF where
  /-- Destructuring assignment of the received value. -/
  | pat (p : Pat) (env : Env)
  /-- Object of a member target evaluated (`k` static or `kexpr` computed). -/
  | obj (op : AsgOp) (k : Option PKey) (kexpr : Option Expr) (v : Expr) (env : Env)
  | key (op : AsgOp) (o : Val) (v : Expr) (env : Env)
  | privObj (op : AsgOp) (brand : Nat) (n : Name) (v : Expr) (env : Env)
  /-- Old value of a compound/logical target received. -/
  | old (op : AsgOp) (t : Target) (v : Expr) (env : Env)
  /-- Right-hand side received: combine with `old` by `op` and store. -/
  | put (op : Option BinOp) (t : Target) (old : Val)
  | updObj (inc pre : Bool) (k : Option PKey) (kexpr : Option Expr) (env : Env)
  | updKey (inc pre : Bool) (o : Val)
  | updPrivObj (inc pre : Bool) (brand : Nat) (n : Name)
  | updOld (inc pre : Bool) (t : Target)

/-- Statement frames. -/
inductive StmtF where
  | block (rest : List Stmt) (env : Env)
  /-- Lexical scope with `using` resources (value, dispose method), newest first. -/
  | scope (res : List (Val × Val))
  | dispose (rest : List (Val × Val)) (c : Comp)
  | if_ (t : Stmt) (e : Option Stmt) (env : Env)
  | decl (kind : DeclKind) (p : Pat) (rest : List (Pat × Option Expr)) (env : Env)
  | declNext (kind : DeclKind) (rest : List (Pat × Option Expr)) (env : Env)
  | ret
  | throw
  | try_ (handler : Option (Option Pat × List Stmt)) (fin : Option (List Stmt)) (env : Env)
  | catch_ (fin : Option (List Stmt)) (env : Env)
  | finally_ (c : Comp)
  | label (l : Name)
  | switchD (cases : List (Option Expr × List Stmt)) (env : Env)
  | switchCase (d : Val) (rest : List (Option Expr × List Stmt)) (all : List (Option Expr × List Stmt)) (env : Env)
  | switchBody

/-- Loop frames; `labels` are the loop's label set. -/
inductive LoopF where
  /-- Before the test; `copy` creates the next iteration's bindings first. -/
  | forTest (copy : Bool) (test update : Option Expr) (body : Stmt) (env : Env) (names : List Name) (labels : List Name)
  | forBody (test update : Option Expr) (body : Stmt) (env : Env) (names : List Name) (labels : List Name)
  | forUpd (test update : Option Expr) (body : Stmt) (env : Env) (names : List Name) (labels : List Name)
  | whileTest (c : Expr) (body : Stmt) (env : Env) (labels : List Name)
  | whileBody (c : Expr) (body : Stmt) (env : Env) (labels : List Name)
  | doBody (body : Stmt) (c : Expr) (env : Env) (labels : List Name)
  | forOfSrc (async : Bool) (kind : Option DeclKind) (p : Pat) (body : Stmt) (env : Env) (labels : List Name)
  /-- Iterator obtained from `[Symbol.iterator]()`. -/
  | forOfIt (async : Bool) (kind : Option DeclKind) (p : Pat) (body : Stmt) (env : Env) (labels : List Name)
  /-- Result of `next()` received. -/
  | forOfNext (it next : Val) (async : Bool) (kind : Option DeclKind) (p : Pat) (body : Stmt) (env : Env) (labels : List Name)
  | forOfBody (src : IterSrc) (async : Bool) (kind : Option DeclKind) (p : Pat) (body : Stmt) (env : Env) (labels : List Name)
  /-- Completion `c` waits for the iterator's `return()`. -/
  | close (c : Comp)

/-- Pattern-binding frames. -/
inductive BindF where
  | dflt (p : Pat) (env : Env) (mode : BindMode) (kind : DeclKind)
  /-- Array pattern over collected values. -/
  | arr (ps : List (Option Pat)) (rest : Option Pat) (vs : List Val) (env : Env) (mode : BindMode) (kind : DeclKind)
  | arrSrc (ps : List (Option Pat)) (rest : Option Pat) (env : Env) (mode : BindMode) (kind : DeclKind)
  | obj (src : Val) (ps : List (Key × Pat)) (rest : Option Pat) (used : List PKey) (env : Env) (mode : BindMode) (kind : DeclKind)
  | objKey (src : Val) (p : Pat) (ps : List (Key × Pat)) (rest : Option Pat) (used : List PKey) (env : Env) (mode : BindMode) (kind : DeclKind)
  | objVal (src : Val) (k : PKey) (p : Pat) (ps : List (Key × Pat)) (rest : Option Pat) (used : List PKey) (env : Env) (mode : BindMode) (kind : DeclKind)
  /-- Collect an iterator into a list (array patterns, spread of non-arrays). -/
  | collect (acc : List Val) (it next : Val)
  | collectIt (acc : List Val)

/-- Function, class and builtin frames. -/
inductive FnF where
  | fn (b : Boundary)
  /-- Bind remaining parameters, then run the body of `f`. -/
  | params (f : Func) (ps : List Pat) (args : List Val) (env : Env)
  | paramDflt (f : Func) (p : Pat) (ps : List Pat) (args : List Val) (env : Env)
  | classHeritage (c : Class) (env : Env)
  /-- Class definition: constructor `f`, prototype `p`, class scope `env`,
  members left, instance members collected (reversed). -/
  | classMembers (f p : Nat) (ms : List Member) (inst : List InstMember) (env : Env)
  | classKey (f p : Nat) (m : Member) (ms : List Member) (inst : List InstMember) (env : Env)
  | classStatic (f p : Nat) (k : PKey) (ms : List Member) (inst : List InstMember) (env : Env)
  /-- Installing instance members on `o`; `env` binds `this`. -/
  | fields (o : Nat) (ms : List InstMember) (env : Env)
  | fieldVal (o : Nat) (k : PKey) (ms : List InstMember) (env : Env)
  | privVal (o : Nat) (brand : Nat) (n : Name) (ms : List InstMember) (env : Env)
  /-- Base constructor: fields installed, run the constructor. -/
  | ctorBody (o : Val) (f : Func) (env : Env) (args : List Val)
  /-- `super(...)` returned the parent's object; class `cls`, ctor scope `env`. -/
  | superRet (thisCell : Nat) (cls : Nat) (env : Env)
  | paramProps (o : Val) (ns : List Name) (env : Env)
  /-- A builtin continuing after a callback, with captured values. -/
  | native (n : Native) (data : List Val)
  /-- Resolve (or reject) derived promise `p` with the callback's result. -/
  | promiseThen (p : Nat)
  | yield (delegate : Bool)
  /-- `yield*`: iterator received from `[Symbol.iterator]()`. -/
  | ystarIt
  /-- `yield*`: inner `next()` result received. -/
  | ystarNext (it next : Val)
  /-- `yield*`: resumed with a value for the inner `next`. -/
  | ystarResume (it next : Val)
  /-- Async `yield*`: iterator received from `[Symbol.asyncIterator]()`. -/
  | ystarAIt
  /-- Async `yield*`: awaited inner `next()`/`throw()` result received. -/
  | ystarAResult (it next : Val)
  /-- Async `yield*`: resumed with a value for the inner `next`. -/
  | ystarAResume (it next : Val)
  /-- Async `yield*`: awaited inner `return()` result received. -/
  | ystarAReturned (it next : Val)
  /-- Async `yield*` returning: the awaited return value received. -/
  | ystarAReturn
  | await
  /-- Module bodies still to run, with their environments. -/
  | modules (rest : List (List Stmt × Env))

inductive Frame where
  | e (f : ExprF)
  | c (f : CallF)
  | l (f : LitF)
  | a (f : AsgF)
  | s (f : StmtF)
  | lp (f : LoopF)
  | b (f : BindF)
  | k (f : FnF)

inductive Ctl where
  | ev (e : Expr) (env : Env)
  | ex (s : Stmt) (env : Env)
  | ret (v : Val)
  | abr (a : Abrupt)
  | call (f this : Val) (args : List Val)
  /-- `new f(args)` with `newTarget`. -/
  | construct (f : Val) (args : List Val) (newTarget : Val)
  | bind (p : Pat) (v : Val) (env : Env) (mode : BindMode) (kind : DeclKind)
  /-- Optional chain short-circuit: unwind to `ExprF.chain`. -/
  | short
  | halt (c : Comp)

/-- A suspended computation: its frames (innermost first) up to and
including its boundary, and the AsyncLocalStorage store. -/
structure Susp where
  frames : List Frame
  stores : List (Nat × Val)

inductive GenState where
  | start (body : List Stmt) (env : Env)
  | suspended (s : Susp)
  | running
  | done

inductive Reaction where
  | resume (s : Susp)
  | then_ (onF onR : Val) (derived : Nat) (stores : List (Nat × Val))
  /-- Adopt the state of the thenable (the job value) into promise `p`. -/
  | adopt (p : Nat)
  /-- Settle promise `p` the same way (thenable adoption). -/
  | forward (p : Nat)

inductive PState where
  | pending (rs : List Reaction)
  | fulfilled (v : Val)
  | rejected (v : Val)

/-- Function code. `home` is the object `super` refers to (`[[HomeObject]]`). -/
inductive Code where
  | closure (f : Func) (env : Env) (arrow : Bool) (home : Val)
  /-- Class constructor: explicit constructor, class scope, parent
  constructor (`null` for a base class), instance members. -/
  | klass (ctor : Option Func) (env : Env) (parent : Val) (inst : List InstMember)
  /-- Builtin with captured data. -/
  | native (n : Native) (data : List Val)
  | bound (target this : Val) (args : List Val)

inductive Kind where
  | ordinary
  | array (elems : List Val)
  | fn (c : Code)
  | buf (bytes : List Byte)
  /-- An `ArrayBuffer` over native memory region `r` (`toArrayBuffer`). -/
  | extBuf (r off len : Nat)
  | typed (k : EltK) (buf off len : Nat)
  | view (buf off len : Nat)
  | map (entries : List (Val × Val))
  | set (elems : List Val)
  | promise (s : PState)
  | gen (s : GenState) (async : Bool) (queue : List (Nat × Comp))
  /-- Module namespace: export names to cells. -/
  | ns (exports : List (Name × Nat))
  | box (v : Val)
  /-- Array iterator over `src` at `i`; `mode` 0 values, 1 keys, 2 entries. -/
  | iter (src : Val) (i : Nat) (mode : Nat)

structure Obj where
  kind : Kind
  proto : Val
  props : Props
  priv : List ((Nat × Name) × PropV)
  extensible : Bool

/-- Heap entries: variable cells (`none` = uninitialized, TDZ) and objects. -/
inductive HObj where
  | cell (v : Option Val)
  | obj (o : Obj)

/-! ## FFI -/

/-- A decoded FFI argument. JS-memory pointers carry the buffer contents
from the pointer on (the bytes the native side may read). -/
inductive Arg where
  | null
  | num (x : NumV)
  | big (i : Int)
  | bool (b : Bool)
  | jsPtr (buf off : Nat) (bytes : List Byte)
  | extPtr (r off : Nat)
  | other (v : Val)

/-- FFI return value as the JS side receives it. -/
inductive Ret where
  | void
  | num (x : NumV)
  | big (i : Int)
  | bool (b : Bool)
  | ptr (r off : Nat)
  | null
  | cstr (s : List Char)
  /-- The native side calls `JSCallback` `fn` (its pointer region) with these
  arguments before the call returns; `Ffi.back` continues it with the result. -/
  | callback (fn : Nat) (args : List Arg)

/-- One FFI call: symbol, decoded arguments, result. -/
structure Event where
  sym : Name
  args : List Arg
  ret : Ret

/-- The FFI as a parameter: a native state, calls (which may write JS
buffers through pointer arguments: buffer, offset, bytes) and native memory
reads. -/
structure Ffi where
  S : Type
  call : S → Name → List Arg → M (Option (S × Ret × List (Nat × Nat × List Byte)))
  read : S → Nat → Nat → Nat → Option (List Byte)
  /-- Address of a symbol (a `.ptr` property of `dlopen` functions). -/
  addr : Name → Nat
  /-- Continue the pending native call with its `JSCallback`'s result. -/
  back : S → Arg → M (Option (S × Ret × List (Nat × Nat × List Byte)))

/-- A microtask: a promise reaction with the settled value. -/
structure Job where
  r : Reaction
  throw : Bool
  v : Val

/-- Rarely changing state, grouped so a step's record update copies one
field. -/
structure Aux (S : Type) where
  jobs : List Job
  ffi : S
  /-- Newest first. -/
  trace : List Event
  /-- AsyncLocalStorage stores: (instance, value), innermost first. -/
  stores : List (Nat × Val)

structure St (S : Type) where
  heap : PTrie HObj
  next : Nat
  ctl : Ctl
  stack : List Frame
  aux : Aux S

def St.jobs {S : Type} (s : St S) : List Job := s.aux.jobs
def St.ffi {S : Type} (s : St S) : S := s.aux.ffi
def St.trace {S : Type} (s : St S) : List Event := s.aux.trace
def St.stores {S : Type} (s : St S) : List (Nat × Val) := s.aux.stores
def St.setJobs {S : Type} (s : St S) (j : List Job) : St S := { s with aux := { s.aux with jobs := j } }
def St.setFfi {S : Type} (s : St S) (f : S) : St S := { s with aux := { s.aux with ffi := f } }
def St.setTrace {S : Type} (s : St S) (t : List Event) : St S := { s with aux := { s.aux with trace := t } }
def St.setStores {S : Type} (s : St S) (t : List (Nat × Val)) : St S := { s with aux := { s.aux with stores := t } }

end Host.Ts
