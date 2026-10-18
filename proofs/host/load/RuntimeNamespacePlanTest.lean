import host.load.RuntimeBlockPlan
import host.ts.RenameLoopVariableNamespace
import host.mlx.OrdinaryVectorStates
import host.ts.renameOrdinary.MapBodyStates
import host.ts.renameOrdinary.HostCuts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RuntimeNamespacePlanTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_source_plan_subst P.F, P.RestStream.micro0 from 0 plan_steps 14
  substitute LoopVariables.oracleVariables as Shape
host_source_plan_subst P.F, P.RestStream.micro0 from 119 plan_steps 26
  substitute LoopVariables.oracleVariables as Mapper
host_source_plan_subst P.F, P.RestStream.micro0 from 258 plan_steps 1
  substitute LoopVariables.oracleVariables as ObjectRead

theorem mapper_span : Mapper.starts = [119] ∧ Mapper.spans = [26] := by decide +kernel
theorem shape_span : Shape.spans.sum = 14 := Shape.span_total

theorem object_source_server : ObjectRead.Block258.initialServer =
    (numberServer P.RestStream.micro0.micro2.S58).substitute LoopVariables.oracleVariables := rfl
theorem mapper_source_server : Mapper.Block119.initialServer =
    (numberServer P.RestStream.micro0.micro1.S19).substitute LoopVariables.oracleVariables := rfl

host_retained_theorem mapper_call := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Mapper.Block119.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Mapper.Block119.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Mapper.Block119.input s)
    (fnRole thisRole role : Annotated.Value) (extraRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj Mapper.Block119.sourceOwner::extraRoles))
    (fieldNote : notes.privates.owners Mapper.Block119.sourceOwner =
      some ⟨Mapper.Block119.sourceBrand,Mapper.Block119.sourceHandleName,role⟩)
    (budget : s.next+3 ≤ 2^64) => by
  host_retained_plan_chain P.F, Mapper using h, inventory, inst
host_assert_retained_schema mapper_call, 26

host_retained_theorem object_read := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ ObjectRead.Block258.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ObjectRead.Block258.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live ObjectRead.Block258.input s) => by
  host_retained_plan_chain P.F, ObjectRead using h, inventory, inst
host_assert_retained_schema object_read, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema object_read, 2

end Host.Load.Run.Full.Ordinary.RuntimeNamespacePlanTest
