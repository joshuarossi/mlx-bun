import host.sim.template.Build
import host.sim.template.ShiftJS

/-! # Choosing restart maps natively

`tpl_restart R : T, X i` walks the template start `T.s0` and the case end
`X.s<i>` in lockstep (`host.sim.template.Walk`) and defines the restart map as
data: `R.data : RData` (renamed addresses, handles and nodes; number images),
`R.inv` (the inverse of the renamed addresses), `R.theta` (the substitution of
the template variables), `R.lo` (the first renamed handle) and the template's
unframed present addresses in blocks `R.blk<j>` with `R.ukeys` their
concatenation. The walk is a choice only; every use is a kernel check.
`tpl_heap_blocks R : σ, s0, s1` proves `R.hb<j> : HeapImg σ s0 s1 R.blk<j>` by
`Eq.refl` (kernel evaluation) and composes `R.heapImg : HeapImg σ s0 s1 R.ukeys`. -/

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Load Host.Ts.Stream

private def addD (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private def listE (ty : Lean.Expr) (xs : List Lean.Expr) : Lean.Expr :=
  xs.foldr (fun x acc => mkApp3 (mkConst ``List.cons [.zero]) ty x acc) (mkApp (mkConst ``List.nil [.zero]) ty)

unsafe def restartCmd (pre base case : Lean.Name) (t1 : Nat) (block : Nat) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  let t0 ← IO.monoMsNow
  let (s0, c0, _) ← restore (mkConst (base ++ `s0)) (mkConst (base ++ `S0)) pre
  let (s1, c1, _) ← restore (mkConst (case ++ Lean.Name.mkSimple s!"s{t1}")) (mkConst (case ++ Lean.Name.mkSimple s!"S{t1}")) pre
  let tr ← IO.monoMsNow
  let m0 := s0.aux.ffi.mlx; let m1 := s1.aux.ffi.mlx
  let tab0 := c0.tab.toArray; let tab1 := c1.tab.toArray
  let env ← getEnv
  let ctx : Ctx := { s1 := s0, s2 := s1, t1 := tab0, t2 := tab1, env, framed := framedArrays, traceNodes := traceNodesOf m0 }
  let intr := (List.range 40).filter (fun a => (s0.heap.get a).isSome) |>.map fun a => (a, a)
  let ((), w) ← ((walkRoots intr).run ctx).run {}
  let bad := w.mism.size + w.litDiff.size + w.bigs.size + w.nats.size
  unless bad == 0 do
    let first := (w.mism.toList.take 5).map fun (l, lab, msg) => s!"{l.str} {lab}: {msg} @ {pathOf w l 12}"
    throwError "tpl_restart: the lockstep walk is not a restart ({w.mism.size} mismatches, {w.litDiff.size} literal changes, {w.bigs.size} bigint changes, {w.nats.size} nat changes): {first}"
  -- names
  let heapP := w.sig.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set a b) PTrie.nil
  let invP := w.sig.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set b a) PTrie.nil
  let hndP := w.hnd.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set a b) PTrie.nil
  let hinvP := w.hnd.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set b a) PTrie.nil
  let nodeP := w.nod.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set a b) PTrie.nil
  let ninvP := w.nod.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set b a) PTrie.nil
  let lo := w.hnd.fold (fun (m : Nat) a b => if a == b then m else min m a) (2 ^ 56)
  -- numbers
  let mut numP : PTrie NumV := PTrie.nil
  let mut cand : Std.HashMap Nat SymE := {}
  for (r, y, _, _) in w.pairs do
    unless decide (y = .ref r) do numP := numP.set r y
    let e1 := match y with | .lit x => SymE.lit x | .ref j => tab1[j]?.getD (.lit .nan)
    match tab0[r]? with
    | some (.var v) => if !cand.contains v then cand := cand.insert v e1
    | _ => pure ()
  -- the token read at the cut: its next-iteration value is a fresh end reference (`var 17`)
  for r in [0:tab0.size] do
    if decide (tab0[r]? = some (SymE.var 14)) then numP := numP.set r (.ref tab1.size)
  cand := cand.insert 14 (.var 17)
  let theta := cand.toList.filter (fun (v, e) => !decide (e = .var v)) |>.mergeSort (fun a b => a.1 ≤ b.1)
  let D := mkAppN (mkConst ``RData.mk) #[toExpr s0.next, toExpr s1.next, toExpr heapP, toExpr hndP,
    toExpr m0.next, toExpr m1.next, toExpr m0.nnext, toExpr m1.nnext, toExpr nodeP, toExpr numP]
  addD (pre ++ `data) (mkConst ``RData) D
  addD (pre ++ `inv) (mkApp (mkConst ``PTrie) (mkConst ``Nat)) (toExpr invP)
  addD (pre ++ `hinv) (mkApp (mkConst ``PTrie) (mkConst ``Nat)) (toExpr hinvP)
  addD (pre ++ `ninv) (mkApp (mkConst ``PTrie) (mkConst ``Nat)) (toExpr ninvP)
  let pTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``SymE)
  addD (pre ++ `theta) (mkApp (mkConst ``List [.zero]) pTy) (toExpr theta)
  addD (pre ++ `lo) (mkConst ``Nat) (mkRawNatLit lo)
  let _ := block
  let ren := w.sig.fold (fun (n : Nat) a b => if a == b then n else n + 1) 0
  let renH := w.hnd.fold (fun (n : Nat) a b => if a == b then n else n + 1) 0
  let renN := w.nod.fold (fun (n : Nat) a b => if a == b then n else n + 1) 0
  logInfo m!"tpl_restart {pre}: restore {tr - t0} ms, walk+data {(← IO.monoMsNow) - tr} ms; heap {w.sig.size} ({ren} renamed), handles {w.hnd.size} ({renH} renamed, first {lo}), nodes {w.nod.size} ({renN} renamed), {w.pairs.size} number pairs; θ = {theta.map fun (v, e) => s!"v{v} ↦ {fmtSym e}"}"

