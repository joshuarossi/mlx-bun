import host.sim.template.a4pre_first_tail_x15_r0_body.H49
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

/-! The compaction after the merge at call site 162 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1571` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa162` into the merged state
`PRE_first_tail_x15_r0_body.s1570`. -/

def PRE_first_tail_x15_r0_body.pl162 : List Nat := [2803503, 2802678, 2803509, 2803505, 2802680, 2803511]
def PRE_first_tail_x15_r0_body.nr162 : List Nat := [7040, 7039, 7015, 7023, 7028, 7033, 7038, 7012, 7013, 7014, 7021, 7022, 7010, 7017, 7018, 7019, 7020, 7016]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd162 : RData :=
  ⟨2802397, 2803546, Stage.setAll PTrie.nil [(2802391, 2803503), (2802392, 2802678), (2802393, 2803509), (2802394, 2803505), (2802395, 2802680), (2802396, 2803511)], Stage.setAll PTrie.nil [(21398, 21424), (21399, 21402), (21400, 21425)],
   21401, 21426, 18512, 18512, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7010, .ref 7040), (7011, .ref 7039), (7012, .ref 7015), (7013, .ref 7023), (7014, .ref 7028), (7015, .ref 7033), (7016, .ref 7038), (7017, .ref 7012), (7018, .ref 7013), (7019, .ref 7014), (7020, .ref 7021), (7021, .ref 7022), (7022, .ref 7010), (7023, .ref 7017), (7024, .ref 7018), (7025, .ref 7019), (7026, .ref 7020), (7027, .ref 7016)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa162 : Map :=
  Conv.Map.compact 2802391 2803546 7010 PRE_first_tail_x15_r0_body.pl162 (PRE_first_tail_x15_r0_body.nr162.map NumV.ref) PRE_first_tail_x15_r0_body.kd162.big
    PRE_first_tail_x15_r0_body.kd162.region PRE_first_tail_x15_r0_body.kd162.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws162 : List Nat := [3744, 3745, 3746, 3747, 3748, 3749, 3750, 3751, 3752, 3753, 3754, 3755, 3756, 3757, 3758, 3759, 3760, 3761]
noncomputable def PRE_first_tail_x15_r0_body.crs162 : List SymE := PRE_first_tail_x15_r0_body.nr162.map fun r => (nth? PRE_first_tail_x15_r0_body.S1570.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta162 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws162 PRE_first_tail_x15_r0_body.crs162
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB162 : List Nat := [2665, 2672713, 2673467, 2801565, 2802110, 2802366]

kernel_rfl PRE_first_tail_x15_r0_body.ctab162 : PRE_first_tail_x15_r0_body.S1571.tab = PRE_first_tail_x15_r0_body.S1569.tab ++ PRE_first_tail_x15_r0_body.cws162.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace162 : PRE_first_tail_x15_r0_body.s1571.trace = PRE_first_tail_x15_r0_body.s1569.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext162 : PRE_first_tail_x15_r0_body.s1571.next = 2802397
kernel_rfl PRE_first_tail_x15_r0_body.ccounters162 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.nnext) = (21401, 18512)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue162 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1570.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa162.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp162 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.tokens.all (bSN 7028) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean162 : Conv.cleanListB 21401 131072 (fun r => Nat.ble 85604 r) PRE_first_tail_x15_r0_body.s1571
    (PRE_first_tail_x15_r0_body.wrB162 ++ (List.range 6).map (2802391 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs162 : bigsOutB 21401 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx = true

end Host.Load.Run.Tpl
