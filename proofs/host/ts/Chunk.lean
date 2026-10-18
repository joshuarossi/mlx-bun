import host.ts.Mock
import host.ts.Ast
namespace Host.Ts
open Lean Elab Command Meta

/-! # Chunked runs

A long run is a chain of separately kernel-checked theorems
`runS F k sᵢ Sᵢ = some (sᵢ₊₁, Sᵢ₊₁)` between explicit state constants;
`runS_chain` composes them (`runWith_add`). Each check reduces `k` steps
from a constant, so its kernel caches hold one chunk, not the whole run.

`host_chain` computes the intermediate states natively (compiled machine)
and adds them as definitions. A state is serialized with every AST node it
holds as the node's constant (`AstTab`, the names `source_ast` gave them),
so a state's size is its heap and stack, not the source text it runs. The
elaborator only chooses the states; a wrong choice fails a chunk check. -/

/-! ## Composition -/

section
variable (F : Ffi) {Srv : Type} (interp : Free (St F.S) → Srv → Option (St F.S × Srv))

theorem runWith_halted (s : St F.S) (c : Srv) (h : isHalt s.ctl = true) :
    ∀ n, runWith F interp n s c = some (s, c)
  | 0 => rfl
  | n + 1 => by rw [runWith_succ, h]; rfl

theorem runWith_add : ∀ (m n : Nat) (s : St F.S) (c : Srv),
    runWith F interp (m + n) s c = (runWith F interp m s c).bind fun p => runWith F interp n p.1 p.2
  | 0, n, s, c => by rw [Nat.zero_add]; rfl
  | m + 1, n, s, c => by
    rw [Nat.add_right_comm, runWith_succ, runWith_succ]
    cases hh : isHalt s.ctl
    · simp only [Bool.cond_false]
      cases interp (step F s).run c with
      | none => rfl
      | some p =>
        obtain ⟨s', c'⟩ := p
        simp only [St.rebuild_eq]
        exact runWith_add m n s' c'
    · simp only [Bool.cond_true, Option.bind_some]
      exact (runWith_halted F interp s c hh n).symm

end

/-- Two chunks compose. -/
theorem runS_trans (F : Ffi) {m n : Nat} {s₀ s₁ s₂ : St F.S} {S₀ S₁ S₂ : SSrv}
    (h₁ : runS F m s₀ S₀ = some (s₁, S₁)) (h₂ : runS F n s₁ S₁ = some (s₂, S₂)) :
    runS F (m + n) s₀ S₀ = some (s₂, S₂) := by
  unfold runS at *; rw [runWith_add, h₁]; exact h₂

/-- A halted state absorbs further fuel. -/
theorem runS_halted (F : Ffi) {s : St F.S} (S : SSrv) (h : isHalt s.ctl = true) (n : Nat) :
    runS F n s S = some (s, S) := runWith_halted F interpS s S h n

/-- A booted chain that halts: the run from the boot with any larger fuel. -/
theorem chain_result (F : Ffi) {boot : Option (St F.S)} {srv S₀ S : SSrv} {s₀ s : St F.S} {K : Nat}
    (hb : boot = some s₀) (hs : srv = S₀) (hr : runS F K s₀ S₀ = some (s, S)) (hh : isHalt s.ctl = true) :
    ∀ n, K ≤ n → (boot.bind fun t => runS F n t srv) = some (s, S) := by
  intro n hn
  subst hb hs
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hn
  exact runS_trans F hr (runS_halted F S hh d)

/-! ## Serialization -/

/-- The AST node names of the loaded modules (set by `host_chain`). -/
initialize astTabRef : IO.Ref AstTab ← IO.mkRef {}

unsafe def readAstTabImpl {α : Type} (_ : α) : AstTab := unsafeBaseIO astTabRef.get

/-- The current table; the argument keeps the call from being hoisted. -/
@[implemented_by readAstTabImpl] opaque readAstTab {α : Type} (x : α) : AstTab

/-- Natural numbers as literals (no `OfNat` instance to unfold). -/
instance (priority := high) instToExprNatRaw : ToExpr Nat := ⟨mkRawNatLit, mkConst ``Nat⟩

instance (priority := high) instToExprIntRaw : ToExpr Int where
  toExpr
    | .ofNat n => mkApp (mkConst ``Int.ofNat) (mkRawNatLit n)
    | .negSucc n => mkApp (mkConst ``Int.negSucc) (mkRawNatLit n)
  toTypeExpr := mkConst ``Int

section
variable {α : Type} (f : α → HoistM Lean.Expr)
def serNamed (x : α) : Lean.Expr := (f x).run' { tab := readAstTab x }
end

