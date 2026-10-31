import host.sim.template.a4final_eos1.H0
import host.sim.template.Bridges
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `FinalEos1` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl FinalEos1.ctlA1 : FinalEos1.s2.ctl = .ret (.obj 2665)
kernel_rfl FinalEos1.lenA1 : Host.Ts.Sim.Template.Bridge.isLenFrame FinalEos1.s2.stack = true
kernel_rfl FinalEos1.objA1 : FinalEos1.s2.obj? 2665 = some (objOf FinalEos1.s2 2665)
kernel_rfl FinalEos1.kindA1 : (objOf FinalEos1.s2 2665).kind = .array (arrOf FinalEos1.s2 2665)
kernel_rfl FinalEos1.ctlA2 : FinalEos1.s5.ctl = .ret (.obj 2665)
kernel_rfl FinalEos1.lenA2 : Host.Ts.Sim.Template.Bridge.isLenFrame FinalEos1.s5.stack = true
kernel_rfl FinalEos1.objA2 : FinalEos1.s5.obj? 2665 = some (objOf FinalEos1.s5 2665)
kernel_rfl FinalEos1.kindA2 : (objOf FinalEos1.s5 2665).kind = .array (arrOf FinalEos1.s5 2665)
kernel_rfl FinalEos1.ctlA3 : FinalEos1.s8.ctl = .ret (.obj 2673448)

/-- Bridge 3's spread frame: accumulator, environment and the frames below it. -/
noncomputable def FinalEos1.accA3 : List Val := match FinalEos1.s8.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def FinalEos1.envA3 : Env := match FinalEos1.s8.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FinalEos1.fsA3 : List Frame := match FinalEos1.s8.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl FinalEos1.stackA3 : FinalEos1.s8.stack = .l (.spread FinalEos1.accA3 [] FinalEos1.envA3) :: FinalEos1.fsA3
kernel_rfl FinalEos1.roomA3_check : Nat.blt (FinalEos1.s8.next + margin) Sim.bound = true
kernel_rfl FinalEos1.arrA3 : (FinalEos1.s8.heap.get aArrayProto).isSome = true
kernel_rfl FinalEos1.newA3 : FinalEos1.s8.next = 3123628
end Host.Load.Run.Tpl
