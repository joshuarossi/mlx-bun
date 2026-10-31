import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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

/-! The compaction after the merge at call site 47 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s461` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa47` into the merged state
`PRE_first_tail_x15_r0_body.s460`. -/

def PRE_first_tail_x15_r0_body.pl47 : List Nat := [2711644]
def PRE_first_tail_x15_r0_body.nr47 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd47 : RData :=
  ⟨2711626, 2711645, Stage.setAll PTrie.nil [(2711625, 2711644)], Stage.setAll PTrie.nil [],
   19125, 19125, 16207, 16207, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa47 : Map :=
  Conv.Map.compact 2711625 2711645 2062 PRE_first_tail_x15_r0_body.pl47 (PRE_first_tail_x15_r0_body.nr47.map NumV.ref) PRE_first_tail_x15_r0_body.kd47.big
    PRE_first_tail_x15_r0_body.kd47.region PRE_first_tail_x15_r0_body.kd47.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws47 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs47 : List SymE := PRE_first_tail_x15_r0_body.nr47.map fun r => (nth? PRE_first_tail_x15_r0_body.S460.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta47 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws47 PRE_first_tail_x15_r0_body.crs47
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB47 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab47 : PRE_first_tail_x15_r0_body.S461.tab = PRE_first_tail_x15_r0_body.S459.tab ++ PRE_first_tail_x15_r0_body.cws47.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace47 : PRE_first_tail_x15_r0_body.s461.trace = PRE_first_tail_x15_r0_body.s459.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext47 : PRE_first_tail_x15_r0_body.s461.next = 2711626
kernel_rfl PRE_first_tail_x15_r0_body.ccounters47 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext) = (19125, 16207)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s460.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa47.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.tokens.all (bSN 2062) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean47 : Conv.cleanListB 19125 131072 (fun r => Nat.ble 76500 r) PRE_first_tail_x15_r0_body.s461
    (PRE_first_tail_x15_r0_body.wrB47 ++ (List.range 1).map (2711625 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs47 : bigsOutB 19125 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx = true

end Host.Load.Run.Tpl
