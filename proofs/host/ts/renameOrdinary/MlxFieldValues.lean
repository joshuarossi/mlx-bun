import host.ts.renameOrdinary.MlxFieldsEntry
import host.ts.RenameRouteDriverClassValues
import host.ts.RenameParametricEmptyObject
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
host_transport_step P.F, P.RestStream.micro0.micro3.s74 to P.RestStream.micro0.micro3.s75 as DisposedLiteral374
host_transport_private_initializer P.F, P.RestStream.micro0.micro3.s75 to P.RestStream.micro0.micro3.s76 as DisposedField375
host_transport_private_initializer P.F, P.RestStream.micro0.micro3.s77 to P.RestStream.micro0.micro3.s78 as TokenField377
host_transport_step P.F, P.RestStream.micro0.micro3.s78 to P.RestStream.micro0.micro3.s79 as PinLiteral378
host_transport_private_initializer P.F, P.RestStream.micro0.micro3.s79 to P.RestStream.micro0.micro3.s80 as PinField379
end Host.Load.Run.Full.Ordinary.VectorToConcat
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.TokenObject376
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro3.s76
noncomputable def output : St LSt := P.RestStream.micro0.micro3.s77
noncomputable def sourceEnv : Env := match input.ctl with | .ev _ env => env | _ => []
theorem source_control : input.ctl = .ev (.object []) sourceEnv := by host_kernel_rfl
theorem source_post : (input.alloc (.obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩)).2.ret (.obj input.next) = output := by host_kernel_rfl
theorem source_bound : input.next < 2^64 := by decide +kernel

/-- The real #token initializer allocates its ordinary object and keeps the
owned argument under its unchanged initializer/constructor stack. -/
theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (bound : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R (LiveAfter live input.next) framed before after old old' output result ∧
      constructorArgument result = constructorArgument s := by
  obtain ⟨_,run,related⟩ := step_empty_object_from_source P.F NR FR R C₀ C live framed before after old old' input s h
    sourceEnv source_control prototypeLive prototypeFixed source_bound bound
  exact ⟨_,run,source_post ▸ related,rfl⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.TokenObject376