instance (priority := high) : ToExpr Expr := ⟨serNamed serExpr, mkConst ``Expr⟩
instance (priority := high) : ToExpr Stmt := ⟨serNamed serStmt, mkConst ``Stmt⟩
instance (priority := high) : ToExpr Func := ⟨serNamed serFunc, mkConst ``Func⟩
instance (priority := high) : ToExpr Class := ⟨serNamed serClass, mkConst ``Class⟩
instance (priority := high) : ToExpr Pat := ⟨serNamed serPat, mkConst ``Pat⟩
instance (priority := high) : ToExpr Elem := ⟨serNamed serElem, mkConst ``Elem⟩
instance (priority := high) : ToExpr Property := ⟨serNamed serProp, mkConst ``Property⟩
instance (priority := high) : ToExpr Member := ⟨serNamed serMember, mkConst ``Member⟩
instance (priority := high) : ToExpr Key := ⟨serNamed serKey, mkConst ``Key⟩

deriving instance Lean.ToExpr for Host.Ts.F64
deriving instance Lean.ToExpr for Host.Ts.Trie
deriving instance Lean.ToExpr for Host.Ts.NBin
deriving instance Lean.ToExpr for Host.Ts.NUn
deriving instance Lean.ToExpr for Host.Ts.NTest
deriving instance Lean.ToExpr for Host.Ts.NumV
deriving instance Lean.ToExpr for Host.Ts.PKey
deriving instance Lean.ToExpr for Host.Ts.Mem
deriving instance Lean.ToExpr for Host.Ts.Val
deriving instance Lean.ToExpr for Host.Ts.PropV
deriving instance Lean.ToExpr for Host.Ts.EltK
deriving instance Lean.ToExpr for Host.Ts.Cell
deriving instance Lean.ToExpr for Host.Ts.Byte
deriving instance Lean.ToExpr for Host.Ts.Abrupt
deriving instance Lean.ToExpr for Host.Ts.Comp
deriving instance Lean.ToExpr for Host.Ts.InstMember
deriving instance Lean.ToExpr for Host.Ts.Boundary
deriving instance Lean.ToExpr for Host.Ts.IterSrc
deriving instance Lean.ToExpr for Host.Ts.BindMode
deriving instance Lean.ToExpr for Host.Ts.ObjN
deriving instance Lean.ToExpr for Host.Ts.ArrN
deriving instance Lean.ToExpr for Host.Ts.IterN
deriving instance Lean.ToExpr for Host.Ts.MathN
deriving instance Lean.ToExpr for Host.Ts.NumN
deriving instance Lean.ToExpr for Host.Ts.StrN
deriving instance Lean.ToExpr for Host.Ts.Str2N
deriving instance Lean.ToExpr for Host.Ts.ErrN
deriving instance Lean.ToExpr for Host.Ts.MapN
deriving instance Lean.ToExpr for Host.Ts.SetN
deriving instance Lean.ToExpr for Host.Ts.BufN
deriving instance Lean.ToExpr for Host.Ts.FnN
deriving instance Lean.ToExpr for Host.Ts.CtlN
deriving instance Lean.ToExpr for Host.Ts.FfiN
deriving instance Lean.ToExpr for Host.Ts.Native
deriving instance Lean.ToExpr for Host.Ts.CallF
deriving instance Lean.ToExpr for Host.Ts.ExprF
deriving instance Lean.ToExpr for Host.Ts.LitF
deriving instance Lean.ToExpr for Host.Ts.Target
deriving instance Lean.ToExpr for Host.Ts.AsgF
deriving instance Lean.ToExpr for Host.Ts.StmtF
deriving instance Lean.ToExpr for Host.Ts.LoopF
deriving instance Lean.ToExpr for Host.Ts.BindF
deriving instance Lean.ToExpr for Host.Ts.FnF
deriving instance Lean.ToExpr for Host.Ts.Frame
deriving instance Lean.ToExpr for Host.Ts.Ctl
deriving instance Lean.ToExpr for Host.Ts.Susp
deriving instance Lean.ToExpr for Host.Ts.GenState
deriving instance Lean.ToExpr for Host.Ts.Reaction
deriving instance Lean.ToExpr for Host.Ts.PState
deriving instance Lean.ToExpr for Host.Ts.Code
deriving instance Lean.ToExpr for Host.Ts.Kind
deriving instance Lean.ToExpr for Host.Ts.Obj
deriving instance Lean.ToExpr for Host.Ts.HObj
deriving instance Lean.ToExpr for Host.Ts.Arg
deriving instance Lean.ToExpr for Host.Ts.Ret
deriving instance Lean.ToExpr for Host.Ts.Event
deriving instance Lean.ToExpr for Host.Ts.Job
deriving instance Lean.ToExpr for Host.Ts.Aux
deriving instance Lean.ToExpr for Host.Ts.St
deriving instance Lean.ToExpr for Host.Ts.SymE
deriving instance Lean.ToExpr for Host.Ts.Ans
deriving instance Lean.ToExpr for Host.Ts.SSrv
deriving instance Lean.ToExpr for Host.Ts.Mock.MArr
deriving instance Lean.ToExpr for Host.Ts.Mock.St

