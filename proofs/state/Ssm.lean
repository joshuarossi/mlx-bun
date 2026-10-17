import kernels.delta.Convolution
import kernels.delta.Inputs
import layers.DeltaHeads

namespace Inference.State.Ssm
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

-- One batch row of SSMCache.#recur, without speculative rollback or padding.
-- Time is unbounded here; each finite prefix is handled by the recurrence
-- theorem. Other batch rows are independent by Delta.Layout's address proof.
structure ConvData (α : Type) where
  history : Fin 3 → Fin 10240 → α
  input : Nat → Fin 10240 → α
  weight : Fin 10240 → Fin 4 → α

structure GateData (α : Type) where
  aLog : Fin 48 → α
  dtBias : Fin 48 → α
  a : Nat → Fin 48 → α
  b : Nat → Fin 48 → α

structure Platform where
  convolutionContracted : Bool
  heads : SiluRmsHeads.Platform
  gates : Inputs.Platform
  reduce : (Fin 32 → Float32) → Float32
  reduction : FlushedReduction.SimdContract reduce
  flags : Gated.Contraction

structure Parameters where
  qScale : Fin 128 → BF
  kScale : Fin 128 → BF
  width : Float32
  eps : Float32

def window (x : ConvData α) (t : Nat) (c : Fin 10240) : Fin 4 → α :=
  Convolution.window (fun i => x.history i c) (fun s => x.input s c) t

def convolved (p : Platform) (x : ConvData BF) (t : Nat) (c : Fin 10240) : BF :=
  Convolution.value p.convolutionContracted (window x t c) (x.weight c)

noncomputable def targetConv (x : ConvData ℝ) (t : Nat) (c : Fin 10240) : ℝ :=
  ∑ i, window x t c i * x.weight c i

noncomputable def convBudget (p : Platform) (x : ConvData BF) (y error : ConvData ℝ) (t : Nat) (c : Fin 10240) : ℝ :=
  Convolution.budget p.convolutionContracted (window x t c) (x.weight c)
    (window y t c) (y.weight c) (window error t c) (error.weight c)

structure ConvError (x : ConvData BF) (y error : ConvData ℝ) : Prop where
  history : ∀ i c, |Model.toReal (x.history i c) - y.history i c| ≤ error.history i c
  input : ∀ t c, |Model.toReal (x.input t c) - y.input t c| ≤ error.input t c
  weight : ∀ c i, |Model.toReal (x.weight c i) - y.weight c i| ≤ error.weight c i

structure ConvFinite (p : Platform) (x : ConvData BF) : Prop where
  history : ∀ i c, Model.isFinite (x.history i c) = true
  input : ∀ t c, Model.isFinite (x.input t c) = true
  weight : ∀ c i, Model.isFinite (x.weight c i) = true
  arithmetic : ∀ t c, Arithmetic.Finite
    (Convolution.bind (fun i => BFloat16.widen (window x t c i)) (fun i => BFloat16.widen (x.weight c i)))
    (Convolution.expression p.convolutionContracted)
  cast : ∀ t c, Model.isFinite (convolved p x t c) = true

theorem convolved_error (p : Platform) (x : ConvData BF) (y error : ConvData ℝ)
    (hf : ConvFinite p x) (he : ConvError x y error) (t : Nat) (c : Fin 10240) :
    |Model.toReal (convolved p x t c) - targetConv y t c| ≤ convBudget p x y error t c := by
  apply Convolution.value_error
  · exact Convolution.window_finite _ _ (fun i => hf.history i c) (fun s => hf.input s c) t
  · exact hf.weight c
  · exact Convolution.window_error _ _ _ _ _ _ (fun i => he.history i c) (fun s => he.input s c) t
  · exact he.weight c
  · exact hf.arithmetic t c
  · exact hf.cast t c

def heads (p : Platform) (params : Parameters) (x : ConvData BF) (t : Nat) : Layers.DeltaHeads.Output 1 BF :=
  Layers.DeltaHeads.forward p.heads (fun _ => convolved p x t) params.qScale params.kScale params.width params.eps

noncomputable def targetHeads (params : Parameters) (eps : ℝ) (y : ConvData ℝ) (t : Nat) : Layers.DeltaHeads.Output 1 ℝ :=
  Layers.DeltaHeads.target (fun _ => targetConv y t) params.qScale params.kScale eps

noncomputable def headBudget (p : Platform) (params : Parameters) (eps epsError : ℝ)
    (x : ConvData BF) (y error : ConvData ℝ) (t : Nat) : Layers.DeltaHeads.Output 1 ℝ :=
  Layers.DeltaHeads.bounds p.heads (fun _ => convolved p x t) params.qScale params.kScale params.width params.eps
    eps epsError (fun _ => targetConv y t) (fun _ => convBudget p x y error t)

def HeadFinite (p : Platform) (params : Parameters) (x : ConvData BF) (t : Nat) : Prop :=
  Layers.DeltaHeads.Finite p.heads (fun _ : Fin 1 => convolved p x t) params.qScale params.kScale params.width params.eps

