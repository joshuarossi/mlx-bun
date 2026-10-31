import host.sim.template.a4pre_first_tail_x15_r0_body.H33
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

/-! The compaction after the merge at call site 121 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1073` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa121` into the merged state
`PRE_first_tail_x15_r0_body.s1072`. -/

def PRE_first_tail_x15_r0_body.pl121 : List Nat := []
def PRE_first_tail_x15_r0_body.nr121 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd121 : RData :=
  ⟨2770119, 2770121, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20592, 20592, 17688, 17688, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa121 : Map :=
  Conv.Map.compact 2770119 2770121 5252 PRE_first_tail_x15_r0_body.pl121 (PRE_first_tail_x15_r0_body.nr121.map NumV.ref) PRE_first_tail_x15_r0_body.kd121.big
    PRE_first_tail_x15_r0_body.kd121.region PRE_first_tail_x15_r0_body.kd121.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws121 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs121 : List SymE := PRE_first_tail_x15_r0_body.nr121.map fun r => (nth? PRE_first_tail_x15_r0_body.S1072.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta121 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws121 PRE_first_tail_x15_r0_body.crs121
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB121 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab121 : PRE_first_tail_x15_r0_body.S1073.tab = PRE_first_tail_x15_r0_body.S1071.tab ++ PRE_first_tail_x15_r0_body.cws121.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace121 : PRE_first_tail_x15_r0_body.s1073.trace = PRE_first_tail_x15_r0_body.s1071.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext121 : PRE_first_tail_x15_r0_body.s1073.next = 2770119
kernel_rfl PRE_first_tail_x15_r0_body.ccounters121 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1073.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1073.ffi).mlx.nnext) = (20592, 17688)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue121 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1072.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1073.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa121.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp121 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1073.ffi).mlx.tokens.all (bSN 5252) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean121 : Conv.cleanListB 20592 131072 (fun r => Nat.ble 82368 r) PRE_first_tail_x15_r0_body.s1073
    (PRE_first_tail_x15_r0_body.wrB121 ++ (List.range 0).map (2770119 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs121 : bigsOutB 20592 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1073.ffi).mlx = true

end Host.Load.Run.Tpl
