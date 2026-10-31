import host.sim.template.a4pre_first_tail_x15_r0_body.H41
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

/-! The compaction after the merge at call site 135 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1312` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa135` into the merged state
`PRE_first_tail_x15_r0_body.s1311`. -/

def PRE_first_tail_x15_r0_body.pl135 : List Nat := [2782403, 2781578, 2782409, 2782405, 2781580, 2782411]
def PRE_first_tail_x15_r0_body.nr135 : List Nat := [5885, 5884, 5860, 5868, 5873, 5878, 5883, 5857, 5858, 5859, 5866, 5867, 5855, 5862, 5863, 5864, 5865, 5861]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd135 : RData :=
  ⟨2781297, 2782446, Stage.setAll PTrie.nil [(2781291, 2782403), (2781292, 2781578), (2781293, 2782409), (2781294, 2782405), (2781295, 2781580), (2781296, 2782411)], Stage.setAll PTrie.nil [(20869, 20895), (20870, 20873), (20871, 20896)],
   20872, 20897, 17975, 17975, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5855, .ref 5885), (5856, .ref 5884), (5857, .ref 5860), (5858, .ref 5868), (5859, .ref 5873), (5860, .ref 5878), (5861, .ref 5883), (5862, .ref 5857), (5863, .ref 5858), (5864, .ref 5859), (5865, .ref 5866), (5866, .ref 5867), (5867, .ref 5855), (5868, .ref 5862), (5869, .ref 5863), (5870, .ref 5864), (5871, .ref 5865), (5872, .ref 5861)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa135 : Map :=
  Conv.Map.compact 2781291 2782446 5855 PRE_first_tail_x15_r0_body.pl135 (PRE_first_tail_x15_r0_body.nr135.map NumV.ref) PRE_first_tail_x15_r0_body.kd135.big
    PRE_first_tail_x15_r0_body.kd135.region PRE_first_tail_x15_r0_body.kd135.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws135 : List Nat := [3274, 3275, 3276, 3277, 3278, 3279, 3280, 3281, 3282, 3283, 3284, 3285, 3286, 3287, 3288, 3289, 3290, 3291]
noncomputable def PRE_first_tail_x15_r0_body.crs135 : List SymE := PRE_first_tail_x15_r0_body.nr135.map fun r => (nth? PRE_first_tail_x15_r0_body.S1311.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta135 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws135 PRE_first_tail_x15_r0_body.crs135
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB135 : List Nat := [2665, 2672646, 2673467, 2780465, 2781010, 2781266]

kernel_rfl PRE_first_tail_x15_r0_body.ctab135 : PRE_first_tail_x15_r0_body.S1312.tab = PRE_first_tail_x15_r0_body.S1310.tab ++ PRE_first_tail_x15_r0_body.cws135.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace135 : PRE_first_tail_x15_r0_body.s1312.trace = PRE_first_tail_x15_r0_body.s1310.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext135 : PRE_first_tail_x15_r0_body.s1312.next = 2781297
kernel_rfl PRE_first_tail_x15_r0_body.ccounters135 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext) = (20872, 17975)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1311.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa135.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.tokens.all (bSN 5873) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean135 : Conv.cleanListB 20872 131072 (fun r => Nat.ble 83488 r) PRE_first_tail_x15_r0_body.s1312
    (PRE_first_tail_x15_r0_body.wrB135 ++ (List.range 6).map (2781291 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs135 : bigsOutB 20872 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx = true

end Host.Load.Run.Tpl