/-! ## Oracle discovery (native)

`interpRec` is `interpS` answering every test by evaluating its operands
at a valuation `ρ` and recording the answer. The recorded list is the
oracle of the symbolic run: its answers are the run's hypotheses on the
symbolic numbers, which `run_sim` turns into the side condition of a
concrete run. Choosing the oracle this way is not trusted: a list that
does not match the run's queries makes the chunk checks fail. -/

def interpRec {α : Type} (ρ : Nat → F64) : Free α → SSrv → List Ans → Option (α × SSrv × List Ans)
  | .pure a, c, o => some (a, c, o)
  | .fail _, _, _ => none
  | .bin op a b k, c, o => match c.val a, c.val b with
    | some x, some y => interpRec ρ (k c.tab.length) { c with tab := c.tab ++ [.bin op x y] } o
    | _, _ => none
  | .un op a k, c, o => match c.val a with
    | some x => interpRec ρ (k c.tab.length) { c with tab := c.tab ++ [.un op x] } o
    | none => none
  | .test op a b k, c, o => match c.val a, c.val b with
    | some x, some y => let r := F64.test op (x.eval ρ) (y.eval ρ); interpRec ρ (k r) c (⟨op, x, y, r⟩ :: o)
    | _, _ => none
  | .conc a k, c, o => match c.val a with
    | some (.lit x) => interpRec ρ (k x) c o
    | _ => none

