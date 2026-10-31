import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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

/-! The compaction after the merge at call site 61 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s548` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa61` into the merged state
`PRE_first_tail_x15_r0_body.s547`. -/

def PRE_first_tail_x15_r0_body.pl61 : List Nat := []
def PRE_first_tail_x15_r0_body.nr61 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd61 : RData :=
  ⟨2723043, 2723045, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19412, 19412, 16503, 16503, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa61 : Map :=
  Conv.Map.compact 2723043 2723045 2687 PRE_first_tail_x15_r0_body.pl61 (PRE_first_tail_x15_r0_body.nr61.map NumV.ref) PRE_first_tail_x15_r0_body.kd61.big
    PRE_first_tail_x15_r0_body.kd61.region PRE_first_tail_x15_r0_body.kd61.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws61 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs61 : List SymE := PRE_first_tail_x15_r0_body.nr61.map fun r => (nth? PRE_first_tail_x15_r0_body.S547.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta61 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws61 PRE_first_tail_x15_r0_body.crs61
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB61 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab61 : PRE_first_tail_x15_r0_body.S548.tab = PRE_first_tail_x15_r0_body.S546.tab ++ PRE_first_tail_x15_r0_body.cws61.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace61 : PRE_first_tail_x15_r0_body.s548.trace = PRE_first_tail_x15_r0_body.s546.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext61 : PRE_first_tail_x15_r0_body.s548.next = 2723043
kernel_rfl PRE_first_tail_x15_r0_body.ccounters61 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.nnext) = (19412, 16503)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue61 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s547.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa61.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp61 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.tokens.all (bSN 2687) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean61 : Conv.cleanListB 19412 131072 (fun r => Nat.ble 77648 r) PRE_first_tail_x15_r0_body.s548
    (PRE_first_tail_x15_r0_body.wrB61 ++ (List.range 0).map (2723043 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs61 : bigsOutB 19412 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx = true

end Host.Load.Run.Tpl
