import host.sim.footprint.Compiled

namespace Host.Mlx.Ffi.Footprint
open Host.Ts FullKeep Host.Load.Layers Host.Ts.Sim.BufSim

theorem aneBack_w {H I : Nat → Prop} {s₀ s : St} (b : FfiAne.St) (a : Arg)
    (hc : AllX (Result H I s₀ id) (back s a)) :
    AllX (fun o => ∀ m b' r ws, o = some (m, b', r, ws) → Writes H I s₀ m)
      (FfiAne.back b s a) := by
  unfold FfiAne.back
  refine AllX.bind (Host.Load.LayerLift.ffiBack_l _ _) hc fun o ho => ?_
  rcases o with _ | ⟨m, r, ws⟩
  · exact AllX.pure fun _ _ _ _ e => by cases e
  · refine AllX.pure fun m' b' r' ws' e => ?_
    cases hb : b.active
    · rw [hb, Bool.cond_false] at e; cases e; exact ho _ _ _ rfl
    · rw [hb, Bool.cond_true] at e
      cases ha : FfiAne.classify b m (m.nnext - s.nnext) s.nnext with
      | none => rw [ha] at e; cases e
      | some b'' => rw [ha] at e; cases e; exact ho _ _ _ rfl

theorem observerBack_w {F : Ffi} (O : Observer F) (hF : FfiLawful F)
    {H I : Nat → Prop} {s : St} (f : F.S → St) (p : F.S × O.E) (a : Arg)
    (hc : AllX (Result H I s f) (F.back p.1 a)) :
    AllX (Result H I s fun q => f q.1) (O.ffi.back p a) := by
  change AllX _ (Observer.back O p a)
  unfold Observer.back
  refine AllX.bind (hF.back _ _) hc fun o ho => AllX.pure ?_
  intro t r ws he
  exact ho t.1 r ws ((Observer.post_some O).mp he).1

/-- The actual continuation footprint through bridge classification and both
observers, including an active Neural Engine bridge. -/
theorem fullBack_w {H I : Nat → Prop} (p : Host.Ts.Sim.Full.FF.S) (a : Arg)
    (hc : AllX (Result H I (Host.Ts.Sim.Full.mlxOf p) id) (back (Host.Ts.Sim.Full.mlxOf p) a)) :
    AllX (Result H I (Host.Ts.Sim.Full.mlxOf p) Host.Ts.Sim.Full.mlxOf)
      (Host.Ts.Sim.Full.FF.back p a) := by
  have hane : AllX (Result H I (Host.Ts.Sim.Full.mlxOf p) fun q : Host.Load.Ane.ASt => q.base.mlx)
      (Host.Load.Ane.back p.1.1 a) := by
    unfold Host.Load.Ane.back
    refine AllX.bind (Host.Load.LayerLift.aneBack_l _ _ _) (aneBack_w _ a hc) fun o ho => ?_
    rcases o with _ | ⟨m, b, r, ws⟩
    · exact result_none
    · exact result_some (ho _ _ _ _ rfl)
  exact observerBack_w kern.total (Host.Load.LayerLift.Observer.lawful live.total Host.Load.LayerLift.symLawful) _ p a
    (observerBack_w live.total Host.Load.LayerLift.symLawful _ p.1 a hane)

theorem fullBack_pending_w (p : Host.Ts.Sim.Full.FF.S) (a : Arg) :
    AllX (Result (PendingWrite (Host.Ts.Sim.Full.mlxOf p)) (fun _ => False)
      (Host.Ts.Sim.Full.mlxOf p) Host.Ts.Sim.Full.mlxOf) (Host.Ts.Sim.Full.FF.back p a) :=
  fullBack_w p a (back_w _ a)

end Host.Mlx.Ffi.Footprint