/-- Run to halt (at most `fuel` steps) recording the oracle; steps taken. -/
def discover (F : Ffi) (ρ : Nat → F64) : Nat → St F.S → SSrv → List Ans → Nat → Option (List Ans × Nat × String)
  | 0, _, _, o, n => some (o.reverse, n, "fuel")
  | f + 1, s, c, o, n => bif isHalt s.ctl then some (o.reverse, n, "halt") else
    match interpRec ρ (step F s).run c o with
    | some (s', c', o') => discover F ρ f s' c' o' (n + 1)
    | none => some (o.reverse, n, "stuck")

/-- States of a chunked symbolic run: after boot, then after each chunk of
`ks` steps; each with its number server. `none` if a chunk gets stuck. -/
def chainStates (F : Ffi) (serS : F.S → Lean.Expr) (tyS : Lean.Expr) (s₀ : St F.S) (S₀ : SSrv) (ks : List Nat) :
    Option (List (Lean.Expr × Lean.Expr × Bool)) :=
  letI : ToExpr F.S := ⟨serS, tyS⟩
  let rec go (s : St F.S) (S : SSrv) : List Nat → Option (List (Lean.Expr × Lean.Expr × Bool))
    | [] => some []
    | k :: ks => (runS F k s S).bind fun (s', S') =>
      (go s' S' ks).map ((toExpr s', toExpr S', isHalt s'.ctl) :: ·)
  (go s₀ S₀ ks).map ((toExpr s₀, toExpr S₀, isHalt s₀.ctl) :: ·)

/-- The AST name table of every `source_ast` module in the environment. -/
def loadAstTab : MetaM AstTab := do
  let env ← getEnv
  let nss := env.constants.fold (init := #[]) fun acc n _ =>
    if n.isStr && n.getString! == "astNative" then acc.push n.getPrefix else acc
  let mut tab : AstTab := {}
  for ns in nss.qsort Name.lt do
    let m ← unsafe evalConst Module (ns ++ `astNative)
    let (_, st) := hoistModule ns m
    unless st.decls.all fun (n, _, _) => env.contains n do
      throwError "AST constants of {ns} do not match a re-hoisting"
    tab := { stmts := st.tab.stmts.fold (fun m k v => if m.contains k then m else m.insert k v) tab.stmts,
             funcs := st.tab.funcs.fold (fun m k v => if m.contains k then m else m.insert k v) tab.funcs,
             classes := st.tab.classes.fold (fun m k v => if m.contains k then m else m.insert k v) tab.classes }
  pure tab

/-- Tree size of an expression (shared subterms counted once per occurrence), capped. -/
partial def exprSize (e : Lean.Expr) : Nat :=
  let rec go (e : Lean.Expr) (n : Nat) : Nat :=
    if n > 100000000 then n else
    match e with
    | .app f a => go a (go f (n + 1))
    | .lam _ t b _ | .forallE _ t b _ => go b (go t (n + 1))
    | .letE _ t v b _ => go b (go v (go t (n + 1)))
    | .mdata _ b | .proj _ _ b => go b (n + 1)
    | _ => n + 1
  go e 0

unsafe def dagSizeImpl (e : Lean.Expr) : Nat :=
  let rec go (e : Lean.Expr) (seen : Std.HashSet USize) : Std.HashSet USize :=
    if seen.contains (ptrAddrUnsafe e) then seen else
    let seen := seen.insert (ptrAddrUnsafe e)
    match e with
    | .app f a => go a (go f seen)
    | .lam _ t b _ | .forallE _ t b _ => go b (go t seen)
    | .letE _ t v b _ => go b (go v (go t seen))
    | .mdata _ b | .proj _ _ b => go b seen
    | _ => seen
  (go e {}).size

/-- Distinct nodes of an expression (pointer identity). -/
@[implemented_by dagSizeImpl] opaque dagSize (e : Lean.Expr) : Nat

/-- Add the chain's constants: states, servers, chunk sizes, the FFI, boot and server terms. -/
def addChain (pre : Lean.Name) (fE stTy bE srvE : Lean.Expr) (ksV : List Nat) (states : List (Lean.Expr × Lean.Expr × Bool))
    (t : Nat) : MetaM Unit := do
  let states := ShareCommon.shareCommon' states
  let mut i := 0
  for (sE, srvV, _) in states do
    let nS := pre ++ Name.mkSimple ("s" ++ toString i)
    let nV := pre ++ Name.mkSimple ("S" ++ toString i)
    addDecl (Declaration.defnDecl { name := nS, levelParams := [], type := stTy, value := sE, hints := .regular 0, safety := .safe })
    addDecl (Declaration.defnDecl { name := nV, levelParams := [], type := mkConst ``SSrv, value := srvV, hints := .regular 0, safety := .safe })
    i := i + 1
  let ksTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  addDecl (Declaration.defnDecl { name := pre ++ `ks, levelParams := [], type := ksTy, value := toExpr ksV, hints := ReducibilityHints.abbrev, safety := .safe })
  compileDecl (Declaration.defnDecl { name := pre ++ `ks, levelParams := [], type := ksTy, value := toExpr ksV, hints := ReducibilityHints.abbrev, safety := .safe })
  addDecl (Declaration.defnDecl { name := pre ++ `F, levelParams := [], type := mkConst ``Ffi, value := fE, hints := ReducibilityHints.abbrev, safety := .safe })
  let optSt := mkApp (mkConst ``Option [.zero]) stTy
  addDecl (Declaration.defnDecl { name := pre ++ `boot, levelParams := [], type := optSt, value := bE, hints := ReducibilityHints.abbrev, safety := .safe })
  addDecl (Declaration.defnDecl { name := pre ++ `srv, levelParams := [], type := mkConst ``SSrv, value := srvE, hints := ReducibilityHints.abbrev, safety := .safe })
  let sizes := states.map fun (sE, _, h) => toString (exprSize sE) ++ "/" ++ toString (dagSize sE) ++ (if h then "h" else "")
  logInfo m!"host_chain {pre}: {states.length} states, native {t} ms; tree/dag size {sizes}"

/-- The chain's inputs elaborated: FFI, state type, boot. -/
def chainInputs (f b : Syntax) : TermElabM (Lean.Expr × Lean.Expr × Lean.Expr × Lean.Expr × Lean.Expr) := do
  let fE ← instantiateMVars (← Term.elabTermAndSynthesize f (some (mkConst ``Ffi)))
  let sTy := mkApp (mkConst ``Ffi.S) fE
  let stTy := mkApp (mkConst ``St) sTy
  let bE ← instantiateMVars (← Term.elabTermAndSynthesize b (some (mkApp (mkConst ``Option [.zero]) stTy)))
  astTabRef.set (← loadAstTab)
  -- serializer of the FFI state, by instance on the reduced type
  let sRed ← whnf sTy
  let serS ← mkAppOptM ``Lean.ToExpr.toExpr #[sRed, none]
  let tyS ← mkAppOptM ``Lean.ToExpr.toTypeExpr #[sRed, none]
  pure (fE, stTy, bE, serS, tyS)

/-- `host_chain P : F, boot, S₀, [k₁, …]` adds `P.s0 … P.sN` (states) and
`P.S0 … P.SN` (number servers): `P.s0` the booted state, `P.s(i+1)` after
`kᵢ₊₁` more steps of `runS F`, and `P.ks` (the chunk sizes). -/
elab "host_chain " p:ident " : " f:term ", " b:term ", " srv:term ", " ks:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let (fE, stTy, bE, serS, tyS) ← chainInputs f b
  let srvE ← instantiateMVars (← Term.elabTermAndSynthesize srv (some (mkConst ``SSrv)))
  let ksV ← unsafe evalExpr (List Nat) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat))
    (← instantiateMVars (← Term.elabTermAndSynthesize ks (some (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)))))
  let call ← mkAppM ``Option.bind #[bE, ← withLocalDeclD `s stTy fun s => do
    mkLambdaFVars #[s] (mkAppN (mkConst ``chainStates) #[fE, serS, tyS, s, srvE, toExpr ksV])]
  let t0 ← IO.monoMsNow
  let some states ← unsafe evalExpr (Option (List (Lean.Expr × Lean.Expr × Bool))) (← inferType call) call
    | throwError "host_chain: boot or a chunk failed natively"
  addChain pre fE stTy bE srvE ksV states ((← IO.monoMsNow) - t0)

