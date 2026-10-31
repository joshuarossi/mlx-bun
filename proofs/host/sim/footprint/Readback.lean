import host.sim.footprint.Full

namespace Host.Mlx.Ffi.Footprint
open Host.Ts FullKeep
open Host.Ts.Sim.Full (FF mlxOf)

/-- The node of the array passed to `mlx_array_item_uint32`, as decoded before the call. -/
def ReadItem (s : St) (args : List Arg) (i : Nat) : Prop :=
  ∃ p a, args = [p, a] ∧ (argNat a).bind s.nodeId? = some i

/-- A token readback changes only its array's item; it preserves all handle contents. -/
theorem call_item_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .itemU32) :
    AllX (Result (fun _ => False) (ReadItem s args) s id) (call s name args) := by
  unfold call
  rw [hsym]
  dsimp only
  repeat' (first
    | (allx_goal; reduce_call)
    | (allx_goal; case_call)
    | with_reducible exact result_stuck
    | with_reducible refine result_okW ?_
    | with_reducible exact Writes.refl _
    | with_reducible refine Writes.pop (Writes.refl _) _ _ _ ?_
    | (exact ⟨_, _, rfl, by assumption⟩)
    | with_reducible refine AllX.cond _ ?_ ?_
    | split_small)

theorem fullCall_item_w (p : FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (hsym : symOf name = some .itemU32) :
    AllX (Result (fun _ => False) (ReadItem (mlxOf p) args) (mlxOf p) mlxOf) (FF.call p name args) := by
  apply fullCall_w p name args hm hp (call_item_w _ name args hsym)
  unfold SymShape.symShapeCall
  rw [hsym]
  exact result_stuck

end Host.Mlx.Ffi.Footprint
