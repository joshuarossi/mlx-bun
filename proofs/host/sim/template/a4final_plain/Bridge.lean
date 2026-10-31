import host.sim.template.a4final_plain.H0
import host.sim.template.Bridges
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `FinalPlain` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl FinalPlain.ctlA1 : FinalPlain.s2.ctl = .ret (.obj 2665)
kernel_rfl FinalPlain.lenA1 : Host.Ts.Sim.Template.Bridge.isLenFrame FinalPlain.s2.stack = true
kernel_rfl FinalPlain.objA1 : FinalPlain.s2.obj? 2665 = some (objOf FinalPlain.s2 2665)
kernel_rfl FinalPlain.kindA1 : (objOf FinalPlain.s2 2665).kind = .array (arrOf FinalPlain.s2 2665)
kernel_rfl FinalPlain.ctlA2 : FinalPlain.s5.ctl = .ret (.obj 2665)
kernel_rfl FinalPlain.lenA2 : Host.Ts.Sim.Template.Bridge.isLenFrame FinalPlain.s5.stack = true
kernel_rfl FinalPlain.objA2 : FinalPlain.s5.obj? 2665 = some (objOf FinalPlain.s5 2665)
kernel_rfl FinalPlain.kindA2 : (objOf FinalPlain.s5 2665).kind = .array (arrOf FinalPlain.s5 2665)
kernel_rfl FinalPlain.ctlA3 : FinalPlain.s8.ctl = .ret (.obj 2673448)

/-- Bridge 3's spread frame: accumulator, environment and the frames below it. -/
noncomputable def FinalPlain.accA3 : List Val := match FinalPlain.s8.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def FinalPlain.envA3 : Env := match FinalPlain.s8.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FinalPlain.fsA3 : List Frame := match FinalPlain.s8.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl FinalPlain.stackA3 : FinalPlain.s8.stack = .l (.spread FinalPlain.accA3 [] FinalPlain.envA3) :: FinalPlain.fsA3
kernel_rfl FinalPlain.roomA3_check : Nat.blt (FinalPlain.s8.next + margin) Sim.bound = true
kernel_rfl FinalPlain.arrA3 : (FinalPlain.s8.heap.get aArrayProto).isSome = true
kernel_rfl FinalPlain.newA3 : FinalPlain.s8.next = 3123642
end Host.Load.Run.Tpl
