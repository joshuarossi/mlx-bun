import host.sim.template.a4pre_post_head.H0
import host.sim.template.a4pre_post_head.Small
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

def PRE_post_head.singletonGoodB (ν : Nat → F64) (O : List Ans) : Bool :=
  O.all fun q => decide (F64.test q.op ((q.a.subst PostHeadSmall.singleton).eval ν)
    ((q.b.subst PostHeadSmall.singleton).eval ν) = q.r)

theorem PRE_post_head.singletonGoodB_sound {ν : Nat → F64} {O : List Ans}
    (hν : ν 10 = F64.ofNat 1) (h : PRE_post_head.singletonGoodB ν O = true) : Good ν O := by
  intro q hq
  have he := of_decide_eq_true (List.all_eq_true.mp h q hq)
  simpa only [PostHeadSmall.eval_singleton hν] using he

kernel_rfl PRE_post_head.good_checked :
  (fun ν : Nat → F64 => PRE_post_head.singletonGoodB ν PRE_post_head.S0.oracle) = fun _ => true

theorem PRE_post_head.good {ν : Nat → F64} (hν : ν 10 = F64.ofNat 1) : Good ν PRE_post_head.S0.oracle :=
  PRE_post_head.singletonGoodB_sound hν (congrFun PRE_post_head.good_checked ν)
end Host.Load.Run.Tpl
