import host.ts.HostBuiltins
namespace Host.Ts

/-! # Control builtins: functions, promises, generators, AsyncLocalStorage, FFI

Promises follow the ECMAScript job order: reactions are queued as jobs in
registration order; resolving with a native promise takes one extra job
(`adopt`, the spec's `NewPromiseResolveThenableJob`). Non-promise
thenables are not modelled (resolution with them fulfills). -/

/-! ## Hoisting -/

/-- Names a pattern binds. Fuel-indexed: structural recursion on the
mutual AST would unfold its 45k-node `brecOn` in every kernel call. -/
def patNamesF : Nat → Pat → List Name
  | 0, _ => []
  | f + 1, p => match p with
    | .id n => [n]
    | .expr _ => []
    | .array ps r => (ps.filterMap id).flatMap (patNamesF f) ++ (match r with | some q => patNamesF f q | none => [])
    | .object ps r => ps.flatMap (fun kp => patNamesF f kp.2) ++ (match r with | some q => patNamesF f q | none => [])
    | .dflt q _ => patNamesF f q

def patNames (p : Pat) : List Name := patNamesF 32 p

def patNamesR : Option Pat → List Name
  | some p => patNames p
  | none => []

def declsNames : List (Pat × Option Expr) → List Name
  | [] => []
  | (p, _) :: ds => patNames p ++ declsNames ds

def stmtNames : Stmt → List Name
  | .decl _ ds => declsNames ds
  | .cls (.mk (some n) _ _) => [n]
  | .func (.mk (some n) _ _ _ _ _ _) => [n]
  | .enum _ n _ => [n]
  | _ => []

def blockNames : List Stmt → List Name
  | [] => []
  | s :: ss => stmtNames s ++ blockNames ss

section
variable {S : Type}

def allocCells (s : St S) : List Name → Env → Env × St S
  | [], env => (env, s)
  | n :: ns, env => let (c, s) := s.alloc (.cell none); allocCells s ns ((n, c) :: env)

def closureObj (s : St S) (f : Func) (env : Env) (arrow : Bool) (home : Val) : Nat × St S :=
  s.allocObj (.fn (.closure f env arrow home)) (.obj aFunctionProto) []

/-- Initialize hoisted function declarations of a block. -/
def initFuncs (s : St S) (env : Env) : List Stmt → St S
  | [] => s
  | .func f@(.mk (some n) _ _ _ _ _ _) :: ss => match lookupEnv n env with
    | some c => let (a, s) := closureObj s f env false .undef; initFuncs (s.setCell c (.obj a)) env ss
    | none => initFuncs s env ss
  | _ :: ss => initFuncs s env ss

/-- Block entry: cells for the block's lexical declarations (uninitialized),
function declarations initialized. -/
def hoist (s : St S) (ss : List Stmt) (env : Env) : Env × St S :=
  match blockNames ss with
  | [] => (env, s)
  | ns => let (env, s) := allocCells s ns env; (env, initFuncs s env ss)

/-- Enter a block: scope frame, then statements. -/
def enterBlock (s : St S) (ss : List Stmt) (env : Env) : St S :=
  let (env, s) := hoist s ss env
  ((s.push (.s (.scope []))).push (.s (.block ss env))).ret .undef

/-! ## Promises -/

def newPromise (s : St S) : Nat × St S := s.allocObj (.promise (.pending [])) (.obj aPromiseProto) []

def enqueue (s : St S) (j : Job) : St S := s.setJobs (s.jobs ++ [j])

def promiseOf (s : St S) (p : Nat) : Option (Obj × PState) :=
  match s.obj? p with
  | some o => match o.kind with
    | .promise st => some (o, st)
    | _ => none
  | none => none

def isPromise (s : St S) : Val → Option Nat
  | .obj a => (promiseOf s a).map fun _ => a
  | _ => none

def enqueueAll (s : St S) (th : Bool) (v : Val) : List Reaction → St S
  | [] => s
  | r :: rs => enqueueAll (enqueue s ⟨r, th, v⟩) th v rs

/-- Fulfill (`th = false`) or reject a pending promise. -/
def settle (s : St S) (p : Nat) (th : Bool) (v : Val) : St S :=
  match promiseOf s p with
  | some (o, .pending rs) =>
    let s := s.setObj p { o with kind := .promise (bif th then .rejected v else .fulfilled v) }
    enqueueAll s th v rs
  | _ => s

/-- `resolve(p, v)`: adopt a promise's state one job later, else fulfill. -/
def resolveP (s : St S) (p : Nat) (v : Val) : St S :=
  match isPromise s v with
  | some q => bif Nat.beq p q then s else enqueue s ⟨.adopt p, false, v⟩
  | none => settle s p false v

def react (s : St S) (p : Nat) (r : Reaction) : St S :=
  match promiseOf s p with
  | some (o, .pending rs) => s.setObj p { o with kind := .promise (.pending (rs ++ [r])) }
  | some (_, .fulfilled v) => enqueue s ⟨r, false, v⟩
  | some (_, .rejected v) => enqueue s ⟨r, true, v⟩
  | none => s

/-- A promise for `v` (`PromiseResolve`). -/
def promiseFor (s : St S) (v : Val) : Nat × St S :=
  match isPromise s v with
  | some p => (p, s)
  | none => let (p, s) := newPromise s; (p, settle s p false v)

/-! ## Suspension -/

def isSuspBoundary : Frame → Bool
  | .k (.fn (.async _)) => true
  | .k (.fn (.gen _)) => true
  | _ => false

/-- Split the stack after the nearest generator/async boundary. -/
def splitSusp : List Frame → List Frame → Option (List Frame × Frame × List Frame)
  | _, [] => none
  | acc, f :: fs => bif isSuspBoundary f then some ((f :: acc).reverse, f, fs) else splitSusp (f :: acc) fs

def setGen (s : St S) (g : Nat) (st : GenState) : St S :=
  match s.obj? g with
  | some o => match o.kind with
    | .gen _ a q => s.setObj g { o with kind := .gen st a q }
    | _ => s
  | none => s

def genOf (s : St S) (g : Nat) : Option (GenState × Bool) :=
  match s.obj? g with
  | some o => match o.kind with
    | .gen st a _ => some (st, a)
    | _ => none
  | none => none

/-- Resume generator `g`: `mode` 0 next, 1 return, 2 throw. -/
def genResume (s : St S) (g : Nat) (mode : Nat) (v : Val) : Mr S :=
  match genOf s g with
  | some (.start body env, false) => match mode with
    | 0 => .pure (enterBlock ((setGen s g .running).push (.k (.fn (.gen g)))) body env)
    | 1 => let (r, s) := iterResult (setGen s g .done) v true; .pure (s.ret (.obj r))
    | _ => .pure ((setGen s g .done).go (.abr (.throw v)))
  | some (.suspended su, false) =>
    let s := { setGen s g .running with stack := su.frames ++ s.stack }
    .pure (s.go (match mode with | 0 => .ret v | 1 => .abr (.ret v) | _ => .abr (.throw v)))
  | some (.running, _) => typeErr s (chars!"generator is already running")
  | some (.done, false) => match mode with
    | 2 => .pure (s.go (.abr (.throw v)))
    | 1 => let (r, s) := iterResult s v true; .pure (s.ret (.obj r))
    | _ => let (r, s) := iterResult s .undef true; .pure (s.ret (.obj r))
  | some (_, true) => .fail "async generator resumed synchronously"
  | none => typeErr s (chars!"not a generator")

/-! ## Async generators

Requests queue on the generator; each `next`/`return`/`throw` returns a
promise. A resumed body runs above an `agen` job sentinel; `yield v`
awaits `v`, fulfills the head request and suspends (or continues with the
next queued request). -/

def agenQueue (s : St S) (g : Nat) : List (Nat × Comp) :=
  match s.obj? g with
  | some o => match o.kind with
    | .gen _ _ q => q
    | _ => []
  | none => []

def setQueue (s : St S) (g : Nat) (q : List (Nat × Comp)) : St S :=
  match s.obj? g with
  | some o => match o.kind with
    | .gen st a _ => s.setObj g { o with kind := .gen st a q }
    | _ => s
  | none => s

/-- Start or resume the async generator for its head request, if idle. -/
def agenDrain (s : St S) (g : Nat) : St S :=
  match genOf s g, agenQueue s g with
  | some (.start body env, true), (_, .normal _) :: _ =>
    -- runs on a fresh stack above the caller's: the caller's frames are restored at the first suspension
    enterBlock ((setGen s g .running).push (.k (.fn (.gen g)))) body env
  | some (.start _ _, true), (p, .abrupt (.ret v)) :: q =>
    let s := setQueue (setGen s g .done) g q
    let (r, s) := iterResult s v true
    (resolveP s p (.obj r)).ret .undef
  | some (.start _ _, true), (p, .abrupt (.throw v)) :: q =>
    (settle (setQueue (setGen s g .done) g q) p true v).ret .undef
  | some (.suspended su, true), (_, c) :: _ =>
    let s := ({ setGen s g .running with stack := su.frames ++ s.stack }).setStores su.stores
    s.go (match c with | .normal v => .ret v | .abrupt a => .abr a)
  | some (.done, true), (p, c) :: q =>
    let s := setQueue s g q
    match c with
    | .abrupt (.throw v) => (settle s p true v).ret .undef
    | .abrupt (.ret v) => let (r, s) := iterResult s v true; (resolveP s p (.obj r)).ret .undef
    | _ => let (r, s) := iterResult s .undef true; (resolveP s p (.obj r)).ret .undef
  | _, _ => s.ret .undef

end

section
variable (F : Ffi)

/-! ## Function, Reflect, misc -/

def fnN (s : St F.S) (this : Val) (args : List Val) : FnN → RS F
  | .call => .pure (s.go (.call this (arg args 0) args.tail))
  | .apply => .bind (match arg args 1 with
      | .undef | .null => .pure (some [])
      | v => elemsOf F s v) fun
    | some vs => .pure (s.go (.call this (arg args 0) vs))
    | none => typeErr s (chars!"apply with a non-array")
  | .reflectApply => .bind (elemsOf F s (arg args 2)) fun
    | some vs => .pure (s.go (.call (arg args 0) (arg args 1) vs))
    | none => typeErr s (chars!"Reflect.apply with a non-array")
  | .bind => let (a, s) := s.allocObj (.fn (.bound this (arg args 0) args.tail)) (.obj aFunctionProto) []
    retS F s (.obj a)
  | .reflectGet => .bind (toKey (arg args 1)) fun
    | some k => match arg args 0 with
      | .obj _ => getV F s (arg args 0) k
      | _ => typeErr s (chars!"Reflect.get on a primitive")
    | none => .fail "Reflect.get key"
  | .reflectHas => .bind (toKey (arg args 1)) fun
    | some k => .bind (lookup F s (arg args 0) k) fun p => retS F s (.bool p.isSome)
    | none => .fail "Reflect.has key"
  | .perfNow => retS F s (.num zeroN)
  | .finRegCtor => .fail "FinalizationRegistry requires new"
  | .finRegister => retS F s .undef
  | .finUnregister => retS F s (.bool false)
  | .consoleLog => retS F s .undef
  | .jsonStringify => .fail "JSON.stringify"
  | .noop => retS F s .undef

/-! ## Promises, generators, AsyncLocalStorage -/

def resolveFns (s : St F.S) (p : Nat) : Val × Val × St F.S :=
  let (r, s) := s.allocObj (.fn (.native (.ctl .resolveFn) [.obj p])) (.obj aFunctionProto) []
  let (j, s) := s.allocObj (.fn (.native (.ctl .rejectFn) [.obj p])) (.obj aFunctionProto) []
  (.obj r, .obj j, s)

def thenOn (s : St F.S) (p : Nat) (onF onR : Val) : RS F :=
  let (d, s) := newPromise s
  retS F (react s p (.then_ onF onR d s.stores)) (.obj d)

def ctlN (s : St F.S) (this : Val) (args : List Val) (data : List Val) : CtlN → RS F
  | .genNext => gen 0
  | .genReturn => gen 1
  | .genThrow => gen 2
  | .agenNext => agen (.normal (arg args 0))
  | .agenReturn => agen (.abrupt (.ret (arg args 0)))
  | .agenThrow => agen (.abrupt (.throw (arg args 0)))
  | .promiseCtor => .fail "Promise requires new"
  | .promiseResolve => let (p, s) := promiseFor s (arg args 0); retS F s (.obj p)
  | .promiseReject => let (p, s) := newPromise s; retS F (settle s p true (arg args 0)) (.obj p)
  | .promiseThen => match isPromise s this with
    | some p => thenOn F s p (arg args 0) (arg args 1)
    | none => typeErr s (chars!"then on a non-promise")
  | .promiseCatch => match isPromise s this with
    | some p => thenOn F s p .undef (arg args 0)
    | none => typeErr s (chars!"catch on a non-promise")
  | .resolveFn => match data with
    | [.obj p] => retS F (resolveP s p (arg args 0)) .undef
    | _ => .fail "resolve function"
  | .rejectFn => match data with
    | [.obj p] => retS F (settle s p true (arg args 0)) .undef
    | _ => .fail "reject function"
  | .alsCtor => .fail "AsyncLocalStorage requires new"
  | .alsRun => match this with
    | .obj a =>
      let s := s.setStores ((a, arg args 0) :: s.stores)
      .pure ((s.push (.k (.native (.ctl .alsRun) []))).go (.call (arg args 1) .undef (args.drop 2)))
    | _ => typeErr s (chars!"run on a non-AsyncLocalStorage")
  | .alsGetStore => match this with
    | .obj a => retS F s ((s.stores.find? fun (b, _) => Nat.beq a b).elim .undef Prod.snd)
    | _ => typeErr s (chars!"getStore on a non-AsyncLocalStorage")
where
  gen (mode : Nat) : RS F := match this with
    | .obj g => genResume s g mode (arg args 0)
    | _ => typeErr s (chars!"generator method on a non-generator")
  agen (c : Comp) : RS F := match this with
    | .obj g => match genOf s g with
      | some (st, true) =>
        let (p, s) := newPromise s
        let s := setQueue s g (agenQueue s g ++ [(p, c)])
        let idle := match st with | .running => false | _ => true
        -- the caller receives the promise; an idle generator starts now, above the caller
        .pure (bif idle then agenDrain ((s.push (.e (.const (.obj p))))) g else s.ret (.obj p))
      | _ => typeErr s (chars!"not an async generator")
    | _ => typeErr s (chars!"not an async generator")

/-! ## FFI -/

def decodeArg (s : St F.S) (ty : List Char) (v : Val) : M (Option Arg) :=
  bif nameEq ty (chars!"ptr") || nameEq ty (chars!"pointer") || nameEq ty (chars!"buffer") || nameEq ty (chars!"cstring") then
    match v with
    | .ptr (.js b) o => .pure ((bufBytes F s b).map fun bs => .jsPtr b o (bs.drop o))
    | .ptr (.ext r) o => .pure (some (.extPtr r o))
    | .null | .undef => .pure (some .null)
    | .num x => .pure (some (.num x))
    | .obj a => match s.obj? a with
      | some ⟨.typed _ b off _, _, _, _, _⟩ => .pure ((bufBytes F s b).map fun bs => .jsPtr b off (bs.drop off))
      | _ => .pure none
    | .big i => .pure (some (.big i))
    | _ => .pure none
  else bif nameEq ty (chars!"u64") || nameEq ty (chars!"i64") || nameEq ty (chars!"usize") then
    match v with
    | .big i => .pure (some (.big i))
    | .num x => .pure (some (.num x))
    | _ => .pure none
  else bif nameEq ty (chars!"f32") || nameEq ty (chars!"float") then
    match v with
    | .num x => .bind (numUn .f32 x) fun y => .pure (some (.num y))
    | _ => .pure none
  else bif nameEq ty (chars!"f64") || nameEq ty (chars!"double") then
    match v with
    | .num x => .pure (some (.num x))
    | _ => .pure none
  else bif nameEq ty (chars!"bool") then .bind (truthy v) fun b => .pure (some (.bool b))
  else
    match v with
    | .num x => .bind (numUn .int32 x) fun y => .pure (some (.num y))
    | .bool b => .pure (some (.num (bif b then one else zeroN)))
    | _ => .pure none

def decodeArgs (s : St F.S) : List Val → List Val → M (Option (List Arg))
  | [], [] => .pure (some [])
  | .str ty :: ts, v :: vs => .bind (decodeArg F s ty v) fun
    | some a => .bind (decodeArgs s ts vs) fun r => .pure (r.map (a :: ·))
    | none => .pure none
  | .str ty :: ts, [] => .bind (decodeArg F s ty .undef) fun
    | some a => .bind (decodeArgs s ts []) fun r => .pure (r.map (a :: ·))
    | none => .pure none
  | _, _ => .pure none

def retVal : Ret → Val
  | .void => .undef
  | .num x => .num x
  | .big i => .big i
  | .bool b => .bool b
  | .ptr r off => .ptr (.ext r) off
  | .null => .null
  | .cstr cs => .str cs
  | .callback _ _ => .undef

def applyWrites (s : St F.S) : List (Nat × Nat × List Byte) → Option (St F.S)
  | [] => some s
  | (b, off, bytes) :: ws => match s.obj? b with
    | some o => match o.kind with
      | .buf bs => applyWrites (s.setObj b { o with kind := .buf (bs.take off ++ bytes ++ bs.drop (off + len bytes)) }) ws
      | _ => none
    | none => none

def readMem (s : St F.S) (p : Val) (off : Nat) (k : EltK) : M (Option Cell) :=
  match p with
  | .ptr (.js b) o => .pure ((bufBytes F s b).bind fun bs => readCell k (bs.drop (o + off)))
  | .ptr (.ext r) o => .pure ((F.read s.ffi r (o + off) k.size).bind (readCell k))
  | _ => .pure none

/-- `JSCallback` pointers are native regions `cbBase + a` for callback object `a`. -/
def cbBase : Nat := 2 ^ 48

def kCbFn : PKey := .str chars!"%fn"
def kCbArgs : PKey := .str chars!"%args"
def kCbRet : PKey := .str chars!"%returns"

/-- The JS value of a native argument passed to a callback parameter of type `ty`. -/
def argVal (ty : List Char) : Arg → Val
  | .null => .null
  | .num x => .num x
  | .big i => bif nameEq ty chars!"u64" || nameEq ty chars!"i64" then .big i else .num (.lit (F64.ofInt i))
  | .bool b => .bool b
  | .jsPtr b off _ => .ptr (.js b) off
  | .extPtr r off => .ptr (.ext r) off
  | .other v => v

def argVals : List Val → List Arg → List Val
  | .str t :: ts, a :: as => argVal t a :: argVals ts as
  | _, _ => []

/-- Invoke `JSCallback` `r` for native call `name`: its frame waits for the result. -/
def ffiCallback (s : St F.S) (name : Name) (r : Nat) (cargs : List Arg) : RS F :=
  bif Nat.blt r cbBase then .fail "callback of a non-JSCallback pointer" else
  match s.obj? (r - cbBase) with
  | some o => match findProp kCbFn o.props, findProp kCbArgs o.props, findProp kCbRet o.props with
    | some (.data fn _ _), some (.data ats _ _), some (.data rt _ _) => .bind (elemsOf F s ats) fun
      | some tys => .pure ((s.push (.k (.native (.ffi .callbackRet) [.str name, rt]))).go (.call fn .undef (argVals tys cargs)))
      | none => .fail "JSCallback signature"
    | _, _, _ => .fail "JSCallback object"
  | none => .fail "callback of an unknown JSCallback"

/-- A native call's result: writes into JS buffers, the trace event, then the
return value or a `JSCallback` invocation the call is waiting for. -/
def ffiDone (s : St F.S) (name : Name) (as : List Arg) : Option (F.S × Ret × List (Nat × Nat × List Byte)) → RS F
  | some (st, ret, ws) => match applyWrites F (s.setFfi st) ws with
    | some s =>
      let s := s.setTrace (⟨name, as, ret⟩ :: s.trace)
      match ret with
      | .callback r cargs => ffiCallback F s name r cargs
      | _ => retS F s (retVal ret)
    | none => .fail "FFI write outside a JS buffer"
  | none => .fail ("FFI model rejected " ++ String.ofList name)

def ffiN (s : St F.S) (this : Val) (args : List Val) (data : List Val) : FfiN → RS F
  | .dlopen => match arg args 1 with
    | .obj sigs => match s.obj? sigs with
      | some o =>
        let rec mk (s : St F.S) : Props → M (Props × St F.S)
          | [] => .pure ([], s)
          | (.str name, .data (.obj d) _ true) :: ps =>
            .bind (dataOf F s (.obj d) (.str (chars!"args"))) fun ats =>
            .bind (dataOf F s (.obj d) (.str (chars!"returns"))) fun rt =>
            match ats, rt with
            | some ats, some rt =>
              let (f, s) := s.allocObj (.fn (.native (.ffi .symbol) [.str name, ats, rt])) (.obj aFunctionProto)
                [(.str chars!"ptr", .data (natV (F.addr name)) false false)]
              .bind (mk s ps) fun (r, s) => .pure ((.str name, .data (.obj f) true true) :: r, s)
            | _, _ => .fail "dlopen signature"
          | _ :: ps => mk s ps
        .bind (mk s o.props) fun (syms, s) =>
        let (so, s) := s.allocObj .ordinary (.obj aObjectProto) syms
        let (cl, s) := s.allocObj (.fn (.native (.ffi .close) [])) (.obj aFunctionProto) []
        let (lib, s) := s.allocObj .ordinary (.obj aObjectProto)
          [(.str (chars!"symbols"), .data (.obj so) true true), (.str (chars!"close"), .data (.obj cl) true true)]
        retS F s (.obj lib)
      | none => .fail "dangling"
    | _ => typeErr s (chars!"dlopen signatures")
  | .symbol => match data with
    | [.str name, ats, .str rt] => .bind (elemsOf F s ats) fun
      | some tys => .bind (decodeArgs F s tys args) fun
        | some as => let _ := rt; .bind (F.call s.ffi name as) (ffiDone F s name as)
        | none => .fail ("FFI argument decoding: " ++ String.ofList name)
      | none => .fail "FFI signature"
    | _ => .fail "FFI symbol data"
  | .ptr => match arg args 0 with
    | .obj a => .bind (offsetArg (arg args 1)) fun extra => match s.obj? a with
      | some ⟨.typed k b off n, _, _, _, _⟩ => bif Nat.beq n 0 then typeErr s (chars!"ptr of an empty view") else
        match s.obj? b with
        | some ⟨.extBuf r o _, _, _, _, _⟩ => retS F s (.ptr (.ext r) (o + off + extra))
        | _ => let _ := k; retS F s (.ptr (.js b) (off + extra))
      | some ⟨.buf bs, _, _, _, _⟩ => bif bs.isEmpty then typeErr s (chars!"ptr of an empty buffer") else retS F s (.ptr (.js a) extra)
      | some ⟨.extBuf r o _, _, _, _, _⟩ => retS F s (.ptr (.ext r) (o + extra))
      | _ => typeErr s (chars!"ptr of a non-buffer")
    | _ => typeErr s (chars!"ptr of a non-buffer")
  | .readU64 => rd .u64
  | .readU32 => rd .u32
  | .readI32 => rd .i32
  | .readF32 => rd .f32
  | .readPtr => .fail "read.ptr"
  | .toArrayBuffer => match arg args 0 with
    | .ptr (.ext r) o => .bind (offsetArg (arg args 1)) fun off => .bind (offsetArg (arg args 2)) fun n =>
      let (b, s) := s.allocObj (.extBuf r (o + off) n) (.obj aArrayBufferProto) []
      retS F s (.obj b)
    | .num (.lit x) => match hostAddr x with
      | some (r, o) => .bind (offsetArg (arg args 1)) fun off => .bind (offsetArg (arg args 2)) fun n =>
        let (b, s) := s.allocObj (.extBuf r (o + off) n) (.obj aArrayBufferProto) []
        retS F s (.obj b)
      | none => .fail "toArrayBuffer of a number that names no native memory"
    | _ => .fail "toArrayBuffer of a non-native pointer"
  | .jsCallback => .fail "JSCallback requires new"
  | .callbackRet => .fail "callback continuation called"
  | .cstring => .fail "CString"
  | .close => let _ := this; retS F s .undef
where
  rd (k : EltK) : RS F := .bind (offsetArg (arg args 1)) fun off => .bind (readMem F s (arg args 0) off k) fun
    | some c => retS F s (cellVal c)
    | none => .fail "read of unknown memory"

/-- A call into the host world model: `Ffi.call` with the builtin's name;
JavaScript values pass as they are (`Arg.other` for strings and objects). -/
def hostCall (s : St F.S) (args : List Val) (data : List Val) : RS F :=
  match data with
  | [.str name] =>
    let as := args.map fun
      | .num x => Arg.num x | .big i => .big i | .bool b => .bool b | .undef | .null => .null
      | .ptr (.ext r) off => .extPtr r off
      | v => .other v
    .bind (F.call s.ffi name as) (ffiDone F s name as)
  | _ => .fail "host call data"

/-! ## Dispatch -/

def callNative (s : St F.S) (n : Native) (data : List Val) (this : Val) (args : List Val) : RS F :=
  match n with
  | .obj f => objN F s this args f
  | .arr f => arrN F s this args f
  | .iter f => iterN F s this f
  | .math f => mathN F s args f
  | .num f => numN F s this args f
  | .str f => strN F s this args f
  | .str2 f => str2N F s this args f
  | .err f => errN F s this args .undef f
  | .map f => match f with
    | .ctor | .weakCtor => typeErr s (chars!"Map requires new")
    | f => mapN F s this args f
  | .set f => match f with
    | .ctor => typeErr s (chars!"Set requires new")
    | f => setN F s this args f
  | .buf f => match f with
    | .typedCtor | .arrayBuffer | .dataView => typeErr s (chars!"constructor requires new")
    | f => bufN F s this args data f
  | .fn f => fnN F s this args f
  | .ctl f => ctlN F s this args data f
  | .ffi f => ffiN F s this args data f
  | .host f => match f with
    | .call => hostCall F s args data
    | f => hostN F s this args data f

def constructNative (s : St F.S) (n : Native) (data : List Val) (args : List Val) (nt : Val) : RS F :=
  match n with
  | .err f => errN F s .undef args nt f
  | .map f => mapN F s .undef args f
  | .set .ctor => setN F s .undef args .ctor
  | .buf f => bufN F s .undef args data f
  | .arr .ctor => arrN F s .undef args .ctor
  | .fn .finRegCtor => let (a, s) := s.allocObj .ordinary (.obj aFinRegProto) []; retS F s (.obj a)
  | .host f => let _ := nt; hostN F s .undef args data f
  | .ctl .alsCtor => let (a, s) := s.allocObj .ordinary (.obj aAlsProto) []; retS F s (.obj a)
  | .ctl .promiseCtor =>
    let (p, s) := newPromise s
    let (r, j, s) := resolveFns F s p
    .pure ((s.push (.k (.native (.ctl .promiseCtor) [.obj p]))).go (.call (arg args 0) .undef [r, j]))
  | .ffi .jsCallback =>
    -- the pointer names the object: native calls invoke it through `Ret.callback`
    let (a, s) := s.allocObj .ordinary (.obj aJsCallbackProto) []
    .bind (dataOf F s (arg args 1) (.str chars!"args")) fun ats => .bind (dataOf F s (arg args 1) (.str chars!"returns")) fun rt =>
    match ats, rt with
    | some ats, some rt =>
      let s := defineProp F s a (.str (chars!"ptr")) (.data (.ptr (.ext (cbBase + a)) 0) false true)
      let s := defineProp F (defineProp F (defineProp F s a kCbFn (.data (arg args 0) false false)) a kCbArgs (.data ats false false)) a kCbRet (.data rt false false)
      retS F s (.obj a)
    | _, _ => .fail "JSCallback signature"
  | _ => typeErr s (chars!"not a constructor")

/-- A builtin frame receiving its callback's normal result. -/
def nativeRet (s : St F.S) (n : Native) (data : List Val) (v : Val) : RS F :=
  match n, data with
  | .ffi .callbackRet, [.str name, .str rt] =>
    bif nameEq rt chars!"void" then .bind (F.back s.ffi .null) (ffiDone F s name [.null])
    else .bind (decodeArg F s rt v) fun
      | some a => .bind (F.back s.ffi a) (ffiDone F s name [a])
      | none => .fail "JSCallback result"
  | .ctl .promiseCtor, [p] => let _ := v; retS F s p
  | .ctl .alsRun, _ => retS F (s.setStores s.stores.tail) v
  | .host .jsonParse, data => jsonResume F s data
  | _, _ => .fail "builtin continuation"

/-- A builtin frame receiving an abrupt completion. -/
def nativeAbr (s : St F.S) (n : Native) (data : List Val) (a : Abrupt) : RS F :=
  match n, data, a with
  | .ffi .callbackRet, _, _ => .fail "exception escaping a JSCallback"
  | .ctl .promiseCtor, [.obj p], .throw e => retS F (settle s p true e) (.obj p)
  | .ctl .alsRun, _, a => .pure ((s.setStores s.stores.tail).go (.abr a))
  | _, _, a => .pure (s.go (.abr a))

end
end Host.Ts
