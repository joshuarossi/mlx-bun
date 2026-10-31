import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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

/-! The compaction after the merge at call site 100 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s890` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa100` into the merged state
`PRE_first_tail_x15_r0_body.s889`. -/

def PRE_first_tail_x15_r0_body.pl100 : List Nat := []
def PRE_first_tail_x15_r0_body.nr100 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd100 : RData :=
  ⟨2753547, 2753549, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20177, 20177, 17277, 17277, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa100 : Map :=
  Conv.Map.compact 2753547 2753549 4355 PRE_first_tail_x15_r0_body.pl100 (PRE_first_tail_x15_r0_body.nr100.map NumV.ref) PRE_first_tail_x15_r0_body.kd100.big
    PRE_first_tail_x15_r0_body.kd100.region PRE_first_tail_x15_r0_body.kd100.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws100 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs100 : List SymE := PRE_first_tail_x15_r0_body.nr100.map fun r => (nth? PRE_first_tail_x15_r0_body.S889.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta100 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws100 PRE_first_tail_x15_r0_body.crs100
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB100 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab100 : PRE_first_tail_x15_r0_body.S890.tab = PRE_first_tail_x15_r0_body.S888.tab ++ PRE_first_tail_x15_r0_body.cws100.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace100 : PRE_first_tail_x15_r0_body.s890.trace = PRE_first_tail_x15_r0_body.s888.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext100 : PRE_first_tail_x15_r0_body.s890.next = 2753547
kernel_rfl PRE_first_tail_x15_r0_body.ccounters100 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s890.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s890.ffi).mlx.nnext) = (20177, 17277)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue100 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s889.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s890.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa100.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp100 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s890.ffi).mlx.tokens.all (bSN 4355) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean100 : Conv.cleanListB 20177 131072 (fun r => Nat.ble 80708 r) PRE_first_tail_x15_r0_body.s890
    (PRE_first_tail_x15_r0_body.wrB100 ++ (List.range 0).map (2753547 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs100 : bigsOutB 20177 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s890.ffi).mlx = true

end Host.Load.Run.Tpl
