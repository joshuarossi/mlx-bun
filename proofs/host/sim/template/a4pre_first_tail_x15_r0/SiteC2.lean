import host.sim.template.a4pre_first_tail_x15_r0.H1
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

/-! The compaction after the merge at call site 2 of chain `PRE_first_tail_x15_r0` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0.s40` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0.kappa2` into the merged state
`PRE_first_tail_x15_r0.s39`. -/

def PRE_first_tail_x15_r0.pl2 : List Nat := []
def PRE_first_tail_x15_r0.nr2 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0.kd2 : RData :=
  ⟨2673488, 2673519, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18156, 18156, 15236, 15236, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0.kappa2 : Map :=
  Conv.Map.compact 2673488 2673519 18 PRE_first_tail_x15_r0.pl2 (PRE_first_tail_x15_r0.nr2.map NumV.ref) PRE_first_tail_x15_r0.kd2.big
    PRE_first_tail_x15_r0.kd2.region PRE_first_tail_x15_r0.kd2.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0.cws2 : List Nat := []
noncomputable def PRE_first_tail_x15_r0.crs2 : List SymE := PRE_first_tail_x15_r0.nr2.map fun r => (nth? PRE_first_tail_x15_r0.S39.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0.ctheta2 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0.cws2 PRE_first_tail_x15_r0.crs2
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0.wrB2 : List Nat := [2665]

kernel_rfl PRE_first_tail_x15_r0.ctab2 : PRE_first_tail_x15_r0.S40.tab = PRE_first_tail_x15_r0.S38.tab ++ PRE_first_tail_x15_r0.cws2.map SymE.var
kernel_rfl PRE_first_tail_x15_r0.ctrace2 : PRE_first_tail_x15_r0.s40.trace = PRE_first_tail_x15_r0.s38.trace
kernel_rfl PRE_first_tail_x15_r0.cnext2 : PRE_first_tail_x15_r0.s40.next = 2673488
kernel_rfl PRE_first_tail_x15_r0.ccounters2 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.nnext) = (18156, 15236)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0.cqueue2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s39.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.tokens.map PRE_first_tail_x15_r0.kappa2.nv
kernel_rfl PRE_first_tail_x15_r0.ctokSupp2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.tokens.all (bSN 18) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0.cclean2 : Conv.cleanListB 18156 131072 (fun r => Nat.ble 72624 r) PRE_first_tail_x15_r0.s40
    (PRE_first_tail_x15_r0.wrB2 ++ (List.range 0).map (2673488 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0.cbigs2 : bigsOutB 18156 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx = true

end Host.Load.Run.Tpl
