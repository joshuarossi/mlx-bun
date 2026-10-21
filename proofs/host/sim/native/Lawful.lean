import host.sim.steps.FfiJs
import host.load.World
namespace Host.Ts.Sim
open BufSim

/-! # The load world's native calls are lawful (`BufSim.FfiLawful Host.Load.ffi`)

Every mlx-model and host computation is built from `pure`, `bind`,
conditionals, matches and number requests, so it runs its continuation on
its own result. -/

namespace NativeLawful
open Lean Meta Elab Tactic

/-- The matcher of `Host.Mlx.Ffi.call`'s dispatch on symbol and arguments. -/
def dispatchMatcher : Lean.Name := `Host.Mlx.Ffi.call.match_66

/-- The free variable a stuck `casesOn` (after unfolding) scrutinizes. -/
partial def stuckFVar? (e : Lean.Expr) : MetaM (Option FVarId) := do
  let e ← whnf e
  match e.getAppFn with
  | .const n us =>
    if let some (.recInfo rv) := (← getEnv).find? n then
      let idx := rv.getMajorIdx
      let args := e.getAppArgs
      if h : idx < args.size then
        let major := args[idx]
        if major.isFVar then return some major.fvarId! else stuckFVar? major
      else return none
    else if isCasesOnRecursor (← getEnv) n then
      let some (.inductInfo iv) := (← getEnv).find? n.getPrefix | return none
      let idx := iv.numParams + 1 + iv.numIndices
      let args := e.getAppArgs
      if h : idx < args.size then
        let major := args[idx]
        if major.isFVar then return some major.fvarId! else stuckFVar? major
      else return none
    else if ← isMatcher n then
      let info ← getConstInfo n
      match info.value? with
      | some v => stuckFVar? ((v.instantiateLevelParams info.levelParams us).beta e.getAppArgs)
      | none => return none
    else
      -- a stuck primitive (e.g. `Nat.beq off 0` of a literal pattern): its first variable argument
      for a in e.getAppArgs do
        if a.isFVar then
          let ty ← whnf (← inferType a)
          if let .const tn _ := ty.getAppFn then
            if let some (.inductInfo _) := (← getEnv).find? tn then return some a.fvarId!
      return none
  | _ => return none

/-- Case on the variable the dispatch match of `Host.Mlx.Ffi.call` is stuck on (its splitter is
too large to generate). -/
elab "case_call" : tactic => withMainContext do
  let tgt ← instantiateMVars (← getMainTarget)
  let m := tgt.appArg!
  let fn := m.getAppFn
  unless fn.isConst && (fn.constName! == dispatchMatcher) do
    throwError "not the call matcher"
  let some fv ← stuckFVar? m | throwError "no stuck variable"
  let gs ← (← getMainGoal).cases fv
  replaceMainGoal (gs.toList.map (·.mvarId))

/-- Reduce the dispatch match of `Host.Mlx.Ffi.call` at the head, when its discriminants are known. -/
elab "reduce_call" : tactic => withMainContext do
  let tgt ← instantiateMVars (← getMainTarget)
  let m := tgt.appArg!
  let fn := m.getAppFn
  unless fn.isConst && (fn.constName! == dispatchMatcher) do
    throwError "not the call matcher"
  match ← reduceMatcher? m with
  | .reduced m' =>
    let tgt' := tgt.updateApp! tgt.appFn! m'
    replaceMainGoal [← (← getMainGoal).replaceTargetDefEq tgt']
  | _ => throwError "stuck"

/-- `split`, except on the dispatch match of `Host.Mlx.Ffi.call`. -/
elab "split_small" : tactic => withMainContext do
  let tgt ← instantiateMVars (← getMainTarget)
  if (tgt.find? fun e => e.isConst && e.constName! == dispatchMatcher).isSome then
    throwError "the call matcher"
  evalTactic (← `(tactic| split))

set_option maxHeartbeats 4000000

