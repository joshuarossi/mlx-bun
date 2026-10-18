import host.load.run.full.cached.First
import host.load.run.full.cached.Forward2
import host.load.run.full.cached.Forward3
import host.load.run.full.cached.Forward4
import host.load.run.full.cached.Forward5
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

/-- All five actual forward graphs compute one fixed checkpoint recurrence,
including its 64 cache values at every source snapshot. -/
theorem terminal_all_five (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)) :
    ForwardResult M K env table leaves typed parameters 1 (by decide) firstChoice.cache 17776 ∧
    ForwardResult M K env table leaves typed parameters 2 (by decide) after2.cache 20157 ∧
    ForwardResult M K env table leaves typed parameters 3 (by decide) after3.cache 22538 ∧
    ForwardResult M K env table leaves typed parameters 4 (by decide) after4.cache 24919 ∧
    ForwardResult M K env table leaves typed parameters 5 (by decide) after5.cache 27300 := by
  have one : ForwardResult M K env table leaves typed parameters 1 (by decide) firstChoice.cache 17776 :=
    terminal_first_step M K env table leaves typed parameters
  have two := terminal_forward2 M K env table leaves typed parameters one
  have three := terminal_forward3 M K env table leaves typed parameters two
  have four := terminal_forward4 M K env table leaves typed parameters three
  have five := terminal_forward5 M K env table leaves typed parameters four
  exact ⟨one,two,three,four,five⟩

theorem all_carrier_frontiers :
    firstCarriers.all (fun n => decide (n < 17777)) = true ∧
    carriers2.all (fun n => decide (n < 20158)) = true ∧
    carriers3.all (fun n => decide (n < 22539)) = true ∧
    carriers4.all (fun n => decide (n < 24920)) = true ∧
    carriers5.all (fun n => decide (n < 27301)) = true :=
  ⟨carriers1_before_next_forward,carriers2_before_next_forward,carriers3_before_next_forward,
    carriers4_before_next_forward,carriers5_before_next_forward⟩
end Host.Load.Run.Full.Cached
