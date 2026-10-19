import host.load.RuntimeBlockPlan
import host.load.RuntimePostConcatCleanupCuts
import host.load.RuntimeCompiledArgumentEntryCuts2057
import host.load.RuntimeNamespacedDecodeCuts1220
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.WholeCallPlanCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

-- Only the actual entry and exit are exposed, so selecting intermediate
-- transitions cannot accidentally satisfy these complete-call plans.
namespace DisposeInput
noncomputable def s0 := PostConcatCleanup.Region.s41
noncomputable def s40 := CompiledArgumentEntry.From2057.s3
noncomputable def S0 := PostConcatCleanup.Region.S41
noncomputable def S40 := CompiledArgumentEntry.From2057.S3
end DisposeInput

namespace NdimInput
noncomputable def s0 := NamespacedDecode.From1175.s12
noncomputable def s39 := NamespacedDecode.From1220.s6
noncomputable def S0 := NamespacedDecode.From1175.S12
noncomputable def S39 := NamespacedDecode.From1220.S6
end NdimInput

host_source_linear_plan_subst P.F, DisposeInput from 0 plan_steps 40
  substitute LoopVariables.oracleVariables as DisposePlan
host_source_linear_plan_subst P.F, NdimInput from 0 plan_steps 39
  substitute LoopVariables.oracleVariables as NdimPlan

theorem dispose_whole_call : DisposePlan.spans = [40] ∧ DisposePlan.blockCount = 1 ∧
    DisposePlan.sourceSteps = 40 ∧ DisposePlan.spans.sum = 40 := by decide +kernel
theorem ndim_whole_call : NdimPlan.spans = [39] ∧ NdimPlan.blockCount = 1 ∧
    NdimPlan.sourceSteps = 39 ∧ NdimPlan.spans.sum = 39 := by decide +kernel

theorem dispose_actual_endpoints : DisposePlan.Block0.input = PostConcatCleanup.Region.s41 ∧
    DisposePlan.Block0.output = CompiledArgumentEntry.From2057.s3 := by
  constructor <;> host_kernel_rfl
theorem ndim_actual_endpoints : NdimPlan.Block0.input = NamespacedDecode.From1175.s12 ∧
    NdimPlan.Block0.output = NamespacedDecode.From1220.s6 := by
  constructor <;> host_kernel_rfl

host_assert_retained_schema DisposePlan.Block0.retained_transport, 40
host_assert_retained_schema NdimPlan.Block0.retained_transport, 39

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema DisposePlan.Block0.retained_transport, 39

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema NdimPlan.Block0.retained_transport, 40

-- A one-transition window must retain the original closure-entry selector.
namespace DisposeWindow
noncomputable def s0 := DisposeInput.s0
noncomputable def s1 := PostConcatCleanup.Region.s42
noncomputable def S0 := DisposeInput.S0
noncomputable def S1 := PostConcatCleanup.Region.S42
end DisposeWindow
namespace NdimWindow
noncomputable def s0 := NdimInput.s0
noncomputable def s1 := NamespacedDecode.From1175.s13
noncomputable def S0 := NdimInput.S0
noncomputable def S1 := NamespacedDecode.From1175.S13
end NdimWindow

host_source_linear_plan_subst P.F, DisposeWindow from 0 plan_steps 1
  substitute LoopVariables.oracleVariables as DisposeBounded
host_source_linear_plan_subst P.F, NdimWindow from 0 plan_steps 1
  substitute LoopVariables.oracleVariables as NdimBounded

theorem dispose_bounded_fallback : DisposeBounded.spans = [1] ∧ DisposeBounded.blockCount = 1 := by decide +kernel
theorem ndim_bounded_fallback : NdimBounded.spans = [1] ∧ NdimBounded.blockCount = 1 := by decide +kernel

host_retained_theorem selected_dispose := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (inst : Inst ν₀ DisposePlan.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' DisposeInput.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live DisposeInput.s0 s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (handleNote : notes.privates.owners DisposePlan.Block0.owner =
      some ⟨DisposePlan.Block0.brand,Dispose.handle,.handle DisposePlan.Block0.arrayHandle⟩)
    (registryLive : live DisposePlan.Block0.registryAddress) (moduleLive : live DisposePlan.Block0.moduleAddress)
    (signatureFrame : ¬ framed DisposePlan.Block0.types) (handleLive : H DisposePlan.Block0.arrayHandle)
    (budget : s.next+2 ≤ 2^64) (nativeBudget : s.ffi.mlx.next < 2^64) => by
  host_retained_plan_chain P.F, DisposePlan using state, inventory, inst
host_assert_retained_schema selected_dispose, 40

host_retained_theorem selected_ndim := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (inst : Inst ν₀ NdimPlan.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' NdimInput.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live NdimInput.s0 s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (globalLive : live aGlobal) (moduleCellLive : live NdimPlan.Block0.sourceModuleCell)
    (moduleLive : live NdimPlan.Block0.sourceModule) (ownerLive : live NdimPlan.Block0.sourceOwner)
    (getterLive : live NdimPlan.Block0.sourceGetter) (numberLive : live NdimPlan.Block0.sourceNumberFn)
    (nativeLive : live NdimPlan.Block0.sourceNativeFn) (typesLive : live NdimPlan.Block0.sourceTypes)
    (globalFixed : R.a aGlobal = aGlobal) (signatureFrame : ¬ framed NdimPlan.Block0.sourceTypes)
    (handleLive : H NdimPlan.Block0.sourceHandle)
    (fieldNote : notes.privates.owners NdimPlan.Block0.sourceOwner =
      some ⟨NdimPlan.Block0.sourceBrand,NdimPlan.Block0.sourceField,.handle NdimPlan.Block0.sourceHandle⟩)
    (controlNote : notes.runtime.control = callNote (.obj NdimPlan.Block0.sourceNdimGetter) (.obj NdimPlan.Block0.sourceOwner) [])
    (budget : s.next+4 ≤ 2^64) => by
  host_retained_plan_chain P.F, NdimPlan using state, inventory, inst
host_assert_retained_schema selected_ndim, 39

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  for theoremName in [``selected_dispose,``selected_ndim] do
    forallTelescopeReducing (← getConstInfo theoremName).type fun _ conclusion => do
      let conclusion ← whnf conclusion
      unless conclusion.isAppOfArity ``Exists 2 do throwError "whole-call chain: expected reached state"
      withLocalDeclD `result conclusion.getAppArgs[0]! fun result => do
        let rec state (type : Lean.Expr) : MetaM Lean.Expr := do
          let type ← whnf type
          if type.getAppFn.isConstOf ``Parametric.StateR then return type
          if type.isAppOfArity ``And 2 then
            try state type.getAppArgs[0]! catch _ => state type.getAppArgs[1]!
          else throwError "whole-call chain: missing StateR"
        let post ← state (mkApp conclusion.getAppArgs[1]! result)
        unless post.getAppArgs[2]!.getAppFn.isConstOf ``VectorHost.NativeRelation do
          throwError "whole-call chain lost strong native relation: {post.getAppArgs[2]!}"

end Host.Load.Run.Full.Ordinary.WholeCallPlanCases
