import host.sim.template.a4pre_first_tail_x15_r0_body.H50
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

/-! The compaction after the merge at call site 166 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1607` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa166` into the merged state
`PRE_first_tail_x15_r0_body.s1606`. -/

def PRE_first_tail_x15_r0_body.pl166 : List Nat := []
def PRE_first_tail_x15_r0_body.nr166 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd166 : RData :=
  ⟨2805513, 2805515, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21478, 21478, 18573, 18573, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa166 : Map :=
  Conv.Map.compact 2805513 2805515 7175 PRE_first_tail_x15_r0_body.pl166 (PRE_first_tail_x15_r0_body.nr166.map NumV.ref) PRE_first_tail_x15_r0_body.kd166.big
    PRE_first_tail_x15_r0_body.kd166.region PRE_first_tail_x15_r0_body.kd166.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws166 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs166 : List SymE := PRE_first_tail_x15_r0_body.nr166.map fun r => (nth? PRE_first_tail_x15_r0_body.S1606.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta166 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws166 PRE_first_tail_x15_r0_body.crs166
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB166 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab166 : PRE_first_tail_x15_r0_body.S1607.tab = PRE_first_tail_x15_r0_body.S1605.tab ++ PRE_first_tail_x15_r0_body.cws166.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace166 : PRE_first_tail_x15_r0_body.s1607.trace = PRE_first_tail_x15_r0_body.s1605.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext166 : PRE_first_tail_x15_r0_body.s1607.next = 2805513
kernel_rfl PRE_first_tail_x15_r0_body.ccounters166 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.nnext) = (21478, 18573)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue166 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1606.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa166.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp166 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.tokens.all (bSN 7175) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean166 : Conv.cleanListB 21478 131072 (fun r => Nat.ble 85912 r) PRE_first_tail_x15_r0_body.s1607
    (PRE_first_tail_x15_r0_body.wrB166 ++ (List.range 0).map (2805513 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs166 : bigsOutB 21478 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx = true

end Host.Load.Run.Tpl
