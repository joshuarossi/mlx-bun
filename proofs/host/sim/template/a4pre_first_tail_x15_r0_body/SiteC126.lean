import host.sim.template.a4pre_first_tail_x15_r0_body.H38
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

/-! The compaction after the merge at call site 126 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1226` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa126` into the merged state
`PRE_first_tail_x15_r0_body.s1225`. -/

def PRE_first_tail_x15_r0_body.pl126 : List Nat := [2775247, 2774422, 2775253, 2775249, 2774424, 2775255]
def PRE_first_tail_x15_r0_body.nr126 : List Nat := [5501, 5500, 5476, 5484, 5489, 5494, 5499, 5473, 5474, 5475, 5482, 5483, 5471, 5478, 5479, 5480, 5481, 5477]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd126 : RData :=
  ⟨2774141, 2775290, Stage.setAll PTrie.nil [(2774135, 2775247), (2774136, 2774422), (2774137, 2775253), (2774138, 2775249), (2774139, 2774424), (2774140, 2775255)], Stage.setAll PTrie.nil [(20690, 20716), (20691, 20694), (20692, 20717)],
   20693, 20718, 17801, 17801, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5471, .ref 5501), (5472, .ref 5500), (5473, .ref 5476), (5474, .ref 5484), (5475, .ref 5489), (5476, .ref 5494), (5477, .ref 5499), (5478, .ref 5473), (5479, .ref 5474), (5480, .ref 5475), (5481, .ref 5482), (5482, .ref 5483), (5483, .ref 5471), (5484, .ref 5478), (5485, .ref 5479), (5486, .ref 5480), (5487, .ref 5481), (5488, .ref 5477)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa126 : Map :=
  Conv.Map.compact 2774135 2775290 5471 PRE_first_tail_x15_r0_body.pl126 (PRE_first_tail_x15_r0_body.nr126.map NumV.ref) PRE_first_tail_x15_r0_body.kd126.big
    PRE_first_tail_x15_r0_body.kd126.region PRE_first_tail_x15_r0_body.kd126.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws126 : List Nat := [3135, 3136, 3137, 3138, 3139, 3140, 3141, 3142, 3143, 3144, 3145, 3146, 3147, 3148, 3149, 3150, 3151, 3152]
noncomputable def PRE_first_tail_x15_r0_body.crs126 : List SymE := PRE_first_tail_x15_r0_body.nr126.map fun r => (nth? PRE_first_tail_x15_r0_body.S1225.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta126 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws126 PRE_first_tail_x15_r0_body.crs126
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB126 : List Nat := [2665, 2672620, 2673467, 2773309, 2773854, 2774110]

kernel_rfl PRE_first_tail_x15_r0_body.ctab126 : PRE_first_tail_x15_r0_body.S1226.tab = PRE_first_tail_x15_r0_body.S1224.tab ++ PRE_first_tail_x15_r0_body.cws126.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace126 : PRE_first_tail_x15_r0_body.s1226.trace = PRE_first_tail_x15_r0_body.s1224.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext126 : PRE_first_tail_x15_r0_body.s1226.next = 2774141
kernel_rfl PRE_first_tail_x15_r0_body.ccounters126 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.nnext) = (20693, 17801)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1225.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa126.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.tokens.all (bSN 5489) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean126 : Conv.cleanListB 20693 131072 (fun r => Nat.ble 82772 r) PRE_first_tail_x15_r0_body.s1226
    (PRE_first_tail_x15_r0_body.wrB126 ++ (List.range 6).map (2774135 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs126 : bigsOutB 20693 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx = true

end Host.Load.Run.Tpl
