import host.sim.template.a4final_clear0.H0
import host.sim.template.Bridges
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `FinalClear0` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl FinalClear0.ctlA1 : FinalClear0.s2.ctl = .ret (.obj 2665)
kernel_rfl FinalClear0.lenA1 : Host.Ts.Sim.Template.Bridge.isLenFrame FinalClear0.s2.stack = true
kernel_rfl FinalClear0.objA1 : FinalClear0.s2.obj? 2665 = some (objOf FinalClear0.s2 2665)
kernel_rfl FinalClear0.kindA1 : (objOf FinalClear0.s2 2665).kind = .array (arrOf FinalClear0.s2 2665)
kernel_rfl FinalClear0.ctlA2 : FinalClear0.s5.ctl = .ret (.obj 2665)
kernel_rfl FinalClear0.lenA2 : Host.Ts.Sim.Template.Bridge.isLenFrame FinalClear0.s5.stack = true
kernel_rfl FinalClear0.objA2 : FinalClear0.s5.obj? 2665 = some (objOf FinalClear0.s5 2665)
kernel_rfl FinalClear0.kindA2 : (objOf FinalClear0.s5 2665).kind = .array (arrOf FinalClear0.s5 2665)
kernel_rfl FinalClear0.ctlA3 : FinalClear0.s8.ctl = .ret (.obj 2673448)

/-- Bridge 3's spread frame: accumulator, environment and the frames below it. -/
noncomputable def FinalClear0.accA3 : List Val := match FinalClear0.s8.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def FinalClear0.envA3 : Env := match FinalClear0.s8.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FinalClear0.fsA3 : List Frame := match FinalClear0.s8.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl FinalClear0.stackA3 : FinalClear0.s8.stack = .l (.spread FinalClear0.accA3 [] FinalClear0.envA3) :: FinalClear0.fsA3
kernel_rfl FinalClear0.roomA3_check : Nat.blt (FinalClear0.s8.next + margin) Sim.bound = true
kernel_rfl FinalClear0.arrA3 : (FinalClear0.s8.heap.get aArrayProto).isSome = true
kernel_rfl FinalClear0.newA3 : FinalClear0.s8.next = 3123643
end Host.Load.Run.Tpl
