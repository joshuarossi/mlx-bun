import host.load.RuntimeOptIntCases
import host.load.RuntimeBlockPlan
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.OptIntPlanCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

namespace First
noncomputable def s0 := OptIntCases.input64
noncomputable def s40 := OptIntCases.output64
noncomputable def S0 := OptIntSource.From8175.S1
noncomputable def S40 := S0
end First

namespace Second
noncomputable def s0 := OptIntCases.input4
noncomputable def s40 := OptIntCases.output4
noncomputable def S0 := OptIntCases.From8216.S8
noncomputable def S40 := S0
end Second

namespace Null
noncomputable def s0 : St LSt := {OptIntCases.input64 with
  ctl := (.call (.obj OptIntCases.Source8176.address) OptIntCases.Source8176.sourceThis [.null])}
noncomputable def s18 := optIntSourceOutput s0
noncomputable def S0 := OptIntSource.From8175.S1
noncomputable def S18 := S0
end Null

-- There are deliberately no intermediate aliases: each selected rule must
-- account for the whole actual function invocation.
host_source_linear_plan_subst P.F, First from 0 plan_steps 40
  substitute LoopVariables.oracleVariables as FirstPlan
host_source_linear_plan_subst P.F, Second from 0 plan_steps 40
  substitute (fun i => SymE.var i) as SecondPlan
host_source_linear_plan_subst P.F, Null from 0 plan_steps 18
  substitute LoopVariables.oracleVariables as NullPlan

theorem first_whole_call : FirstPlan.spans = [40] := by decide +kernel
theorem second_whole_call : SecondPlan.spans = [40] := by decide +kernel
theorem null_whole_call : NullPlan.spans = [18] := by decide +kernel

host_retained_theorem selected_first_call := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ FirstPlan.Block0.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' First.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live First.s0 s)
    (meaning : SymE) (closed : ∀ valuation, meaning.eval valuation = F64.ofNat FirstPlan.Block0.sourceNumber)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.literal meaning])
    (budget : s.next+3 ≤ 2^64) => by
  host_retained_plan_chain P.F, FirstPlan using h, inventory, inst
host_assert_retained_schema selected_first_call, 40

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_first_call, 39

end Host.Load.Run.Full.Ordinary.OptIntPlanCases