elab "tpl_restart " p:ident " : " b:ident ", " c:ident i:num : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let ns ← getCurrNamespace
    unsafe restartCmd (ns ++ p.getId) (ns ++ b.getId) (ns ++ c.getId) i.getNat 0

/-! ## Present addresses in group parts

`tpl_keys T` lists, for every occupied 4096-address group of `T.s0`'s heap, its
unframed present addresses: parts `T.gc<j> : List (Nat × List Nat)` of whole
groups (at most about 1024 addresses each, `T.gks` their concatenation). It
proves, by kernel evaluation per chunk, that the parts are exactly the heap's
groups (`T.groups_check`, `T.gcc<j>`), hence `T.cover`: every unframed present
address is listed. Properties of all listed addresses are then checked chunk by
chunk (`tpl_all_blocks`, `tpl_heap_blocks`), so no single kernel check
evaluates the whole heap. -/

/-- A group chunk is exactly the group's unframed addresses. -/
def groupOK {α : Type} (t : PTrie α) (fr : List Nat) (q : Nat × List Nat) : Bool :=
  (PTrie.groupKeys t q.1).filter (fun a => !fr.contains a) == q.2

theorem chunk_all {p : Nat × List Nat → Bool} {gc : List (Nat × List Nat)} (h : gc.all p = true) :
    ∀ q ∈ gc, p q = true := List.all_eq_true.mp h

theorem chunk_all2 {p : Nat → Bool} {gc : List (Nat × List Nat)} (h : gc.all (fun q => q.2.all p) = true) :
    ∀ q ∈ gc, ∀ a ∈ q.2, p a = true :=
  fun q hq => List.all_eq_true.mp (List.all_eq_true.mp h q hq)

