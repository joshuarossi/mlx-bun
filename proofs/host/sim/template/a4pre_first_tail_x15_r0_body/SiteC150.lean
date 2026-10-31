import host.sim.template.a4pre_first_tail_x15_r0_body.H45
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

/-! The compaction after the merge at call site 150 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1456` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa150` into the merged state
`PRE_first_tail_x15_r0_body.s1455`. -/

def PRE_first_tail_x15_r0_body.pl150 : List Nat := [2794091, 2793266, 2794097, 2794093, 2793268, 2794099]
def PRE_first_tail_x15_r0_body.nr150 : List Nat := [6527, 6526, 6502, 6510, 6515, 6520, 6525, 6499, 6500, 6501, 6508, 6509, 6497, 6504, 6505, 6506, 6507, 6503]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd150 : RData :=
  ⟨2792985, 2794134, Stage.setAll PTrie.nil [(2792979, 2794091), (2792980, 2793266), (2792981, 2794097), (2792982, 2794093), (2792983, 2793268), (2792984, 2794099)], Stage.setAll PTrie.nil [(21162, 21188), (21163, 21166), (21164, 21189)],
   21165, 21190, 18275, 18275, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6497, .ref 6527), (6498, .ref 6526), (6499, .ref 6502), (6500, .ref 6510), (6501, .ref 6515), (6502, .ref 6520), (6503, .ref 6525), (6504, .ref 6499), (6505, .ref 6500), (6506, .ref 6501), (6507, .ref 6508), (6508, .ref 6509), (6509, .ref 6497), (6510, .ref 6504), (6511, .ref 6505), (6512, .ref 6506), (6513, .ref 6507), (6514, .ref 6503)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa150 : Map :=
  Conv.Map.compact 2792979 2794134 6497 PRE_first_tail_x15_r0_body.pl150 (PRE_first_tail_x15_r0_body.nr150.map NumV.ref) PRE_first_tail_x15_r0_body.kd150.big
    PRE_first_tail_x15_r0_body.kd150.region PRE_first_tail_x15_r0_body.kd150.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws150 : List Nat := [3551, 3552, 3553, 3554, 3555, 3556, 3557, 3558, 3559, 3560, 3561, 3562, 3563, 3564, 3565, 3566, 3567, 3568]
noncomputable def PRE_first_tail_x15_r0_body.crs150 : List SymE := PRE_first_tail_x15_r0_body.nr150.map fun r => (nth? PRE_first_tail_x15_r0_body.S1455.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta150 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws150 PRE_first_tail_x15_r0_body.crs150
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB150 : List Nat := [2665, 2672682, 2673467, 2792153, 2792698, 2792954]

kernel_rfl PRE_first_tail_x15_r0_body.ctab150 : PRE_first_tail_x15_r0_body.S1456.tab = PRE_first_tail_x15_r0_body.S1454.tab ++ PRE_first_tail_x15_r0_body.cws150.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace150 : PRE_first_tail_x15_r0_body.s1456.trace = PRE_first_tail_x15_r0_body.s1454.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext150 : PRE_first_tail_x15_r0_body.s1456.next = 2792985
kernel_rfl PRE_first_tail_x15_r0_body.ccounters150 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi).mlx.nnext) = (21165, 18275)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue150 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1455.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa150.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp150 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi).mlx.tokens.all (bSN 6515) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean150 : Conv.cleanListB 21165 131072 (fun r => Nat.ble 84660 r) PRE_first_tail_x15_r0_body.s1456
    (PRE_first_tail_x15_r0_body.wrB150 ++ (List.range 6).map (2792979 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs150 : bigsOutB 21165 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi).mlx = true

end Host.Load.Run.Tpl
