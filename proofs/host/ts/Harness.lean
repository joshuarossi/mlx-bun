import host.ts.Module
import host.ts.Run
namespace Host.Ts

/-! # Harness for kernel-checked runs

`moduleOut` boots modules, runs the machine with a concrete number
server, and reads a top-level binding of the entry module. -/

def nullFfi : Ffi := ⟨Unit, fun _ _ _ => .pure none, fun _ _ _ _ => none, fun _ => 0⟩

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
