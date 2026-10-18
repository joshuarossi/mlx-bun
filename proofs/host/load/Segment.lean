import host.ts.Memo
namespace Host.Ts
open Lean Elab Command Meta

/-! # Run segments

A long run is split into segments, one `States` file each:
`run_segment P : F, boot, srv, skip, [k₁, …, k_N]` boots natively, runs
`skip` steps natively (no states), then adds `P.s0 … P.sN` and
`P.S0 … P.SN` like `host_chain` (`P.s0` the state after the skipped
steps). Chunk files (`host_chunk P i`) and `host_chain_run P` work as for
`host_chain`; consecutive segments are joined by `seg_join P Q`
(`P.join_Q : P.sN = Q.s0 ∧ P.SN = Q.S0`, kernel), so the segments
compose into one run (`runS_trans`). The first segment's `P.s0` is joined
to the end of a link chain by `boot_join`. -/

/-- `chainStates` over the memoizing serializers (`Memo`). -/
def chainStatesM (F : Ffi) (serS : F.S → Lean.Expr) (tyS : Lean.Expr) (s₀ : St F.S) (S₀ : SSrv) (ks : List Nat) :
    Option (List (Lean.Expr × Lean.Expr × Bool)) :=
  letI : ToExpr F.S := ⟨serS, tyS⟩
  let rec go (s : St F.S) (S : SSrv) : List Nat → Option (List (Lean.Expr × Lean.Expr × Bool))
    | [] => some []
    | k :: ks => (runS F k s S).bind fun (s', S') =>
      (go s' S' ks).map ((toExpr s', toExpr S', isHalt s'.ctl) :: ·)
  (go s₀ S₀ ks).map ((toExpr s₀, toExpr S₀, isHalt s₀.ctl) :: ·)

def segmentStates (F : Ffi) (serS : F.S → Lean.Expr) (tyS : Lean.Expr) (s₀ : St F.S) (S₀ : SSrv) (skip : Nat)
    (ks : List Nat) : Option (List (Lean.Expr × Lean.Expr × Bool)) :=
  (runS F skip s₀ S₀).bind fun (s, S) => chainStatesM F serS tyS s S ks

elab "run_segment " p:ident " : " f:term ", " b:term ", " srv:term ", " skip:term ", " ks:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let (fE, stTy, bE, serS, tyS) ← chainInputs f b
  let srvE ← instantiateMVars (← Term.elabTermAndSynthesize srv (some (mkConst ``SSrv)))
  let skipV ← unsafe evalExpr Nat (mkConst ``Nat) (← instantiateMVars (← Term.elabTermAndSynthesize skip (some (mkConst ``Nat))))
  let ksV ← unsafe evalExpr (List Nat) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat))
    (← instantiateMVars (← Term.elabTermAndSynthesize ks (some (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)))))
  let call ← mkAppM ``Option.bind #[bE, ← withLocalDeclD `s stTy fun s => do
    mkLambdaFVars #[s] (mkAppN (mkConst ``segmentStates) #[fE, serS, tyS, s, srvE, toExpr skipV, toExpr ksV])]
  Memo.reset
  let t0 ← IO.monoMsNow
  let some states ← unsafe evalExpr (Option (List (Lean.Expr × Lean.Expr × Bool))) (← inferType call) call
    | throwError "run_segment: boot or a chunk failed natively"
  addChain pre fE stTy bE srvE ksV states ((← IO.monoMsNow) - t0)
  let nTy := mkConst ``Nat
  addDecl (.defnDecl { name := pre ++ `skip, levelParams := [], type := nTy, value := toExpr skipV, hints := .abbrev, safety := .safe })

private def sName (pre : Lean.Name) (s : String) (i : Nat) : Lean.Name := pre ++ Name.mkSimple (s ++ toString i)

private def segLen (pre : Lean.Name) : MetaM Nat := do
  pure (← unsafe evalConst (List Nat) (pre ++ `ks)).length

/-- `seg_join P Q`: `P.join : P.sN = Q.s0` and `P.joinS : P.SN = Q.S0`, by the kernel. -/
elab "seg_join " p:ident q:ident : command => liftTermElabM do
  let ns ← getCurrNamespace
  let pre := ns ++ p.getId
  let qre := ns ++ q.getId
  let n ← segLen pre
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))
  let eq (ty a b : Lean.Expr) := mkApp3 (mkConst ``Eq [.succ .zero]) ty a b
  let rfl (ty a : Lean.Expr) := mkApp2 (mkConst ``Eq.refl [.succ .zero]) ty a
  let t1 := eq stTy (mkConst (sName pre "s" n)) (mkConst (sName qre "s" 0))
  let v1 := rfl stTy (mkConst (sName pre "s" n))
  addDecl (.thmDecl { name := pre ++ `join, levelParams := [], type := t1, value := v1 })
  let t2 := eq (mkConst ``SSrv) (mkConst (sName pre "S" n)) (mkConst (sName qre "S" 0))
  let v2 := rfl (mkConst ``SSrv) (mkConst (sName pre "S" n))
  addDecl (.thmDecl { name := pre ++ `joinS, levelParams := [], type := t2, value := v2 })

end Host.Ts
