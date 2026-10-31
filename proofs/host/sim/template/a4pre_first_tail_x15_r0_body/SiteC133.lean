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

/-! The compaction after the merge at call site 133 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1178` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa133` into the merged state
`PRE_first_tail_x15_r0_body.s1177`. -/

def PRE_first_tail_x15_r0_body.pl133 : List Nat := []
def PRE_first_tail_x15_r0_body.nr133 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd133 : RData :=
  ⟨2779531, 2779533, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20828, 20828, 17925, 17925, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa133 : Map :=
  Conv.Map.compact 2779531 2779533 5765 PRE_first_tail_x15_r0_body.pl133 (PRE_first_tail_x15_r0_body.nr133.map NumV.ref) PRE_first_tail_x15_r0_body.kd133.big
    PRE_first_tail_x15_r0_body.kd133.region PRE_first_tail_x15_r0_body.kd133.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws133 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs133 : List SymE := PRE_first_tail_x15_r0_body.nr133.map fun r => (nth? PRE_first_tail_x15_r0_body.S1177.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta133 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws133 PRE_first_tail_x15_r0_body.crs133
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB133 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab133 : PRE_first_tail_x15_r0_body.S1178.tab = PRE_first_tail_x15_r0_body.S1176.tab ++ PRE_first_tail_x15_r0_body.cws133.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace133 : PRE_first_tail_x15_r0_body.s1178.trace = PRE_first_tail_x15_r0_body.s1176.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext133 : PRE_first_tail_x15_r0_body.s1178.next = 2779531
kernel_rfl PRE_first_tail_x15_r0_body.ccounters133 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext) = (20828, 17925)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1177.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa133.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.tokens.all (bSN 5765) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean133 : Conv.cleanListB 20828 131072 (fun r => Nat.ble 83312 r) PRE_first_tail_x15_r0_body.s1178
    (PRE_first_tail_x15_r0_body.wrB133 ++ (List.range 0).map (2779531 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs133 : bigsOutB 20828 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx = true

end Host.Load.Run.Tpl
