import host.ts.Module
namespace Host.Ts

/-! # Linking a module graph in steps

`link` (`Module`) links and instantiates a whole graph in one function; a
kernel check of it grows with the graph. Here the same linking is a sequence
of steps over a `LinkSt`, one module per step, so a chain of kernel checks
covers a graph of hundreds of modules (`link_chain`, `LinkChain`):

1. per user module: import elision (below), its own cells, `import.meta`
   and its namespace object; per host module: its exports;
2. per module: the namespace object's export table;
3. the evaluation order (post-order of the import graph from the entry);
4. per module in that order: its environment (imports resolved to the
   exporters' cells, live bindings) and hoisted function declarations;
5. the machine starts the module bodies (`FnF.modules`).

Steps past the last leave the state unchanged, so `linkRun` with any larger
step count is the same link.

**Import elision.** Bun's TypeScript transpiler drops an import specifier
whose binding the module never references as a value (type-only uses are
erased before), and an import with specifiers that are all dropped is
dropped entirely: the imported module is then not loaded through it. The
parser keeps every specifier (`Parser.importP`); `elide` drops those whose
local name occurs in no expression of the module (`refsM`). An occurrence
under a shadowing local binding counts as a reference, which can only keep
a specifier Bun drops; a kept specifier with no value export makes linking
fail, so a completed link never kept one.

**`import.meta`** is the module binding `%meta` (the parser's reading of
`import.meta`): an object with `url`, `path`, `filename`, `dir`, `dirname`
and `main` for the module's absolute path `root/path`, created for modules
that reference it. -/

def nMeta : Name := chars!"%meta"

/-! ## Value references -/

mutual
def refsE : Nat → Expr → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, e, acc => match e with
    | .lit _ => acc
    | .this => acc
    | .super => acc
    | .id n => pack n :: acc
    | .template t _ ss => ss.foldl (fun a x => refsE f x a) (match t with | some t => refsE f t acc | none => acc)
    | .array es => es.foldl (fun a x => refsEl f x a) acc
    | .object ps => ps.foldl (fun a p => refsP f p a) acc
    | .func fn => refsF f fn acc
    | .arrow fn => refsF f fn acc
    | .cls c => refsC f c acc
    | .member o _ _ => refsE f o acc
    | .priv o _ _ => refsE f o acc
    | .index o k _ => refsE f k (refsE f o acc)
    | .call c as _ => as.foldl (fun a x => refsEl f x a) (refsE f c acc)
    | .new c as => as.foldl (fun a x => refsEl f x a) (refsE f c acc)
    | .chain x => refsE f x acc
    | .unary _ x => refsE f x acc
    | .update _ _ x => refsE f x acc
    | .await x => refsE f x acc
    | .bin _ a b => refsE f b (refsE f a acc)
    | .log _ a b => refsE f b (refsE f a acc)
    | .seq a b => refsE f b (refsE f a acc)
    | .cond c a b => refsE f b (refsE f a (refsE f c acc))
    | .assign _ t v => refsE f v (refsPat f t acc)
    | .yield a _ => match a with | some a => refsE f a acc | none => acc
def refsEl : Nat → Elem → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, x, acc => match x with
    | .hole => acc
    | .expr e => refsE f e acc
    | .spread e => refsE f e acc
def refsK : Nat → Key → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, k, acc => match k with
    | .computed e => refsE f e acc
    | _ => acc
def refsP : Nat → Property → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, p, acc => match p with
    | .init k v => refsE f v (refsK f k acc)
    | .short n => pack n :: acc
    | .method _ k fn => refsF f fn (refsK f k acc)
    | .spread e => refsE f e acc
/-- Patterns: defaults, computed keys and member targets (bound names are not references). -/
def refsPat : Nat → Pat → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, p, acc => match p with
    | .id _ => acc
    | .expr e => refsE f e acc
    | .array ps r => (match r with | some q => refsPat f q | none => id) (ps.foldl (fun a q => match q with
        | some q => refsPat f q a
        | none => a) acc)
    | .object ps r => (match r with | some q => refsPat f q | none => id) (ps.foldl (fun a (k, q) => refsPat f q (refsK f k a)) acc)
    | .dflt q d => refsE f d (refsPat f q acc)
def refsF : Nat → Func → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, .mk _ ps r b _ _ _, acc =>
    let acc := ps.foldl (fun a q => refsPat f q a) acc
    let acc := match r with | some q => refsPat f q acc | none => acc
    match b with
    | .block ss => ss.foldl (fun a s => refsS f s a) acc
    | .expr e => refsE f e acc
def refsC : Nat → Class → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, .mk _ sup ms, acc =>
    let acc := match sup with | some e => refsE f e acc | none => acc
    ms.foldl (fun a m => refsMem f m a) acc
def refsMem : Nat → Member → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, m, acc => match m with
    | .ctor fn => refsF f fn acc
    | .method _ _ k fn => refsF f fn (refsK f k acc)
    | .field _ k i => (match i with | some e => refsE f e | none => id) (refsK f k acc)
    | .block ss => ss.foldl (fun a s => refsS f s a) acc
def refsDecls : Nat → List (Pat × Option Expr) → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, ds, acc => ds.foldl (fun a (p, i) => (match i with | some e => refsE f e | none => id) (refsPat f p a)) acc
def refsS : Nat → Stmt → List Nat → List Nat
  | 0, _, acc => 0 :: acc
  | f + 1, s, acc => match s with
    | .expr e => refsE f e acc
    | .decl _ ds => refsDecls f ds acc
    | .func fn => refsF f fn acc
    | .cls c => refsC f c acc
    | .enum _ _ ms => ms.foldl (fun a (k, i) => (match i with | some e => refsE f e | none => id) (refsK f k a)) acc
    | .ret e => match e with | some e => refsE f e acc | none => acc
    | .if_ c t e => (match e with | some e => refsS f e | none => id) (refsS f t (refsE f c acc))
    | .block ss => ss.foldl (fun a s => refsS f s a) acc
    | .for_ i t u b =>
      let acc := match i with
        | some (.decl _ ds) => refsDecls f ds acc
        | some (.expr e) => refsE f e acc
        | none => acc
      let acc := match t with | some e => refsE f e acc | none => acc
      let acc := match u with | some e => refsE f e acc | none => acc
      refsS f b acc
    | .forOf _ _ p e b => refsS f b (refsE f e (refsPat f p acc))
    | .forIn _ p e b => refsS f b (refsE f e (refsPat f p acc))
    | .while_ c b => refsS f b (refsE f c acc)
    | .doWhile b c => refsE f c (refsS f b acc)
    | .switch d cs => cs.foldl (fun a (t, ss) => ss.foldl (fun a s => refsS f s a)
        (match t with | some e => refsE f e a | none => a)) (refsE f d acc)
    | .try_ b h fin =>
      let acc := b.foldl (fun a s => refsS f s a) acc
      let acc := match h with
        | some (p, ss) => ss.foldl (fun a s => refsS f s a) (match p with | some p => refsPat f p acc | none => acc)
        | none => acc
      match fin with | some ss => ss.foldl (fun a s => refsS f s a) acc | none => acc
    | .throw e => refsE f e acc
    | .break _ => acc
    | .continue _ => acc
    | .labeled _ s => refsS f s acc
    | .empty => acc
end

/-- Nesting fuel of the reference scan; exhausting it records `0` (no name's code). -/
def refsFuel : Nat := 4096

/-- Codes of the names a module's code references (imports excluded). -/
def refsM (m : Module) : List Nat :=
  m.foldl (fun acc it => match it with
    | .stmt s => refsS refsFuel s acc
    | .export_ s => refsS refsFuel s acc
    | .exportDefault e => refsE refsFuel e acc
    | .exportNamed specs none => specs.foldl (fun a (l, _) => pack l :: a) acc
    | _ => acc) []

def specLocal : Spec → Name
  | .default l => l
  | .ns l => l
  | .named _ l => l

/-- The module with unreferenced import specifiers dropped (`none` if the scan ran out of fuel). -/
def elide (m : Module) : Option Module :=
  let refs := refsM m
  bif refs.any (Nat.beq 0) then none else
  some (m.filterMap fun it => match it with
    | .import_ [] src => some (.import_ [] src)
    | .import_ specs src => match specs.filter (fun sp => refs.any (Nat.beq (pack (specLocal sp)))) with
      | [] => none
      | sp => some (.import_ sp src)
    | it => some it)

def usesMeta (m : Module) : Bool := (refsM m).any (Nat.beq (pack nMeta))

/-! ## Link state and steps -/

/-- What is linked: user modules, host modules, the entry's path, and the
directory module paths are relative to (for `import.meta`). -/
structure LinkCx (S : Type) where
  us : List UMod
  hs : List (HMod S)
  entry : List Char
  root : List Char

structure LinkSt (S : Type) where
  st : St S
  mods : List LMod
  order : List Nat
  bodies : List (List Stmt × Env)
  done : Bool

def LinkSt.init {S : Type} (ffi : S) : LinkSt S := ⟨realm ffi, [], [], [], false⟩

def dirOf (p : List Char) : List Char := joinSegs ((splitSlash p).dropLast)

section
variable {S : Type}

/-- The `import.meta` object of absolute path `abs`. -/
def metaObj (abs : List Char) : B S Val :=
  objOf [(chars!"url", .str (chars!"file://" ++ abs)), (chars!"path", .str abs), (chars!"filename", .str abs),
    (chars!"dir", .str (dirOf abs)), (chars!"dirname", .str (dirOf abs)), (chars!"main", .bool false)]

def addUser (root : List Char) (u : UMod) : B S (Option LMod) := do
  match elide u.ast with
  | none => pure none
  | some items =>
    let own ← allocOwn (items.flatMap itemNames)
    let own ← bif usesMeta items then do
        let m ← metaObj (root ++ '/' :: u.path)
        let c ← modifyGet fun s => s.alloc (.cell (some m))
        pure ((nMeta, c) :: own)
      else pure own
    let (ns, nc) ← allocNs
    pure (some ⟨u.path, items, own, ns, nc⟩)

def addHost (h : HMod S) : B S LMod := do
  let vals ← h.exports
  let own ← hostCells vals
  let (ns, nc) ← allocNs
  pure ⟨h.path, [], own, ns, nc⟩

/-- The body of module `i` with its environment, functions hoisted. -/
def addBody (ms : List LMod) (i : Nat) : B S (Option (List Stmt × Env)) := do
  match lmodAt ms i with
  | some m => match modEnv ms m with
    | some env =>
      let (tc, s) := (← get).alloc (.cell (some .undef))
      let env := (nThis, tc) :: env
      let stmts := m.items.flatMap itemStmts
      set (initFuncs s env stmts)
      pure (some (stmts, env))
    | none => pure none
  | none => pure none

end

section
variable {S : Type} (cx : LinkCx S)

def nUser : Nat := len cx.us
def nMods : Nat := len cx.us + len cx.hs

/-- Link step `k`. -/
def linkStep (k : Nat) (ls : LinkSt S) : Option (LinkSt S) :=
  bif ls.done then some ls else
  let u := len cx.us
  let n := u + len cx.hs
  bif Nat.blt k u then match nth? cx.us k with
    | some um => match (addUser cx.root um).run ls.st with
      | (some m, st) => some { ls with st, mods := ls.mods ++ [m] }
      | (none, _) => none
    | none => none
  else bif Nat.blt k n then match nth? cx.hs (k - u) with
    | some h => let (m, st) := (addHost h).run ls.st; some { ls with st, mods := ls.mods ++ [m] }
    | none => none
  else bif Nat.blt k (2 * n) then some { ls with st := ((setNs ls.mods (k - n)).run ls.st).2 }
  else bif Nat.beq k (2 * n) then match findPath (paths ls.mods) cx.entry with
    | some e => some { ls with order := (postOrder ls.mods 256 [] e).2 }
    | none => none
  else let j := k - (2 * n + 1)
  bif Nat.blt j (len ls.order) then match (addBody ls.mods (nthD 0 ls.order j)).run ls.st with
    | (some b, st) => some { ls with st, bodies := ls.bodies ++ [b] }
    | (none, _) => none
  else some { ls with st := (ls.st.push (.k (.modules ls.bodies))).ret .undef, done := true }

def linkRun : Nat → Nat → LinkSt S → Option (LinkSt S)
  | _, 0, ls => some ls
  | k, n + 1, ls => (linkStep cx k ls).bind (linkRun (k + 1) n)

theorem linkRun_add : ∀ (m n k : Nat) (ls : LinkSt S),
    linkRun cx k (m + n) ls = (linkRun cx k m ls).bind (linkRun cx (k + m) n)
  | 0, n, k, ls => by simp [linkRun]
  | m + 1, n, k, ls => by
    rw [show m + 1 + n = (m + n) + 1 by omega]
    simp only [linkRun]
    cases linkStep cx k ls with
    | none => rfl
    | some ls' =>
      simp only [Option.bind_some]
      rw [linkRun_add m n (k + 1) ls', show k + 1 + m = k + (m + 1) by omega]

theorem linkRun_done (k : Nat) (ls : LinkSt S) (h : ls.done = true) : ∀ n, linkRun cx k n ls = some ls := by
  intro n
  induction n generalizing k with
  | zero => rfl
  | succ n ih => simp [linkRun, linkStep, h, ih]

/-- The booted machine: realm, then every link step. -/
def bootL (ffi : S) (fuel : Nat) : Option (St S) := (linkRun cx 0 fuel (LinkSt.init ffi)).map LinkSt.st

end

end Host.Ts
