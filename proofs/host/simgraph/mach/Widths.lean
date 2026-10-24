import host.load.run.full.Parameters
import host.simgraph.mach.PreEnv
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx Host.Mlx.GlueStep Host.Load.Run.Full

/-! # The loaded stages' MLP widths are the route's

The loaded weights' quantization widths are the checkpoint's parameter choice (`weights`, from
`load_parameters`), not tensor contents: at any tensor values they are those at the blank values, where every
layer's gate and up widths are a route pair (`GateUpRoute`, by evaluation). With the weights' types (`PipeTy`),
every loaded stage is a prefill stage (`stageW_loaded`). -/

/-- A tensor-value table of empty tensors. -/
def blankValues : Host.Load.Extract.TensorValues := fun _ => ⟨.uint8, [], fun _ => 0⟩

theorem blank_delta : ∀ i : Fin 48,
    GateUpRoute ((weights blankValues).delta i).mlp.gateBits ((weights blankValues).delta i).mlp.upBits := by
  unfold GateUpRoute; decide

theorem blank_attn : ∀ i : Fin 16,
    GateUpRoute ((weights blankValues).attention i).mlp.gateBits ((weights blankValues).attention i).mlp.upBits := by
  unfold GateUpRoute; decide

theorem delta_bits (value : Host.Load.Extract.TensorValues) : ∀ i : Fin 48,
    ((weights value).delta i).mlp.gateBits = ((weights blankValues).delta i).mlp.gateBits ∧
      ((weights value).delta i).mlp.upBits = ((weights blankValues).delta i).mlp.upBits := by
  intro i; fin_cases i <;> exact ⟨rfl, rfl⟩

theorem attn_bits (value : Host.Load.Extract.TensorValues) : ∀ i : Fin 16,
    ((weights value).attention i).mlp.gateBits = ((weights blankValues).attention i).mlp.gateBits ∧
      ((weights value).attention i).mlp.upBits = ((weights blankValues).attention i).mlp.upBits := by
  intro i; fin_cases i <;> exact ⟨rfl, rfl⟩

theorem widths_delta (value : Host.Load.Extract.TensorValues) (i : Fin 48) :
    GateUpRoute ((weights value).delta i).mlp.gateBits ((weights value).delta i).mlp.upBits := by
  rw [(delta_bits value i).1, (delta_bits value i).2]; exact blank_delta i

theorem widths_attn (value : Host.Load.Extract.TensorValues) (i : Fin 16) :
    GateUpRoute ((weights value).attention i).mlp.gateBits ((weights value).attention i).mlp.upBits := by
  rw [(attn_bits value i).1, (attn_bits value i).2]; exact blank_attn i

/-- A stage's MLP gate and up widths. -/
def StageGU : StageWeights → Prop
  | .delta w => GateUpRoute w.mlp.gateBits w.mlp.upBits
  | .attention w => GateUpRoute w.mlp.gateBits w.mlp.upBits

/-- **Every loaded stage is a prefill stage**: typed, its MLP widths a route pair. -/
theorem stageW_loaded (value : Host.Load.Extract.TensorValues) (hpw : PipeTy (weights value)) :
    ∀ s ∈ stageWeights (weights value), StageW s := by
  have hgu : ∀ s ∈ stageWeights (weights value), StageGU s := by
    have hd : ∀ i, StageGU (.delta ((weights value).delta i)) := widths_delta value
    have ha : ∀ i, StageGU (.attention ((weights value).attention i)) := widths_attn value
    simp only [stageWeights, List.mem_cons, List.not_mem_nil, or_false, forall_eq_or_imp, forall_eq, hd, ha,
      true_and]
  intro s hs
  cases s with
  | delta d => exact ⟨hpw.stages _ hs, hgu _ hs⟩
  | attention a => exact ⟨hpw.stages _ hs, hgu _ hs⟩

end Host.Mlx.SimGraph.Mach
