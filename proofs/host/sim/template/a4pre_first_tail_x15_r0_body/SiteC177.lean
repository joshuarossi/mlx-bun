import host.sim.template.a4pre_first_tail_x15_r0_body.H53
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

/-! The compaction after the merge at call site 177 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1714` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa177` into the merged state
`PRE_first_tail_x15_r0_body.s1713`. -/

def PRE_first_tail_x15_r0_body.pl177 : List Nat := [2814706, 2814542, 2814594, 2814707, 2814708, 2814544, 2814596, 2814705, 2814704, 2814703, 2814702, 2814696, 2814647, 2814698, 2814649]
def PRE_first_tail_x15_r0_body.nr177 : List Nat := [7664, 7665, 7661, 7667, 7663, 7671, 7672, 7669, 7670]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd177 : RData :=
  ⟨2814359, 2814709, Stage.setAll PTrie.nil [(2814344, 2814706), (2814345, 2814542), (2814346, 2814594), (2814347, 2814707), (2814348, 2814708), (2814349, 2814544), (2814350, 2814596), (2814351, 2814705), (2814352, 2814704), (2814353, 2814703), (2814354, 2814702), (2814355, 2814696), (2814356, 2814647), (2814357, 2814698), (2814358, 2814649)], Stage.setAll PTrie.nil [(21697, 21699), (21698, 21700), (21699, 21702), (21700, 21701)],
   21701, 21703, 18800, 18800, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7656, .ref 7664), (7657, .ref 7665), (7658, .ref 7661), (7659, .ref 7667), (7660, .ref 7663), (7661, .ref 7671), (7662, .ref 7672), (7663, .ref 7669), (7664, .ref 7670)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa177 : Map :=
  Conv.Map.compact 2814344 2814709 7656 PRE_first_tail_x15_r0_body.pl177 (PRE_first_tail_x15_r0_body.nr177.map NumV.ref) PRE_first_tail_x15_r0_body.kd177.big
    PRE_first_tail_x15_r0_body.kd177.region PRE_first_tail_x15_r0_body.kd177.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws177 : List Nat := [4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015]
noncomputable def PRE_first_tail_x15_r0_body.crs177 : List SymE := PRE_first_tail_x15_r0_body.nr177.map fun r => (nth? PRE_first_tail_x15_r0_body.S1713.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta177 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws177 PRE_first_tail_x15_r0_body.crs177
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB177 : List Nat := [2665, 2672756, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab177 : PRE_first_tail_x15_r0_body.S1714.tab = PRE_first_tail_x15_r0_body.S1712.tab ++ PRE_first_tail_x15_r0_body.cws177.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace177 : PRE_first_tail_x15_r0_body.s1714.trace = PRE_first_tail_x15_r0_body.s1712.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext177 : PRE_first_tail_x15_r0_body.s1714.next = 2814359
kernel_rfl PRE_first_tail_x15_r0_body.ccounters177 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.nnext) = (21701, 18800)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue177 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1713.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa177.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp177 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.tokens.all (bSN 7665) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean177 : Conv.cleanListB 21701 131072 (fun r => Nat.ble 86804 r) PRE_first_tail_x15_r0_body.s1714
    (PRE_first_tail_x15_r0_body.wrB177 ++ (List.range 15).map (2814344 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs177 : bigsOutB 21701 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx = true

end Host.Load.Run.Tpl
