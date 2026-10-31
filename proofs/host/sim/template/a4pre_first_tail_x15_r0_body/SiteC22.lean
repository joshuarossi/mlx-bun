import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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

/-! The compaction after the merge at call site 22 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s206` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa22` into the merged state
`PRE_first_tail_x15_r0_body.s205`. -/

def PRE_first_tail_x15_r0_body.pl22 : List Nat := []
def PRE_first_tail_x15_r0_body.nr22 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd22 : RData :=
  ⟨2692505, 2692507, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18646, 18646, 15729, 15729, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa22 : Map :=
  Conv.Map.compact 2692505 2692507 1019 PRE_first_tail_x15_r0_body.pl22 (PRE_first_tail_x15_r0_body.nr22.map NumV.ref) PRE_first_tail_x15_r0_body.kd22.big
    PRE_first_tail_x15_r0_body.kd22.region PRE_first_tail_x15_r0_body.kd22.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws22 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs22 : List SymE := PRE_first_tail_x15_r0_body.nr22.map fun r => (nth? PRE_first_tail_x15_r0_body.S205.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta22 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws22 PRE_first_tail_x15_r0_body.crs22
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB22 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab22 : PRE_first_tail_x15_r0_body.S206.tab = PRE_first_tail_x15_r0_body.S204.tab ++ PRE_first_tail_x15_r0_body.cws22.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace22 : PRE_first_tail_x15_r0_body.s206.trace = PRE_first_tail_x15_r0_body.s204.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext22 : PRE_first_tail_x15_r0_body.s206.next = 2692505
kernel_rfl PRE_first_tail_x15_r0_body.ccounters22 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.nnext) = (18646, 15729)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue22 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s205.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa22.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp22 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.tokens.all (bSN 1019) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean22 : Conv.cleanListB 18646 131072 (fun r => Nat.ble 74584 r) PRE_first_tail_x15_r0_body.s206
    (PRE_first_tail_x15_r0_body.wrB22 ++ (List.range 0).map (2692505 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs22 : bigsOutB 18646 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx = true

end Host.Load.Run.Tpl
