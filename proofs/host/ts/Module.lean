import host.ts.Init
namespace Host.Ts

/-! # Module graphs

ES module linking over the embedded sources: every module's top-level
declarations get cells at instantiation (functions initialized, others in
their TDZ); an import binding *is* the exporter's cell (live bindings);
namespace imports are module namespace objects. Evaluation order is the
DFS post-order of the import graph from the entry. Host modules
(`bun:ffi`, `node:async_hooks`, stand-ins for files outside the embedded
route) export values built in the realm. Module specifiers resolve as
Bun does for this repository: relative paths with `.ts`/`/index.ts`, and
the `@mlx-bun/<pkg>/<path>` workspace aliases to `packages/<pkg>/src`. -/

structure UMod where
  path : List Char
  ast : Module

/-- A host module: path and a realm builder for its exports. -/
structure HMod (S : Type) where
  path : List Char
  exports : B S (List (Name × Val))

/-! ## Paths -/

def splitSlash (cs : List Char) : List (List Char) :=
  cs.foldr (fun c acc => bif chEq c '/' then [] :: acc else match acc with
    | x :: r => (c :: x) :: r
    | [] => [[c]]) [[]]

def normSegs : List (List Char) → List (List Char) → List (List Char)
  | acc, [] => acc.reverse
  | acc, ['.'] :: r => normSegs acc r
  | acc, ['.', '.'] :: r => normSegs acc.tail r
  | acc, [] :: r => normSegs acc r
  | acc, s :: r => normSegs (s :: acc) r

def joinSegs : List (List Char) → List Char
  | [] => []
  | [s] => s
  | s :: r => s ++ '/' :: joinSegs r

def dirSegs (p : List Char) : List (List Char) := (splitSlash p).dropLast

def isPrefixC : List Char → List Char → Bool
  | [], _ => true
  | _, [] => false
  | a :: as, b :: bs => chEq a b && isPrefixC as bs

def candidates (importer spec : List Char) : List (List Char) :=
  let withExt (b : List Char) := [b ++ chars!".ts", b ++ chars!"/index.ts", b]
  bif isPrefixC chars!"./" spec || isPrefixC chars!"../" spec then
    withExt (joinSegs (normSegs [] (dirSegs importer ++ splitSlash spec)))
  else bif isPrefixC chars!"@mlx-bun/" spec then
    match splitSlash (spec.drop 9) with
    | pkg :: rest => withExt (joinSegs ([chars!"packages", pkg, chars!"src"] ++ rest))
    | [] => [spec]
  else [spec]

def findPath (paths : List (List Char)) (p : List Char) : Option Nat :=
  let rec go : List (List Char) → Nat → Option Nat
    | [], _ => none
    | q :: qs, i => bif nameEq p q then some i else go qs (i + 1)
  go paths 0

def resolve (paths : List (List Char)) (importer spec : List Char) : Option Nat :=
  (candidates importer spec).findSome? (findPath paths)

/-! ## Linking -/

def itemNames : Item → List Name
  | .stmt s => stmtNames s
  | .export_ s => stmtNames s
  | .exportDefault _ => [nDefault]
  | _ => []

def itemStmts : Item → List Stmt
  | .stmt s => [s]
  | .export_ s => [s]
  | .exportDefault e => [.decl .const [(.id nDefault, some e)]]
  | _ => []

/-- A module during linking: path, items (empty for host modules), own
cells, namespace object. -/
structure LMod where
  path : List Char
  items : Module
  own : Env
  ns : Nat
  /-- A cell holding the namespace object (namespace imports bind it). -/
  nsCell : Nat

def lmodAt (ms : List LMod) (i : Nat) : Option LMod := nth? ms i

def importsOf (m : LMod) : List (List Char) :=
  m.items.filterMap fun
    | .import_ _ src => some src
    | .exportNamed _ (some src) => some src
    | .exportAll _ src => some src
    | _ => none

section
variable (ms : List LMod)

def paths : List (List Char) := ms.map LMod.path

def target (m : LMod) (src : List Char) : Option Nat := resolve (paths ms) m.path src

