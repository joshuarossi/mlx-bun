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

/-! The compaction after the merge at call site 55 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s544` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa55` into the merged state
`PRE_first_tail_x15_r0_body.s543`. -/

def PRE_first_tail_x15_r0_body.pl55 : List Nat := []
def PRE_first_tail_x15_r0_body.nr55 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd55 : RData :=
  ⟨2718139, 2718141, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19290, 19290, 16392, 16392, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa55 : Map :=
  Conv.Map.compact 2718139 2718141 2432 PRE_first_tail_x15_r0_body.pl55 (PRE_first_tail_x15_r0_body.nr55.map NumV.ref) PRE_first_tail_x15_r0_body.kd55.big
    PRE_first_tail_x15_r0_body.kd55.region PRE_first_tail_x15_r0_body.kd55.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws55 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs55 : List SymE := PRE_first_tail_x15_r0_body.nr55.map fun r => (nth? PRE_first_tail_x15_r0_body.S543.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta55 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws55 PRE_first_tail_x15_r0_body.crs55
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB55 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab55 : PRE_first_tail_x15_r0_body.S544.tab = PRE_first_tail_x15_r0_body.S542.tab ++ PRE_first_tail_x15_r0_body.cws55.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace55 : PRE_first_tail_x15_r0_body.s544.trace = PRE_first_tail_x15_r0_body.s542.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext55 : PRE_first_tail_x15_r0_body.s544.next = 2718139
kernel_rfl PRE_first_tail_x15_r0_body.ccounters55 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.nnext) = (19290, 16392)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue55 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s543.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa55.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp55 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.tokens.all (bSN 2432) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean55 : Conv.cleanListB 19290 131072 (fun r => Nat.ble 77160 r) PRE_first_tail_x15_r0_body.s544
    (PRE_first_tail_x15_r0_body.wrB55 ++ (List.range 0).map (2718139 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs55 : bigsOutB 19290 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx = true

end Host.Load.Run.Tpl
