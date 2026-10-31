import host.sim.template.a4pre_g0b.H0
import host.sim.template.Bridges
import host.sim.LoopFinal
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `PRE_g0b` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl PRE_g0b.ctlA1 : PRE_g0b.s2.ctl = .ret (.obj 2665)
kernel_rfl PRE_g0b.lenA1 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_g0b.s2.stack = true
kernel_rfl PRE_g0b.objA1 : PRE_g0b.s2.obj? 2665 = some (objOf PRE_g0b.s2 2665)
kernel_rfl PRE_g0b.kindA1 : (objOf PRE_g0b.s2 2665).kind = .array (arrOf PRE_g0b.s2 2665)
kernel_rfl PRE_g0b.ctlA2 : PRE_g0b.s5.ctl = .ret (.obj 2665)
kernel_rfl PRE_g0b.lenA2 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_g0b.s5.stack = true
kernel_rfl PRE_g0b.objA2 : PRE_g0b.s5.obj? 2665 = some (objOf PRE_g0b.s5 2665)
kernel_rfl PRE_g0b.kindA2 : (objOf PRE_g0b.s5 2665).kind = .array (arrOf PRE_g0b.s5 2665)
kernel_rfl PRE_g0b.ctlA3 : PRE_g0b.s8.ctl = .ret (.obj 2665)
kernel_rfl PRE_g0b.lenA3 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_g0b.s8.stack = true
kernel_rfl PRE_g0b.objA3 : PRE_g0b.s8.obj? 2665 = some (objOf PRE_g0b.s8 2665)
kernel_rfl PRE_g0b.kindA3 : (objOf PRE_g0b.s8 2665).kind = .array (arrOf PRE_g0b.s8 2665)
end Host.Load.Run.Tpl