theorem heads_error (p : Platform) (params : Parameters) (eps epsError : ℝ)
    (hp : 0 < eps) (hee : |real params.eps - eps| ≤ epsError)
    (x : ConvData BF) (y error : ConvData ℝ) (hf : ConvFinite p x) (he : ConvError x y error)
    (t : Nat) (hh : HeadFinite p params x t) :
    Layers.DeltaHeads.Error (heads p params x t) (targetHeads params eps y t)
      (headBudget p params eps epsError x y error t) :=
  Layers.DeltaHeads.forward_error p.heads _ params.qScale params.kScale params.width params.eps eps epsError
    hp hee hh _ _ (fun _ c => convolved_error p x y error hf he t c)

-- The kernel repeats each Q/K head three times across value heads. A state
-- row belongs to one value coordinate and retains all 128 key coordinates.
def projected (h : Layers.DeltaHeads.Output 1 α) (g : GateData α) (t : Nat)
    (head : Fin 48) (value : Fin 128) : Inputs.Projected α where
  key := h.k 0 (Layout.keyHead head)
  query := h.q 0 (Layout.keyHead head)
  value := h.v 0 head value
  aLog := g.aLog head
  dtBias := g.dtBias head
  a := g.a t head
  b := g.b t head

structure GateError (g : GateData BF) (y error : GateData ℝ) : Prop where
  aLog : ∀ h, |Model.toReal (g.aLog h) - y.aLog h| ≤ error.aLog h
  dtBias : ∀ h, |Model.toReal (g.dtBias h) - y.dtBias h| ≤ error.dtBias h
  a : ∀ t h, |Model.toReal (g.a t h) - y.a t h| ≤ error.a t h
  b : ∀ t h, |Model.toReal (g.b t h) - y.b t h| ≤ error.b t h

structure GateFinite (p : Platform) (g : GateData BF) (t : Nat) : Prop where
  aLog : ∀ h, Model.isFinite (g.aLog h) = true
  b : ∀ h, Model.isFinite (g.b t h) = true
  decay : ∀ h, Decay.Finite p.gates.decay (BFloat16.widen (g.aLog h)) (g.a t h) (g.dtBias h)
  beta : ∀ h, Gates.BetaValid p.gates.expAbs (g.b t h)

theorem projected_error (h : Layers.DeltaHeads.Output 1 BF) (y error : Layers.DeltaHeads.Output 1 ℝ)
    (he : Layers.DeltaHeads.Error h y error) (g : GateData BF) (yg eg : GateData ℝ) (hg : GateError g yg eg)
    (t : Nat) (head : Fin 48) (value : Fin 128) :
    Inputs.ProjectionError (projected h g t head value) (projected y yg t head value) (projected error eg t head value) := by
  constructor
  · exact he.k 0 (Layout.keyHead head)
  · exact he.q 0 (Layout.keyHead head)
  · exact he.v 0 head value
  · exact hg.aLog head
  · exact hg.a t head
  · exact hg.dtBias head
  · exact hg.b t head

theorem projected_finite (p : Platform) (params : Parameters) (x : ConvData BF) (g : GateData BF)
    (t : Nat) (hh : HeadFinite p params x t) (hg : GateFinite p g t) (head : Fin 48) (value : Fin 128) :
    Inputs.Finite p.gates (projected (heads p params x t) g t head value) := by
  constructor
  · exact SiluRmsHeads.normalized_finite p.heads _ params.kScale params.width params.eps (hh.kNorm 0 (Layout.keyHead head))
  · exact SiluRmsHeads.normalized_finite p.heads _ params.qScale params.width params.eps (hh.qNorm 0 (Layout.keyHead head))
  · exact SiluRmsHeads.activate_finite p.heads _ (hh.activation 0 (Layers.DeltaHeads.vHead head) value)
  · exact hg.aLog head
  · exact hg.b head
  · exact hg.decay head
  · exact hg.beta head

def inputs (p : Platform) (params : Parameters) (x : ConvData BF) (g : GateData BF)
    (head : Fin 48) (value : Fin 128) (t : Nat) : Recurrence.Inputs Float32 :=
  Inputs.actual p.gates (projected (heads p params x t) g t head value)

noncomputable def targets (params : Parameters) (eps : ℝ) (y : ConvData ℝ) (g : GateData ℝ)
    (head : Fin 48) (value : Fin 128) (t : Nat) : Recurrence.Inputs ℝ :=
  Inputs.target (projected (targetHeads params eps y t) g t head value)

noncomputable def inputBudget (p : Platform) (params : Parameters) (eps epsError : ℝ)
    (x : ConvData BF) (y error : ConvData ℝ) (g : GateData BF) (yg eg : GateData ℝ)
    (head : Fin 48) (value : Fin 128) (t : Nat) : Recurrence.Inputs ℝ :=
  Inputs.bounds p.gates (projected (heads p params x t) g t head value)
    (projected (targetHeads params eps y t) yg t head value)
    (projected (headBudget p params eps epsError x y error t) eg t head value)

