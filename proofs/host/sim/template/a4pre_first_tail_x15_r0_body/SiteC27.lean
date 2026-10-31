import host.sim.template.a4pre_first_tail_x15_r0_body.H8
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

/-! The compaction after the merge at call site 27 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s277` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa27` into the merged state
`PRE_first_tail_x15_r0_body.s276`. -/

def PRE_first_tail_x15_r0_body.pl27 : List Nat := [2697655, 2696830, 2697661, 2697657, 2696832, 2697663]
def PRE_first_tail_x15_r0_body.nr27 : List Nat := [1268, 1267, 1243, 1251, 1256, 1261, 1266, 1240, 1241, 1242, 1249, 1250, 1238, 1245, 1246, 1247, 1248, 1244]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd27 : RData :=
  ⟨2696549, 2697698, Stage.setAll PTrie.nil [(2696543, 2697655), (2696544, 2696830), (2696545, 2697661), (2696546, 2697657), (2696547, 2696832), (2696548, 2697663)], Stage.setAll PTrie.nil [(18745, 18771), (18746, 18749), (18747, 18772)],
   18748, 18773, 15842, 15842, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1238, .ref 1268), (1239, .ref 1267), (1240, .ref 1243), (1241, .ref 1251), (1242, .ref 1256), (1243, .ref 1261), (1244, .ref 1266), (1245, .ref 1240), (1246, .ref 1241), (1247, .ref 1242), (1248, .ref 1249), (1249, .ref 1250), (1250, .ref 1238), (1251, .ref 1245), (1252, .ref 1246), (1253, .ref 1247), (1254, .ref 1248), (1255, .ref 1244)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa27 : Map :=
  Conv.Map.compact 2696543 2697698 1238 PRE_first_tail_x15_r0_body.pl27 (PRE_first_tail_x15_r0_body.nr27.map NumV.ref) PRE_first_tail_x15_r0_body.kd27.big
    PRE_first_tail_x15_r0_body.kd27.region PRE_first_tail_x15_r0_body.kd27.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws27 : List Nat := [1477, 1478, 1479, 1480, 1481, 1482, 1483, 1484, 1485, 1486, 1487, 1488, 1489, 1490, 1491, 1492, 1493, 1494]
noncomputable def PRE_first_tail_x15_r0_body.crs27 : List SymE := PRE_first_tail_x15_r0_body.nr27.map fun r => (nth? PRE_first_tail_x15_r0_body.S276.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta27 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws27 PRE_first_tail_x15_r0_body.crs27
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB27 : List Nat := [2665, 2672367, 2673467, 2695717, 2696262, 2696518]

kernel_rfl PRE_first_tail_x15_r0_body.ctab27 : PRE_first_tail_x15_r0_body.S277.tab = PRE_first_tail_x15_r0_body.S275.tab ++ PRE_first_tail_x15_r0_body.cws27.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace27 : PRE_first_tail_x15_r0_body.s277.trace = PRE_first_tail_x15_r0_body.s275.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext27 : PRE_first_tail_x15_r0_body.s277.next = 2696549
kernel_rfl PRE_first_tail_x15_r0_body.ccounters27 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.nnext) = (18748, 15842)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue27 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s276.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa27.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp27 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.tokens.all (bSN 1256) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean27 : Conv.cleanListB 18748 131072 (fun r => Nat.ble 74992 r) PRE_first_tail_x15_r0_body.s277
    (PRE_first_tail_x15_r0_body.wrB27 ++ (List.range 6).map (2696543 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs27 : bigsOutB 18748 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx = true

end Host.Load.Run.Tpl
