import host.sim.template.a4pre_first_tail_x15_r0.H1
import host.sim.template.Bridges
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `PRE_first_tail_x15_r0` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl PRE_first_tail_x15_r0.ctlA1 : PRE_first_tail_x15_r0.s2.ctl = .ret (.obj 2665)
kernel_rfl PRE_first_tail_x15_r0.lenA1 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_first_tail_x15_r0.s2.stack = true
kernel_rfl PRE_first_tail_x15_r0.objA1 : PRE_first_tail_x15_r0.s2.obj? 2665 = some (objOf PRE_first_tail_x15_r0.s2 2665)
kernel_rfl PRE_first_tail_x15_r0.kindA1 : (objOf PRE_first_tail_x15_r0.s2 2665).kind = .array (arrOf PRE_first_tail_x15_r0.s2 2665)
kernel_rfl PRE_first_tail_x15_r0.callA2 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0.s4 "chunkSize" none = true
kernel_rfl PRE_first_tail_x15_r0.ctlA3 : PRE_first_tail_x15_r0.s8.ctl = .ret (.obj 2665)
kernel_rfl PRE_first_tail_x15_r0.lenA3 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_first_tail_x15_r0.s8.stack = true
kernel_rfl PRE_first_tail_x15_r0.objA3 : PRE_first_tail_x15_r0.s8.obj? 2665 = some (objOf PRE_first_tail_x15_r0.s8 2665)
kernel_rfl PRE_first_tail_x15_r0.kindA3 : (objOf PRE_first_tail_x15_r0.s8 2665).kind = .array (arrOf PRE_first_tail_x15_r0.s8 2665)
kernel_rfl PRE_first_tail_x15_r0.ctlA4 : PRE_first_tail_x15_r0.s11.ctl = .ret (.obj 2665)
kernel_rfl PRE_first_tail_x15_r0.lenA4 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_first_tail_x15_r0.s11.stack = true
kernel_rfl PRE_first_tail_x15_r0.objA4 : PRE_first_tail_x15_r0.s11.obj? 2665 = some (objOf PRE_first_tail_x15_r0.s11 2665)
kernel_rfl PRE_first_tail_x15_r0.kindA4 : (objOf PRE_first_tail_x15_r0.s11 2665).kind = .array (arrOf PRE_first_tail_x15_r0.s11 2665)
kernel_rfl PRE_first_tail_x15_r0.ctlA5 : PRE_first_tail_x15_r0.s14.ctl = .ret (.obj 2665)
kernel_rfl PRE_first_tail_x15_r0.lenA5 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_first_tail_x15_r0.s14.stack = true
kernel_rfl PRE_first_tail_x15_r0.objA5 : PRE_first_tail_x15_r0.s14.obj? 2665 = some (objOf PRE_first_tail_x15_r0.s14 2665)
kernel_rfl PRE_first_tail_x15_r0.kindA5 : (objOf PRE_first_tail_x15_r0.s14 2665).kind = .array (arrOf PRE_first_tail_x15_r0.s14 2665)
kernel_rfl PRE_first_tail_x15_r0.callA6 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0.s17 "nextPrefillStep" none = true
noncomputable def PRE_first_tail_x15_r0.sliceArr7 : Nat := match PRE_first_tail_x15_r0.s21.ctl with
  | .call _ (.obj a) _ => a
  | _ => 0
kernel_rfl PRE_first_tail_x15_r0.sliceA7 : Host.Ts.Sim.Template.Bridge.isSliceOf PRE_first_tail_x15_r0.s21 PRE_first_tail_x15_r0.sliceArr7 = true
kernel_rfl PRE_first_tail_x15_r0.kindA7 : (objOf PRE_first_tail_x15_r0.s21 PRE_first_tail_x15_r0.sliceArr7).kind = .array (arrOf PRE_first_tail_x15_r0.s21 PRE_first_tail_x15_r0.sliceArr7)
kernel_rfl PRE_first_tail_x15_r0.roomA7_check : Nat.blt (PRE_first_tail_x15_r0.s21.next + margin) Sim.bound = true
kernel_rfl PRE_first_tail_x15_r0.arrA7 : (PRE_first_tail_x15_r0.s21.heap.get aArrayProto).isSome = true
kernel_rfl PRE_first_tail_x15_r0.newA7 : PRE_first_tail_x15_r0.s21.next = 2673467
kernel_rfl PRE_first_tail_x15_r0.ctlA8 : PRE_first_tail_x15_r0.s24.ctl = .ret (.obj 2673467)
kernel_rfl PRE_first_tail_x15_r0.lenA8 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_first_tail_x15_r0.s24.stack = true
kernel_rfl PRE_first_tail_x15_r0.objA8 : PRE_first_tail_x15_r0.s24.obj? 2673467 = some (objOf PRE_first_tail_x15_r0.s24 2673467)
kernel_rfl PRE_first_tail_x15_r0.kindA8 : (objOf PRE_first_tail_x15_r0.s24 2673467).kind = .array (arrOf PRE_first_tail_x15_r0.s24 2673467)
kernel_rfl PRE_first_tail_x15_r0.typedA9 : Host.Ts.Sim.Template.Bridge.typedProto PRE_first_tail_x15_r0.s27 = some 21
kernel_rfl PRE_first_tail_x15_r0.roomA9_check : Nat.blt (PRE_first_tail_x15_r0.s27.next + margin) Sim.bound = true
kernel_rfl PRE_first_tail_x15_r0.bufA9 : (PRE_first_tail_x15_r0.s27.heap.get aArrayBufferProto).isSome = true
kernel_rfl PRE_first_tail_x15_r0.protoA9 : (PRE_first_tail_x15_r0.s27.heap.get 21).isSome = true
kernel_rfl PRE_first_tail_x15_r0.newA9 : PRE_first_tail_x15_r0.s27.next = 2673472
kernel_rfl PRE_first_tail_x15_r0.ptrA10 : Host.Ts.Sim.Template.Bridge.ptrView PRE_first_tail_x15_r0.s30 = some 2673473
kernel_rfl PRE_first_tail_x15_r0.ndA11 : (Host.Ts.Sim.Template.Bridge.ndParts PRE_first_tail_x15_r0.s33).map (·.2.2.2.2) = some 2673472
kernel_rfl PRE_first_tail_x15_r0.ctlA12 : PRE_first_tail_x15_r0.s36.ctl = .ret (.obj 2673467)
kernel_rfl PRE_first_tail_x15_r0.lenA12 : Host.Ts.Sim.Template.Bridge.isLenFrame PRE_first_tail_x15_r0.s36.stack = true
kernel_rfl PRE_first_tail_x15_r0.objA12 : PRE_first_tail_x15_r0.s36.obj? 2673467 = some (objOf PRE_first_tail_x15_r0.s36 2673467)
kernel_rfl PRE_first_tail_x15_r0.kindA12 : (objOf PRE_first_tail_x15_r0.s36 2673467).kind = .array (arrOf PRE_first_tail_x15_r0.s36 2673467)
kernel_rfl PRE_first_tail_x15_r0.callA13 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0.s38 "prompt" none = true
end Host.Load.Run.Tpl
