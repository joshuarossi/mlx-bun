import host.sim.template.a4pre_first_tail_x15_r0_body.H24
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

/-! The compaction after the merge at call site 79 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s774` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa79` into the merged state
`PRE_first_tail_x15_r0_body.s773`. -/

def PRE_first_tail_x15_r0_body.pl79 : List Nat := []
def PRE_first_tail_x15_r0_body.nr79 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd79 : RData :=
  ⟨2736967, 2736969, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19762, 19762, 16866, 16866, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa79 : Map :=
  Conv.Map.compact 2736967 2736969 3458 PRE_first_tail_x15_r0_body.pl79 (PRE_first_tail_x15_r0_body.nr79.map NumV.ref) PRE_first_tail_x15_r0_body.kd79.big
    PRE_first_tail_x15_r0_body.kd79.region PRE_first_tail_x15_r0_body.kd79.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws79 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs79 : List SymE := PRE_first_tail_x15_r0_body.nr79.map fun r => (nth? PRE_first_tail_x15_r0_body.S773.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta79 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws79 PRE_first_tail_x15_r0_body.crs79
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB79 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab79 : PRE_first_tail_x15_r0_body.S774.tab = PRE_first_tail_x15_r0_body.S772.tab ++ PRE_first_tail_x15_r0_body.cws79.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace79 : PRE_first_tail_x15_r0_body.s774.trace = PRE_first_tail_x15_r0_body.s772.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext79 : PRE_first_tail_x15_r0_body.s774.next = 2736967
kernel_rfl PRE_first_tail_x15_r0_body.ccounters79 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx.nnext) = (19762, 16866)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue79 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s773.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa79.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp79 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx.tokens.all (bSN 3458) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean79 : Conv.cleanListB 19762 131072 (fun r => Nat.ble 79048 r) PRE_first_tail_x15_r0_body.s774
    (PRE_first_tail_x15_r0_body.wrB79 ++ (List.range 0).map (2736967 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs79 : bigsOutB 19762 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx = true

end Host.Load.Run.Tpl
