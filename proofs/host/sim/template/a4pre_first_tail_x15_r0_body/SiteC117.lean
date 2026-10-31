import host.sim.template.a4pre_first_tail_x15_r0_body.H32
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

/-! The compaction after the merge at call site 117 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1039` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa117` into the merged state
`PRE_first_tail_x15_r0_body.s1038`. -/

def PRE_first_tail_x15_r0_body.pl117 : List Nat := [2767606, 2767442, 2767494, 2767607, 2767608, 2767444, 2767496, 2767605, 2767604, 2767603, 2767602, 2767596, 2767547, 2767598, 2767549]
def PRE_first_tail_x15_r0_body.nr117 : List Nat := [5099, 5100, 5096, 5102, 5098, 5106, 5107, 5104, 5105]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd117 : RData :=
  ⟨2767259, 2767609, Stage.setAll PTrie.nil [(2767244, 2767606), (2767245, 2767442), (2767246, 2767494), (2767247, 2767607), (2767248, 2767608), (2767249, 2767444), (2767250, 2767496), (2767251, 2767605), (2767252, 2767604), (2767253, 2767603), (2767254, 2767602), (2767255, 2767596), (2767256, 2767547), (2767257, 2767598), (2767258, 2767549)], Stage.setAll PTrie.nil [(20517, 20519), (20518, 20520), (20519, 20522), (20520, 20521)],
   20521, 20523, 17615, 17615, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5091, .ref 5099), (5092, .ref 5100), (5093, .ref 5096), (5094, .ref 5102), (5095, .ref 5098), (5096, .ref 5106), (5097, .ref 5107), (5098, .ref 5104), (5099, .ref 5105)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa117 : Map :=
  Conv.Map.compact 2767244 2767609 5091 PRE_first_tail_x15_r0_body.pl117 (PRE_first_tail_x15_r0_body.nr117.map NumV.ref) PRE_first_tail_x15_r0_body.kd117.big
    PRE_first_tail_x15_r0_body.kd117.region PRE_first_tail_x15_r0_body.kd117.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws117 : List Nat := [2982, 2983, 2984, 2985, 2986, 2987, 2988, 2989, 2990]
noncomputable def PRE_first_tail_x15_r0_body.crs117 : List SymE := PRE_first_tail_x15_r0_body.nr117.map fun r => (nth? PRE_first_tail_x15_r0_body.S1038.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta117 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws117 PRE_first_tail_x15_r0_body.crs117
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB117 : List Nat := [2665, 2672601, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab117 : PRE_first_tail_x15_r0_body.S1039.tab = PRE_first_tail_x15_r0_body.S1037.tab ++ PRE_first_tail_x15_r0_body.cws117.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace117 : PRE_first_tail_x15_r0_body.s1039.trace = PRE_first_tail_x15_r0_body.s1037.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext117 : PRE_first_tail_x15_r0_body.s1039.next = 2767259
kernel_rfl PRE_first_tail_x15_r0_body.ccounters117 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1039.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1039.ffi).mlx.nnext) = (20521, 17615)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue117 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1038.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1039.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa117.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp117 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1039.ffi).mlx.tokens.all (bSN 5100) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean117 : Conv.cleanListB 20521 131072 (fun r => Nat.ble 82084 r) PRE_first_tail_x15_r0_body.s1039
    (PRE_first_tail_x15_r0_body.wrB117 ++ (List.range 15).map (2767244 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs117 : bigsOutB 20521 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1039.ffi).mlx = true

end Host.Load.Run.Tpl
