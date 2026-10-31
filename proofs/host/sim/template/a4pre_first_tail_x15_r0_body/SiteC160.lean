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

/-! The compaction after the merge at call site 160 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1415` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa160` into the merged state
`PRE_first_tail_x15_r0_body.s1414`. -/

def PRE_first_tail_x15_r0_body.pl160 : List Nat := []
def PRE_first_tail_x15_r0_body.nr160 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd160 : RData :=
  ⟨2800631, 2800633, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21357, 21357, 18462, 18462, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa160 : Map :=
  Conv.Map.compact 2800631 2800633 6920 PRE_first_tail_x15_r0_body.pl160 (PRE_first_tail_x15_r0_body.nr160.map NumV.ref) PRE_first_tail_x15_r0_body.kd160.big
    PRE_first_tail_x15_r0_body.kd160.region PRE_first_tail_x15_r0_body.kd160.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws160 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs160 : List SymE := PRE_first_tail_x15_r0_body.nr160.map fun r => (nth? PRE_first_tail_x15_r0_body.S1414.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta160 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws160 PRE_first_tail_x15_r0_body.crs160
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB160 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab160 : PRE_first_tail_x15_r0_body.S1415.tab = PRE_first_tail_x15_r0_body.S1413.tab ++ PRE_first_tail_x15_r0_body.cws160.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace160 : PRE_first_tail_x15_r0_body.s1415.trace = PRE_first_tail_x15_r0_body.s1413.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext160 : PRE_first_tail_x15_r0_body.s1415.next = 2800631
kernel_rfl PRE_first_tail_x15_r0_body.ccounters160 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.nnext) = (21357, 18462)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue160 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1414.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa160.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp160 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.tokens.all (bSN 6920) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean160 : Conv.cleanListB 21357 131072 (fun r => Nat.ble 85428 r) PRE_first_tail_x15_r0_body.s1415
    (PRE_first_tail_x15_r0_body.wrB160 ++ (List.range 0).map (2800631 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs160 : bigsOutB 21357 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx = true

end Host.Load.Run.Tpl
