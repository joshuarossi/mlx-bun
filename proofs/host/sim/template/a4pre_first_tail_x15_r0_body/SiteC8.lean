import host.sim.template.a4pre_first_tail_x15_r0_body.H2
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

/-! The compaction after the merge at call site 8 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s81` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa8` into the merged state
`PRE_first_tail_x15_r0_body.s80`. -/

def PRE_first_tail_x15_r0_body.pl8 : List Nat := [2680767]
def PRE_first_tail_x15_r0_body.nr8 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd8 : RData :=
  ⟨2680758, 2680768, Stage.setAll PTrie.nil [(2680757, 2680767)], Stage.setAll PTrie.nil [],
   18353, 18353, 15448, 15448, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa8 : Map :=
  Conv.Map.compact 2680757 2680768 397 PRE_first_tail_x15_r0_body.pl8 (PRE_first_tail_x15_r0_body.nr8.map NumV.ref) PRE_first_tail_x15_r0_body.kd8.big
    PRE_first_tail_x15_r0_body.kd8.region PRE_first_tail_x15_r0_body.kd8.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws8 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs8 : List SymE := PRE_first_tail_x15_r0_body.nr8.map fun r => (nth? PRE_first_tail_x15_r0_body.S80.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta8 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws8 PRE_first_tail_x15_r0_body.crs8
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB8 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab8 : PRE_first_tail_x15_r0_body.S81.tab = PRE_first_tail_x15_r0_body.S79.tab ++ PRE_first_tail_x15_r0_body.cws8.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace8 : PRE_first_tail_x15_r0_body.s81.trace = PRE_first_tail_x15_r0_body.s79.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext8 : PRE_first_tail_x15_r0_body.s81.next = 2680758
kernel_rfl PRE_first_tail_x15_r0_body.ccounters8 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s81.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s81.ffi).mlx.nnext) = (18353, 15448)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue8 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s80.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s81.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa8.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp8 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s81.ffi).mlx.tokens.all (bSN 397) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean8 : Conv.cleanListB 18353 131072 (fun r => Nat.ble 73412 r) PRE_first_tail_x15_r0_body.s81
    (PRE_first_tail_x15_r0_body.wrB8 ++ (List.range 1).map (2680757 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs8 : bigsOutB 18353 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s81.ffi).mlx = true

end Host.Load.Run.Tpl
