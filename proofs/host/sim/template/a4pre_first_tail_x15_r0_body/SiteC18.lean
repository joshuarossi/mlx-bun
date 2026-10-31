import host.sim.template.a4pre_first_tail_x15_r0_body.H5
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

/-! The compaction after the merge at call site 18 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s175` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa18` into the merged state
`PRE_first_tail_x15_r0_body.s174`. -/

def PRE_first_tail_x15_r0_body.pl18 : List Nat := [2690499, 2689674, 2690505, 2690501, 2689676, 2690507]
def PRE_first_tail_x15_r0_body.nr18 : List Nat := [884, 883, 859, 867, 872, 877, 882, 856, 857, 858, 865, 866, 854, 861, 862, 863, 864, 860]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd18 : RData :=
  ⟨2689393, 2690542, Stage.setAll PTrie.nil [(2689387, 2690499), (2689388, 2689674), (2689389, 2690505), (2689390, 2690501), (2689391, 2689676), (2689392, 2690507)], Stage.setAll PTrie.nil [(18566, 18592), (18567, 18570), (18568, 18593)],
   18569, 18594, 15668, 15668, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(854, .ref 884), (855, .ref 883), (856, .ref 859), (857, .ref 867), (858, .ref 872), (859, .ref 877), (860, .ref 882), (861, .ref 856), (862, .ref 857), (863, .ref 858), (864, .ref 865), (865, .ref 866), (866, .ref 854), (867, .ref 861), (868, .ref 862), (869, .ref 863), (870, .ref 864), (871, .ref 860)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa18 : Map :=
  Conv.Map.compact 2689387 2690542 854 PRE_first_tail_x15_r0_body.pl18 (PRE_first_tail_x15_r0_body.nr18.map NumV.ref) PRE_first_tail_x15_r0_body.kd18.big
    PRE_first_tail_x15_r0_body.kd18.region PRE_first_tail_x15_r0_body.kd18.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws18 : List Nat := [1338, 1339, 1340, 1341, 1342, 1343, 1344, 1345, 1346, 1347, 1348, 1349, 1350, 1351, 1352, 1353, 1354, 1355]
noncomputable def PRE_first_tail_x15_r0_body.crs18 : List SymE := PRE_first_tail_x15_r0_body.nr18.map fun r => (nth? PRE_first_tail_x15_r0_body.S174.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta18 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws18 PRE_first_tail_x15_r0_body.crs18
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB18 : List Nat := [2665, 2672341, 2673467, 2688561, 2689106, 2689362]

kernel_rfl PRE_first_tail_x15_r0_body.ctab18 : PRE_first_tail_x15_r0_body.S175.tab = PRE_first_tail_x15_r0_body.S173.tab ++ PRE_first_tail_x15_r0_body.cws18.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace18 : PRE_first_tail_x15_r0_body.s175.trace = PRE_first_tail_x15_r0_body.s173.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext18 : PRE_first_tail_x15_r0_body.s175.next = 2689393
kernel_rfl PRE_first_tail_x15_r0_body.ccounters18 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s175.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s175.ffi).mlx.nnext) = (18569, 15668)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue18 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s175.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa18.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp18 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s175.ffi).mlx.tokens.all (bSN 872) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean18 : Conv.cleanListB 18569 131072 (fun r => Nat.ble 74276 r) PRE_first_tail_x15_r0_body.s175
    (PRE_first_tail_x15_r0_body.wrB18 ++ (List.range 6).map (2689387 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs18 : bigsOutB 18569 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s175.ffi).mlx = true

end Host.Load.Run.Tpl