theorem HeapImg.chunk {S : Type} {σ : Map} {s0 s1 : St S} {gc : List (Nat × List Nat)}
    (h : HeapImg σ s0 s1 (gc.flatMap Prod.snd)) :
    ∀ q ∈ gc, ∀ a ∈ q.2, s1.heap.get (σ.a a) = (s0.heap.get a).map σ.hobj :=
  fun q hq a ha => h.mem (List.mem_flatMap.mpr ⟨q, hq, ha⟩)

/-- The value of a numeral definition. -/
def natConst (n : Lean.Name) : MetaM Nat := do
  match (← getConstInfo n).value? with
  | some (.lit (.natVal k)) => pure k
  | _ => throwError "{n} is not a numeral definition"

private def natL : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
private def pairTy : Lean.Expr := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) natL
private def chunkTy : Lean.Expr := mkApp (mkConst ``List [.zero]) pairTy

unsafe def keysCmd (pre : Lean.Name) (budget : Nat) : TermElabM Nat := do
  let t0 ← IO.monoMsNow
  let (s0, _, _) ← restore (mkConst (pre ++ `s0)) (mkConst (pre ++ `S0)) pre
  let groups := PTrie.groups s0.heap
  let mut parts : Array (List (Nat × List Nat)) := #[]
  let mut cur : Array (Nat × List Nat) := #[]
  let mut size := 0
  let mut total := 0
  for gi in groups do
    let l := (PTrie.groupKeys s0.heap gi).filter fun a => !framedArrays.contains a
    if size + l.length > budget && !cur.isEmpty then
      parts := parts.push cur.toList; cur := #[]; size := 0
    cur := cur.push (gi, l); size := size + l.length; total := total + l.length
  unless cur.isEmpty do parts := parts.push cur.toList
  let mut gks := mkApp (mkConst ``List.nil [.zero]) pairTy
  for j' in [0:parts.size] do
    let j := parts.size - 1 - j'
    let n := pre ++ Lean.Name.mkSimple s!"gc{j}"
    addD n chunkTy (toExpr parts[j]!)
    gks ← mkAppM ``HAppend.hAppend #[mkConst n, gks]
  addD (pre ++ `gks) chunkTy gks
  addD (pre ++ `ngc) (mkConst ``Nat) (mkRawNatLit parts.size)
  logInfo m!"tpl_keys {pre}: {total} unframed present addresses, {groups.length} groups in {parts.size} parts ({(← IO.monoMsNow) - t0} ms)"
  return parts.size

