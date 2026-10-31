import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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

/-! The compaction after the merge at call site 108 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s961` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa108` into the merged state
`PRE_first_tail_x15_r0_body.s960`. -/

def PRE_first_tail_x15_r0_body.pl108 : List Nat := [2761323, 2760498, 2761329, 2761325, 2760500, 2761331]
def PRE_first_tail_x15_r0_body.nr108 : List Nat := [4730, 4729, 4705, 4713, 4718, 4723, 4728, 4702, 4703, 4704, 4711, 4712, 4700, 4707, 4708, 4709, 4710, 4706]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd108 : RData :=
  ⟨2760217, 2761366, Stage.setAll PTrie.nil [(2760211, 2761323), (2760212, 2760498), (2760213, 2761329), (2760214, 2761325), (2760215, 2760500), (2760216, 2761331)], Stage.setAll PTrie.nil [(20340, 20366), (20341, 20344), (20342, 20367)],
   20343, 20368, 17438, 17438, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4700, .ref 4730), (4701, .ref 4729), (4702, .ref 4705), (4703, .ref 4713), (4704, .ref 4718), (4705, .ref 4723), (4706, .ref 4728), (4707, .ref 4702), (4708, .ref 4703), (4709, .ref 4704), (4710, .ref 4711), (4711, .ref 4712), (4712, .ref 4700), (4713, .ref 4707), (4714, .ref 4708), (4715, .ref 4709), (4716, .ref 4710), (4717, .ref 4706)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa108 : Map :=
  Conv.Map.compact 2760211 2761366 4700 PRE_first_tail_x15_r0_body.pl108 (PRE_first_tail_x15_r0_body.nr108.map NumV.ref) PRE_first_tail_x15_r0_body.kd108.big
    PRE_first_tail_x15_r0_body.kd108.region PRE_first_tail_x15_r0_body.kd108.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws108 : List Nat := [2834, 2835, 2836, 2837, 2838, 2839, 2840, 2841, 2842, 2843, 2844, 2845, 2846, 2847, 2848, 2849, 2850, 2851]
noncomputable def PRE_first_tail_x15_r0_body.crs108 : List SymE := PRE_first_tail_x15_r0_body.nr108.map fun r => (nth? PRE_first_tail_x15_r0_body.S960.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta108 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws108 PRE_first_tail_x15_r0_body.crs108
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB108 : List Nat := [2665, 2672579, 2673467, 2759385, 2759930, 2760186]

kernel_rfl PRE_first_tail_x15_r0_body.ctab108 : PRE_first_tail_x15_r0_body.S961.tab = PRE_first_tail_x15_r0_body.S959.tab ++ PRE_first_tail_x15_r0_body.cws108.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace108 : PRE_first_tail_x15_r0_body.s961.trace = PRE_first_tail_x15_r0_body.s959.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext108 : PRE_first_tail_x15_r0_body.s961.next = 2760217
kernel_rfl PRE_first_tail_x15_r0_body.ccounters108 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s961.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s961.ffi).mlx.nnext) = (20343, 17438)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s960.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s961.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa108.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s961.ffi).mlx.tokens.all (bSN 4718) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean108 : Conv.cleanListB 20343 131072 (fun r => Nat.ble 81372 r) PRE_first_tail_x15_r0_body.s961
    (PRE_first_tail_x15_r0_body.wrB108 ++ (List.range 6).map (2760211 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs108 : bigsOutB 20343 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s961.ffi).mlx = true

end Host.Load.Run.Tpl
