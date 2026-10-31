import host.sim.footprint.Kernel

namespace Host.Mlx.Ffi.Footprint
open Host.Ts FullKeep

/-- Vector allocation, access, completion of a pending callback's output, and free.
`vecSetData` changes pending bookkeeping only, not old handle or node contents. -/
def VectorSym : Sym → Bool
  | .vecNew | .vecNewData | .vecFree | .vecSize | .vecGet | .vecSetData | .eval | .asyncEval => true
  | _ => false

macro "vector_dispatch_w" : tactic => `(tactic|
  (unfold call
   rw [show symOf _ = some _ from by assumption]
   dsimp only
   repeat' (first
     | (allx_goal; reduce_call)
     | (allx_goal; case_call)
     | with_reducible exact result_stuck
     | with_reducible refine result_okW ?_
     | with_reducible refine result_ok ?_
     | with_reducible exact Writes.refl _
     | with_reducible refine Writes.newObj ?_ _
     | with_reducible refine Writes.setArr ?_ _ _ (Or.inr (outSlot_cons (by assumption)))
     | with_reducible refine AllX.cond _ ?_ ?_
     | split
     | with_reducible exact ⟨Nat.le_refl _, Nat.le_refl _, fun _ _ _ => rfl,
         fun _ _ _ => rfl, fun _ _ => rfl, fun _ _ => rfl⟩)))

theorem call_vecNew_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .vecNew) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by vector_dispatch_w
theorem call_vecNewData_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .vecNewData) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by vector_dispatch_w
theorem call_vecFree_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .vecFree) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by vector_dispatch_w
theorem call_vecSize_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .vecSize) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by vector_dispatch_w
theorem call_vecGet_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .vecGet) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by vector_dispatch_w
theorem call_vecSetData_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .vecSetData) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by vector_dispatch_w
theorem call_eval_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .eval) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by vector_dispatch_w
theorem call_asyncEval_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .asyncEval) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by vector_dispatch_w

theorem call_vector_w (s : St) (name : Name) (args : List Arg)
    (ha : (symOf name).any VectorSym = true) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by
  cases hn : symOf name with
  | none => simp only [hn, Option.any] at ha; contradiction
  | some x =>
    rw [hn] at ha
    cases x <;> simp only [Option.any, VectorSym] at ha <;> try contradiction
    all_goals first
      | exact call_vecNew_w s name args hn
      | exact call_vecNewData_w s name args hn
      | exact call_vecFree_w s name args hn
      | exact call_vecSize_w s name args hn
      | exact call_vecGet_w s name args hn
      | exact call_vecSetData_w s name args hn
      | exact call_eval_w s name args hn
      | exact call_asyncEval_w s name args hn

theorem fullCall_vector_w (p : Host.Ts.Sim.Full.FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any VectorSym = true) :
    AllX (Result (OutSlot args) (fun _ => False) (Host.Ts.Sim.Full.mlxOf p) Host.Ts.Sim.Full.mlxOf)
      (Host.Ts.Sim.Full.FF.call p name args) := by
  apply fullCall_w p name args hm hp (call_vector_w _ name args ha)
  cases hn : symOf name with
  | none => simp only [hn, Option.any] at ha; contradiction
  | some x =>
    rw [hn] at ha
    cases x <;> simp only [Option.any, VectorSym] at ha <;> try contradiction
    all_goals unfold SymShape.symShapeCall; rw [hn]; exact result_stuck

end Host.Mlx.Ffi.Footprint
