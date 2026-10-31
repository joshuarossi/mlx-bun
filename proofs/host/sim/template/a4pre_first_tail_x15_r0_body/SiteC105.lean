import host.sim.template.a4pre_first_tail_x15_r0_body.H29
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

/-! The compaction after the merge at call site 105 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s934` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa105` into the merged state
`PRE_first_tail_x15_r0_body.s933`. -/

def PRE_first_tail_x15_r0_body.pl105 : List Nat := [2758194, 2758030, 2758082, 2758195, 2758196, 2758032, 2758084, 2758193, 2758192, 2758191, 2758190, 2758184, 2758135, 2758186, 2758137]
def PRE_first_tail_x15_r0_body.nr105 : List Nat := [4586, 4587, 4583, 4589, 4585, 4593, 4594, 4591, 4592]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd105 : RData :=
  ⟨2757847, 2758197, Stage.setAll PTrie.nil [(2757832, 2758194), (2757833, 2758030), (2757834, 2758082), (2757835, 2758195), (2757836, 2758196), (2757837, 2758032), (2757838, 2758084), (2757839, 2758193), (2757840, 2758192), (2757841, 2758191), (2757842, 2758190), (2757843, 2758184), (2757844, 2758135), (2757845, 2758186), (2757846, 2758137)], Stage.setAll PTrie.nil [(20281, 20283), (20282, 20284), (20283, 20286), (20284, 20285)],
   20285, 20287, 17378, 17378, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4578, .ref 4586), (4579, .ref 4587), (4580, .ref 4583), (4581, .ref 4589), (4582, .ref 4585), (4583, .ref 4593), (4584, .ref 4594), (4585, .ref 4591), (4586, .ref 4592)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa105 : Map :=
  Conv.Map.compact 2757832 2758197 4578 PRE_first_tail_x15_r0_body.pl105 (PRE_first_tail_x15_r0_body.nr105.map NumV.ref) PRE_first_tail_x15_r0_body.kd105.big
    PRE_first_tail_x15_r0_body.kd105.region PRE_first_tail_x15_r0_body.kd105.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws105 : List Nat := [2789, 2790, 2791, 2792, 2793, 2794, 2795, 2796, 2797]
noncomputable def PRE_first_tail_x15_r0_body.crs105 : List SymE := PRE_first_tail_x15_r0_body.nr105.map fun r => (nth? PRE_first_tail_x15_r0_body.S933.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta105 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws105 PRE_first_tail_x15_r0_body.crs105
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB105 : List Nat := [2665, 2672570, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab105 : PRE_first_tail_x15_r0_body.S934.tab = PRE_first_tail_x15_r0_body.S932.tab ++ PRE_first_tail_x15_r0_body.cws105.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace105 : PRE_first_tail_x15_r0_body.s934.trace = PRE_first_tail_x15_r0_body.s932.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext105 : PRE_first_tail_x15_r0_body.s934.next = 2757847
kernel_rfl PRE_first_tail_x15_r0_body.ccounters105 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s934.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s934.ffi).mlx.nnext) = (20285, 17378)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s933.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s934.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa105.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s934.ffi).mlx.tokens.all (bSN 4587) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean105 : Conv.cleanListB 20285 131072 (fun r => Nat.ble 81140 r) PRE_first_tail_x15_r0_body.s934
    (PRE_first_tail_x15_r0_body.wrB105 ++ (List.range 15).map (2757832 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs105 : bigsOutB 20285 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s934.ffi).mlx = true

end Host.Load.Run.Tpl