/-- `tpl_keys T`: group parts of `T.s0`'s unframed present addresses, checked, and `T.cover`. -/
elab "tpl_keys " p:ident : command => do
  let ns ← getCurrNamespace
  let pre := ns ++ p.getId
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let n ← unsafe keysCmd pre 1024
    let s0 := mkConst (pre ++ `s0)
    let heapE ← mkAppM ``St.heap #[s0]
    let frE := mkConst ``framedList
    let okE ← mkAppM ``groupOK #[heapE, frE]
    -- the parts list the occupied groups
    let lhs ← mkAppM ``BEq.beq #[← mkAppM ``PTrie.groups #[heapE], ← mkAppM ``List.map #[mkConst ``Prod.fst [.zero, .zero] |> fun f => mkApp2 f (mkConst ``Nat) natL, mkConst (pre ++ `gks)]]
    let t0 ← IO.monoMsNow
    addDecl (.thmDecl { name := pre ++ `groups_check, levelParams := [], type := ← mkEq lhs (mkConst ``Bool.true), value := ← mkEqRefl lhs })
    -- each chunk is exactly its groups' addresses
    for j in [0:n] do
      let l ← mkAppM ``List.all #[mkConst (pre ++ Lean.Name.mkSimple s!"gc{j}"), okE]
      addDecl (.thmDecl { name := pre ++ Lean.Name.mkSimple s!"gcc{j}", levelParams := [], type := ← mkEq l (mkConst ``Bool.true), value := ← mkEqRefl l })
    let R ← withLocalDeclD `q pairTy fun q => do mkLambdaFVars #[q] (← mkEq (mkApp okE q) (mkConst ``Bool.true))
    let mut acc := mkApp2 (mkConst ``forall_mem_nil') pairTy R
    let mut lAcc := mkApp (mkConst ``List.nil [.zero]) pairTy
    for j' in [0:n] do
      let j := n - 1 - j'
      let gc := mkConst (pre ++ Lean.Name.mkSimple s!"gc{j}")
      let hj := mkAppN (mkConst ``chunk_all) #[okE, gc, mkConst (pre ++ Lean.Name.mkSimple s!"gcc{j}")]
      acc := mkAppN (mkConst ``forall_mem_append') #[pairTy, R, gc, lAcc, hj, acc]
      lAcc ← mkAppM ``HAppend.hAppend #[gc, lAcc]
    let allTy ← withLocalDeclD `q pairTy fun q => do
      mkForallFVars #[q] (← mkArrow (← mkAppM ``Membership.mem #[mkConst (pre ++ `gks), q]) (mkApp R q |>.headBeta))
    addDecl (.thmDecl { name := pre ++ `gccAll, levelParams := [], type := allTy, value := acc })
    let cover ← mkAppM ``PTrie.cover #[mkConst (pre ++ `groups_check), mkConst (pre ++ `gccAll)]
    addDecl (.thmDecl { name := pre ++ `cover, levelParams := [], type := ← inferType cover, value := cover })
    logInfo m!"tpl_keys {pre}: {n} chunk checks, {(← IO.monoMsNow) - t0} ms"

