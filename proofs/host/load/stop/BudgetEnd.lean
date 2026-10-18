import host.load.run.full.CG893
import host.load.Stop
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

namespace BudgetEnd
def offsets (s : St LSt) (env : Env) : Option (Nat × Nat) := do
  let root ← bindingOf s env chars!"cache"
  let attention ← elemOf s root 3
  let recurrent ← elemOf s root 0
  let a ← (Extract.own s attention chars!"offset").bind Extract.nat
  let r ← (Extract.own s recurrent chars!"offset").bind Extract.nat
  pure (a,r)
end BudgetEnd

/-- Resume the fourth consumer yield, emit the final budgeted token without
another forward pass, and run the real generator's cleanup to normal halt. -/
theorem BudgetEnd.execution :
    runS P.F 1310 P.s3573 P.S3573 = some (P.s3575, P.S3575) :=
  runS_trans P.F (m := 601) (n := 709)
    (s₀ := P.s3573) (s₁ := P.s3574) (s₂ := P.s3575)
    (S₀ := P.S3573) (S₁ := P.S3574) (S₂ := P.S3575) P.c3573 P.c3574

theorem BudgetEnd.completed :
    Stop.summary P.s3575 P.S3575 (entryEnv P.s0) =
      some ⟨[.var 1, .var 2, .var 3, .var 4, .var 5], .lit (F64.ofNat 5), .lit (F64.ofNat 5),
        [.lit (F64.ofNat 1), .lit (F64.ofNat 4), .lit (F64.ofNat 256), .lit (F64.ofNat 256)],
        .lit (F64.ofNat 5), .lit (F64.ofNat 5), true⟩ := by rfl

theorem BudgetEnd.offsets_before : BudgetEnd.offsets P.s3573 (entryEnv P.s0) = some (5,5) := by rfl
theorem BudgetEnd.offsets_after : BudgetEnd.offsets P.s3575 (entryEnv P.s0) = some (5,5) := by rfl

theorem BudgetEnd.nodes_preserved : P.s3575.ffi.mlx.nodes = P.s3573.ffi.mlx.nodes := by rfl

theorem BudgetEnd.normal_halt : ∃ v, P.s3575.ctl = .halt (.normal v) := by
  exact ⟨_, rfl⟩

theorem BudgetEnd.model_preserved :
    bindingOf P.s3575 (entryEnv P.s0) chars!"model" =
      bindingOf P.s3573 (entryEnv P.s0) chars!"model" := by rfl

theorem BudgetEnd.cache_root_preserved :
    bindingOf P.s3575 (entryEnv P.s0) chars!"cache" =
      bindingOf P.s3573 (entryEnv P.s0) chars!"cache" := by rfl

end Host.Load.Run.Full
