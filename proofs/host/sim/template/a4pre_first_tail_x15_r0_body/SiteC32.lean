import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 32 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s318` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa32` into the merged state
`PRE_first_tail_x15_r0_body.s317`. -/

def PRE_first_tail_x15_r0_body.pl32 : List Nat := [2699593]
def PRE_first_tail_x15_r0_body.nr32 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd32 : RData :=
  ⟨2699584, 2699594, Stage.setAll PTrie.nil [(2699583, 2699593)], Stage.setAll PTrie.nil [],
   18825, 18825, 15922, 15922, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa32 : Map :=
  Conv.Map.compact 2699583 2699594 1423 PRE_first_tail_x15_r0_body.pl32 (PRE_first_tail_x15_r0_body.nr32.map NumV.ref) PRE_first_tail_x15_r0_body.kd32.big
    PRE_first_tail_x15_r0_body.kd32.region PRE_first_tail_x15_r0_body.kd32.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws32 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs32 : List SymE := PRE_first_tail_x15_r0_body.nr32.map fun r => (nth? PRE_first_tail_x15_r0_body.S317.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta32 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws32 PRE_first_tail_x15_r0_body.crs32
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB32 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab32 : PRE_first_tail_x15_r0_body.S318.tab = PRE_first_tail_x15_r0_body.S316.tab ++ PRE_first_tail_x15_r0_body.cws32.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace32 : PRE_first_tail_x15_r0_body.s318.trace = PRE_first_tail_x15_r0_body.s316.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext32 : PRE_first_tail_x15_r0_body.s318.next = 2699584
kernel_rfl PRE_first_tail_x15_r0_body.ccounters32 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx.nnext) = (18825, 15922)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue32 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s317.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa32.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp32 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx.tokens.all (bSN 1423) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean32 : Conv.cleanListB 18825 131072 (fun r => Nat.ble 75300 r) PRE_first_tail_x15_r0_body.s318
    (PRE_first_tail_x15_r0_body.wrB32 ++ (List.range 1).map (2699583 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs32 : bigsOutB 18825 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx = true

end Host.Load.Run.Tpl