theorem numBin_lawful (op : NBin) (x y : NumV) : Lawful (numBin op x y) := by
  have req : ∀ a b : NumV, (∀ u v, a = .lit u → b = .lit v → False) →
      ∀ γ (k : NumV → Free γ), (numBin op a b) γ k = .bin op a b fun j => k (.ref j) := by
    intro a b hab γ k
    cases a with
    | lit u =>
      cases b with
      | lit v => exact (hab u v rfl rfl).elim
      | ref _ => rfl
    | ref _ => cases b <;> rfl
  have gen : ∀ a b : NumV, (∀ u v, a = .lit u → b = .lit v → False) → Lawful (numBin op a b) := by
    intro a b hab
    refine ⟨fun γ k S => ?_, fun γ k C => ?_⟩
    · rw [req a b hab, Host.Ts.M.run, req a b hab, interpS_bin, interpS_bin]
      cases S.val a with
      | none => rfl
      | some ea => cases S.val b <;> rfl
    · rw [req a b hab, Host.Ts.M.run, req a b hab, interpC_bin, interpC_bin]
      cases C.val a with
      | none => rfl
      | some ea => cases C.val b <;> rfl
  cases x with
  | lit u =>
    cases y with
    | lit v => exact Lawful.pure _
    | ref j => exact gen _ _ (fun _ _ _ h => nomatch h)
  | ref i => exact gen _ _ (fun _ _ h _ => nomatch h)

/-- A computation equal to `pure a`. -/
theorem lawful_of_pure {α : Type} {m : Host.Ts.M α} {a : α} (h : ∀ γ (k : α → Free γ), m γ k = k a) : Lawful m := by
  have : m = Host.Ts.M.pure a := by funext γ k; exact h γ k
  rw [this]; exact Lawful.pure a

theorem ok_l (s : Host.Mlx.Ffi.St) (r : Ret) : Lawful (Host.Mlx.Ffi.ok s r) := Lawful.pure _
theorem okW_l (s : Host.Mlx.Ffi.St) (r : Ret) (ws : List (Nat × Nat × List Byte)) :
    Lawful (Host.Mlx.Ffi.okW s r ws) := Lawful.pure _
theorem stuck_l : Lawful Host.Mlx.Ffi.stuck := Lawful.pure _
theorem okH_l (s : Host.Load.LSt) (h : Host.Load.HostSt) (r : Ret) : Lawful (Host.Load.okH s h r) := Lawful.pure _
theorem stuckH_l : Lawful Host.Load.stuckH := Lawful.pure _

macro "lawful_step" : tactic => `(tactic| first
  | contradiction
  | with_reducible exact Lawful.pure _
  | with_reducible exact Lawful.fail _
  | with_reducible exact ok_l _ _
  | with_reducible exact okW_l _ _ _
  | with_reducible exact stuck_l
  | with_reducible exact okH_l _ _ _
  | with_reducible exact stuckH_l
  | with_reducible exact numBin_lawful _ _ _
  | with_reducible exact numTest_lawful _ _ _
  | with_reducible exact numUn_lawful _ _
  | with_reducible refine Lawful.bind ?_ fun _ => ?_
  | with_reducible refine Lawful.cond _ ?_ ?_
  | split
  | dsimp only)

open Host.Mlx.Ffi

theorem dAdd_l (a b : Dim) : Lawful (dAdd a b) := by unfold dAdd; repeat' lawful_step
theorem dSub_l (a b : Dim) : Lawful (dSub a b) := by unfold dSub; repeat' lawful_step
theorem dMul_l (a b : Dim) : Lawful (dMul a b) := by unfold dMul; repeat' lawful_step
theorem dEq_l (a b : Dim) : Lawful (dEq a b) := by unfold dEq; repeat' lawful_step
theorem dLt_l (a b : Dim) : Lawful (dLt a b) := by unfold dLt; repeat' lawful_step
theorem dMin_l (a b : Dim) : Lawful (dMin a b) := by
  unfold dMin; exact Lawful.bind (dLt_l a b) fun _ => Lawful.pure _
theorem dMax_l (a b : Dim) : Lawful (dMax a b) := by
  unfold dMax; exact Lawful.bind (dLt_l a b) fun _ => Lawful.pure _

macro "lawful_dims" : tactic => `(tactic| repeat' (first
  | with_reducible exact dAdd_l _ _ | with_reducible exact dSub_l _ _ | with_reducible exact dMul_l _ _ | with_reducible exact dEq_l _ _ | with_reducible exact dLt_l _ _
  | with_reducible exact dMin_l _ _ | with_reducible exact dMax_l _ _ | lawful_step))

