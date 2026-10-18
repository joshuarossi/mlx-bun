import host.ts.RenameRuntimeDriverObjects
import host.mlx.OrdinaryConcatStates
import host.ts.renameOrdinary.ObjectValueCutStates

set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedObjects
open Host.Ts

theorem value_prefix : runS P.F 31 P.RestStream.micro0.s28 P.RestStream.micro0.S28 =
    some (P.RestStream.micro0.micro28.s31,P.RestStream.micro0.micro28.S31) := by
  host_kernel_rfl

host_retained_object P.F, P.RestStream.micro0.micro3.s76 using P.RestStream.micro0.micro3.S76
  to P.RestStream.micro0.micro3.s77 using P.RestStream.micro0.micro3.S77 as Empty376
noncomputable def nextProperties : List Property :=
  match P.RestStream.micro0.micro28.s31.stack with
  | .l (.objVal _ _ properties _)::_ => properties
  | _ => []

theorem shorthand_continuation : nextProperties = [.short chars!"k",.short chars!"v"] := by
  host_kernel_rfl

theorem final_value_prefix : runS P.F 33 P.RestStream.micro0.s28 P.RestStream.micro0.S28 =
    some (P.RestStream.micro0.micro28.s33,P.RestStream.micro0.micro28.S33) := by
  host_kernel_rfl

host_retained_object P.F, P.RestStream.micro0.micro28.s33 using P.RestStream.micro0.micro28.S33
  to P.RestStream.micro0.micro28.s34 using P.RestStream.micro0.micro28.S34 as Value2833
end Host.Load.Run.Full.Ordinary.RetainedObjects
