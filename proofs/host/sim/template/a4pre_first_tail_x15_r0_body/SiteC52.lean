import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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

/-! The compaction after the merge at call site 52 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s470` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa52` into the merged state
`PRE_first_tail_x15_r0_body.s469`. -/

def PRE_first_tail_x15_r0_body.pl52 : List Nat := []
def PRE_first_tail_x15_r0_body.nr52 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd52 : RData :=
  ⟨2715879, 2715881, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19233, 19233, 16329, 16329, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa52 : Map :=
  Conv.Map.compact 2715879 2715881 2303 PRE_first_tail_x15_r0_body.pl52 (PRE_first_tail_x15_r0_body.nr52.map NumV.ref) PRE_first_tail_x15_r0_body.kd52.big
    PRE_first_tail_x15_r0_body.kd52.region PRE_first_tail_x15_r0_body.kd52.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws52 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs52 : List SymE := PRE_first_tail_x15_r0_body.nr52.map fun r => (nth? PRE_first_tail_x15_r0_body.S469.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta52 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws52 PRE_first_tail_x15_r0_body.crs52
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB52 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab52 : PRE_first_tail_x15_r0_body.S470.tab = PRE_first_tail_x15_r0_body.S468.tab ++ PRE_first_tail_x15_r0_body.cws52.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace52 : PRE_first_tail_x15_r0_body.s470.trace = PRE_first_tail_x15_r0_body.s468.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext52 : PRE_first_tail_x15_r0_body.s470.next = 2715879
kernel_rfl PRE_first_tail_x15_r0_body.ccounters52 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s470.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s470.ffi).mlx.nnext) = (19233, 16329)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s469.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s470.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa52.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s470.ffi).mlx.tokens.all (bSN 2303) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean52 : Conv.cleanListB 19233 131072 (fun r => Nat.ble 76932 r) PRE_first_tail_x15_r0_body.s470
    (PRE_first_tail_x15_r0_body.wrB52 ++ (List.range 0).map (2715879 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs52 : bigsOutB 19233 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s470.ffi).mlx = true

end Host.Load.Run.Tpl