mutual
/-- The cell module `i` exports as `name`. Fuel bounds the re-export
chain; items are scanned with `findSome?`. -/
def exportCell : Nat → Nat → Name → Option Nat
  | 0, _, _ => none
  | f + 1, i, name => (lmodAt ms i).bind fun m =>
    match m.items with
    | [] => lookupEnv name m.own
    | items => items.findSome? fun it => exportItem f m it name
def exportItem : Nat → LMod → Item → Name → Option Nat
  | 0, _, _, _ => none
  | f + 1, m, it, name => match it with
    | .export_ s => bif (stmtNames s).any (nameEq name) then lookupEnv name m.own else none
    | .exportDefault _ => bif nameEq name chars!"default" then lookupEnv nDefault m.own else none
    | .exportNamed specs none => (specs.find? fun (_, e) => nameEq e name).bind fun (l, _) => localCell f m l
    | .exportNamed specs (some src) => (specs.find? fun (_, e) => nameEq e name).bind fun (l, _) =>
        (target ms m src).bind fun t => exportCell f t l
    | .exportAll none src => bif nameEq name chars!"default" then none else (target ms m src).bind fun t => exportCell f t name
    | .exportAll (some n) src => bif nameEq name n then (target ms m src).bind fun t => (lmodAt ms t).map LMod.nsCell else none
    | _ => none
/-- A local binding of module `m`: own, or an import. -/
def localCell : Nat → LMod → Name → Option Nat
  | 0, _, _ => none
  | f + 1, m, n => match lookupEnv n m.own with
    | some c => some c
    | none => m.items.findSome? fun it => importIn f m it n
def importIn : Nat → LMod → Item → Name → Option Nat
  | 0, _, _, _ => none
  | f + 1, m, it, n => match it with
    | .import_ specs src => specs.findSome? fun
      | .named imp l => bif nameEq l n then (target ms m src).bind fun t => exportCell f t imp else none
      | .default l => bif nameEq l n then (target ms m src).bind fun t => exportCell f t chars!"default" else none
      | .ns l => bif nameEq l n then (target ms m src).bind fun t => (lmodAt ms t).map LMod.nsCell else none
    | _ => none
end

def importCell (f : Nat) (m : LMod) (n : Name) : Option Nat := m.items.findSome? fun it => importIn ms f m it n

/-- Export names of module `i` (for its namespace object). -/
def exportNames : Nat → Nat → List Name
  | 0, _ => []
  | f + 1, i => match lmodAt ms i with
    | some m => match m.items with
      | [] => m.own.map Prod.fst
      | items => items.flatMap fun
        | .export_ s => stmtNames s
        | .exportDefault _ => [chars!"default"]
        | .exportNamed specs _ => specs.map Prod.snd
        | .exportAll none src => ((target ms m src).map fun t => (exportNames f t).filter fun n => !nameEq n chars!"default").getD []
        | .exportAll (some n) _ => [n]
        | _ => []
    | none => []

/-- Environment of module `i`: imports, then own cells. -/
def modEnv (m : LMod) : Option Env :=
  let imports := m.items.flatMap fun
    | .import_ specs _ => specs.map fun
      | .named _ l => l
      | .default l => l
      | .ns l => l
    | _ => []
  imports.foldr (fun n acc => acc.bind fun e => (importCell ms 64 m n).map fun c => (n, c) :: e) (some m.own)

end

/-- Post-order: `visit` prepends on entry, so evaluation order is the
reverse of completion. We compute completion order separately. -/
def postOrder (ms : List LMod) : Nat → List Nat → Nat → List Nat × List Nat
  | 0, seen, _ => (seen, [])
  | f + 1, seen, i =>
    bif seen.any (Nat.beq i) then (seen, []) else
    match lmodAt ms i with
    | some m =>
      let (seen, out) := (importsOf m).foldl (fun (seen, out) src => match target ms m src with
        | some t => let (seen, o) := postOrder ms f seen t; (seen, out ++ o)
        | none => (seen, out)) (i :: seen, [])
      (seen, out ++ bif m.items.isEmpty then [] else [i])
    | none => (seen, [])

