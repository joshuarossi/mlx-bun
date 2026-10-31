import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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

/-! The compaction after the merge at call site 74 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s720` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa74` into the merged state
`PRE_first_tail_x15_r0_body.s719`. -/

def PRE_first_tail_x15_r0_body.pl74 : List Nat := [2732753]
def PRE_first_tail_x15_r0_body.nr74 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd74 : RData :=
  ⟨2732744, 2732754, Stage.setAll PTrie.nil [(2732743, 2732753)], Stage.setAll PTrie.nil [],
   19655, 19655, 16744, 16744, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa74 : Map :=
  Conv.Map.compact 2732743 2732754 3217 PRE_first_tail_x15_r0_body.pl74 (PRE_first_tail_x15_r0_body.nr74.map NumV.ref) PRE_first_tail_x15_r0_body.kd74.big
    PRE_first_tail_x15_r0_body.kd74.region PRE_first_tail_x15_r0_body.kd74.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws74 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs74 : List SymE := PRE_first_tail_x15_r0_body.nr74.map fun r => (nth? PRE_first_tail_x15_r0_body.S719.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta74 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws74 PRE_first_tail_x15_r0_body.crs74
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB74 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab74 : PRE_first_tail_x15_r0_body.S720.tab = PRE_first_tail_x15_r0_body.S718.tab ++ PRE_first_tail_x15_r0_body.cws74.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace74 : PRE_first_tail_x15_r0_body.s720.trace = PRE_first_tail_x15_r0_body.s718.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext74 : PRE_first_tail_x15_r0_body.s720.next = 2732744
kernel_rfl PRE_first_tail_x15_r0_body.ccounters74 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.nnext) = (19655, 16744)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s719.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa74.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.tokens.all (bSN 3217) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean74 : Conv.cleanListB 19655 131072 (fun r => Nat.ble 78620 r) PRE_first_tail_x15_r0_body.s720
    (PRE_first_tail_x15_r0_body.wrB74 ++ (List.range 1).map (2732743 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs74 : bigsOutB 19655 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx = true

end Host.Load.Run.Tpl
