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

/-! The compaction after the merge at call site 30 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s306` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa30` into the merged state
`PRE_first_tail_x15_r0_body.s305`. -/

def PRE_first_tail_x15_r0_body.pl30 : List Nat := [2699911, 2699086, 2699917, 2699913, 2699088, 2699919]
def PRE_first_tail_x15_r0_body.nr30 : List Nat := [1397, 1396, 1372, 1380, 1385, 1390, 1395, 1369, 1370, 1371, 1378, 1379, 1367, 1374, 1375, 1376, 1377, 1373]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd30 : RData :=
  ⟨2698805, 2699954, Stage.setAll PTrie.nil [(2698799, 2699911), (2698800, 2699086), (2698801, 2699917), (2698802, 2699913), (2698803, 2699088), (2698804, 2699919)], Stage.setAll PTrie.nil [(18802, 18828), (18803, 18806), (18804, 18829)],
   18805, 18830, 15905, 15905, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1367, .ref 1397), (1368, .ref 1396), (1369, .ref 1372), (1370, .ref 1380), (1371, .ref 1385), (1372, .ref 1390), (1373, .ref 1395), (1374, .ref 1369), (1375, .ref 1370), (1376, .ref 1371), (1377, .ref 1378), (1378, .ref 1379), (1379, .ref 1367), (1380, .ref 1374), (1381, .ref 1375), (1382, .ref 1376), (1383, .ref 1377), (1384, .ref 1373)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa30 : Map :=
  Conv.Map.compact 2698799 2699954 1367 PRE_first_tail_x15_r0_body.pl30 (PRE_first_tail_x15_r0_body.nr30.map NumV.ref) PRE_first_tail_x15_r0_body.kd30.big
    PRE_first_tail_x15_r0_body.kd30.region PRE_first_tail_x15_r0_body.kd30.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws30 : List Nat := [1531, 1532, 1533, 1534, 1535, 1536, 1537, 1538, 1539, 1540, 1541, 1542, 1543, 1544, 1545, 1546, 1547, 1548]
noncomputable def PRE_first_tail_x15_r0_body.crs30 : List SymE := PRE_first_tail_x15_r0_body.nr30.map fun r => (nth? PRE_first_tail_x15_r0_body.S305.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta30 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws30 PRE_first_tail_x15_r0_body.crs30
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB30 : List Nat := [2665, 2672372, 2673467, 2697973, 2698518, 2698774]

kernel_rfl PRE_first_tail_x15_r0_body.ctab30 : PRE_first_tail_x15_r0_body.S306.tab = PRE_first_tail_x15_r0_body.S304.tab ++ PRE_first_tail_x15_r0_body.cws30.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace30 : PRE_first_tail_x15_r0_body.s306.trace = PRE_first_tail_x15_r0_body.s304.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext30 : PRE_first_tail_x15_r0_body.s306.next = 2698805
kernel_rfl PRE_first_tail_x15_r0_body.ccounters30 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.nnext) = (18805, 15905)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue30 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s305.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa30.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp30 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.tokens.all (bSN 1385) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean30 : Conv.cleanListB 18805 131072 (fun r => Nat.ble 75220 r) PRE_first_tail_x15_r0_body.s306
    (PRE_first_tail_x15_r0_body.wrB30 ++ (List.range 6).map (2698799 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs30 : bigsOutB 18805 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx = true

end Host.Load.Run.Tpl
