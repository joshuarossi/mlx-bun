import host.sim.footprint.Replay

namespace Host.Mlx.Ffi.Footprint
open Host.Ts FullKeep

def CompiledSym : Sym → Bool
  | .closureNew | .closureFuncPayload | .closureFree | .compile | .closureApply => true
  | _ => false

macro "compiled_dispatch_w" : tactic => `(tactic|
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
     | with_reducible refine Writes.setObj ?_ _ _ (outSlot_cons (by assumption))
     | split)))

theorem call_closureNew_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .closureNew) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by compiled_dispatch_w
theorem call_closureFuncPayload_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .closureFuncPayload) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by compiled_dispatch_w
theorem call_closureFree_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .closureFree) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by compiled_dispatch_w
theorem call_compile_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .compile) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by compiled_dispatch_w

theorem call_compiled_w (s : St) (name : Name) (args : List Arg)
    (ha : (symOf name).any CompiledSym = true) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by
  cases hn : symOf name with
  | none => simp only [hn, Option.any] at ha; contradiction
  | some x =>
    rw [hn] at ha
    cases x <;> simp only [Option.any, CompiledSym] at ha <;> try contradiction
    all_goals first
      | exact call_closureNew_w s name args hn
      | exact call_closureFuncPayload_w s name args hn
      | exact call_closureFree_w s name args hn
      | exact call_compile_w s name args hn
      | exact call_closureApply_w s name args hn

theorem fullCall_compiled_w (p : Host.Ts.Sim.Full.FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any CompiledSym = true) :
    AllX (Result (OutSlot args) (fun _ => False) (Host.Ts.Sim.Full.mlxOf p) Host.Ts.Sim.Full.mlxOf)
      (Host.Ts.Sim.Full.FF.call p name args) := by
  apply fullCall_w p name args hm hp (call_compiled_w _ name args ha)
  cases hn : symOf name with
  | none => simp only [hn, Option.any] at ha; contradiction
  | some x =>
    rw [hn] at ha
    cases x <;> simp only [Option.any, CompiledSym] at ha <;> try contradiction
    all_goals unfold SymShape.symShapeCall; rw [hn]; exact result_stuck

/-- Returning from a recorded callback updates its closure's trace cache and
the pending call's output vector, with replayed nodes allocated freshly. -/
theorem traceBack_w {H I : Nat → Prop} {s₀ s : St} (w : Writes H I s₀ s) (a : Arg)
    (hs : ∀ p rest, s.pending = p :: rest → H p.cls ∧ H p.outSlot) :
    AllX (Result H I s₀ id) (traceBack s a) := by
  unfold traceBack
  split
  · rename_i p rest he ha
    have hp := hs p rest he
    repeat' (first
      | with_reducible refine applyDone_w ?_ _ _ _ _ _ _ hp.2
      | with_reducible exact result_stuck
      | with_reducible exact (w.setObj _ _ hp.1).pending rest
      | with_reducible refine AllX.cond _ ?_ ?_
      | split)
  · exact result_stuck

/-- The two old handles named by the actual pending continuation. -/
def PendingWrite (s : St) (h : Nat) : Prop :=
  ∃ p rest, s.pending = p :: rest ∧ (h = p.cls ∨ h = p.outSlot)

theorem back_w (s : St) (a : Arg) :
    AllX (Result (PendingWrite s) (fun _ => False) s id) (back s a) := by
  apply traceBack_w (Writes.refl _) a
  intro p rest he
  exact ⟨⟨p, rest, he, Or.inl rfl⟩, ⟨p, rest, he, Or.inr rfl⟩⟩

end Host.Mlx.Ffi.Footprint
