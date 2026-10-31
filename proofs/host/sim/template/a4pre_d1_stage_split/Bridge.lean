import host.sim.template.a4pre_d1_stage_split.H0
import host.sim.template.Bridges
import host.sim.LoopFinal
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `D1StageSplit` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl D1StageSplit.callA1 : Host.Ts.Sim.Template.isCallOf D1StageSplit.s0 "nextPrefillStep" none = true
noncomputable def D1StageSplit.sliceArr2 : Nat := match D1StageSplit.s3.ctl with
  | .call _ (.obj a) _ => a
  | _ => 0
kernel_rfl D1StageSplit.sliceA2 : Host.Ts.Sim.Template.Bridge.isSliceOf D1StageSplit.s3 D1StageSplit.sliceArr2 = true
kernel_rfl D1StageSplit.kindA2 : (objOf D1StageSplit.s3 D1StageSplit.sliceArr2).kind = .array (arrOf D1StageSplit.s3 D1StageSplit.sliceArr2)
kernel_rfl D1StageSplit.roomA2_check : Nat.blt (D1StageSplit.s3.next + margin) Sim.bound = true
kernel_rfl D1StageSplit.arrA2 : (D1StageSplit.s3.heap.get aArrayProto).isSome = true
kernel_rfl D1StageSplit.newA2 : D1StageSplit.s3.next = 2673479
kernel_rfl D1StageSplit.ctlA3 : D1StageSplit.s6.ctl = .ret (.obj 2673479)
kernel_rfl D1StageSplit.lenA3 : Host.Ts.Sim.Template.Bridge.isLenFrame D1StageSplit.s6.stack = true
kernel_rfl D1StageSplit.objA3 : D1StageSplit.s6.obj? 2673479 = some (objOf D1StageSplit.s6 2673479)
kernel_rfl D1StageSplit.kindA3 : (objOf D1StageSplit.s6 2673479).kind = .array (arrOf D1StageSplit.s6 2673479)
kernel_rfl D1StageSplit.typedA4 : Host.Ts.Sim.Template.Bridge.typedProto D1StageSplit.s9 = some 21
kernel_rfl D1StageSplit.roomA4_check : Nat.blt (D1StageSplit.s9.next + margin) Sim.bound = true
kernel_rfl D1StageSplit.bufA4 : (D1StageSplit.s9.heap.get aArrayBufferProto).isSome = true
kernel_rfl D1StageSplit.protoA4 : (D1StageSplit.s9.heap.get 21).isSome = true
kernel_rfl D1StageSplit.newA4 : D1StageSplit.s9.next = 2673484
kernel_rfl D1StageSplit.ptrA5 : Host.Ts.Sim.Template.Bridge.ptrView D1StageSplit.s12 = some 2673485
kernel_rfl D1StageSplit.ndA6 : (Host.Ts.Sim.Template.Bridge.ndParts D1StageSplit.s15).map (·.2.2.2.2) = some 2673484
kernel_rfl D1StageSplit.ctlA7 : D1StageSplit.s18.ctl = .ret (.obj 2673479)
kernel_rfl D1StageSplit.lenA7 : Host.Ts.Sim.Template.Bridge.isLenFrame D1StageSplit.s18.stack = true
kernel_rfl D1StageSplit.objA7 : D1StageSplit.s18.obj? 2673479 = some (objOf D1StageSplit.s18 2673479)
kernel_rfl D1StageSplit.kindA7 : (objOf D1StageSplit.s18 2673479).kind = .array (arrOf D1StageSplit.s18 2673479)
kernel_rfl D1StageSplit.callA8 : Host.Ts.Sim.Template.isCallOf D1StageSplit.s20 "prompt" none = true
end Host.Load.Run.Tpl
