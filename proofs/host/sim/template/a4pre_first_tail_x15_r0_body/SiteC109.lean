import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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

/-! The compaction after the merge at call site 109 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s968` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa109` into the merged state
`PRE_first_tail_x15_r0_body.s967`. -/

def PRE_first_tail_x15_r0_body.pl109 : List Nat := []
def PRE_first_tail_x15_r0_body.nr109 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd109 : RData :=
  ⟨2760707, 2760709, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20356, 20356, 17451, 17451, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa109 : Map :=
  Conv.Map.compact 2760707 2760709 4739 PRE_first_tail_x15_r0_body.pl109 (PRE_first_tail_x15_r0_body.nr109.map NumV.ref) PRE_first_tail_x15_r0_body.kd109.big
    PRE_first_tail_x15_r0_body.kd109.region PRE_first_tail_x15_r0_body.kd109.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws109 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs109 : List SymE := PRE_first_tail_x15_r0_body.nr109.map fun r => (nth? PRE_first_tail_x15_r0_body.S967.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta109 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws109 PRE_first_tail_x15_r0_body.crs109
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB109 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab109 : PRE_first_tail_x15_r0_body.S968.tab = PRE_first_tail_x15_r0_body.S966.tab ++ PRE_first_tail_x15_r0_body.cws109.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace109 : PRE_first_tail_x15_r0_body.s968.trace = PRE_first_tail_x15_r0_body.s966.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext109 : PRE_first_tail_x15_r0_body.s968.next = 2760707
kernel_rfl PRE_first_tail_x15_r0_body.ccounters109 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s968.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s968.ffi).mlx.nnext) = (20356, 17451)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue109 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s968.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa109.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp109 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s968.ffi).mlx.tokens.all (bSN 4739) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean109 : Conv.cleanListB 20356 131072 (fun r => Nat.ble 81424 r) PRE_first_tail_x15_r0_body.s968
    (PRE_first_tail_x15_r0_body.wrB109 ++ (List.range 0).map (2760707 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs109 : bigsOutB 20356 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s968.ffi).mlx = true

end Host.Load.Run.Tpl
