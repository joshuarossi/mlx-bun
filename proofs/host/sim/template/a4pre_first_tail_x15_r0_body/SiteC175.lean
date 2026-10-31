import host.sim.template.a4pre_first_tail_x15_r0_body.H48
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

/-! The compaction after the merge at call site 175 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1547` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa175` into the merged state
`PRE_first_tail_x15_r0_body.s1546`. -/

def PRE_first_tail_x15_r0_body.pl175 : List Nat := []
def PRE_first_tail_x15_r0_body.nr175 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd175 : RData :=
  ⟨2812315, 2812317, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21650, 21650, 18762, 18762, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa175 : Map :=
  Conv.Map.compact 2812315 2812317 7562 PRE_first_tail_x15_r0_body.pl175 (PRE_first_tail_x15_r0_body.nr175.map NumV.ref) PRE_first_tail_x15_r0_body.kd175.big
    PRE_first_tail_x15_r0_body.kd175.region PRE_first_tail_x15_r0_body.kd175.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws175 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs175 : List SymE := PRE_first_tail_x15_r0_body.nr175.map fun r => (nth? PRE_first_tail_x15_r0_body.S1546.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta175 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws175 PRE_first_tail_x15_r0_body.crs175
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB175 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab175 : PRE_first_tail_x15_r0_body.S1547.tab = PRE_first_tail_x15_r0_body.S1545.tab ++ PRE_first_tail_x15_r0_body.cws175.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace175 : PRE_first_tail_x15_r0_body.s1547.trace = PRE_first_tail_x15_r0_body.s1545.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext175 : PRE_first_tail_x15_r0_body.s1547.next = 2812315
kernel_rfl PRE_first_tail_x15_r0_body.ccounters175 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1547.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1547.ffi).mlx.nnext) = (21650, 18762)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue175 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1546.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1547.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa175.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp175 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1547.ffi).mlx.tokens.all (bSN 7562) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean175 : Conv.cleanListB 21650 131072 (fun r => Nat.ble 86600 r) PRE_first_tail_x15_r0_body.s1547
    (PRE_first_tail_x15_r0_body.wrB175 ++ (List.range 0).map (2812315 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs175 : bigsOutB 21650 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1547.ffi).mlx = true

end Host.Load.Run.Tpl
