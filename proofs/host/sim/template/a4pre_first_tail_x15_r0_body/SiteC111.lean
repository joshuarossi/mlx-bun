import host.sim.template.a4pre_first_tail_x15_r0_body.H33
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

/-! The compaction after the merge at call site 111 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1082` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa111` into the merged state
`PRE_first_tail_x15_r0_body.s1081`. -/

def PRE_first_tail_x15_r0_body.pl111 : List Nat := [2763579, 2762754, 2763585, 2763581, 2762756, 2763587]
def PRE_first_tail_x15_r0_body.nr111 : List Nat := [4859, 4858, 4834, 4842, 4847, 4852, 4857, 4831, 4832, 4833, 4840, 4841, 4829, 4836, 4837, 4838, 4839, 4835]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd111 : RData :=
  ⟨2762473, 2763622, Stage.setAll PTrie.nil [(2762467, 2763579), (2762468, 2762754), (2762469, 2763585), (2762470, 2763581), (2762471, 2762756), (2762472, 2763587)], Stage.setAll PTrie.nil [(20397, 20423), (20398, 20401), (20399, 20424)],
   20400, 20425, 17501, 17501, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4829, .ref 4859), (4830, .ref 4858), (4831, .ref 4834), (4832, .ref 4842), (4833, .ref 4847), (4834, .ref 4852), (4835, .ref 4857), (4836, .ref 4831), (4837, .ref 4832), (4838, .ref 4833), (4839, .ref 4840), (4840, .ref 4841), (4841, .ref 4829), (4842, .ref 4836), (4843, .ref 4837), (4844, .ref 4838), (4845, .ref 4839), (4846, .ref 4835)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa111 : Map :=
  Conv.Map.compact 2762467 2763622 4829 PRE_first_tail_x15_r0_body.pl111 (PRE_first_tail_x15_r0_body.nr111.map NumV.ref) PRE_first_tail_x15_r0_body.kd111.big
    PRE_first_tail_x15_r0_body.kd111.region PRE_first_tail_x15_r0_body.kd111.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws111 : List Nat := [2888, 2889, 2890, 2891, 2892, 2893, 2894, 2895, 2896, 2897, 2898, 2899, 2900, 2901, 2902, 2903, 2904, 2905]
noncomputable def PRE_first_tail_x15_r0_body.crs111 : List SymE := PRE_first_tail_x15_r0_body.nr111.map fun r => (nth? PRE_first_tail_x15_r0_body.S1081.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta111 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws111 PRE_first_tail_x15_r0_body.crs111
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB111 : List Nat := [2665, 2672584, 2673467, 2761641, 2762186, 2762442]

kernel_rfl PRE_first_tail_x15_r0_body.ctab111 : PRE_first_tail_x15_r0_body.S1082.tab = PRE_first_tail_x15_r0_body.S1080.tab ++ PRE_first_tail_x15_r0_body.cws111.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace111 : PRE_first_tail_x15_r0_body.s1082.trace = PRE_first_tail_x15_r0_body.s1080.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext111 : PRE_first_tail_x15_r0_body.s1082.next = 2762473
kernel_rfl PRE_first_tail_x15_r0_body.ccounters111 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi).mlx.nnext) = (20400, 17501)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue111 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1081.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa111.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp111 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi).mlx.tokens.all (bSN 4847) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean111 : Conv.cleanListB 20400 131072 (fun r => Nat.ble 81600 r) PRE_first_tail_x15_r0_body.s1082
    (PRE_first_tail_x15_r0_body.wrB111 ++ (List.range 6).map (2762467 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs111 : bigsOutB 20400 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi).mlx = true

end Host.Load.Run.Tpl
