import host.sim.template.a4pre_first_tail_x15_r0_body.H46
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

/-! The compaction after the merge at call site 153 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1484` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa153` into the merged state
`PRE_first_tail_x15_r0_body.s1483`. -/

def PRE_first_tail_x15_r0_body.pl153 : List Nat := [2795862, 2795698, 2795750, 2795863, 2795864, 2795700, 2795752, 2795861, 2795860, 2795859, 2795858, 2795852, 2795803, 2795854, 2795805]
def PRE_first_tail_x15_r0_body.nr153 : List Nat := [6638, 6639, 6635, 6641, 6637, 6645, 6646, 6643, 6644]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd153 : RData :=
  ⟨2795515, 2795865, Stage.setAll PTrie.nil [(2795500, 2795862), (2795501, 2795698), (2795502, 2795750), (2795503, 2795863), (2795504, 2795864), (2795505, 2795700), (2795506, 2795752), (2795507, 2795861), (2795508, 2795860), (2795509, 2795859), (2795510, 2795858), (2795511, 2795852), (2795512, 2795803), (2795513, 2795854), (2795514, 2795805)], Stage.setAll PTrie.nil [(21225, 21227), (21226, 21228), (21227, 21230), (21228, 21229)],
   21229, 21231, 18326, 18326, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6630, .ref 6638), (6631, .ref 6639), (6632, .ref 6635), (6633, .ref 6641), (6634, .ref 6637), (6635, .ref 6645), (6636, .ref 6646), (6637, .ref 6643), (6638, .ref 6644)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa153 : Map :=
  Conv.Map.compact 2795500 2795865 6630 PRE_first_tail_x15_r0_body.pl153 (PRE_first_tail_x15_r0_body.nr153.map NumV.ref) PRE_first_tail_x15_r0_body.kd153.big
    PRE_first_tail_x15_r0_body.kd153.region PRE_first_tail_x15_r0_body.kd153.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws153 : List Nat := [3591, 3592, 3593, 3594, 3595, 3596, 3597, 3598, 3599]
noncomputable def PRE_first_tail_x15_r0_body.crs153 : List SymE := PRE_first_tail_x15_r0_body.nr153.map fun r => (nth? PRE_first_tail_x15_r0_body.S1483.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta153 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws153 PRE_first_tail_x15_r0_body.crs153
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB153 : List Nat := [2665, 2672694, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab153 : PRE_first_tail_x15_r0_body.S1484.tab = PRE_first_tail_x15_r0_body.S1482.tab ++ PRE_first_tail_x15_r0_body.cws153.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace153 : PRE_first_tail_x15_r0_body.s1484.trace = PRE_first_tail_x15_r0_body.s1482.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext153 : PRE_first_tail_x15_r0_body.s1484.next = 2795515
kernel_rfl PRE_first_tail_x15_r0_body.ccounters153 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.nnext) = (21229, 18326)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue153 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1483.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa153.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp153 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.tokens.all (bSN 6639) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean153 : Conv.cleanListB 21229 131072 (fun r => Nat.ble 84916 r) PRE_first_tail_x15_r0_body.s1484
    (PRE_first_tail_x15_r0_body.wrB153 ++ (List.range 15).map (2795500 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs153 : bigsOutB 21229 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx = true

end Host.Load.Run.Tpl
