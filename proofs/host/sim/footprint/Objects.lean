import host.sim.footprint.Full

namespace Host.Mlx.Ffi.Footprint
open Host.Ts FullKeep

/-- The handle argument of a configuration update. -/
def FirstHandle (args : List Arg) (h : Nat) : Prop :=
  ∃ a rest, args = a :: rest ∧ argNat a = some h

private theorem handle_of_bind {s : St} {a : Option Nat} {h : Nat} {o : Obj}
    (he : (a.bind fun k => (s.obj? k).map (k, ·)) = some (h, o)) : a = some h := by
  obtain ⟨k, hk, he⟩ := Option.bind_eq_some_iff.mp he
  obtain ⟨o0, _, he⟩ := Option.map_eq_some_iff.mp he
  cases he
  exact hk

/-- An actual configuration update replaces only the configuration named by its argument. -/
theorem cfgUpdate_w {H I : Nat → Prop} {s₀ s : St} (w : Writes H I s₀ s) (a : Arg) (f : Cfg → Option Cfg)
    (hs : ∀ h, argNat a = some h → H h) : AllX (Result H I s₀ id) (cfgUpdate s a f) := by
  unfold cfgUpdate
  split
  · rename_i h c he
    have hh : H h := hs _ (handle_of_bind he)
    split
    · exact result_ok (w.setObj _ _ hh)
    · exact result_stuck
  · exact result_stuck

/-- `mlx_fast_metal_kernel_config_set_grid` is one concrete dispatcher use of the update. -/
theorem call_cfgGrid_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .cfgGrid) :
    AllX (Result (FirstHandle args) (fun _ => False) s id) (call s name args) := by
  unfold call
  rw [hsym]
  dsimp only
  repeat' (first
    | (allx_goal; reduce_call)
    | (allx_goal; case_call)
    | with_reducible refine cfgUpdate_w (Writes.refl _) _ _ ?_
    | (intro h he; exact ⟨_, _, rfl, he⟩)
    | with_reducible exact result_stuck)

/-- Full-world configuration grid updates have the same object-content support. -/
theorem fullCall_cfgGrid_w (p : Host.Ts.Sim.Full.FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (hsym : symOf name = some .cfgGrid) :
    AllX (Result (FirstHandle args) (fun _ => False) (Host.Ts.Sim.Full.mlxOf p) Host.Ts.Sim.Full.mlxOf)
      (Host.Ts.Sim.Full.FF.call p name args) := by
  apply fullCall_w p name args hm hp (call_cfgGrid_w _ name args hsym)
  unfold SymShape.symShapeCall
  rw [hsym]
  exact result_stuck

end Host.Mlx.Ffi.Footprint
