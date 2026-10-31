import host.sim.footprint.Full

namespace Host.Mlx.Ffi.Footprint
open Host.Ts FullKeep

/-- A decoded first output slot, including null. Object APIs inspect the object table
before deciding whether to allocate; this support is valid even for malformed states. -/
def OutSlot (args : List Arg) (h : Nat) : Prop :=
  ∃ o rest b off, args = o :: rest ∧ slotOf o = some (b, off, h)

theorem outSlot_cons {o : Arg} {rest : List Arg} {b off h : Nat}
    (he : slotOf o = some (b, off, h)) : OutSlot (o :: rest) h :=
  ⟨o, rest, b, off, rfl, he⟩

theorem kernelApply_w {H I : Nat → Prop} {s₀ s : St} (w : Writes H I s₀ s)
    (o k inv cfg : Arg) (hs : ∀ b off slot, slotOf o = some (b, off, slot) → H slot) :
    AllX (Result H I s₀ id) (kernelApply s o k inv cfg) := by
  unfold kernelApply
  split
  · exact result_okW ((w.outs _ _ _ _ _ _).setVec _ _ (hs _ _ _ (by assumption)))
  · exact result_stuck

theorem call_kernelApply_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .kernelApply) :
    AllX (Result (OutSlot args) (fun _ => False) s id) (call s name args) := by
  unfold call
  rw [hsym]
  dsimp only
  repeat' (first
    | (allx_goal; reduce_call)
    | (allx_goal; case_call)
    | with_reducible refine kernelApply_w (Writes.refl _) _ _ _ _ ?_
    | (intro b off h he; exact outSlot_cons he)
    | with_reducible exact result_stuck)

theorem fullCall_kernelApply_w (p : Host.Ts.Sim.Full.FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (hsym : symOf name = some .kernelApply) :
    AllX (Result (OutSlot args) (fun _ => False) (Host.Ts.Sim.Full.mlxOf p) Host.Ts.Sim.Full.mlxOf)
      (Host.Ts.Sim.Full.FF.call p name args) := by
  apply fullCall_w p name args hm hp (call_kernelApply_w _ name args hsym)
  unfold SymShape.symShapeCall
  rw [hsym]
  exact result_stuck

/-- Allocation and release of the Metal kernel and its configuration. Releases
are recorded by the full world's observer and do not erase native contents. -/
def MetalLifeSym : Sym → Bool
  | .kernelNew | .kernelFree | .cfgNew | .cfgFree => true
  | _ => false

macro "metal_life_w" : tactic => `(tactic|
  (unfold call
   rw [show symOf _ = some _ from by assumption]
   dsimp only
   repeat' (first
     | (allx_goal; reduce_call)
     | (allx_goal; case_call)
     | with_reducible exact result_stuck
     | with_reducible refine result_ok ?_
     | with_reducible exact Writes.refl _
     | with_reducible refine Writes.newObj ?_ _
     | split)))

theorem call_kernelNew_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .kernelNew) :
    AllX (Result (fun _ => False) (fun _ => False) s id) (call s name args) := by metal_life_w
theorem call_kernelFree_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .kernelFree) :
    AllX (Result (fun _ => False) (fun _ => False) s id) (call s name args) := by metal_life_w
theorem call_cfgNew_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .cfgNew) :
    AllX (Result (fun _ => False) (fun _ => False) s id) (call s name args) := by metal_life_w
theorem call_cfgFree_w (s : St) (name : Name) (args : List Arg) (hsym : symOf name = some .cfgFree) :
    AllX (Result (fun _ => False) (fun _ => False) s id) (call s name args) := by metal_life_w

theorem call_metalLife_w (s : St) (name : Name) (args : List Arg)
    (ha : (symOf name).any MetalLifeSym = true) :
    AllX (Result (fun _ => False) (fun _ => False) s id) (call s name args) := by
  cases hn : symOf name with
  | none => simp only [hn, Option.any] at ha; contradiction
  | some x =>
    rw [hn] at ha
    cases x <;> simp only [Option.any, MetalLifeSym] at ha <;> try contradiction
    all_goals first
      | exact call_kernelNew_w s name args hn
      | exact call_kernelFree_w s name args hn
      | exact call_cfgNew_w s name args hn
      | exact call_cfgFree_w s name args hn

theorem fullCall_metalLife_w (p : Host.Ts.Sim.Full.FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any MetalLifeSym = true) :
    AllX (Result (fun _ => False) (fun _ => False) (Host.Ts.Sim.Full.mlxOf p) Host.Ts.Sim.Full.mlxOf)
      (Host.Ts.Sim.Full.FF.call p name args) := by
  apply fullCall_w p name args hm hp (call_metalLife_w _ name args ha)
  cases hn : symOf name with
  | none => simp only [hn, Option.any] at ha; contradiction
  | some x =>
    rw [hn] at ha
    cases x <;> simp only [Option.any, MetalLifeSym] at ha <;> try contradiction
    all_goals unfold SymShape.symShapeCall; rw [hn]; exact result_stuck

end Host.Mlx.Ffi.Footprint
