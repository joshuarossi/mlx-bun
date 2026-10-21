import host.simgraph.iter.ShortGF
import host.simgraph.iter.ShortCaches
import host.simgraph.iter.FinalC
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Full.Cached
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tail
open Inference.Models.Qwen

/-! # The short budgets' final goal

`GFC` at the halts of the budgets `T = 1, 2`: `short1_gf`/`short2_gf` and the last
forward's result moved to the caches the program's `cache` binding extracts to. -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The final goal of the one-token budget.** -/
theorem short1_gfc (ρ : Nat → F64) (tk : Nat → Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hρ1 : ρ 1 = F64.ofNat (tk 1)) :
    GFC M K env leaves typed parameters 1 (Short1.S4.tab.map (SymE.eval ρ)) Short1.s4 := by
  let tab := Short1.S4.tab.map (SymE.eval ρ)
  obtain ⟨one, -, -, -, -⟩ := terminal_all_five M K env tab leaves typed (hpOf M K env leaves typed parameters tab)
  have f1 := forward_shrink M K env leaves typed _ _ (nodes_of_check _ _ short1_nodes_check)
    (kernels_of_check _ short1_kernels_check) tab _ _ _ _ _ one (by decide) short1_below1
  exact ⟨short1_gf M K env leaves typed parameters ρ tk htk hρ1, fun _ =>
    ⟨short1Caches, _, short1_caches, forwardAt_congr M K env leaves typed f1 short1_cacheNodes.symm⟩⟩

/-- **The final goal of the two-token budget.** -/
theorem short2_gfc (ρ : Nat → F64) (tk : Nat → Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hρ1 : ρ 1 = F64.ofNat (tk 1)) (hρ2 : ρ 2 = F64.ofNat (tk 2)) :
    GFC M K env leaves typed parameters 2 (Short2.S2.tab.map (SymE.eval ρ)) Short2.s2 := by
  let tab := Short2.S2.tab.map (SymE.eval ρ)
  obtain ⟨-, two, -, -, -⟩ := terminal_all_five M K env tab leaves typed (hpOf M K env leaves typed parameters tab)
  have f2 := forward_shrink M K env leaves typed _ _ (nodes_of_check _ _ short2_nodes_check)
    (kernels_of_check _ short2_kernels_check) tab _ _ _ _ _ two (by decide) short2_below2
  exact ⟨short2_gf M K env leaves typed parameters ρ tk htk hρ1 hρ2, fun _ =>
    ⟨short2Caches, _, short2_caches, forwardAt_congr M K env leaves typed f2 short2_cacheNodes.symm⟩⟩

end Host.Mlx.SimGraph.Iter