/-- `tpl_all_blocks NAME from T : p`: `NAME.ab<j> : T.gc<j>.all (·.2.all p) = true` by kernel
evaluation, and `NAME.all : ∀ q ∈ T.gks, ∀ a ∈ q.2, p a = true`. -/
elab "tpl_all_blocks " nm:ident " from " r:ident " : " pt:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ nm.getId
    let src := (← getCurrNamespace) ++ r.getId
    let pE ← instantiateMVars (← Term.elabTermAndSynthesize pt (some (← mkArrow (mkConst ``Nat) (mkConst ``Bool))))
    let n ← natConst (src ++ `ngc)
    let t0 ← IO.monoMsNow
    let inner ← withLocalDeclD `q pairTy fun q => do mkLambdaFVars #[q] (← mkAppM ``List.all #[← mkAppM ``Prod.snd #[q], pE])
    let R ← withLocalDeclD `q pairTy fun q => do
      mkLambdaFVars #[q] (← withLocalDeclD `a (mkConst ``Nat) fun a => do
        mkForallFVars #[a] (← mkArrow (← mkAppM ``Membership.mem #[← mkAppM ``Prod.snd #[q], a]) (← mkEq (mkApp pE a) (mkConst ``Bool.true))))
    let mut acc := mkApp2 (mkConst ``forall_mem_nil') pairTy R
    let mut lAcc := mkApp (mkConst ``List.nil [.zero]) pairTy
    for j' in [0:n] do
      let j := n - 1 - j'
      let gc := mkConst (src ++ Lean.Name.mkSimple s!"gc{j}")
      let l ← mkAppM ``List.all #[gc, inner]
      let name := pre ++ Lean.Name.mkSimple s!"ab{j}"
      addDecl (.thmDecl { name, levelParams := [], type := ← mkEq l (mkConst ``Bool.true), value := ← mkEqRefl l })
      let hj := mkAppN (mkConst ``chunk_all2) #[pE, gc, mkConst name]
      acc := mkAppN (mkConst ``forall_mem_append') #[pairTy, R, gc, lAcc, hj, acc]
      lAcc ← mkAppM ``HAppend.hAppend #[gc, lAcc]
    let ty ← withLocalDeclD `q pairTy fun q => do
      mkForallFVars #[q] (← mkArrow (← mkAppM ``Membership.mem #[mkConst (src ++ `gks), q]) (mkApp R q |>.headBeta))
    addDecl (.thmDecl { name := pre ++ `all, levelParams := [], type := ty, value := acc })
    logInfo m!"tpl_all_blocks {pre}: {n} parts, {(← IO.monoMsNow) - t0} ms"

/-- `tpl_heap_blocks NAME from T : σ, s0, s1`: `NAME.hb<j> : HeapImg σ s0 s1 (T.gc<j>.flatMap Prod.snd)`
by kernel evaluation, and `NAME.heapAt : ∀ q ∈ T.gks, ∀ a ∈ q.2, s1.heap.get (σ.a a) = (s0.heap.get a).map σ.hobj`. -/
elab "tpl_heap_blocks " nm:ident " from " r:ident " : " sg:term ", " s0:term ", " s1:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ nm.getId
    let src := (← getCurrNamespace) ++ r.getId
    let σ ← instantiateMVars (← Term.elabTermAndSynthesize sg (some (mkConst ``Map)))
    let a0 ← instantiateMVars (← Term.elabTermAndSynthesize s0 none)
    let a1 ← instantiateMVars (← Term.elabTermAndSynthesize s1 none)
    let n ← natConst (src ++ `ngc)
    let t0 ← IO.monoMsNow
    let sndE := mkApp2 (mkConst ``Prod.snd [.zero, .zero]) (mkConst ``Nat) natL
    let mut acc : Option Lean.Expr := none
    let mut lAcc := mkApp (mkConst ``List.nil [.zero]) pairTy
    let mut R : Lean.Expr := default
    for j' in [0:n] do
      let j := n - 1 - j'
      let gc := mkConst (src ++ Lean.Name.mkSimple s!"gc{j}")
      let flat ← mkAppM ``List.flatMap #[sndE, gc]
      let ty ← mkAppM ``HeapImg #[σ, a0, a1, flat]
      let some body ← unfoldDefinition? ty | throwError "HeapImg"
      let lhs := body.appFn!.appArg!
      let name := pre ++ Lean.Name.mkSimple s!"hb{j}"
      let tj ← IO.monoMsNow
      addDecl (.thmDecl { name, levelParams := [], type := ty, value := ← mkEqRefl lhs })
      logInfo m!"{name}: {(← IO.monoMsNow) - tj} ms"
      let hj ← mkAppM ``HeapImg.chunk #[mkConst name]
      -- R q := ∀ a ∈ q.2, … (from the chunk lemma's statement)
      let hjTy ← inferType hj
      let .forallE _ _ body' _ := hjTy | throwError "chunk statement"
      let .forallE _ _ rq _ := body' | throwError "chunk statement"
      R ← withLocalDeclD `q pairTy fun q => do mkLambdaFVars #[q] (rq.instantiate1 q)
      acc := some (match acc with
        | none => mkAppN (mkConst ``forall_mem_append') #[pairTy, R, gc, lAcc, hj, mkApp2 (mkConst ``forall_mem_nil') pairTy R]
        | some a => mkAppN (mkConst ``forall_mem_append') #[pairTy, R, gc, lAcc, hj, a])
      lAcc ← mkAppM ``HAppend.hAppend #[gc, lAcc]
    let some pf := acc | throwError "no parts"
    let ty ← withLocalDeclD `q pairTy fun q => do
      mkForallFVars #[q] (← mkArrow (← mkAppM ``Membership.mem #[mkConst (src ++ `gks), q]) (mkApp R q |>.headBeta))
    addDecl (.thmDecl { name := pre ++ `heapAt, levelParams := [], type := ty, value := pf })
    logInfo m!"tpl_heap_blocks {pre}: {n} parts, {(← IO.monoMsNow) - t0} ms"

end Host.Ts.Sim.Template
