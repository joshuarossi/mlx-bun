import host.ts.Module
import host.ts.Run
namespace Host.Ts

/-! # Harness for kernel-checked runs

`moduleOut` boots modules, runs the machine with a concrete number
server, and reads a top-level binding of the entry module. -/

def nullFfi : Ffi := ⟨Unit, fun _ _ _ => .pure none, fun _ _ _ _ => none, fun _ => 0, fun _ _ => .pure none⟩

def entryEnv {S : Type} (s : St S) : Env :=
  match s.stack with
  | .k (.modules bodies) :: _ => match bodies.getLast? with
    | some (_, env) => env
    | none => []
  | _ => []

def bindingOf {S : Type} (s : St S) (env : Env) (n : Name) : Option Val :=
  (lookupEnv n env).bind fun c => (s.cell? c).bind id

/-- Run modules to completion; the entry module's binding `n`. -/
def moduleOut (F : Ffi) (ffi : F.S) (us : List UMod) (hs : List (HMod F.S)) (entry : List Char) (fuel : Nat) (n : Name) : Option Val :=
  (boot ffi us hs entry).bind fun s =>
    let env := entryEnv s
    (runC F fuel s ⟨[]⟩).bind fun (s', _) =>
      match s'.ctl with
      | .halt (.normal _) => bindingOf s' env n
      | _ => none

def snippetOut (m : Module) (fuel : Nat) : Option Val :=
  moduleOut nullFfi () [⟨chars!"main.ts", m⟩] [] chars!"main.ts" fuel chars!"out"

end Host.Ts

namespace Host.Ts

/-- Final state and entry environment of a concrete run that halted normally. -/
def runModules (F : Ffi) (ffi : F.S) (us : List UMod) (hs : List (HMod F.S)) (entry : List Char) (fuel : Nat) :
    Option (St F.S × Env) :=
  (boot ffi us hs entry).bind fun s =>
    let env := entryEnv s
    (runC F fuel s ⟨[]⟩).bind fun (s', _) =>
      match s'.ctl with
      | .halt (.normal _) => some (s', env)
      | _ => none

/-- A number value as a natural number. -/
def natOf : Val → Option Nat
  | .num (.lit x) => F64.toIndex? x
  | _ => none

/-- An array of numbers. -/
def natsOf {S : Type} (s : St S) : Val → Option (List Nat)
  | .obj a => match s.obj? a with
    | some ⟨.array es, _, _, _, _⟩ => es.mapM natOf
    | _ => none
  | _ => none

/-- An array of arrays of numbers. -/
def natss {S : Type} (s : St S) : Val → Option (List (List Nat))
  | .obj a => match s.obj? a with
    | some ⟨.array es, _, _, _, _⟩ => es.mapM (natsOf s)
    | _ => none
  | _ => none

def traceSyms {S : Type} (s : St S) : List Name := s.trace.reverse.map Event.sym

end Host.Ts

namespace Host.Ts

/-- A number through the symbolic table. -/
def symOf (S : SSrv) : Val → Option SymE
  | .num x => S.val x
  | _ => none

def symsOf {Sf : Type} (s : St Sf) (S : SSrv) : Val → Option (List SymE)
  | .obj a => match s.obj? a with
    | some ⟨.array es, _, _, _, _⟩ => es.mapM (symOf S)
    | _ => none
  | _ => none

/-- The `i`-th element of an array value. -/
def elemOf {Sf : Type} (s : St Sf) (v : Val) (i : Nat) : Option Val :=
  match v with
  | .obj a => match s.obj? a with
    | some ⟨.array es, _, _, _, _⟩ => nth? es i
    | _ => none
  | _ => none

end Host.Ts

namespace Host.Ts

/-- A rendered value: integral numbers, strings, arrays (objects are not rendered). -/
inductive J where
  | num (i : Int) | big (i : Int) | str (s : List Char) | bool (b : Bool) | undef | null | arr (xs : List J)

mutual
def J.beq : J → J → Bool
  | .num a, .num b => decide (a = b)
  | .big a, .big b => decide (a = b)
  | .str a, .str b => nameEq a b
  | .bool a, .bool b => a == b
  | .undef, .undef => true
  | .null, .null => true
  | .arr a, .arr b => J.beqL a b
  | _, _ => false
def J.beqL : List J → List J → Bool
  | [], [] => true
  | a :: as, b :: bs => J.beq a b && J.beqL as bs
  | _, _ => false
end

def render {S : Type} (s : St S) : Nat → Val → Option J
  | 0, _ => none
  | _ + 1, .num (.lit x) => (F64.toInt? x).map J.num
  | _ + 1, .big i => some (.big i)
  | _ + 1, .str cs => some (.str cs)
  | _ + 1, .bool b => some (.bool b)
  | _ + 1, .undef => some .undef
  | _ + 1, .null => some .null
  | f + 1, .obj a => match s.obj? a with
    | some ⟨.array es, _, _, _, _⟩ => (es.mapM (render s f)).map J.arr
    | _ => none
  | _ + 1, _ => none

/-- Run a snippet module; render its binding `out`. -/
def snippetJ (m : Module) (fuel : Nat := 20000) : Option J :=
  (runModules nullFfi () [⟨chars!"main.ts", m⟩] [] chars!"main.ts" fuel).bind fun (s, env) =>
    (bindingOf s env chars!"out").bind (render s 8)

end Host.Ts

namespace Host.Ts

/-! ## Native debugging runs

`debugRun` steps a concrete run like `runC` but keeps the message of a
stuck step (`Free.fail`) and reports how the run ended: the step count, the
last FFI symbols, the thrown error's message. For `#eval` while building
drivers; nothing proved depends on it. -/

def interpD {α : Type} : Free α → CSrv → Except String (α × CSrv)
  | .pure a, c => .ok (a, c)
  | .fail m, _ => .error m
  | .bin op a b k, c => match c.val a, c.val b with
    | some x, some y => interpD (k c.tab.length) ⟨c.tab ++ [F64.bin op x y]⟩
    | _, _ => .error "number table"
  | .un op a k, c => match c.val a with
    | some x => interpD (k c.tab.length) ⟨c.tab ++ [F64.un op x]⟩
    | none => .error "number table"
  | .test op a b k, c => match c.val a, c.val b with
    | some x, some y => interpD (k (F64.test op x y)) c
    | _, _ => .error "number table"
  | .conc a k, c => match c.val a with
    | some x => interpD (k x) c
    | none => .error "number table"

def errMessage {S : Type} (s : St S) : Val → String
  | .obj a => match s.obj? a with
    | some o => match findProp kMessage o.props with
      | some (.data (.str m) _ _) => String.ofList m
      | _ => "(object)"
    | none => "(dangling)"
  | .str m => String.ofList m
  | _ => "(value)"

def ctlTag {S : Type} : St S → String
  | s => match s.ctl with
    | .ev e _ => match e with
      | .id n => s!"ev id {String.ofList n}"
      | .member _ p _ => s!"ev .{String.ofList p}"
      | .call (.member _ p _) _ _ => s!"ev call .{String.ofList p}"
      | .call (.id n) _ _ => s!"ev call {String.ofList n}"
      | _ => "ev"
    | .ex _ _ => "ex" | .ret _ => "ret" | .abr _ => "abr"
    | .call _ _ _ => "call" | .construct _ _ _ => "construct" | .bind _ _ _ _ _ => "bind"
    | .short => "short" | .halt _ => "halt"

def lastSyms {S : Type} (s : St S) (n : Nat) : String :=
  String.intercalate " " ((s.trace.take n).reverse.map fun e => String.ofList e.sym)

partial def debugRun (F : Ffi) (fuel : Nat) (s : St F.S) (c : CSrv) (n : Nat := 0) : String :=
  bif Nat.ble fuel n then s!"fuel out at {n}: {ctlTag s}; last FFI {lastSyms s 6}" else
  match s.ctl with
  | .halt (.normal _) => s!"halted normally after {n} steps, {s.trace.length} FFI calls; last {lastSyms s 6}"
  | .halt (.abrupt (.throw v)) => s!"threw after {n} steps: {errMessage s v}; last FFI {lastSyms s 6}"
  | .halt (.abrupt _) => s!"abrupt halt after {n} steps"
  | _ => match interpD (step F s).run c with
    | .ok (s', c') => debugRun F fuel s' c' (n + 1)
    | .error m => s!"stuck at step {n} ({ctlTag s}): {m}; last FFI {lastSyms s 8}"

end Host.Ts

namespace Host.Ts

/-- Imports of user modules that resolve to no module of `us ++ hosts` (debugging aid). -/
def missingImports (us : List UMod) (hosts : List (List Char)) : List String :=
  let paths := us.map UMod.path ++ hosts
  us.flatMap fun u => u.ast.filterMap fun
    | .import_ _ src | .exportNamed _ (some src) | .exportAll _ src =>
      match resolve paths u.path src with
      | some _ => none
      | none => some (String.ofList u.path ++ " → " ++ String.ofList src)
    | _ => none

end Host.Ts

namespace Host.Ts

/-- The entry module's binding `n` after a concrete run of `fuel` steps, rendered (debugging aid). -/
def debugOut (F : Ffi) (b : Option (St F.S)) (fuel : Nat) (tab : List F64) (n : Name) : String :=
  match b with
  | none => "boot failed"
  | some s0 => match runC F fuel s0 ⟨tab⟩ with
    | some (s, _) => match bindingOf s (entryEnv s0) n with
      | some v => showV s 6 v
      | none => "(no binding)"
    | none => "(stuck)"
where
  showV {S : Type} (s : St S) : Nat → Val → String
    | 0, _ => "…"
    | _ + 1, .num (.lit x) => match F64.toInt? x with | some i => toString i | none => "(float)"
    | _ + 1, .num (.ref i) => s!"#{i}"
    | _ + 1, .big i => toString i ++ "n"
    | _ + 1, .str cs => "\"" ++ String.ofList cs ++ "\""
    | _ + 1, .bool b => toString b
    | _ + 1, .undef => "undefined"
    | _ + 1, .null => "null"
    | f + 1, .obj a => match s.obj? a with
      | some ⟨.array es, _, _, _, _⟩ => "[" ++ ", ".intercalate (es.map (showV s f)) ++ "]"
      | some _ => "(object)"
      | none => "(dangling)"
    | _ + 1, _ => "(value)"

end Host.Ts
