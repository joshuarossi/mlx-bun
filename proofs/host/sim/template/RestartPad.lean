import host.sim.template.RestartCmd
set_option Elab.async false

/-! # A restart into a template whose table the source doesn't contain

`tpl_restart_pad R : T, X i` is `tpl_restart` for a template shared by chains whose tables differ: `Iso.num` covers every template entry, and
most of them have no image in the source. The source table is taken as `S1.tab ++ T.S0.tab.map (·.subst θ)`, so every entry the walk didn't pair
(and the token, `var 14`) goes to `.ref (S1.tab.length + i)`. The entries it did pair stay, and those the source already holds at their
index. -/

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Load Host.Ts.Stream

private def addD (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

unsafe def restartPadCmdW {F : Ffi} (wd : TWorld F) (pre base case : Lean.Name) (t1 : Nat) (block : Nat)
    (loopToken : Bool := true) (subst : Option Lean.Name := none) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  let t0 ← IO.monoMsNow
  let (x0, c0, _) ← restoreAny (S := F.S) (mkConst (base ++ `s0)) (mkConst (base ++ `S0)) pre
  let (x1, c1, _) ← restoreAny (S := F.S) (mkConst (case ++ Lean.Name.mkSimple s!"s{t1}")) (mkConst (case ++ Lean.Name.mkSimple s!"S{t1}")) pre
  -- the end table de-canonicalized (`subst`: a chain's canonical variables to their defining terms)
  let c1 ← match subst with
    | none => pure c1
    | some n => do let dθ ← evalConst (Nat → SymE) n; pure { c1 with tab := c1.tab.map (·.subst dθ) }
  let s0 := wd.proj x0; let s1 := wd.proj x1
  let tr ← IO.monoMsNow
  let m0 := s0.aux.ffi.mlx; let m1 := s1.aux.ffi.mlx
  let tab0 := c0.tab.toArray; let tab1 := c1.tab.toArray
  let env ← getEnv
  let framed ← natsConstD (base ++ `frames) framedArrays
  let ghosts ← natsConstD (base ++ `ghosts) []
  let maps ← natsConstD (base ++ `maps) []
  let ctx : Ctx := { s1 := s0, s2 := s1, t1 := tab0, t2 := tab1, env, framed, traceNodes := traceNodesOf m0,
                     ghosts := ghosts.foldl (·.insert ·) {}, byKey := maps }
  -- a link (`tpl_link`) also walks from the JavaScript objects the native state names, as collection does,
  -- so every present address of the start is paired
  let natR := if loopToken then [] else (nativeHeapRefs m0).map fun a => (a, a)
  let intr := ((List.range 40).filter (fun a => (s0.heap.get a).isSome) |>.map fun a => (a, a)) ++ natR
  let ((), w) ← ((do walkRoots intr; wd.walkExtra x0.aux.ffi x1.aux.ffi; drain).run ctx).run {}
  let bad := w.mism.size + w.litDiff.size + w.bigs.size + w.nats.size
  unless bad == 0 do
    let first := (w.mism.toList.take 5).map fun (l, lab, msg) => s!"{l.str} {lab}: {msg} @ {pathOf w l 12}"
    throwError "tpl_restart_pad: the lockstep walk is not a restart ({w.mism.size} mismatches, {w.litDiff.size} literal changes, {w.bigs.size} bigint changes, {w.nats.size} nat changes): {first}"
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
  -- the decode loop's restart: the token read at the cut, its next-iteration value a fresh end
  -- reference (`var 17`); not for a link (`tpl_link`)
  if loopToken then cand := cand.insert 14 (.var 17)
  -- the source table is extended by the template's images: an entry the walk didn't pair, and the token, at its image
  let paired : Std.HashSet Nat := w.pairs.foldl (fun (t : Std.HashSet Nat) (r, _, _, _) => t.insert r) {}
  -- an entry that already agrees stays where it is: the native nodes' references read the table by index
  let θf : Nat → SymE := fun v => (cand.get? v).getD (.var v)
  for r in [0:tab0.size] do
    let same := match tab0[r]?, tab1[r]? with
      | some e, some e1 => decide (e.subst θf = e1)
      | _, _ => false
    if (!paired.contains r && !same) || (loopToken && decide (tab0[r]? = some (SymE.var 14))) then
      numP := numP.set r (.ref (tab1.size + r))
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
  let ghostLog := if w.ghostSeen.isEmpty && w.ghostEntries.isEmpty then "" else s!"; ghosts {w.ghostSeen.size}, ghost map entries {w.ghostEntries.size}"
  logInfo m!"tpl_restart_pad {pre}: restore {tr - t0} ms, walk+data {(← IO.monoMsNow) - tr} ms; heap {w.sig.size} ({ren} renamed), handles {w.hnd.size} ({renH} renamed, first {lo}), nodes {w.nod.size} ({renN} renamed), {w.pairs.size} number pairs; θ = {theta.map fun (v, e) => s!"v{v} ↦ {fmtSym e}"}{ghostLog}"

elab "tpl_restart_pad " p:ident " : " b:ident ", " c:ident i:num os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world, `subst]
    let ns ← getCurrNamespace
    let sub : Option Lean.Name := (os.ident `subst).map (ns ++ ·)
    match os.ident `world with
    | none | some `lf => unsafe restartPadCmdW lfWorld (ns ++ p.getId) (ns ++ b.getId) (ns ++ c.getId) i.getNat 0
    | some n =>
      let args := #[toExpr (ns ++ p.getId), toExpr (ns ++ b.getId), toExpr (ns ++ c.getId), toExpr i.getNat, toExpr (0 : Nat),
        toExpr true, toExpr sub]
      unsafe inWorld ``restartPadCmdW (← worldConst n) args

end Host.Ts.Sim.Template
