import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.template.Bridges
import host.sim.LoopFinal
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `PRE_first_tail_x15_r0_suffix` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl PRE_first_tail_x15_r0_suffix.callA1 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_suffix.s2 "evalCacheState" none = true
kernel_rfl PRE_first_tail_x15_r0_suffix.ctlA2 : PRE_first_tail_x15_r0_suffix.s6.ctl = .ret (.obj 2665)
kernel_rfl PRE_first_tail_x15_r0_suffix.lenA2 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_first_tail_x15_r0_suffix.s6.stack = true
kernel_rfl PRE_first_tail_x15_r0_suffix.objA2 : PRE_first_tail_x15_r0_suffix.s6.obj? 2665 = some (objOf PRE_first_tail_x15_r0_suffix.s6 2665)
kernel_rfl PRE_first_tail_x15_r0_suffix.kindA2 : (objOf PRE_first_tail_x15_r0_suffix.s6 2665).kind = .array (arrOf PRE_first_tail_x15_r0_suffix.s6 2665)
end Host.Load.Run.Tpl