theorem allEq_l : ∀ (xs ys : List Dim), Lawful (allEq xs ys)
  | [], [] => Lawful.pure _
  | [], _ :: _ => Lawful.pure _
  | _ :: _, [] => Lawful.pure _
  | x :: xs, y :: ys => Lawful.bind (dEq_l x y) fun _ => Lawful.cond _ (allEq_l xs ys) (Lawful.pure _)

theorem dProd_l : ∀ (ds : List Dim), Lawful (dProd ds)
  | [] => Lawful.pure _
  | _ :: ds => Lawful.bind (dProd_l ds) fun _ => dMul_l _ _

theorem broadcast_go_l : ∀ (xs ys : List Dim), Lawful (broadcast.go xs ys)
  | [], _ => Lawful.pure _
  | _ :: _, [] => Lawful.pure _
  | x :: xs, y :: ys => by
    have ih := broadcast_go_l xs ys
    exact Lawful.bind (dEq_l x y) fun _ => Lawful.cond _ (Lawful.bind ih fun _ => Lawful.pure _)
      (Lawful.cond _ (Lawful.bind ih fun _ => Lawful.pure _)
        (Lawful.cond _ (Lawful.bind ih fun _ => Lawful.pure _) (Lawful.pure _)))

theorem broadcast_l (a b : List Dim) : Lawful (broadcast a b) :=
  Lawful.bind (broadcast_go_l _ _) fun _ => Lawful.pure _

theorem sliceAxis_l (n s e k : Dim) : Lawful (sliceAxis n s e k) := by
  unfold sliceAxis; lawful_dims

theorem sliceShape_l : ∀ (ns ss es ks : List Dim), Lawful (sliceShape ns ss es ks)
  | [], [], [], [] => Lawful.pure _
  | n :: ns, s :: ss, e :: es, k :: ks => by
    have ih := sliceShape_l ns ss es ks
    unfold sliceShape
    exact Lawful.bind (sliceAxis_l n s e k) fun r => by
      cases r with
      | some _ => exact Lawful.bind ih fun _ => Lawful.pure _
      | none => exact Lawful.pure _
  | [], [], [], _ :: _ => Lawful.pure _
  | [], [], _ :: _, _ => Lawful.pure _
  | [], _ :: _, _, _ => Lawful.pure _
  | _ :: _, [], _, _ => Lawful.pure _
  | _ :: _, _ :: _, [], _ => Lawful.pure _
  | _ :: _, _ :: _, _ :: _, [] => Lawful.pure _

theorem reshapeShape_l (old new : List Dim) : Lawful (reshapeShape old new) := by
  unfold reshapeShape
  refine Lawful.bind (dProd_l old) fun total => ?_
  split
  · exact Lawful.bind (dProd_l _) fun _ => Lawful.bind (dEq_l _ _) fun _ => Lawful.pure _
  · exact Lawful.bind (dProd_l _) fun p => by split <;> repeat' lawful_step
  · exact Lawful.pure _

theorem concatShape_l (axis : Nat) : ∀ (xs : List (List Dim × Nat)), Lawful (concatShape axis xs)
  | [] => Lawful.pure _
  | [_] => Lawful.pure _
  | (s, _) :: q :: rest => by
    have ih := concatShape_l axis (q :: rest)
    unfold concatShape
    exact Lawful.bind ih fun r => by
      cases r with
      | none => exact Lawful.pure _
      | some p =>
        obtain ⟨r, dr⟩ := p
        exact Lawful.cond _ (Lawful.bind (allEq_l _ _) fun _ =>
          Lawful.cond _ (Lawful.bind (dAdd_l _ _) fun _ => Lawful.pure _) (Lawful.pure _)) (Lawful.pure _)

