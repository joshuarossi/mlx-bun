import host.simgraph.iter.BaseGx
import host.sim.template.base.Rel
import host.load.run.tail.Concrete
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tpl Host.Load.Run.Tail

/-! Facts of the template start `Base.s0` used by every case's graph step, and the base of
the loop's graph invariant at the boot tail's cut `P.ta3272 τ`. -/

kernel_rfl base_s0_read : (Base.s0.ffi : LSt).mlx.items.get 20157 = none
kernel_rfl base_s0_fed : (Base.s0.ffi : LSt).mlx.items.get 22538 = none
kernel_rfl base_s0_pread : ((Base.s0.ffi : LSt).mlx.nodes.get 20157).isSome = true
kernel_rfl base_s0_pfed : ((Base.s0.ffi : LSt).mlx.nodes.get 22538).isSome = true
kernel_rfl base_s0_tok : (Base.s0.ffi : LSt).mlx.tokens = [.ref 79]
kernel_rfl base_h79 : nth? Base.S0.tab 79 = some (.var 14)

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Host.Mlx.FfiEval.Env Host.Mlx.FfiEval.InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : Inference.Models.Qwen.TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The base of the loop's graph invariant** at the cut with unread suffix `τ`. -/
theorem base_gx (τ : List NumV) (ρ : Nat → F64) (tk : Nat → Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hρ1 : ρ 1 = F64.ofNat (tk 1)) :
    Gx M K env leaves typed parameters tplInputs 1 Base.M (P.ta3272 τ) (Base.COf ρ) :=
  gx_base M K env leaves typed parameters Base.M (fun _ => rfl) (P.ta3272 τ)
    (by rw [ta3272_eq]; rfl) (by rw [ta3272_eq]; rfl) (by rw [ta3272_eq]; rfl) (by rw [ta3272_eq]; rfl) ρ tk htk hρ1

end Host.Mlx.SimGraph.Iter
