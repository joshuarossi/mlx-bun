import host.sim.template.a4pre_first_tail_x15_r0_body.H7
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

/-! The compaction after the merge at call site 24 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s248` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa24` into the merged state
`PRE_first_tail_x15_r0_body.s247`. -/

def PRE_first_tail_x15_r0_body.pl24 : List Nat := [2695399, 2694574, 2695405, 2695401, 2694576, 2695407]
def PRE_first_tail_x15_r0_body.nr24 : List Nat := [1139, 1138, 1114, 1122, 1127, 1132, 1137, 1111, 1112, 1113, 1120, 1121, 1109, 1116, 1117, 1118, 1119, 1115]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd24 : RData :=
  ⟨2694293, 2695442, Stage.setAll PTrie.nil [(2694287, 2695399), (2694288, 2694574), (2694289, 2695405), (2694290, 2695401), (2694291, 2694576), (2694292, 2695407)], Stage.setAll PTrie.nil [(18688, 18714), (18689, 18692), (18690, 18715)],
   18691, 18716, 15779, 15779, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1109, .ref 1139), (1110, .ref 1138), (1111, .ref 1114), (1112, .ref 1122), (1113, .ref 1127), (1114, .ref 1132), (1115, .ref 1137), (1116, .ref 1111), (1117, .ref 1112), (1118, .ref 1113), (1119, .ref 1120), (1120, .ref 1121), (1121, .ref 1109), (1122, .ref 1116), (1123, .ref 1117), (1124, .ref 1118), (1125, .ref 1119), (1126, .ref 1115)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa24 : Map :=
  Conv.Map.compact 2694287 2695442 1109 PRE_first_tail_x15_r0_body.pl24 (PRE_first_tail_x15_r0_body.nr24.map NumV.ref) PRE_first_tail_x15_r0_body.kd24.big
    PRE_first_tail_x15_r0_body.kd24.region PRE_first_tail_x15_r0_body.kd24.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws24 : List Nat := [1423, 1424, 1425, 1426, 1427, 1428, 1429, 1430, 1431, 1432, 1433, 1434, 1435, 1436, 1437, 1438, 1439, 1440]
noncomputable def PRE_first_tail_x15_r0_body.crs24 : List SymE := PRE_first_tail_x15_r0_body.nr24.map fun r => (nth? PRE_first_tail_x15_r0_body.S247.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta24 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws24 PRE_first_tail_x15_r0_body.crs24
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB24 : List Nat := [2665, 2672362, 2673467, 2693461, 2694006, 2694262]

kernel_rfl PRE_first_tail_x15_r0_body.ctab24 : PRE_first_tail_x15_r0_body.S248.tab = PRE_first_tail_x15_r0_body.S246.tab ++ PRE_first_tail_x15_r0_body.cws24.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace24 : PRE_first_tail_x15_r0_body.s248.trace = PRE_first_tail_x15_r0_body.s246.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext24 : PRE_first_tail_x15_r0_body.s248.next = 2694293
kernel_rfl PRE_first_tail_x15_r0_body.ccounters24 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.nnext) = (18691, 15779)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue24 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s247.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa24.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp24 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.tokens.all (bSN 1127) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean24 : Conv.cleanListB 18691 131072 (fun r => Nat.ble 74764 r) PRE_first_tail_x15_r0_body.s248
    (PRE_first_tail_x15_r0_body.wrB24 ++ (List.range 6).map (2694287 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs24 : bigsOutB 18691 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx = true

end Host.Load.Run.Tpl
