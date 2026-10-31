import host.sim.template.a4pre_first_tail_x15_r0_body.H42
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

/-! The compaction after the merge at call site 139 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1349` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa139` into the merged state
`PRE_first_tail_x15_r0_body.s1348`. -/

def PRE_first_tail_x15_r0_body.pl139 : List Nat := []
def PRE_first_tail_x15_r0_body.nr139 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd139 : RData :=
  ⟨2784047, 2784049, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20942, 20942, 18051, 18051, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa139 : Map :=
  Conv.Map.compact 2784047 2784049 6023 PRE_first_tail_x15_r0_body.pl139 (PRE_first_tail_x15_r0_body.nr139.map NumV.ref) PRE_first_tail_x15_r0_body.kd139.big
    PRE_first_tail_x15_r0_body.kd139.region PRE_first_tail_x15_r0_body.kd139.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws139 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs139 : List SymE := PRE_first_tail_x15_r0_body.nr139.map fun r => (nth? PRE_first_tail_x15_r0_body.S1348.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta139 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws139 PRE_first_tail_x15_r0_body.crs139
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB139 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab139 : PRE_first_tail_x15_r0_body.S1349.tab = PRE_first_tail_x15_r0_body.S1347.tab ++ PRE_first_tail_x15_r0_body.cws139.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace139 : PRE_first_tail_x15_r0_body.s1349.trace = PRE_first_tail_x15_r0_body.s1347.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext139 : PRE_first_tail_x15_r0_body.s1349.next = 2784047
kernel_rfl PRE_first_tail_x15_r0_body.ccounters139 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.nnext) = (20942, 18051)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1348.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa139.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.tokens.all (bSN 6023) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean139 : Conv.cleanListB 20942 131072 (fun r => Nat.ble 83768 r) PRE_first_tail_x15_r0_body.s1349
    (PRE_first_tail_x15_r0_body.wrB139 ++ (List.range 0).map (2784047 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs139 : bigsOutB 20942 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx = true

end Host.Load.Run.Tpl