/-- Oracle discovery then the chain: the run's tests answered at `ρ` (`discover`). -/
def chainStatesSym (F : Ffi) (serS : F.S → Lean.Expr) (tyS : Lean.Expr) (ρ : Nat → F64) (fuel : Nat) (s₀ : St F.S)
    (tab : List SymE) (ks : List Nat) : Option (List Ans × List (Lean.Expr × Lean.Expr × Bool)) :=
  (discover F ρ fuel s₀ ⟨tab, []⟩ [] 0).bind fun (o, _, _) => (chainStates F serS tyS s₀ ⟨tab, o⟩ ks).map (o, ·)

/-- `host_chain_sym P : F, boot, tab, ρ, fuel, [k₁, …]`: `host_chain` with server
`⟨tab, P.O⟩`, `P.O` the oracle of the run answered at `ρ` (at most `fuel` steps). -/
elab "host_chain_sym " p:ident " : " f:term ", " b:term ", " tab:term ", " ρ:term ", " fuel:term ", " ks:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let (fE, stTy, bE, serS, tyS) ← chainInputs f b
  let tE ← instantiateMVars (← Term.elabTermAndSynthesize tab (some (mkApp (mkConst ``List [.zero]) (mkConst ``SymE))))
  let rE ← instantiateMVars (← Term.elabTermAndSynthesize ρ (some (← mkArrow (mkConst ``Nat) (mkConst ``F64))))
  let nE ← instantiateMVars (← Term.elabTermAndSynthesize fuel (some (mkConst ``Nat)))
  let ksV ← unsafe evalExpr (List Nat) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat))
    (← instantiateMVars (← Term.elabTermAndSynthesize ks (some (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)))))
  let call ← mkAppM ``Option.bind #[bE, ← withLocalDeclD `s stTy fun s => do
    mkLambdaFVars #[s] (mkAppN (mkConst ``chainStatesSym) #[fE, serS, tyS, rE, nE, s, tE, toExpr ksV])]
  let t0 ← IO.monoMsNow
  let some (o, states) ← unsafe evalExpr (Option (List Ans × List (Lean.Expr × Lean.Expr × Bool))) (← inferType call) call
    | throwError "host_chain_sym: boot or a chunk failed natively"
  let ansTy := mkApp (mkConst ``List [.zero]) (mkConst ``Ans)
  addDecl (Declaration.defnDecl { name := pre ++ `O, levelParams := [], type := ansTy, value := toExpr o, hints := ReducibilityHints.abbrev, safety := .safe })
  logInfo m!"host_chain_sym {pre}: oracle of {o.length} answers"
  addChain pre fE stTy bE (mkApp2 (mkConst ``SSrv.mk) tE (mkConst (pre ++ `O))) ksV states ((← IO.monoMsNow) - t0)


private def chainName (pre : Lean.Name) (s : String) (i : Nat) : Lean.Name := pre ++ Name.mkSimple (s ++ toString i)

private def chainKs (pre : Lean.Name) : MetaM (List Nat) := unsafe evalConst (List Nat) (pre ++ `ks)

private def runSE (pre : Lean.Name) (k : Nat) (i : Nat) : Lean.Expr :=
  mkAppN (mkConst ``runS) #[mkConst (pre ++ `F), mkRawNatLit k, mkConst (chainName pre "s" i), mkConst (chainName pre "S" i)]

private def someStE (pre : Lean.Name) (i : Nat) : MetaM Lean.Expr := do
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))
  let pTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  pure (mkApp2 (mkConst ``Option.some [.zero]) pTy
    (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) (mkConst (chainName pre "s" i)) (mkConst (chainName pre "S" i))))

private def optPTy (pre : Lean.Name) : Lean.Expr :=
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))
  mkApp (mkConst ``Option [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv))

/-- `host_chunk P i`: `P.c<i> : runS P.F kᵢ P.s<i> P.S<i> = some (P.s<i+1>, P.S<i+1>)`,
checked by the kernel alone (`Eq.refl`). -/
elab "host_chunk " p:ident i:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let i := i.getNat
  let ks ← chainKs pre
  let some k := ks[i]? | throwError "no chunk {i}"
  let lhs := runSE pre k i
  let ty := mkApp3 (mkConst ``Eq [.succ .zero]) (optPTy pre) lhs (← someStE pre (i + 1))
  let t0 ← IO.monoMsNow
  addDecl (.thmDecl { name := chainName pre "c" i, levelParams := [], type := ty, value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) (optPTy pre) lhs })
  let _ := t0

