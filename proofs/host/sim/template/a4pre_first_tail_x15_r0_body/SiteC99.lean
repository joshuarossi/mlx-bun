import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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

/-! The compaction after the merge at call site 99 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s883` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa99` into the merged state
`PRE_first_tail_x15_r0_body.s882`. -/

def PRE_first_tail_x15_r0_body.pl99 : List Nat := [2754163, 2753338, 2754169, 2754165, 2753340, 2754171]
def PRE_first_tail_x15_r0_body.nr99 : List Nat := [4346, 4345, 4321, 4329, 4334, 4339, 4344, 4318, 4319, 4320, 4327, 4328, 4316, 4323, 4324, 4325, 4326, 4322]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd99 : RData :=
  ⟨2753057, 2754206, Stage.setAll PTrie.nil [(2753051, 2754163), (2753052, 2753338), (2753053, 2754169), (2753054, 2754165), (2753055, 2753340), (2753056, 2754171)], Stage.setAll PTrie.nil [(20161, 20187), (20162, 20165), (20163, 20188)],
   20164, 20189, 17264, 17264, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4316, .ref 4346), (4317, .ref 4345), (4318, .ref 4321), (4319, .ref 4329), (4320, .ref 4334), (4321, .ref 4339), (4322, .ref 4344), (4323, .ref 4318), (4324, .ref 4319), (4325, .ref 4320), (4326, .ref 4327), (4327, .ref 4328), (4328, .ref 4316), (4329, .ref 4323), (4330, .ref 4324), (4331, .ref 4325), (4332, .ref 4326), (4333, .ref 4322)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa99 : Map :=
  Conv.Map.compact 2753051 2754206 4316 PRE_first_tail_x15_r0_body.pl99 (PRE_first_tail_x15_r0_body.nr99.map NumV.ref) PRE_first_tail_x15_r0_body.kd99.big
    PRE_first_tail_x15_r0_body.kd99.region PRE_first_tail_x15_r0_body.kd99.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws99 : List Nat := [2689, 2690, 2691, 2692, 2693, 2694, 2695, 2696, 2697, 2698, 2699, 2700, 2701, 2702, 2703, 2704, 2705, 2706]
noncomputable def PRE_first_tail_x15_r0_body.crs99 : List SymE := PRE_first_tail_x15_r0_body.nr99.map fun r => (nth? PRE_first_tail_x15_r0_body.S882.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta99 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws99 PRE_first_tail_x15_r0_body.crs99
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB99 : List Nat := [2665, 2672553, 2673467, 2752225, 2752770, 2753026]

kernel_rfl PRE_first_tail_x15_r0_body.ctab99 : PRE_first_tail_x15_r0_body.S883.tab = PRE_first_tail_x15_r0_body.S881.tab ++ PRE_first_tail_x15_r0_body.cws99.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace99 : PRE_first_tail_x15_r0_body.s883.trace = PRE_first_tail_x15_r0_body.s881.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext99 : PRE_first_tail_x15_r0_body.s883.next = 2753057
kernel_rfl PRE_first_tail_x15_r0_body.ccounters99 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx.nnext) = (20164, 17264)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s882.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa99.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx.tokens.all (bSN 4334) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean99 : Conv.cleanListB 20164 131072 (fun r => Nat.ble 80656 r) PRE_first_tail_x15_r0_body.s883
    (PRE_first_tail_x15_r0_body.wrB99 ++ (List.range 6).map (2753051 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs99 : bigsOutB 20164 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx = true

end Host.Load.Run.Tpl