macro "lawful_shapes" : tactic => `(tactic| repeat' (first
  | with_reducible exact dAdd_l _ _ | with_reducible exact dSub_l _ _ | with_reducible exact dMul_l _ _ | with_reducible exact dEq_l _ _ | with_reducible exact dLt_l _ _
  | with_reducible exact dMin_l _ _ | with_reducible exact dMax_l _ _ | with_reducible exact allEq_l _ _ | with_reducible exact dProd_l _ | with_reducible exact broadcast_l _ _
  | with_reducible exact sliceAxis_l _ _ _ _ | with_reducible exact sliceShape_l _ _ _ _ | with_reducible exact reshapeShape_l _ _
  | with_reducible exact concatShape_l _ _ | lawful_step))

theorem infer_l (p : Prim) (ins : List (List Dim × Nat)) : Lawful (infer p ins) := by
  induction p generalizing ins with
  | replayed c q ih => unfold infer; exact ih ins
  | _ => unfold infer; lawful_shapes; all_goals (first | contradiction | (rename_i h; cases h; exact ih _))

macro "lawful_ops" : tactic => `(tactic| repeat' (first
  | with_reducible exact infer_l _ _ | lawful_shapes))

theorem opOut_l (s : Host.Mlx.Ffi.St) (o : Arg) (p : Prim) (ins : List Nat) : Lawful (opOut s o p ins) := by
  unfold opOut; lawful_ops

theorem leafOut_l (s : Host.Mlx.Ffi.St) (o : Arg) (p : Prim) (sh : List Dim) (d : Nat) : Lawful (leafOut s o p sh d) := by
  unfold leafOut; lawful_ops

theorem replayOrder_l (s : Host.Mlx.Ffi.St) (cls : Nat) : ∀ (m : List (Nat × Nat)) (ns : List Nat), Lawful (replayOrder s cls m ns)
  | m, [] => Lawful.pure _
  | m, n :: ns => by
    unfold replayOrder
    split
    · split
      · exact replayOrder_l s cls m ns
      · exact replayOrder_l s cls m ns
      · exact replayOrder_l s cls m ns
      · exact replayOrder_l s cls m ns
      · exact replayOrder_l s cls m ns
      · refine Lawful.cond _ (replayOrder_l _ _ _ _) ?_
        refine Lawful.cond _ (replayOrder_l s cls m ns) ?_
        split
        · refine Lawful.bind (infer_l _ _) fun r => ?_
          split
          · exact replayOrder_l _ _ _ _
          · split
            · exact replayOrder_l _ _ _ _
            · exact Lawful.pure _
          · exact Lawful.pure _
        · exact Lawful.pure _
    · exact Lawful.pure _

theorem replay_l (s : Host.Mlx.Ffi.St) (cls : Nat) (t : Trace) (xs : List Nat) : Lawful (replay s cls t xs) := by
  unfold replay
  refine Lawful.bind (replayOrder_l _ _ _ _) fun r => ?_
  split <;> exact Lawful.pure _

theorem traceFits_go_l (sl : Bool) : ∀ (a b : List (List Dim × Nat)), Lawful (traceFits.go sl a b)
  | [], [] => Lawful.pure _
  | [], _ :: _ => Lawful.pure _
  | _ :: _, [] => Lawful.pure _
  | (sa, da) :: ra, (sb, db) :: rb => by
    have ih := traceFits_go_l sl ra rb
    unfold traceFits.go
    exact Lawful.cond _ (Lawful.pure _) (Lawful.cond _ ih (Lawful.bind (allEq_l _ _) fun _ => Lawful.cond _ ih (Lawful.pure _)))

theorem traceFits_l (s : Host.Mlx.Ffi.St) (sl : Bool) (t : Trace) (xs : List Nat) : Lawful (traceFits s sl t xs) := by
  unfold traceFits
  split
  · exact traceFits_go_l _ _ _
  · exact Lawful.pure _

theorem findTrace_l (s : Host.Mlx.Ffi.St) (sl : Bool) (xs : List Nat) : ∀ (ts : List Trace), Lawful (findTrace s sl xs ts)
  | [] => Lawful.pure _
  | _ :: ts => Lawful.bind (traceFits_l _ _ _ _) fun _ => Lawful.cond _ (Lawful.pure _) (findTrace_l s sl xs ts)

