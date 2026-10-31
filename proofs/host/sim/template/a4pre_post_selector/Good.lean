import host.sim.template.a4pre_post_selector.H0
import host.sim.template.a4pre_post_head.Good
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
kernel_rfl PRE_post_selector.good_checked :
  (fun ν : Nat → F64 => PRE_post_head.singletonGoodB ν PRE_post_selector.S0.oracle) = fun _ => true

theorem PRE_post_selector.good {ν : Nat → F64} (hν : ν 10 = F64.ofNat 1) : Good ν PRE_post_selector.S0.oracle :=
  PRE_post_head.singletonGoodB_sound hν (congrFun PRE_post_selector.good_checked ν)
end Host.Load.Run.Tpl
