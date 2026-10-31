import host.sim.template.a4pre_first_tail_x15_r0_body.H33
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

/-! The compaction after the merge at call site 110 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1065` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa110` into the merged state
`PRE_first_tail_x15_r0_body.s1064`. -/

def PRE_first_tail_x15_r0_body.pl110 : List Nat := [2761005]
def PRE_first_tail_x15_r0_body.nr110 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd110 : RData :=
  ⟨2760996, 2761006, Stage.setAll PTrie.nil [(2760995, 2761005)], Stage.setAll PTrie.nil [],
   20363, 20363, 17455, 17455, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa110 : Map :=
  Conv.Map.compact 2760995 2761006 4756 PRE_first_tail_x15_r0_body.pl110 (PRE_first_tail_x15_r0_body.nr110.map NumV.ref) PRE_first_tail_x15_r0_body.kd110.big
    PRE_first_tail_x15_r0_body.kd110.region PRE_first_tail_x15_r0_body.kd110.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws110 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs110 : List SymE := PRE_first_tail_x15_r0_body.nr110.map fun r => (nth? PRE_first_tail_x15_r0_body.S1064.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta110 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws110 PRE_first_tail_x15_r0_body.crs110
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB110 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab110 : PRE_first_tail_x15_r0_body.S1065.tab = PRE_first_tail_x15_r0_body.S1063.tab ++ PRE_first_tail_x15_r0_body.cws110.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace110 : PRE_first_tail_x15_r0_body.s1065.trace = PRE_first_tail_x15_r0_body.s1063.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext110 : PRE_first_tail_x15_r0_body.s1065.next = 2760996
kernel_rfl PRE_first_tail_x15_r0_body.ccounters110 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.nnext) = (20363, 17455)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue110 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1064.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa110.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp110 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.tokens.all (bSN 4756) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean110 : Conv.cleanListB 20363 131072 (fun r => Nat.ble 81452 r) PRE_first_tail_x15_r0_body.s1065
    (PRE_first_tail_x15_r0_body.wrB110 ++ (List.range 1).map (2760995 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs110 : bigsOutB 20363 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx = true

end Host.Load.Run.Tpl
