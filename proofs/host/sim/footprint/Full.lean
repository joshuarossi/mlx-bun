import host.sim.footprint.ArrayCall
import host.sim.full.Call

namespace Host.Mlx.Ffi.Footprint
open Host.Ts
open FullKeep (AllX)
open Host.Load.Layers
open Host.Ts.Sim.Full (FF mlxOf liftF liftF_some liftF_none full_call_eq)

section
variable {H I : Nat → Prop} {s : St}

/-- Bridge bookkeeping can reject a result but never changes its mlx state. -/
theorem mlxCall_w (b : FfiAne.St) (name : Name) (args : List Arg)
    (hp : nameEq name FfiAne.payloadName = false)
    (hc : AllX (Result H I s id) (call s name args)) :
    AllX (fun o => ∀ m b' r ws, o = some (m, b', r, ws) → Writes H I s m)
      (FfiAne.mlxCall b s name args) := by
  unfold FfiAne.mlxCall
  rw [hp, Bool.cond_false]
  refine AllX.bind (Host.Ts.Sim.NativeLawful.mlx_call_l _ _ _) hc fun o ho => ?_
  rcases o with _ | ⟨m, r, ws⟩
  · exact AllX.pure fun _ _ _ _ e => by cases e
  · refine AllX.pure fun m' b' r' ws' e => ?_
    cases hb : b.active
    · rw [hb, Bool.cond_false] at e; cases e; exact ho _ _ _ rfl
    · rw [hb, Bool.cond_true] at e
      cases ha : FfiAne.after b s m name args with
      | none => rw [ha] at e; cases e
      | some b'' => rw [ha] at e; cases e; exact ho _ _ _ rfl

end

/-- Preservation lifts from the real base and symbolic-shape calls through the active or
inactive bridge and both observers. There is no frozen-state premise. -/
theorem fullCall_w {H I : Nat → Prop} (p : FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (hc : AllX (Result H I (mlxOf p) id) (call (mlxOf p) name args))
    (hs : AllX (Result H I (mlxOf p) id) (SymShape.symShapeCall (mlxOf p) name args)) :
    AllX (Result H I (mlxOf p) mlxOf) (FF.call p name args) := by
  have hane : AllX (Result H I (mlxOf p) fun a : Host.Load.Ane.ASt => a.base.mlx)
      (Host.Load.Ane.call p.1.1 name args) := by
    unfold Host.Load.Ane.call
    rw [hm, Bool.cond_true]
    refine AllX.bind (Host.Load.LayerLift.mlxCall_l _ _ _ _) (mlxCall_w _ name args hp hc) fun o ho => ?_
    rcases o with _ | ⟨m, b, r, ws⟩
    · exact result_none
    · exact result_some (ho _ _ _ _ rfl)
  have hsym : AllX (Result H I (mlxOf p) fun a : Host.Load.Ane.ASt => a.base.mlx)
      (symCall p.1.1 name args) := by
    unfold symCall
    refine AllX.bind (Host.Load.LayerLift.aneLawful.call _ _ _) hane fun o ho => ?_
    rcases o with _ | ⟨a, r, ws⟩
    · have he : (Host.Load.isMlx name && !nameEq name FfiAne.payloadName) = true := by rw [hm, hp]; rfl
      rw [he, Bool.cond_true]
      refine AllX.bind (Host.Load.LayerLift.symShapeCall_l _ _ _) hs fun o ho => ?_
      rcases o with _ | ⟨m, r, ws⟩
      · exact result_none
      · refine AllX.pure fun a' r' ws' e => ?_
        cases hb : p.1.1.bridge.active
        · rw [hb, Bool.cond_false] at e; cases e; exact ho _ _ _ rfl
        · rw [hb, Bool.cond_true] at e
          cases ha : FfiAne.after p.1.1.bridge p.1.1.base.mlx m name args with
          | none => rw [ha] at e; cases e
          | some b => rw [ha] at e; cases e; exact ho _ _ _ rfl
    · exact result_some (ho _ _ _ rfl)
  rw [full_call_eq]
  refine AllX.bind (Host.Load.LayerLift.symLawful.call _ _ _) hsym fun o ho => ?_
  rcases o with _ | ⟨a, r, ws⟩
  · exact AllX.pure fun _ _ _ e => by rw [liftF_none] at e; cases e
  · exact AllX.pure fun _ _ _ e => by rw [liftF_some] at e; cases e; exact ho _ _ _ rfl

/-- Actual full-world array calls, including symbolic reshape/convolution and an active bridge.
The result holds for every successful call; an accepted call is one such call. -/
theorem fullCall_array_w (p : FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any ArraySym = true) :
    AllX (Result (Output args) (fun _ => False) (mlxOf p) mlxOf) (FF.call p name args) :=
  fullCall_w p name args hm hp (call_array_w _ name args ha) (symShapeCall_w _ name args)

end Host.Mlx.Ffi.Footprint
