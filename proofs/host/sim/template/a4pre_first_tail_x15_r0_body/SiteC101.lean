import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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

/-! The compaction after the merge at call site 101 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s979` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa101` into the merged state
`PRE_first_tail_x15_r0_body.s978`. -/

def PRE_first_tail_x15_r0_body.pl101 : List Nat := [2753854]
def PRE_first_tail_x15_r0_body.nr101 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd101 : RData :=
  ⟨2753836, 2753855, Stage.setAll PTrie.nil [(2753835, 2753854)], Stage.setAll PTrie.nil [],
   20184, 20184, 17281, 17281, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa101 : Map :=
  Conv.Map.compact 2753835 2753855 4372 PRE_first_tail_x15_r0_body.pl101 (PRE_first_tail_x15_r0_body.nr101.map NumV.ref) PRE_first_tail_x15_r0_body.kd101.big
    PRE_first_tail_x15_r0_body.kd101.region PRE_first_tail_x15_r0_body.kd101.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws101 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs101 : List SymE := PRE_first_tail_x15_r0_body.nr101.map fun r => (nth? PRE_first_tail_x15_r0_body.S978.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta101 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws101 PRE_first_tail_x15_r0_body.crs101
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB101 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab101 : PRE_first_tail_x15_r0_body.S979.tab = PRE_first_tail_x15_r0_body.S977.tab ++ PRE_first_tail_x15_r0_body.cws101.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace101 : PRE_first_tail_x15_r0_body.s979.trace = PRE_first_tail_x15_r0_body.s977.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext101 : PRE_first_tail_x15_r0_body.s979.next = 2753836
kernel_rfl PRE_first_tail_x15_r0_body.ccounters101 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.nnext) = (20184, 17281)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s978.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa101.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.tokens.all (bSN 4372) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean101 : Conv.cleanListB 20184 131072 (fun r => Nat.ble 80736 r) PRE_first_tail_x15_r0_body.s979
    (PRE_first_tail_x15_r0_body.wrB101 ++ (List.range 1).map (2753835 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs101 : bigsOutB 20184 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx = true

end Host.Load.Run.Tpl
