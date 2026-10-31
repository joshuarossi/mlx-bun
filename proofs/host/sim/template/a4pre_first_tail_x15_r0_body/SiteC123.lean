import host.sim.template.a4pre_first_tail_x15_r0_body.H37
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

/-! The compaction after the merge at call site 123 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1197` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa123` into the merged state
`PRE_first_tail_x15_r0_body.s1196`. -/

def PRE_first_tail_x15_r0_body.pl123 : List Nat := [2772991, 2772166, 2772997, 2772993, 2772168, 2772999]
def PRE_first_tail_x15_r0_body.nr123 : List Nat := [5372, 5371, 5347, 5355, 5360, 5365, 5370, 5344, 5345, 5346, 5353, 5354, 5342, 5349, 5350, 5351, 5352, 5348]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd123 : RData :=
  ⟨2771885, 2773034, Stage.setAll PTrie.nil [(2771879, 2772991), (2771880, 2772166), (2771881, 2772997), (2771882, 2772993), (2771883, 2772168), (2771884, 2772999)], Stage.setAll PTrie.nil [(20633, 20659), (20634, 20637), (20635, 20660)],
   20636, 20661, 17738, 17738, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5342, .ref 5372), (5343, .ref 5371), (5344, .ref 5347), (5345, .ref 5355), (5346, .ref 5360), (5347, .ref 5365), (5348, .ref 5370), (5349, .ref 5344), (5350, .ref 5345), (5351, .ref 5346), (5352, .ref 5353), (5353, .ref 5354), (5354, .ref 5342), (5355, .ref 5349), (5356, .ref 5350), (5357, .ref 5351), (5358, .ref 5352), (5359, .ref 5348)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa123 : Map :=
  Conv.Map.compact 2771879 2773034 5342 PRE_first_tail_x15_r0_body.pl123 (PRE_first_tail_x15_r0_body.nr123.map NumV.ref) PRE_first_tail_x15_r0_body.kd123.big
    PRE_first_tail_x15_r0_body.kd123.region PRE_first_tail_x15_r0_body.kd123.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws123 : List Nat := [3081, 3082, 3083, 3084, 3085, 3086, 3087, 3088, 3089, 3090, 3091, 3092, 3093, 3094, 3095, 3096, 3097, 3098]
noncomputable def PRE_first_tail_x15_r0_body.crs123 : List SymE := PRE_first_tail_x15_r0_body.nr123.map fun r => (nth? PRE_first_tail_x15_r0_body.S1196.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta123 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws123 PRE_first_tail_x15_r0_body.crs123
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB123 : List Nat := [2665, 2672615, 2673467, 2771053, 2771598, 2771854]

kernel_rfl PRE_first_tail_x15_r0_body.ctab123 : PRE_first_tail_x15_r0_body.S1197.tab = PRE_first_tail_x15_r0_body.S1195.tab ++ PRE_first_tail_x15_r0_body.cws123.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace123 : PRE_first_tail_x15_r0_body.s1197.trace = PRE_first_tail_x15_r0_body.s1195.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext123 : PRE_first_tail_x15_r0_body.s1197.next = 2771885
kernel_rfl PRE_first_tail_x15_r0_body.ccounters123 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.nnext) = (20636, 17738)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1196.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa123.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.tokens.all (bSN 5360) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean123 : Conv.cleanListB 20636 131072 (fun r => Nat.ble 82544 r) PRE_first_tail_x15_r0_body.s1197
    (PRE_first_tail_x15_r0_body.wrB123 ++ (List.range 6).map (2771879 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs123 : bigsOutB 20636 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx = true

end Host.Load.Run.Tpl
