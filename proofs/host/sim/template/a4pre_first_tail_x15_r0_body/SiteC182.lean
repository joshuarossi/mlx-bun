import host.sim.template.a4pre_first_tail_x15_r0_body.H54
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

/-! The compaction after the merge at call site 182 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1755` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa182` into the merged state
`PRE_first_tail_x15_r0_body.s1754`. -/

def PRE_first_tail_x15_r0_body.pl182 : List Nat := [2817530]
def PRE_first_tail_x15_r0_body.nr182 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd182 : RData :=
  ⟨2817512, 2817531, Stage.setAll PTrie.nil [(2817511, 2817530)], Stage.setAll PTrie.nil [],
   21779, 21779, 18877, 18877, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa182 : Map :=
  Conv.Map.compact 2817511 2817531 7834 PRE_first_tail_x15_r0_body.pl182 (PRE_first_tail_x15_r0_body.nr182.map NumV.ref) PRE_first_tail_x15_r0_body.kd182.big
    PRE_first_tail_x15_r0_body.kd182.region PRE_first_tail_x15_r0_body.kd182.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws182 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs182 : List SymE := PRE_first_tail_x15_r0_body.nr182.map fun r => (nth? PRE_first_tail_x15_r0_body.S1754.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta182 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws182 PRE_first_tail_x15_r0_body.crs182
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB182 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab182 : PRE_first_tail_x15_r0_body.S1755.tab = PRE_first_tail_x15_r0_body.S1753.tab ++ PRE_first_tail_x15_r0_body.cws182.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace182 : PRE_first_tail_x15_r0_body.s1755.trace = PRE_first_tail_x15_r0_body.s1753.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext182 : PRE_first_tail_x15_r0_body.s1755.next = 2817512
kernel_rfl PRE_first_tail_x15_r0_body.ccounters182 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1755.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1755.ffi).mlx.nnext) = (21779, 18877)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue182 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1754.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1755.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa182.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp182 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1755.ffi).mlx.tokens.all (bSN 7834) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean182 : Conv.cleanListB 21779 131072 (fun r => Nat.ble 87116 r) PRE_first_tail_x15_r0_body.s1755
    (PRE_first_tail_x15_r0_body.wrB182 ++ (List.range 1).map (2817511 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs182 : bigsOutB 21779 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1755.ffi).mlx = true

end Host.Load.Run.Tpl
