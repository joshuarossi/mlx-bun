import host.sim.template.RestartCmd
set_option Elab.async false

/-! # The restart map of POST's hand-off

`tpl_restart_hand R : T, X i` is `tpl_restart` from the decode template `T.s0` into POST's end `X.s<i>` as the hand-off uses it
(`Host.Route.PrefGraph.handEnd`): the end's prompt array holding the template's elements, its token queue `[.ref 2]`. The template's token
entry `tok` goes to `.ref 2`, whose table entry reads `var 2`. An entry the walk didn't pair goes to an end entry of its value, if the end
holds one. The walk is a choice only; every use is a kernel check. -/

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Load Host.Ts.Stream

private def addD (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private def natL : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)

/-- The variables an entry reads. -/
partial def symVars : SymE → List Nat
  | .lit _ => []
  | .var v => [v]
  | .bin _ a b => symVars a ++ symVars b
  | .un _ a => symVars a

unsafe def restartHandCmdW {F : Ffi} (wd : TWorld F) (pre base case : Lean.Name) (t1 tok emit : Nat) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  let (x0, c0, _) ← restoreAny (S := F.S) (mkConst (base ++ `s0)) (mkConst (base ++ `S0)) pre
  let (x1, c1, _) ← restoreAny (S := F.S) (mkConst (case ++ Lean.Name.mkSimple s!"s{t1}")) (mkConst (case ++ Lean.Name.mkSimple s!"S{t1}")) pre
  let s0 := wd.proj x0; let s1 := wd.proj x1
  let xs0 := match s0.obj? 2665 with
    | some o => match o.kind with
      | .array xs => xs
      | _ => []
    | none => []
  let s1 := match s1.obj? 2665 with
    | some o => s1.setObj 2665 { o with kind := .array xs0 }
    | none => s1
  let m1 := s1.aux.ffi.mlx
  let s1 := s1.setFfi { s1.aux.ffi with mlx := { m1 with tokens := [.ref 2] } }
  let m0 := s0.aux.ffi.mlx; let m1 := s1.aux.ffi.mlx
  let tab0 := c0.tab.toArray; let tab1 := c1.tab.toArray
  let framed ← natsConstD (base ++ `frames) framedArrays
  let ghosts ← natsConstD (base ++ `ghosts) []
  let maps ← natsConstD (base ++ `maps) []
  let ctx : Ctx := { s1 := s0, s2 := s1, t1 := tab0, t2 := tab1, env := ← getEnv, framed, traceNodes := traceNodesOf m0,
                     ghosts := ghosts.foldl (·.insert ·) {}, byKey := maps }
  let intr := (List.range 40).filter (fun a => (s0.heap.get a).isSome) |>.map fun a => (a, a)
  let ((), w) ← ((do walkRoots intr; wd.walkExtra x0.aux.ffi x1.aux.ffi; drain).run ctx).run {}
  let bad := w.mism.size + w.litDiff.size + w.bigs.size + w.nats.size
  unless bad == 0 do
    let first := (w.mism.toList.take 5).map fun (l, lab, msg) => s!"{l.str} {lab}: {msg} @ {pathOf w l 12}"
    throwError "tpl_restart_hand: the lockstep walk is not a restart ({w.mism.size} mismatches, {w.litDiff.size} literal changes, {w.bigs.size} bigint changes, {w.nats.size} nat changes): {first}"
  let heapP := w.sig.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set a b) PTrie.nil
  let invP := w.sig.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set b a) PTrie.nil
  let hndP := w.hnd.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set a b) PTrie.nil
  let hinvP := w.hnd.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set b a) PTrie.nil
  let nodeP := w.nod.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set a b) PTrie.nil
  let ninvP := w.nod.fold (fun (t : PTrie Nat) a b => if a == b then t else t.set b a) PTrie.nil
  let lo := w.hnd.fold (fun (m : Nat) a b => if a == b then m else min m a) (2 ^ 56)
  let mut numP : PTrie NumV := PTrie.nil
  let mut cand : Std.HashMap Nat SymE := {}
  for (r, y, _, _) in w.pairs do
    unless r == tok do
      unless decide (y = .ref r) do numP := numP.set r y
      let e1 := match y with | .lit x => SymE.lit x | .ref j => tab1[j]?.getD (.lit .nan)
      match tab0[r]? with
      | some (.var v) => if !cand.contains v then cand := cand.insert v e1
      | _ => pure ()
  numP := numP.set tok (.ref 2)
  if let some (.var v) := tab0[tok]? then cand := cand.insert v (tab1[2]?.getD (.lit .nan))
  let paired : Std.HashSet Nat := w.pairs.foldl (fun (t : Std.HashSet Nat) (r, _, _, _) => t.insert r) ({} : Std.HashSet Nat) |>.insert tok
  let θf : Nat → SymE := fun v => (cand.get? v).getD (.var v)
  let mut unpaired : Array (Nat × Bool) := #[]
  for r in [0:tab0.size] do
    unless paired.contains r do
      let e := (tab0[r]?.getD (.lit .nan)).subst θf
      match (List.range tab1.size).find? (fun j => decide (tab1[j]? = some e)) with
      | some j => numP := numP.set r (.ref j); unpaired := unpaired.push (r, true)
      | none => unpaired := unpaired.push (r, false)
  logInfo m!"tpl_restart_hand {pre}: unpaired {unpaired.toList.map fun (r, b) => s!"{r} {fmtSym (tab0[r]?.getD (.lit .nan))} {b}"}; end table head {(tab1.toList.take 20).map fmtSym}"
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
  let used := (tab0.toList.flatMap symVars).eraseDups.mergeSort (· ≤ ·)
  addD (pre ++ `used) natL (toExpr used)
  let iE := match s0.obj? emit with
    | some { kind := .array [.num (.ref i)], .. } => i
    | _ => 0
  addD (pre ++ `iE) (mkConst ``Nat) (mkRawNatLit iE)
  let ren := w.sig.fold (fun (n : Nat) a b => if a == b then n else n + 1) 0
  let renH := w.hnd.fold (fun (n : Nat) a b => if a == b then n else n + 1) 0
  let renN := w.nod.fold (fun (n : Nat) a b => if a == b then n else n + 1) 0
  let lost := unpaired.filter (!·.2) |>.map (·.1)
  logInfo m!"tpl_restart_hand {pre}: heap {w.sig.size} ({ren} renamed), handles {w.hnd.size} ({renH} renamed, first {lo}), nodes {w.nod.size} ({renN} renamed), {w.pairs.size} number pairs, {unpaired.size} entries unpaired, {lost.size} with no image {lost.toList}, reads {used}, emit entry {iE}; θ = {theta.map fun (v, e) => s!"v{v} ↦ {fmtSym e}"}"

elab "tpl_restart_hand " p:ident " : " b:ident ", " c:ident i:num " tok " k:num " emit " e:num os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world]
    let ns ← getCurrNamespace
    let args := #[toExpr (ns ++ p.getId), toExpr (ns ++ b.getId), toExpr (ns ++ c.getId), toExpr i.getNat, toExpr k.getNat, toExpr e.getNat]
    match os.ident `world with
    | none => throwError "tpl_restart_hand: give (world := w)"
    | some n => unsafe inWorld ``restartHandCmdW (← worldConst n) args

end Host.Ts.Sim.Template