theorem inputs_error (p : Platform) (params : Parameters) (eps epsError : ℝ)
    (hp : 0 < eps) (hee : |real params.eps - eps| ≤ epsError)
    (x : ConvData BF) (y error : ConvData ℝ) (g : GateData BF) (yg eg : GateData ℝ)
    (hf : ConvFinite p x) (he : ConvError x y error) (hge : GateError g yg eg)
    (t : Nat) (hh : HeadFinite p params x t) (hg : GateFinite p g t) (head : Fin 48) (value : Fin 128) :
    Recurrence.InputError (inputs p params x g head value t) (targets params eps y yg head value t)
      (inputBudget p params eps epsError x y error g yg eg head value t) :=
  Inputs.input_error p.gates _ _ _ (projected_finite p params x g t hh hg head value)
    (projected_error _ _ _ (heads_error p params eps epsError hp hee x y error hf he t hh) g yg eg hge t head value)

-- Composition through arbitrary sequence length: neither convolution, head,
-- nor whole-gate numerical accuracy is an assumption of this theorem.
theorem state_error (p : Platform) (params : Parameters) (eps epsError : ℝ)
    (hp : 0 < eps) (hee : |real params.eps - eps| ≤ epsError)
    (x : ConvData BF) (y error : ConvData ℝ) (g : GateData BF) (yg eg : GateData ℝ)
    (hf : ConvFinite p x) (he : ConvError x y error) (hge : GateError g yg eg)
    (head : Fin 48) (value : Fin 128) (initial : Fin 128 → Float32) (targetInitial initialError : Fin 128 → ℝ)
    (hi : ∀ i, |real (initial i) - targetInitial i| ≤ initialError i) (steps : Nat)
    (hh : ∀ t, t < steps → HeadFinite p params x t) (hg : ∀ t, t < steps → GateFinite p g t)
    (hr : ∀ t, t < steps → ∀ i : Fin 128, Arithmetic.Finite
      (Recurrence.bind (Recurrence.run p.reduce p.flags (inputs p params x g head value) initial t) (inputs p params x g head value t))
      (Gated.stateExpr p.flags p.reduction.tree i)) (i : Fin 128) :
    |real (Recurrence.run p.reduce p.flags (inputs p params x g head value) initial steps i) -
      Recurrence.targetRun (targets params eps y yg head value) targetInitial steps i| ≤
      Recurrence.errorRun p.reduce p.reduction.tree p.flags (inputs p params x g head value) initial
        (targets params eps y yg head value) (inputBudget p params eps epsError x y error g yg eg head value)
        targetInitial initialError steps i :=
  Recurrence.run_error p.reduce p.reduction p.flags _ initial _ _ targetInitial initialError hi steps hr
    (fun t ht => inputs_error p params eps epsError hp hee x y error g yg eg hf he hge t (hh t ht) (hg t ht) head value) i

theorem output_error (p : Platform) (params : Parameters) (eps epsError : ℝ)
    (hp : 0 < eps) (hee : |real params.eps - eps| ≤ epsError)
    (x : ConvData BF) (y error : ConvData ℝ) (g : GateData BF) (yg eg : GateData ℝ)
    (hf : ConvFinite p x) (he : ConvError x y error) (hge : GateError g yg eg)
    (head : Fin 48) (value : Fin 128) (initial : Fin 128 → Float32) (targetInitial initialError : Fin 128 → ℝ)
    (hi : ∀ i, |real (initial i) - targetInitial i| ≤ initialError i) (time : Nat)
    (hh : ∀ t, t ≤ time → HeadFinite p params x t) (hg : ∀ t, t ≤ time → GateFinite p g t)
    (hr : ∀ t, t < time → ∀ i : Fin 128, Arithmetic.Finite
      (Recurrence.bind (Recurrence.run p.reduce p.flags (inputs p params x g head value) initial t) (inputs p params x g head value t))
      (Gated.stateExpr p.flags p.reduction.tree i))
    (ho : Arithmetic.Finite
      (Recurrence.bind (Recurrence.run p.reduce p.flags (inputs p params x g head value) initial time) (inputs p params x g head value time))
      (Gated.outputExpr p.flags p.reduction.tree))
    (hb : Model.isFinite (Recurrence.outputAt p.reduce p.flags (inputs p params x g head value) initial time) = true) :
    |Model.toReal (Recurrence.outputAt p.reduce p.flags (inputs p params x g head value) initial time) -
      Recurrence.targetOutputAt (targets params eps y yg head value) targetInitial time| ≤
      Recurrence.outputBudget p.reduce p.reduction.tree p.flags (inputs p params x g head value) initial
        (targets params eps y yg head value) (inputBudget p params eps epsError x y error g yg eg head value)
        targetInitial initialError time :=
  Recurrence.output_error p.reduce p.reduction p.flags _ initial _ _ targetInitial initialError hi time hr
    (fun t ht => inputs_error p params eps epsError hp hee x y error g yg eg hf he hge t (hh t ht) (hg t ht) head value) ho hb

end Inference.State.Ssm