theorem applyDone_l (s : Host.Mlx.Ffi.St) (cls b off slot : Nat) (t : Trace) (xs : List Nat) :
    Lawful (applyDone s cls b off slot t xs) := by
  unfold applyDone
  refine Lawful.bind (replay_l _ _ _ _) fun r => ?_
  split <;> exact Lawful.pure _

theorem closureApply_l (s : Host.Mlx.Ffi.St) (o c v : Arg) : Lawful (closureApply s o c v) := by
  unfold closureApply
  split
  · refine Lawful.bind (findTrace_l _ _ _ _) fun r => ?_
    split
    · exact applyDone_l _ _ _ _ _ _ _
    · split <;> exact Lawful.pure _
  · exact Lawful.pure _

theorem traceBack_l (s : Host.Mlx.Ffi.St) (a : Arg) : Lawful (traceBack s a) := by
  unfold traceBack
  split
  · split
    · split
      · exact Lawful.cond _ (Lawful.pure _) (applyDone_l _ _ _ _ _ _ _)
      · exact Lawful.pure _
    · exact Lawful.pure _
  · exact Lawful.pure _

theorem cfgUpdate_l (s : Host.Mlx.Ffi.St) (c : Arg) (f : Cfg → Option Cfg) : Lawful (cfgUpdate s c f) := by
  unfold cfgUpdate; repeat' lawful_step

theorem kernelApply_l (s : Host.Mlx.Ffi.St) (o k v c : Arg) : Lawful (kernelApply s o k v c) := by
  unfold kernelApply; repeat' lawful_step

theorem mapGet_l (s : Host.Mlx.Ffi.St) (o m k : Arg) : Lawful (mapGet s o m k) := by
  unfold mapGet; repeat' lawful_step

theorem loadSafetensors_l (s : Host.Mlx.Ffi.St) (a b c : Arg) : Lawful (loadSafetensors s a b c) := by
  unfold loadSafetensors; repeat' lawful_step

theorem mlx_call_l (s : Host.Mlx.Ffi.St) (name : Name) (args : List Arg) : Lawful (call s name args) := by
  unfold call
  cases Host.Mlx.Ffi.symOf name with
  | none => exact Lawful.pure _
  | some x =>
    dsimp only
    induction x <;> repeat' (first
      | reduce_call
      | case_call
      | contradiction
      | with_reducible exact Lawful.pure _
      | with_reducible exact Lawful.fail _
      | with_reducible exact ok_l _ _
      | with_reducible exact okW_l _ _ _
      | with_reducible exact stuck_l
      | with_reducible exact closureApply_l _ _ _ _
      | with_reducible exact cfgUpdate_l _ _ _
      | with_reducible exact kernelApply_l _ _ _ _ _
      | with_reducible exact mapGet_l _ _ _ _
      | with_reducible exact loadSafetensors_l _ _ _ _
      | with_reducible exact opOut_l _ _ _ _
      | with_reducible exact leafOut_l _ _ _ _ _
      | with_reducible exact traceBack_l _ _
      | with_reducible refine Lawful.bind ?_ fun _ => ?_
      | with_reducible refine Lawful.cond _ ?_ ?_
      | split_small
      | dsimp only)

theorem load_hostCall_l (s : Host.Load.LSt) (name : Name) (args : List Arg) :
    Lawful (Host.Load.hostCall s name args) := by
  unfold Host.Load.hostCall Host.Load.pseudoCall Host.Load.msgSend Host.Load.newPtr Host.Load.okH
    Host.Load.stuckH
  repeat' lawful_step

end NativeLawful

/-- **The load world's native calls and continuations are lawful.** -/
theorem loadFfiLawful : FfiLawful Host.Load.ffi where
  call := fun x name as => by
    show Lawful (Host.Load.call x name as)
    unfold Host.Load.call
    refine Lawful.cond _ ?_ (NativeLawful.load_hostCall_l _ _ _)
    exact Lawful.bind (NativeLawful.mlx_call_l _ _ _) fun r => by split <;> exact Lawful.pure _
  back := fun x a => by
    show Lawful (Host.Load.back x a)
    unfold Host.Load.back
    exact Lawful.bind (NativeLawful.traceBack_l _ _) fun r => by split <;> exact Lawful.pure _

end Host.Ts.Sim
