import host.sim.template.a4pre_first_tail_x15_r0_body.H51
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

/-! The compaction after the merge at call site 170 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1640` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa170` into the merged state
`PRE_first_tail_x15_r0_body.s1639`. -/

def PRE_first_tail_x15_r0_body.pl170 : List Nat := [2808102]
def PRE_first_tail_x15_r0_body.nr170 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd170 : RData :=
  ⟨2808084, 2808103, Stage.setAll PTrie.nil [(2808083, 2808102)], Stage.setAll PTrie.nil [],
   21543, 21543, 18640, 18640, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa170 : Map :=
  Conv.Map.compact 2808083 2808103 7321 PRE_first_tail_x15_r0_body.pl170 (PRE_first_tail_x15_r0_body.nr170.map NumV.ref) PRE_first_tail_x15_r0_body.kd170.big
    PRE_first_tail_x15_r0_body.kd170.region PRE_first_tail_x15_r0_body.kd170.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws170 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs170 : List SymE := PRE_first_tail_x15_r0_body.nr170.map fun r => (nth? PRE_first_tail_x15_r0_body.S1639.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta170 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws170 PRE_first_tail_x15_r0_body.crs170
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB170 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab170 : PRE_first_tail_x15_r0_body.S1640.tab = PRE_first_tail_x15_r0_body.S1638.tab ++ PRE_first_tail_x15_r0_body.cws170.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace170 : PRE_first_tail_x15_r0_body.s1640.trace = PRE_first_tail_x15_r0_body.s1638.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext170 : PRE_first_tail_x15_r0_body.s1640.next = 2808084
kernel_rfl PRE_first_tail_x15_r0_body.ccounters170 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx.nnext) = (21543, 18640)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue170 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1639.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa170.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp170 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx.tokens.all (bSN 7321) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean170 : Conv.cleanListB 21543 131072 (fun r => Nat.ble 86172 r) PRE_first_tail_x15_r0_body.s1640
    (PRE_first_tail_x15_r0_body.wrB170 ++ (List.range 1).map (2808083 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs170 : bigsOutB 21543 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx = true

end Host.Load.Run.Tpl
