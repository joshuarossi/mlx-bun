import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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

/-! The compaction after the merge at call site 41 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s369` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa41` into the merged state
`PRE_first_tail_x15_r0_body.s368`. -/

def PRE_first_tail_x15_r0_body.pl41 : List Nat := [2706762]
def PRE_first_tail_x15_r0_body.nr41 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd41 : RData :=
  ⟨2706744, 2706763, Stage.setAll PTrie.nil [(2706743, 2706762)], Stage.setAll PTrie.nil [],
   19004, 19004, 16096, 16096, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa41 : Map :=
  Conv.Map.compact 2706743 2706763 1807 PRE_first_tail_x15_r0_body.pl41 (PRE_first_tail_x15_r0_body.nr41.map NumV.ref) PRE_first_tail_x15_r0_body.kd41.big
    PRE_first_tail_x15_r0_body.kd41.region PRE_first_tail_x15_r0_body.kd41.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws41 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs41 : List SymE := PRE_first_tail_x15_r0_body.nr41.map fun r => (nth? PRE_first_tail_x15_r0_body.S368.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta41 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws41 PRE_first_tail_x15_r0_body.crs41
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB41 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab41 : PRE_first_tail_x15_r0_body.S369.tab = PRE_first_tail_x15_r0_body.S367.tab ++ PRE_first_tail_x15_r0_body.cws41.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace41 : PRE_first_tail_x15_r0_body.s369.trace = PRE_first_tail_x15_r0_body.s367.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext41 : PRE_first_tail_x15_r0_body.s369.next = 2706744
kernel_rfl PRE_first_tail_x15_r0_body.ccounters41 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx.nnext) = (19004, 16096)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue41 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s368.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa41.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp41 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx.tokens.all (bSN 1807) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean41 : Conv.cleanListB 19004 131072 (fun r => Nat.ble 76016 r) PRE_first_tail_x15_r0_body.s369
    (PRE_first_tail_x15_r0_body.wrB41 ++ (List.range 1).map (2706743 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs41 : bigsOutB 19004 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx = true

end Host.Load.Run.Tpl