/-- `host_chain_run P`: `P.run : runS P.F (k₁ + … + k_N) P.s0 P.S0 = some (P.sN, P.SN)`
from the chunk theorems. -/
elab "host_chain_run " p:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let ks ← chainKs pre
  let F := mkConst (pre ++ `F)
  let mut fuel := ks.head!
  let mut pf := mkConst (chainName pre "c" 0)
  let mut i := 1
  for k in ks.tail do
    -- runS_trans F (m := fuel) (n := k) (s₀ s₁ s₂) (S₀ S₁ S₂) pf c_i
    pf := mkAppN (mkConst ``runS_trans) #[F, mkRawNatLit fuel, mkRawNatLit k,
      mkConst (chainName pre "s" 0), mkConst (chainName pre "s" i), mkConst (chainName pre "s" (i + 1)),
      mkConst (chainName pre "S" 0), mkConst (chainName pre "S" i), mkConst (chainName pre "S" (i + 1)),
      pf, mkConst (chainName pre "c" i)]
    fuel := fuel + k
    i := i + 1
  let ty := mkApp3 (mkConst ``Eq [.succ .zero]) (optPTy pre) (runSE pre fuel 0) (← someStE pre ks.length)
  addDecl (.thmDecl { name := pre ++ `run, levelParams := [], type := ty, value := pf })


private def eqThm (name : Lean.Name) (ty lhs rhs : Lean.Expr) : CoreM Unit := do
  let t0 ← IO.monoMsNow
  addDecl (.thmDecl { name, levelParams := [], type := mkApp3 (mkConst ``Eq [.succ .zero]) ty lhs rhs, value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) ty lhs })
  let _ := t0

/-- `host_chain_boot P`: `P.boot_eq : P.boot = some P.s0` and `P.srv_eq : P.srv = P.S0` (kernel). -/
elab "host_chain_boot " p:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))
  let optSt := mkApp (mkConst ``Option [.zero]) stTy
  eqThm (pre ++ `boot_eq) optSt (mkConst (pre ++ `boot)) (mkApp2 (mkConst ``Option.some [.zero]) stTy (mkConst (chainName pre "s" 0)))
  eqThm (pre ++ `srv_eq) (mkConst ``SSrv) (mkConst (pre ++ `srv)) (mkConst (chainName pre "S" 0))

