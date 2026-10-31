import host.sim.template.a4eos_cut_ctx.H0
import host.sim.template.Bridges
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `EOSCutCtxRest` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl EOSCutCtxRest.ctlA1 : EOSCutCtxRest.s2.ctl = .ret (.obj 2665)
kernel_rfl EOSCutCtxRest.lenA1 : Host.Ts.Sim.Template.Bridge.isLenFrame EOSCutCtxRest.s2.stack = true
kernel_rfl EOSCutCtxRest.objA1 : EOSCutCtxRest.s2.obj? 2665 = some (objOf EOSCutCtxRest.s2 2665)
kernel_rfl EOSCutCtxRest.kindA1 : (objOf EOSCutCtxRest.s2 2665).kind = .array (arrOf EOSCutCtxRest.s2 2665)
kernel_rfl EOSCutCtxRest.ctlA2 : EOSCutCtxRest.s5.ctl = .ret (.obj 2673448)

/-- Bridge 2's spread frame: accumulator, environment and the frames below it. -/
noncomputable def EOSCutCtxRest.accA2 : List Val := match EOSCutCtxRest.s5.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def EOSCutCtxRest.envA2 : Env := match EOSCutCtxRest.s5.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def EOSCutCtxRest.fsA2 : List Frame := match EOSCutCtxRest.s5.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl EOSCutCtxRest.stackA2 : EOSCutCtxRest.s5.stack = .l (.spread EOSCutCtxRest.accA2 [] EOSCutCtxRest.envA2) :: EOSCutCtxRest.fsA2
kernel_rfl EOSCutCtxRest.roomA2_check : Nat.blt (EOSCutCtxRest.s5.next + margin) Sim.bound = true
kernel_rfl EOSCutCtxRest.arrA2 : (EOSCutCtxRest.s5.heap.get aArrayProto).isSome = true
kernel_rfl EOSCutCtxRest.newA2 : EOSCutCtxRest.s5.next = 3123590
end Host.Load.Run.Tpl
