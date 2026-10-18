import host.ts.RenameRuntimeBatch
import host.ts.RenameRuntimeDriverTest
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.RuntimeDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_runtime_begin
host_runtime_step ffi, input using initial to output using next as PackedReference
host_runtime_export PackedReference.runtime_transport as packed_transport

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  for name in [`PackedReference.F,`PackedReference.input,`PackedReference.source_step,`PackedReference.runtime_transport] do
    if env.contains ((← getCurrNamespace) ++ name) then
      throwError "batch helper leaked into the persistent environment: {name}"

/-- Closing the temporary rule declarations as proof-local lets preserves the
actual source-ref/target-literal transport theorem. -/
theorem packed_reference_to_literal :
    ∃ D₀, interpC (step ffi input).run C₀ = some (output,D₀) ∧
      interpC (step ffi target).run C = some (targetOutput,C) ∧
      Parametric.StateR (NumberRoles ν ν D₀ C) (fun _ _ _ => True) identity
        (fun _ => False) (fun _ => False) [] [] [] [] output targetOutput ∧ D₀.tab.length = 3 := by
  obtain ⟨result,D₀,D,sourceRun,targetRun,inst,post,_,_,_⟩ := packed_transport notes ν ν C₀ C identity
    (fun _ _ _ => True) (fun _ => False) (fun _ => False) [] [] [] [] target source_inst related annotated
    (.var 0) (.var 1) (.num (.var 0)) (.num (.var 1)) (.number _) (.number _) [] rfl rfl
  have same := Option.some.inj (targetRun.symm.trans target_step)
  obtain ⟨rfl,rfl⟩ := Prod.mk.inj same
  exact ⟨D₀,sourceRun,target_step,post,by rw [inst.1]; rfl⟩

/-- error: host_runtime_step: unsupported source control -/
#guard_msgs in
host_runtime_step ffi, {input with ctl := .halt (.normal .undef)} using initial to output using next as UnsupportedBatchStep

end Host.Ts.Owned.Annotated.Tests.RuntimeDriver