section
variable {S : Type}

def allocOwn (names : List Name) : B S Env := modifyGet fun s => allocCells s names []

def allocNs : B S (Nat × Nat) := do
  let ns ← newObj .null (.ns [])
  let c ← modifyGet fun s => s.alloc (.cell (some (.obj ns)))
  pure (ns, c)

def setNs (ms : List LMod) (i : Nat) : B S Unit := modify fun s =>
  match lmodAt ms i with
  | some m =>
    let ex := (exportNames ms 64 i).filterMap fun n => (exportCell ms 64 i n).map fun c => (n, c)
    match s.obj? m.ns with
    | some o => s.setObj m.ns { o with kind := .ns ex }
    | none => s
  | none => s

def hostCells (vals : List (Name × Val)) : B S Env :=
  modifyGet fun s => vals.foldl (fun (e, s) (n, v) => let (c, s) := s.alloc (.cell (some v)); ((n, c) :: e, s)) ([], s)

end

/-- Link user modules and host modules; the machine starts evaluating the
module bodies of the import closure of `entry` (a path). -/
def link {S : Type} (us : List UMod) (hs : List (HMod S)) (entry : List Char) : B S (Option Unit) := do
  let mut lms : List LMod := []
  for u in us do
    let own ← allocOwn (u.ast.flatMap itemNames)
    let (ns, nc) ← allocNs
    lms := lms ++ [⟨u.path, u.ast, own, ns, nc⟩]
  for h in hs do
    let vals ← h.exports
    let own ← hostCells vals
    let (ns, nc) ← allocNs
    lms := lms ++ [⟨h.path, [], own, ns, nc⟩]
  for i in List.range lms.length do
    setNs lms i
  match findPath (paths lms) entry with
  | none => pure none
  | some e =>
    let order := (postOrder lms 256 [] e).2
    let mut bodies : List (List Stmt × Env) := []
    for i in order do
      match lmodAt lms i with
      | some m => match modEnv lms m with
        | some env =>
          let (tc, s) := (← get).alloc (.cell (some .undef))
          let env := (nThis, tc) :: env
          let stmts := m.items.flatMap itemStmts
          set (initFuncs s env stmts)
          bodies := bodies ++ [(stmts, env)]
        | none => return none
      | none => return none
    modify fun s => (s.push (.k (.modules bodies))).ret .undef
    pure (some ())

/-- Initial state: realm, linked modules, ready to evaluate. -/
def boot {S : Type} (ffi : S) (us : List UMod) (hs : List (HMod S)) (entry : List Char) : Option (St S) :=
  match (link us hs entry).run (realm ffi) with
  | (some (), s) => some s
  | (none, _) => none

/-! ## Host modules -/

section
variable {S : Type}

def objOf (props : List (Name × Val)) : B S Val := do
  let o ← newObj (.obj aObjectProto)
  for (n, v) in props do setP o (.str n) (.data v true true)
  pure (.obj o)

def ffiTypes : List Name :=
  [chars!"ptr", chars!"i32", chars!"u32", chars!"u64", chars!"i64", chars!"f32", chars!"f64", chars!"cstring",
   chars!"bool", chars!"void", chars!"i8", chars!"u8", chars!"i16", chars!"u16", chars!"usize", chars!"pointer"]

def bunFfi : HMod S := ⟨chars!"bun:ffi", do
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
  let cstr ← mkFn (.ffi .cstring)
  pure [(chars!"dlopen", dlopen), (chars!"ptr", ptr), (chars!"toArrayBuffer", toAB), (chars!"read", read),
    (chars!"FFIType", types), (chars!"JSCallback", .obj jscb), (chars!"CString", cstr)]⟩

def asyncHooks : HMod S := ⟨chars!"node:async_hooks", do
  let als ← ctorFn (.ctl .alsCtor) aAlsProto
  pure [(chars!"AsyncLocalStorage", .obj als)]⟩

/-- A stand-in for a module outside the embedded route: named values. -/
def stubMod (path : List Char) (vals : B S (List (Name × Val))) : HMod S := ⟨path, vals⟩

end
end Host.Ts
