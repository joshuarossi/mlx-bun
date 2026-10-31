import host.sim.template.a4pre_first_tail_x15_r0_body.H36
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

/-! The compaction after the merge at call site 132 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1171` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa132` into the merged state
`PRE_first_tail_x15_r0_body.s1170`. -/

def PRE_first_tail_x15_r0_body.pl132 : List Nat := [2780147, 2779322, 2780153, 2780149, 2779324, 2780155]
def PRE_first_tail_x15_r0_body.nr132 : List Nat := [5756, 5755, 5731, 5739, 5744, 5749, 5754, 5728, 5729, 5730, 5737, 5738, 5726, 5733, 5734, 5735, 5736, 5732]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd132 : RData :=
  ⟨2779041, 2780190, Stage.setAll PTrie.nil [(2779035, 2780147), (2779036, 2779322), (2779037, 2780153), (2779038, 2780149), (2779039, 2779324), (2779040, 2780155)], Stage.setAll PTrie.nil [(20812, 20838), (20813, 20816), (20814, 20839)],
   20815, 20840, 17912, 17912, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5726, .ref 5756), (5727, .ref 5755), (5728, .ref 5731), (5729, .ref 5739), (5730, .ref 5744), (5731, .ref 5749), (5732, .ref 5754), (5733, .ref 5728), (5734, .ref 5729), (5735, .ref 5730), (5736, .ref 5737), (5737, .ref 5738), (5738, .ref 5726), (5739, .ref 5733), (5740, .ref 5734), (5741, .ref 5735), (5742, .ref 5736), (5743, .ref 5732)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa132 : Map :=
  Conv.Map.compact 2779035 2780190 5726 PRE_first_tail_x15_r0_body.pl132 (PRE_first_tail_x15_r0_body.nr132.map NumV.ref) PRE_first_tail_x15_r0_body.kd132.big
    PRE_first_tail_x15_r0_body.kd132.region PRE_first_tail_x15_r0_body.kd132.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws132 : List Nat := [3220, 3221, 3222, 3223, 3224, 3225, 3226, 3227, 3228, 3229, 3230, 3231, 3232, 3233, 3234, 3235, 3236, 3237]
noncomputable def PRE_first_tail_x15_r0_body.crs132 : List SymE := PRE_first_tail_x15_r0_body.nr132.map fun r => (nth? PRE_first_tail_x15_r0_body.S1170.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta132 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws132 PRE_first_tail_x15_r0_body.crs132
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB132 : List Nat := [2665, 2672641, 2673467, 2778209, 2778754, 2779010]

kernel_rfl PRE_first_tail_x15_r0_body.ctab132 : PRE_first_tail_x15_r0_body.S1171.tab = PRE_first_tail_x15_r0_body.S1169.tab ++ PRE_first_tail_x15_r0_body.cws132.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace132 : PRE_first_tail_x15_r0_body.s1171.trace = PRE_first_tail_x15_r0_body.s1169.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext132 : PRE_first_tail_x15_r0_body.s1171.next = 2779041
kernel_rfl PRE_first_tail_x15_r0_body.ccounters132 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1171.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1171.ffi).mlx.nnext) = (20815, 17912)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1170.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1171.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa132.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1171.ffi).mlx.tokens.all (bSN 5744) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean132 : Conv.cleanListB 20815 131072 (fun r => Nat.ble 83260 r) PRE_first_tail_x15_r0_body.s1171
    (PRE_first_tail_x15_r0_body.wrB132 ++ (List.range 6).map (2779035 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs132 : bigsOutB 20815 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1171.ffi).mlx = true

end Host.Load.Run.Tpl
