import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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

/-! The compaction after the merge at call site 86 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s762` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa86` into the merged state
`PRE_first_tail_x15_r0_body.s761`. -/

def PRE_first_tail_x15_r0_body.pl86 : List Nat := [2742165]
def PRE_first_tail_x15_r0_body.nr86 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd86 : RData :=
  ⟨2742156, 2742166, Stage.setAll PTrie.nil [(2742155, 2742165)], Stage.setAll PTrie.nil [],
   19891, 19891, 16981, 16981, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa86 : Map :=
  Conv.Map.compact 2742155 2742166 3730 PRE_first_tail_x15_r0_body.pl86 (PRE_first_tail_x15_r0_body.nr86.map NumV.ref) PRE_first_tail_x15_r0_body.kd86.big
    PRE_first_tail_x15_r0_body.kd86.region PRE_first_tail_x15_r0_body.kd86.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws86 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs86 : List SymE := PRE_first_tail_x15_r0_body.nr86.map fun r => (nth? PRE_first_tail_x15_r0_body.S761.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta86 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws86 PRE_first_tail_x15_r0_body.crs86
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB86 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab86 : PRE_first_tail_x15_r0_body.S762.tab = PRE_first_tail_x15_r0_body.S760.tab ++ PRE_first_tail_x15_r0_body.cws86.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace86 : PRE_first_tail_x15_r0_body.s762.trace = PRE_first_tail_x15_r0_body.s760.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext86 : PRE_first_tail_x15_r0_body.s762.next = 2742156
kernel_rfl PRE_first_tail_x15_r0_body.ccounters86 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.nnext) = (19891, 16981)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue86 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s761.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa86.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp86 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.tokens.all (bSN 3730) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean86 : Conv.cleanListB 19891 131072 (fun r => Nat.ble 79564 r) PRE_first_tail_x15_r0_body.s762
    (PRE_first_tail_x15_r0_body.wrB86 ++ (List.range 1).map (2742155 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs86 : bigsOutB 19891 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx = true

end Host.Load.Run.Tpl
