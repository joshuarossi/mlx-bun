import host.sim.footprint.Kernel

namespace Host.Mlx.Ffi.Footprint
open Host.Ts FullKeep

/-- A replay computation returning a state plus bookkeeping. -/
def ReplayResult {α : Type} (H I : Nat → Prop) (s : St) (o : Option (St × α)) : Prop :=
  ∀ t a, o = some (t, a) → Writes H I s t

theorem replay_none {α : Type} {H I : Nat → Prop} {s : St} :
    AllX (ReplayResult (α := α) H I s) (M.pure none) :=
  AllX.pure fun _ _ e => by cases e

theorem replay_some {α : Type} {H I : Nat → Prop} {s t : St} {a : α}
    (w : Writes H I s t) : AllX (ReplayResult H I s) (M.pure (some (t, a))) :=
  AllX.pure fun _ _ e => by cases e; exact w

theorem replayOrder_w {H I : Nat → Prop} {s₀ : St} (cls : Nat) :
    ∀ (s : St) (m : List (Nat × Nat)) (ns : List Nat), Writes H I s₀ s →
      AllX (ReplayResult H I s₀) (replayOrder s cls m ns)
  | _, _, [], w => replay_some w
  | s, m, n :: ns, w => by
    unfold replayOrder
    repeat' (first
      | with_reducible refine replayOrder_w cls _ _ ns ?_
      | with_reducible refine AllX.bind' (Host.Ts.Sim.NativeLawful.infer_l _ _) fun _ => ?_
      | with_reducible exact replay_none
      | with_reducible exact w
      | with_reducible refine Writes.addNode ?_ _
      | with_reducible refine AllX.cond _ ?_ ?_
      | split)

theorem replay_w {H I : Nat → Prop} {s₀ s : St} (w : Writes H I s₀ s)
    (cls : Nat) (t : Trace) (xs : List Nat) :
    AllX (ReplayResult H I s₀) (replay s cls t xs) := by
  unfold replay
  refine AllX.bind (Host.Ts.Sim.NativeLawful.replayOrder_l _ _ _ _) (replayOrder_w cls s _ _ w) fun r hr => ?_
  rcases r with _ | ⟨s', m'⟩
  · exact replay_none
  · exact replay_some (hr _ _ rfl)

theorem applyDone_w {H I : Nat → Prop} {s₀ s : St} (w : Writes H I s₀ s)
    (cls b off slot : Nat) (t : Trace) (xs : List Nat) (hslot : H slot) :
    AllX (Result H I s₀ id) (applyDone s cls b off slot t xs) := by
  unfold applyDone
  refine AllX.bind (Host.Ts.Sim.NativeLawful.replay_l _ _ _ _) (replay_w w cls t xs) fun r hr => ?_
  rcases r with _ | ⟨s', outs⟩
  · exact result_stuck
  · exact result_okW ((hr _ _ rfl).setVec slot outs hslot)

/-- Tracing creates fresh nodes only. -/
theorem Writes.tracers {H I : Nat → Prop} {s₀ : St} :
    ∀ (s : St) (i : Nat) (sh : List (List Dim × Nat)), Writes H I s₀ s →
      Writes H I s₀ (closureApply.tracers s i sh).1
  | _, _, [], w => w
  | s, i, (shape, dt) :: rest, w => Writes.tracers _ (i + 1) rest (w.addNode ⟨.tracer i, [], shape, dt⟩)

/-- Reserving a pending trace id changes no heap contents. -/
theorem Writes.pending {H I : Nat → Prop} {s₀ s : St} (w : Writes H I s₀ s)
    (ps : List Pending) : Writes H I s₀ { s with pending := ps } :=
  w.trans ⟨Nat.le_refl _, Nat.le_refl _, fun _ _ _ => rfl, fun _ _ _ => rfl,
    fun _ _ => rfl, fun _ _ => rfl⟩

theorem Writes.reserve {H I : Nat → Prop} {s₀ s : St} (w : Writes H I s₀ s)
    (ps : List Pending) : Writes H I s₀ { s with next := s.next + 1, pending := ps } :=
  w.trans ⟨Nat.le_succ _, Nat.le_refl _, fun _ _ _ => rfl, fun _ _ _ => rfl,
    fun _ _ => rfl, fun _ _ => rfl⟩

theorem closureApply_w {H I : Nat → Prop} {s₀ s : St} (w : Writes H I s₀ s)
    (o c v : Arg) (hs : ∀ b off slot, slotOf o = some (b, off, slot) → H slot) :
    AllX (Result H I s₀ id) (closureApply s o c v) := by
  unfold closureApply
  repeat' (first
    | with_reducible refine AllX.bind' (Host.Ts.Sim.NativeLawful.findTrace_l _ _ _ _) fun _ => ?_
    | with_reducible refine applyDone_w w _ _ _ _ _ _ (hs _ _ _ (by assumption))
    | with_reducible exact result_stuck
    | with_reducible refine result_ok ?_
    | with_reducible refine Writes.reserve ?_ _
    | with_reducible refine Writes.newObj ?_ _
    | with_reducible refine Writes.tracers _ _ _ w
    | split)

theorem call_closureApply_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .closureApply) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by
  unfold call
  rw [hsym]
  dsimp only
  repeat' (first
    | (allx_goal; reduce_call)
    | (allx_goal; case_call)
    | with_reducible refine closureApply_w (Writes.refl _) _ _ _ ?_
    | (intro b off h he; exact outSlot_cons he)
    | with_reducible exact result_stuck)

theorem fullCall_closureApply_w (p : Host.Ts.Sim.Full.FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (hsym : symOf name = some .closureApply) :
    AllX (Result (OutSlot args) (fun _ => False) (Host.Ts.Sim.Full.mlxOf p) Host.Ts.Sim.Full.mlxOf)
      (Host.Ts.Sim.Full.FF.call p name args) := by
  apply fullCall_w p name args hm hp (call_closureApply_w _ name args hsym)
  unfold SymShape.symShapeCall
  rw [hsym]
  exact result_stuck

end Host.Mlx.Ffi.Footprint
