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

/-! The compaction after the merge at call site 163 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1442` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa163` into the merged state
`PRE_first_tail_x15_r0_body.s1441`. -/

def PRE_first_tail_x15_r0_body.pl163 : List Nat := []
def PRE_first_tail_x15_r0_body.nr163 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd163 : RData :=
  ⟨2802887, 2802889, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21414, 21414, 18525, 18525, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa163 : Map :=
  Conv.Map.compact 2802887 2802889 7049 PRE_first_tail_x15_r0_body.pl163 (PRE_first_tail_x15_r0_body.nr163.map NumV.ref) PRE_first_tail_x15_r0_body.kd163.big
    PRE_first_tail_x15_r0_body.kd163.region PRE_first_tail_x15_r0_body.kd163.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws163 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs163 : List SymE := PRE_first_tail_x15_r0_body.nr163.map fun r => (nth? PRE_first_tail_x15_r0_body.S1441.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta163 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws163 PRE_first_tail_x15_r0_body.crs163
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB163 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab163 : PRE_first_tail_x15_r0_body.S1442.tab = PRE_first_tail_x15_r0_body.S1440.tab ++ PRE_first_tail_x15_r0_body.cws163.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace163 : PRE_first_tail_x15_r0_body.s1442.trace = PRE_first_tail_x15_r0_body.s1440.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext163 : PRE_first_tail_x15_r0_body.s1442.next = 2802887
kernel_rfl PRE_first_tail_x15_r0_body.ccounters163 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.nnext) = (21414, 18525)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue163 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1441.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa163.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp163 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.tokens.all (bSN 7049) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean163 : Conv.cleanListB 21414 131072 (fun r => Nat.ble 85656 r) PRE_first_tail_x15_r0_body.s1442
    (PRE_first_tail_x15_r0_body.wrB163 ++ (List.range 0).map (2802887 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs163 : bigsOutB 21414 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx = true

end Host.Load.Run.Tpl
