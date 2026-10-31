import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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

/-! The compaction after the merge at call site 159 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1408` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa159` into the merged state
`PRE_first_tail_x15_r0_body.s1407`. -/

def PRE_first_tail_x15_r0_body.pl159 : List Nat := [2801247, 2800422, 2801253, 2801249, 2800424, 2801255]
def PRE_first_tail_x15_r0_body.nr159 : List Nat := [6911, 6910, 6886, 6894, 6899, 6904, 6909, 6883, 6884, 6885, 6892, 6893, 6881, 6888, 6889, 6890, 6891, 6887]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd159 : RData :=
  ⟨2800141, 2801290, Stage.setAll PTrie.nil [(2800135, 2801247), (2800136, 2800422), (2800137, 2801253), (2800138, 2801249), (2800139, 2800424), (2800140, 2801255)], Stage.setAll PTrie.nil [(21341, 21367), (21342, 21345), (21343, 21368)],
   21344, 21369, 18449, 18449, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6881, .ref 6911), (6882, .ref 6910), (6883, .ref 6886), (6884, .ref 6894), (6885, .ref 6899), (6886, .ref 6904), (6887, .ref 6909), (6888, .ref 6883), (6889, .ref 6884), (6890, .ref 6885), (6891, .ref 6892), (6892, .ref 6893), (6893, .ref 6881), (6894, .ref 6888), (6895, .ref 6889), (6896, .ref 6890), (6897, .ref 6891), (6898, .ref 6887)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa159 : Map :=
  Conv.Map.compact 2800135 2801290 6881 PRE_first_tail_x15_r0_body.pl159 (PRE_first_tail_x15_r0_body.nr159.map NumV.ref) PRE_first_tail_x15_r0_body.kd159.big
    PRE_first_tail_x15_r0_body.kd159.region PRE_first_tail_x15_r0_body.kd159.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws159 : List Nat := [3690, 3691, 3692, 3693, 3694, 3695, 3696, 3697, 3698, 3699, 3700, 3701, 3702, 3703, 3704, 3705, 3706, 3707]
noncomputable def PRE_first_tail_x15_r0_body.crs159 : List SymE := PRE_first_tail_x15_r0_body.nr159.map fun r => (nth? PRE_first_tail_x15_r0_body.S1407.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta159 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws159 PRE_first_tail_x15_r0_body.crs159
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB159 : List Nat := [2665, 2672708, 2673467, 2799309, 2799854, 2800110]

kernel_rfl PRE_first_tail_x15_r0_body.ctab159 : PRE_first_tail_x15_r0_body.S1408.tab = PRE_first_tail_x15_r0_body.S1406.tab ++ PRE_first_tail_x15_r0_body.cws159.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace159 : PRE_first_tail_x15_r0_body.s1408.trace = PRE_first_tail_x15_r0_body.s1406.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext159 : PRE_first_tail_x15_r0_body.s1408.next = 2800141
kernel_rfl PRE_first_tail_x15_r0_body.ccounters159 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.nnext) = (21344, 18449)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue159 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1407.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa159.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp159 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.tokens.all (bSN 6899) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean159 : Conv.cleanListB 21344 131072 (fun r => Nat.ble 85376 r) PRE_first_tail_x15_r0_body.s1408
    (PRE_first_tail_x15_r0_body.wrB159 ++ (List.range 6).map (2800135 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs159 : bigsOutB 21344 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx = true

end Host.Load.Run.Tpl
