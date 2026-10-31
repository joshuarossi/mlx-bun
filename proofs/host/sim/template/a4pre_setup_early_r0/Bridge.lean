import host.sim.template.a4pre_setup_early_r0.H0
import host.sim.template.Bridges
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `PRE_setup_early_r0` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl PRE_setup_early_r0.ctlA1 : PRE_setup_early_r0.s2.ctl = .ret (.obj 2665)
kernel_rfl PRE_setup_early_r0.lenA1 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_setup_early_r0.s2.stack = true
kernel_rfl PRE_setup_early_r0.objA1 : PRE_setup_early_r0.s2.obj? 2665 = some (objOf PRE_setup_early_r0.s2 2665)
kernel_rfl PRE_setup_early_r0.kindA1 : (objOf PRE_setup_early_r0.s2 2665).kind = .array (arrOf PRE_setup_early_r0.s2 2665)
kernel_rfl PRE_setup_early_r0.callA2 : Host.Ts.Sim.Template.isCallOf PRE_setup_early_r0.s4 "chunkSize" none = true
kernel_rfl PRE_setup_early_r0.ctlA3 : PRE_setup_early_r0.s8.ctl = .ret (.obj 2665)
kernel_rfl PRE_setup_early_r0.lenA3 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_setup_early_r0.s8.stack = true
kernel_rfl PRE_setup_early_r0.objA3 : PRE_setup_early_r0.s8.obj? 2665 = some (objOf PRE_setup_early_r0.s8 2665)
kernel_rfl PRE_setup_early_r0.kindA3 : (objOf PRE_setup_early_r0.s8 2665).kind = .array (arrOf PRE_setup_early_r0.s8 2665)
kernel_rfl PRE_setup_early_r0.ctlA4 : PRE_setup_early_r0.s11.ctl = .ret (.obj 2665)
kernel_rfl PRE_setup_early_r0.lenA4 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_setup_early_r0.s11.stack = true
kernel_rfl PRE_setup_early_r0.objA4 : PRE_setup_early_r0.s11.obj? 2665 = some (objOf PRE_setup_early_r0.s11 2665)
kernel_rfl PRE_setup_early_r0.kindA4 : (objOf PRE_setup_early_r0.s11 2665).kind = .array (arrOf PRE_setup_early_r0.s11 2665)
kernel_rfl PRE_setup_early_r0.ctlA5 : PRE_setup_early_r0.s14.ctl = .ret (.obj 2665)
kernel_rfl PRE_setup_early_r0.lenA5 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_setup_early_r0.s14.stack = true
kernel_rfl PRE_setup_early_r0.objA5 : PRE_setup_early_r0.s14.obj? 2665 = some (objOf PRE_setup_early_r0.s14 2665)
kernel_rfl PRE_setup_early_r0.kindA5 : (objOf PRE_setup_early_r0.s14 2665).kind = .array (arrOf PRE_setup_early_r0.s14 2665)
end Host.Load.Run.Tpl
