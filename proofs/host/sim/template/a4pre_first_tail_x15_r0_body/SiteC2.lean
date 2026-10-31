import host.sim.template.a4pre_first_tail_x15_r0_body.H0
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

/-! The compaction after the merge at call site 2 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s30` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa2` into the merged state
`PRE_first_tail_x15_r0_body.s29`. -/

def PRE_first_tail_x15_r0_body.pl2 : List Nat := [2676072]
def PRE_first_tail_x15_r0_body.nr2 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd2 : RData :=
  ⟨2676054, 2676073, Stage.setAll PTrie.nil [(2676053, 2676072)], Stage.setAll PTrie.nil [],
   18233, 18233, 15322, 15322, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa2 : Map :=
  Conv.Map.compact 2676053 2676073 139 PRE_first_tail_x15_r0_body.pl2 (PRE_first_tail_x15_r0_body.nr2.map NumV.ref) PRE_first_tail_x15_r0_body.kd2.big
    PRE_first_tail_x15_r0_body.kd2.region PRE_first_tail_x15_r0_body.kd2.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws2 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs2 : List SymE := PRE_first_tail_x15_r0_body.nr2.map fun r => (nth? PRE_first_tail_x15_r0_body.S29.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta2 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws2 PRE_first_tail_x15_r0_body.crs2
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB2 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab2 : PRE_first_tail_x15_r0_body.S30.tab = PRE_first_tail_x15_r0_body.S28.tab ++ PRE_first_tail_x15_r0_body.cws2.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace2 : PRE_first_tail_x15_r0_body.s30.trace = PRE_first_tail_x15_r0_body.s28.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext2 : PRE_first_tail_x15_r0_body.s30.next = 2676054
kernel_rfl PRE_first_tail_x15_r0_body.ccounters2 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx.nnext) = (18233, 15322)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s29.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa2.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx.tokens.all (bSN 139) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean2 : Conv.cleanListB 18233 131072 (fun r => Nat.ble 72932 r) PRE_first_tail_x15_r0_body.s30
    (PRE_first_tail_x15_r0_body.wrB2 ++ (List.range 1).map (2676053 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs2 : bigsOutB 18233 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx = true

end Host.Load.Run.Tpl
