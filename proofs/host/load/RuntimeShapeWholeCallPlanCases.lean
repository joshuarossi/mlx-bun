import host.load.RuntimeBlockPlan
import host.load.RuntimeOracleWeightShapeReturn

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.ShapeWholeCallPlanCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

namespace Input
noncomputable def s0 := P.RestStream.micro0.micro4.s45
noncomputable def s115 := P.RestStream.micro0.micro5.s60
noncomputable def S0 := P.RestStream.micro0.micro4.S45
noncomputable def S115 := P.RestStream.micro0.micro5.S60
end Input

-- No intermediate states are exposed: this requires the complete summary.
host_source_linear_plan_subst P.F, Input from 0 plan_steps 115
  substitute LoopVariables.oracleVariables as Whole

theorem selected_whole_call : Whole.spans = [115] ∧ Whole.blockCount = 1 ∧
    Whole.sourceSteps = 115 ∧ Whole.spans.sum = 115 := by decide +kernel

theorem actual_endpoints : Whole.Block0.input = P.RestStream.micro0.micro4.s45 ∧
    Whole.Block0.output = P.RestStream.micro0.micro5.s60 := by
  constructor <;> host_kernel_rfl

host_assert_retained_schema Whole.Block0.retained_transport, 115

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Whole.Block0.retained_transport, 114

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Whole.Block0.retained_transport, 116

namespace Window
noncomputable def s0 := Input.s0
noncomputable def s1 := P.RestStream.micro0.micro4.s46
noncomputable def S0 := Input.S0
noncomputable def S1 := P.RestStream.micro0.micro4.S46
end Window
host_source_linear_plan_subst P.F, Window from 0 plan_steps 1
  substitute LoopVariables.oracleVariables as Bounded

theorem bounded_fallback : Bounded.spans = [1] ∧ Bounded.blockCount = 1 := by decide +kernel

host_retained_theorem selected_shape := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (inst : Inst ν₀ Whole.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' Input.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Input.s0 s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (current : ShapeCall.Current Whole.Block0.sourceData notes live framed R H)
    (budget : s.next+13 ≤ 2^64) => by
  cases current
  host_retained_plan_chain P.F, Whole using state, inventory, inst
host_assert_retained_schema selected_shape, 115

end Host.Load.Run.Full.Ordinary.ShapeWholeCallPlanCases