/-- `host_chain_result P`: after `host_chain_run P` and `host_chain_boot P`, for a chain that
halts, `P.halted` and `P.result : ∀ n, K ≤ n → (P.boot.bind fun s => runS P.F n s P.srv) = some (P.sN, P.SN)`. -/
elab "host_chain_result " p:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let ks ← chainKs pre
  let n := ks.length
  let F := mkConst (pre ++ `F)
  let sN := mkConst (chainName pre "s" n)
  eqThm (pre ++ `halted) (mkConst ``Bool) (mkApp (mkConst ``isHalt) (mkApp2 (mkConst ``St.ctl) (mkApp (mkConst ``Ffi.S) F) sN))
    (mkConst ``Bool.true)
  let pf := mkAppN (mkConst ``chain_result) #[F, mkConst (pre ++ `boot), mkConst (pre ++ `srv), mkConst (chainName pre "S" 0),
    mkConst (chainName pre "S" n), mkConst (chainName pre "s" 0), sN, mkRawNatLit (ks.foldl (· + ·) 0),
    mkConst (pre ++ `boot_eq), mkConst (pre ++ `srv_eq), mkConst (pre ++ `run), mkConst (pre ++ `halted)]
  addDecl (.thmDecl { name := pre ++ `result, levelParams := [], type := ← inferType pf, value := pf })

end Host.Ts


namespace Host.Ts
open Lean Elab Command Meta

/-! ## A push-only array abstracted

A generation loop keeps arrays that grow with the position (`forwarded`, the
tokens whose KV entered the cache) and that an iteration only appends to.
`host_chain_abs` takes a `host_chain_sym` chain and, for its states `i … j`,
adds `P.a<k> : List Val → St`: the state with the elements the array `name`
held at state `i` replaced by an arbitrary list `fw` (the elements pushed since
kept after it, `(fw ++ [x₁]) ++ [x₂] …`, as `push` builds them). `host_chunk_abs P k`
proves the chunk for every `fw` (`P.ac<k>`, one kernel check with `fw` free) and
derives `P.c<k>` at the held elements `P.base` (`P.a<k> P.base` is `P.s<k>`).
An iteration that read the array's elements, or its length, would leave the
kernel stuck on `fw`, and the chunk check would fail. -/

/-- Cells an environment binds to `name`, found in a serialized state. -/
partial def cellsNamed (nameE : Lean.Expr) (e : Lean.Expr) : List Nat :=
  let rec go (e : Lean.Expr) (acc : List Nat) : List Nat :=
    match e with
    | .app f a =>
      let acc := match e.getAppFn, e.getAppArgs with
        | .const ``Prod.mk _, #[_, _, n, .lit (.natVal k)] => if n == nameE then k :: acc else acc
        | _, _ => acc
      go a (go f acc)
    | .lam _ t b _ | .forallE _ t b _ => go b (go t acc)
    | .letE _ t v b _ => go b (go v (go t acc))
    | .mdata _ b | .proj _ _ b => go b acc
    | _ => acc
  go e []

/-- The sentinel element the abstraction replaces (no run makes this symbol). -/
def absSentinel : Val := .sym 1000003

/-- `(fw ++ [x₁]) ++ [x₂] …` over a bound `fw` (de Bruijn index 0). -/
def absList (xs : List Lean.Expr) : Lean.Expr :=
  let valT := mkConst ``Val
  xs.foldl (fun acc x => mkApp3 (mkConst ``List.append [.zero]) valT acc
    (mkApp3 (mkConst ``List.cons [.zero]) valT x (mkApp (mkConst ``List.nil [.zero]) valT))) (.bvar 0)

/-- Replace `sentinel :: rest` by `absList rest`. -/
partial def absReplace (sentE : Lean.Expr) (e : Lean.Expr) : Lean.Expr :=
  e.replace fun t => match t.getAppFn, t.getAppArgs with
    | .const ``List.cons _, #[_, h, rest] => if h == sentE then some (absList (listElems rest)) else none
    | _, _ => none
where
  listElems (e : Lean.Expr) : List Lean.Expr := match e.getAppFn, e.getAppArgs with
    | .const ``List.cons _, #[_, h, r] => h :: listElems r
    | _, _ => []

/-- The chain of `host_chain_sym` with, for states `i … j`, the abstracted states
(`fun fw => …` bodies) and the elements held at state `i`. -/
def chainStatesAbs (F : Ffi) (serS : F.S → Lean.Expr) (tyS : Lean.Expr) (ρ : Nat → F64) (fuel : Nat) (s₀ : St F.S)
    (tab : List SymE) (ks : List Nat) (i j : Nat) (name : List Char) :
    Except String (List Ans × List (Lean.Expr × Lean.Expr × Bool) × List Lean.Expr × Lean.Expr) := letI : ToExpr F.S := ⟨serS, tyS⟩; do
  let o ← match discover F ρ fuel s₀ ⟨tab, []⟩ [] 0 with
    | some (o, _, _) => pure o
    | none => throw "discover failed"
  let rec go (s : St F.S) (S : SSrv) : List Nat → Option (List (St F.S × SSrv))
    | [] => some []
    | k :: ks => (runS F k s S).bind fun (s', S') => (go s' S' ks).map ((s', S') :: ·)
  let some sts := (go s₀ ⟨tab, o⟩ ks).map ((s₀, ⟨tab, o⟩) :: ·) | throw "a chunk failed"
  let states := sts.map fun (s, S) => (toExpr s, toExpr S, isHalt s.ctl)
  let some (si, _) := sts[i]? | throw "no state i"
  let nameE := toExpr name
  let cells := (cellsNamed nameE (toExpr si)).eraseDups
  let addrs := cells.filterMap fun c => match si.cell? c with
    | some (some (.obj a)) => some a
    | _ => none
  let [a] := addrs.eraseDups | throw s!"binding {String.ofList name}: arrays {addrs.eraseDups}"
  let some (_, base) := arrayOf F si a | throw "not an array"
  let sentE := toExpr absSentinel
  let mut abs := []
  for k in [i:j + 1] do
    let some (s, _) := sts[k]? | throw "no state"
    let some (ob, es) := arrayOf F s a | throw "array gone"
    unless es.length ≥ base.length do throw s!"state {k}: the array shrank"
    let s' := s.setObj a { ob with kind := .array (absSentinel :: es.drop base.length) }
    abs := abs ++ [absReplace sentE (toExpr s')]
  pure (o, states, abs, toExpr base)

/-- `host_chain_abs P : F, boot, tab, ρ, fuel, [k₁, …], i, j, "name"`: `host_chain_sym`, and the
abstraction of array `name` over states `i … j` (`P.a<k>`, `P.base`, `P.abs` = `(i, j)`). -/
elab "host_chain_abs " p:ident " : " f:term ", " b:term ", " tab:term ", " ρ:term ", " fuel:term ", " ks:term
    ", " i:num ", " j:num ", " nm:str : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let (fE, stTy, bE, serS, tyS) ← chainInputs f b
  let tE ← instantiateMVars (← Term.elabTermAndSynthesize tab (some (mkApp (mkConst ``List [.zero]) (mkConst ``SymE))))
  let rE ← instantiateMVars (← Term.elabTermAndSynthesize ρ (some (← mkArrow (mkConst ``Nat) (mkConst ``F64))))
  let nE ← instantiateMVars (← Term.elabTermAndSynthesize fuel (some (mkConst ``Nat)))
  let ksV ← unsafe evalExpr (List Nat) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat))
    (← instantiateMVars (← Term.elabTermAndSynthesize ks (some (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)))))
  let (iV, jV) := (i.getNat, j.getNat)
  let resTy := mkApp2 (mkConst ``Except [.zero, .zero]) (mkConst ``String) (mkConst ``Unit)
  let _ := resTy
  let call ← mkAppM ``Option.map #[← withLocalDeclD `s stTy fun s => do
    mkLambdaFVars #[s] (mkAppN (mkConst ``chainStatesAbs) #[fE, serS, tyS, rE, nE, s, tE, toExpr ksV, mkRawNatLit iV,
      mkRawNatLit jV, toExpr nm.getString.toList]), bE]
  let t0 ← IO.monoMsNow
  let r ← unsafe evalExpr (Option (Except String (List Ans × List (Lean.Expr × Lean.Expr × Bool) × List Lean.Expr × Lean.Expr)))
    (← inferType call) call
  let some r := r | throw (.error .missing m!"host_chain_abs: boot failed")
  let (o, states, abs, base) ← match r with
    | .ok v => pure v
    | .error e => throwError "host_chain_abs: {e}"
  let ansTy := mkApp (mkConst ``List [.zero]) (mkConst ``Ans)
  addDecl (Declaration.defnDecl { name := pre ++ `O, levelParams := [], type := ansTy, value := toExpr o, hints := ReducibilityHints.abbrev, safety := .safe })
  addChain pre fE stTy bE (mkApp2 (mkConst ``SSrv.mk) tE (mkConst (pre ++ `O))) ksV states ((← IO.monoMsNow) - t0)
  let valL := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
  addDecl (Declaration.defnDecl { name := pre ++ `base, levelParams := [], type := valL, value := base, hints := .regular 0, safety := .safe })
  let shared := ShareCommon.shareCommon' abs
  let mut k := iV
  for body in shared do
    addDecl (Declaration.defnDecl { name := pre ++ Name.mkSimple ("a" ++ toString k), levelParams := [], type := ← mkArrow valL stTy, value := .lam `fw valL body .default, hints := .regular 0, safety := .safe })
    k := k + 1
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
  addDecl (Declaration.defnDecl { name := pre ++ `abs, levelParams := [], type := pairTy, value := mkApp4 (mkConst ``Prod.mk [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat) (mkRawNatLit iV) (mkRawNatLit jV), hints := ReducibilityHints.abbrev, safety := .safe })
  logInfo m!"host_chain_abs {pre}: oracle of {o.length} answers; {String.ofList nm.getString.toList} abstracted over states {iV}…{jV}"

/-- `host_chunk_abs P k`: `P.ac<k> : ∀ fw, runS P.F kₖ (P.a<k> fw) P.S<k> = some (P.a<k+1> fw, P.S<k+1>)`
(one kernel check, `fw` free), and `P.c<k>` (the chunk of `host_chunk`) at `fw := P.base`. -/
elab "host_chunk_abs " p:ident i:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let k := i.getNat
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  let some n := ks[k]? | throwError "no chunk {k}"
  let F := mkConst (pre ++ `F)
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
  let pTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  let oTy := mkApp (mkConst ``Option [.zero]) pTy
  let valL := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
  let sN (i : Nat) := mkConst (pre ++ Name.mkSimple ("S" ++ toString i))
  let eqAt (l r : Lean.Expr) (i : Nat) :=
    let lhs := mkAppN (mkConst ``runS) #[F, mkRawNatLit n, l, sN i]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) pTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) r (sN (i + 1)))
    (mkApp3 (mkConst ``Eq [.succ .zero]) oTy lhs rhs, lhs)
  let aN (i : Nat) := mkConst (pre ++ Name.mkSimple ("a" ++ toString i))
  let (body, lhs) := eqAt (mkApp (aN k) (.bvar 0)) (mkApp (aN (k + 1)) (.bvar 0)) k
  addDecl (.thmDecl { name := pre ++ Name.mkSimple ("ac" ++ toString k), levelParams := [], type := .forallE `fw valL body .default, value := .lam `fw valL (mkApp2 (mkConst ``Eq.refl [.succ .zero]) oTy lhs) .default })
  let sK (i : Nat) := mkConst (pre ++ Name.mkSimple ("s" ++ toString i))
  let (ty, _) := eqAt (sK k) (sK (k + 1)) k
  addDecl (.thmDecl { name := pre ++ Name.mkSimple ("c" ++ toString k), levelParams := [], type := ty, value := mkApp (mkConst (pre ++ Name.mkSimple ("ac" ++ toString k))) (mkConst (pre ++ `base)) })

end Host.Ts

