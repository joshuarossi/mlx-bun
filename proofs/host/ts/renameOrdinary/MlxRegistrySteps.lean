import host.ts.renameOrdinary.MlxHandlePath
import host.mlx.OrdinaryFreeStates
import host.ts.RenameRouteDriverMethodLookup
import host.ts.RenameRouteDriverEntry
import host.ts.RenameRouteDriverReads
import host.ts.RenameRouteDriverStructural
import host.ts.RenameRouteDriverReturns
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
host_transport_preparation P.F, P.RestStream.micro0.micro3.s91 to P.RestStream.micro0.micro3.s92 as RegistryStatement391
host_transport_statement P.F, P.RestStream.micro0.micro3.s92 to P.RestStream.micro0.micro3.s93 as RegistryExpression392
host_transport_preparation P.F, P.RestStream.micro0.micro3.s93 to P.RestStream.micro0.micro3.s94 as RegistryMethod393
host_transport_step P.F, P.RestStream.micro0.micro3.s94 to P.RestStream.micro0.micro3.s95 as RegistryVariable394
host_transport_method_lookup P.F, P.RestStream.micro0.micro3.s95 to P.RestStream.micro0.micro3.s96 as RegistryMethod395
host_transport_preparation P.F, P.RestStream.micro0.micro3.s96 to P.RestStream.micro0.micro3.s97 as RegistryArguments396
host_transport_map_control P.F, P.RestStream.micro0.micro3.s97 to P.RestStream.micro0.micro3.s98 as RegistryThis397
host_transport_structural P.F, P.RestStream.micro0.micro3.s98 to P.RestStream.micro0.micro3.s99 as RegistryArguments398
host_transport_step P.F, P.RestStream.micro0.micro3.s99 to P.RestStream.micro0.micro4.s0 as RegistryHandle399
host_transport_structural P.F, P.RestStream.micro0.micro4.s0 to P.RestStream.micro0.micro4.s1 as RegistryArguments400
host_transport_entry P.F, P.RestStream.micro0.micro4.s1 to P.RestStream.micro0.micro4.s2 as RegistryToken401
host_transport_map_control P.F, P.RestStream.micro0.micro4.s2 to P.RestStream.micro0.micro4.s3 as RegistryThis402
host_transport_read P.F, P.RestStream.micro0.micro4.s3 to P.RestStream.micro0.micro4.s4 as RegistryToken403
host_transport_structural P.F, P.RestStream.micro0.micro4.s4 to P.RestStream.micro0.micro4.s5 as RegistryArguments404
host_transport_return P.F, P.RestStream.micro0.micro4.s6 to P.RestStream.micro0.micro4.s7 as RegistryBlock406
host_transport_return P.F, P.RestStream.micro0.micro4.s7 to P.RestStream.micro0.micro4.s8 as RegistryScope407
end Host.Load.Run.Full.Ordinary.VectorToConcat
namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro4 5 185 as Ordinary.VectorToConcat.RegistryRegister405.sourceObject
end Host.Load.Run.Full
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.RegistryRegister405
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro4.s5
noncomputable def output : St LSt := P.RestStream.micro0.micro4.s6
noncomputable def sourceThis : Val := match input.ctl with | .call _ v _ => v | _ => .undef
noncomputable def sourceArgs : List Val := match input.ctl with | .call _ _ args => args | _ => []
theorem source_control : input.ctl = .call (.obj 185) sourceThis sourceArgs := by host_kernel_rfl
theorem source_heap : input.heap.get 185 = some (.obj sourceObject) := by host_kernel_rfl
theorem source_kind : sourceObject.kind = .fn (.native (.fn .finRegister) []) := by host_kernel_rfl
theorem source_post : input.ret .undef = output := by host_kernel_rfl

theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt) (h : StateR NR FR R live framed before after old old' input s) :
    interpC (step P.F s).run C = some (s.ret .undef,C) ∧
      StateR NR FR R live framed before after old old' output (s.ret .undef) := by
  obtain ⟨_,run,related⟩ := step_finalization_register_from_source P.F NR FR R C₀ C live framed before after old old'
    input s h 185 sourceObject [] sourceThis sourceArgs source_control source_heap source_kind
  exact ⟨run,source_post ▸ related⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.RegistryRegister405
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.ConstructorReturn408
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro4.s8
noncomputable def output : St LSt := P.RestStream.micro0.micro4.s9
noncomputable def sourceTail : List Frame := input.stack.tail
theorem source_control : input.ctl = .ret .undef := by host_kernel_rfl
theorem source_frame : input.stack = .k (.fn (.ctor (.obj 3126703)))::sourceTail := by host_kernel_rfl
theorem source_post : {input with stack := sourceTail}.ret (.obj 3126703) = output := by host_kernel_rfl

theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt) (h : StateR NR FR R live framed before after old old' input s) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' output result ∧
      result.ctl = .ret (.obj (R.a 3126703)) ∧ result.heap = s.heap := by
  obtain ⟨receiver,fs,_,run,related⟩ := step_constructor_return_from_source P.F NR FR R C₀ C live framed before after old old'
    input s h .undef (.obj 3126703) sourceTail source_control source_frame
  have ctl := (related.control_view rfl).ret_view
  obtain ⟨v,hv,vr⟩ := ctl
  cases vr
  have same : receiver = .obj (R.a 3126703) := Ctl.ret.inj hv
  exact ⟨_,run,source_post ▸ related,congrArg Ctl.ret same,rfl⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.ConstructorReturn408
