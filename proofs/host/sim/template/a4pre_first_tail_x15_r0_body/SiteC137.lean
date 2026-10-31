import host.sim.template.a4pre_first_tail_x15_r0_body.H37
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

/-! The compaction after the merge at call site 137 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1209` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa137` into the merged state
`PRE_first_tail_x15_r0_body.s1208`. -/

def PRE_first_tail_x15_r0_body.pl137 : List Nat := [2782094]
def PRE_first_tail_x15_r0_body.nr137 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd137 : RData :=
  ⟨2782076, 2782095, Stage.setAll PTrie.nil [(2782075, 2782094)], Stage.setAll PTrie.nil [],
   20892, 20892, 17992, 17992, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa137 : Map :=
  Conv.Map.compact 2782075 2782095 5911 PRE_first_tail_x15_r0_body.pl137 (PRE_first_tail_x15_r0_body.nr137.map NumV.ref) PRE_first_tail_x15_r0_body.kd137.big
    PRE_first_tail_x15_r0_body.kd137.region PRE_first_tail_x15_r0_body.kd137.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws137 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs137 : List SymE := PRE_first_tail_x15_r0_body.nr137.map fun r => (nth? PRE_first_tail_x15_r0_body.S1208.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta137 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws137 PRE_first_tail_x15_r0_body.crs137
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB137 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab137 : PRE_first_tail_x15_r0_body.S1209.tab = PRE_first_tail_x15_r0_body.S1207.tab ++ PRE_first_tail_x15_r0_body.cws137.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace137 : PRE_first_tail_x15_r0_body.s1209.trace = PRE_first_tail_x15_r0_body.s1207.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext137 : PRE_first_tail_x15_r0_body.s1209.next = 2782076
kernel_rfl PRE_first_tail_x15_r0_body.ccounters137 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.nnext) = (20892, 17992)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue137 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1208.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa137.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp137 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.tokens.all (bSN 5911) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean137 : Conv.cleanListB 20892 131072 (fun r => Nat.ble 83568 r) PRE_first_tail_x15_r0_body.s1209
    (PRE_first_tail_x15_r0_body.wrB137 ++ (List.range 1).map (2782075 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs137 : bigsOutB 20892 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx = true

end Host.Load.Run.Tpl
