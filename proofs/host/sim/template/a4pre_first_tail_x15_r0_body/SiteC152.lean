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

/-! The compaction after the merge at call site 152 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1468` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa152` into the merged state
`PRE_first_tail_x15_r0_body.s1467`. -/

def PRE_first_tail_x15_r0_body.pl152 : List Nat := [2793773]
def PRE_first_tail_x15_r0_body.nr152 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd152 : RData :=
  ⟨2793764, 2793774, Stage.setAll PTrie.nil [(2793763, 2793773)], Stage.setAll PTrie.nil [],
   21185, 21185, 18292, 18292, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa152 : Map :=
  Conv.Map.compact 2793763 2793774 6553 PRE_first_tail_x15_r0_body.pl152 (PRE_first_tail_x15_r0_body.nr152.map NumV.ref) PRE_first_tail_x15_r0_body.kd152.big
    PRE_first_tail_x15_r0_body.kd152.region PRE_first_tail_x15_r0_body.kd152.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws152 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs152 : List SymE := PRE_first_tail_x15_r0_body.nr152.map fun r => (nth? PRE_first_tail_x15_r0_body.S1467.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta152 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws152 PRE_first_tail_x15_r0_body.crs152
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB152 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab152 : PRE_first_tail_x15_r0_body.S1468.tab = PRE_first_tail_x15_r0_body.S1466.tab ++ PRE_first_tail_x15_r0_body.cws152.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace152 : PRE_first_tail_x15_r0_body.s1468.trace = PRE_first_tail_x15_r0_body.s1466.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext152 : PRE_first_tail_x15_r0_body.s1468.next = 2793764
kernel_rfl PRE_first_tail_x15_r0_body.ccounters152 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi).mlx.nnext) = (21185, 18292)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue152 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1467.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa152.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp152 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi).mlx.tokens.all (bSN 6553) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean152 : Conv.cleanListB 21185 131072 (fun r => Nat.ble 84740 r) PRE_first_tail_x15_r0_body.s1468
    (PRE_first_tail_x15_r0_body.wrB152 ++ (List.range 1).map (2793763 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs152 : bigsOutB 21185 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi).mlx = true

end Host.Load.Run.Tpl
