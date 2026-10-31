import host.sim.template.a4pre_first_tail_x15_r0_body.H15
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

/-! The compaction after the merge at call site 56 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s501` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa56` into the merged state
`PRE_first_tail_x15_r0_body.s500`. -/

def PRE_first_tail_x15_r0_body.pl56 : List Nat := [2718446]
def PRE_first_tail_x15_r0_body.nr56 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd56 : RData :=
  ⟨2718428, 2718447, Stage.setAll PTrie.nil [(2718427, 2718446)], Stage.setAll PTrie.nil [],
   19297, 19297, 16396, 16396, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa56 : Map :=
  Conv.Map.compact 2718427 2718447 2449 PRE_first_tail_x15_r0_body.pl56 (PRE_first_tail_x15_r0_body.nr56.map NumV.ref) PRE_first_tail_x15_r0_body.kd56.big
    PRE_first_tail_x15_r0_body.kd56.region PRE_first_tail_x15_r0_body.kd56.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws56 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs56 : List SymE := PRE_first_tail_x15_r0_body.nr56.map fun r => (nth? PRE_first_tail_x15_r0_body.S500.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta56 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws56 PRE_first_tail_x15_r0_body.crs56
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB56 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab56 : PRE_first_tail_x15_r0_body.S501.tab = PRE_first_tail_x15_r0_body.S499.tab ++ PRE_first_tail_x15_r0_body.cws56.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace56 : PRE_first_tail_x15_r0_body.s501.trace = PRE_first_tail_x15_r0_body.s499.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext56 : PRE_first_tail_x15_r0_body.s501.next = 2718428
kernel_rfl PRE_first_tail_x15_r0_body.ccounters56 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s501.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s501.ffi).mlx.nnext) = (19297, 16396)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue56 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s500.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s501.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa56.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp56 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s501.ffi).mlx.tokens.all (bSN 2449) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean56 : Conv.cleanListB 19297 131072 (fun r => Nat.ble 77188 r) PRE_first_tail_x15_r0_body.s501
    (PRE_first_tail_x15_r0_body.wrB56 ++ (List.range 1).map (2718427 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs56 : bigsOutB 19297 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s501.ffi).mlx = true

end Host.Load.Run.Tpl
