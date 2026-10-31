import host.sim.template.a4pre_first_tail_x15_r0_body.H8
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

/-! The compaction after the merge at call site 29 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s264` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa29` into the merged state
`PRE_first_tail_x15_r0_body.s263`. -/

def PRE_first_tail_x15_r0_body.pl29 : List Nat := [2697337]
def PRE_first_tail_x15_r0_body.nr29 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd29 : RData :=
  ⟨2697328, 2697338, Stage.setAll PTrie.nil [(2697327, 2697337)], Stage.setAll PTrie.nil [],
   18768, 18768, 15859, 15859, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa29 : Map :=
  Conv.Map.compact 2697327 2697338 1294 PRE_first_tail_x15_r0_body.pl29 (PRE_first_tail_x15_r0_body.nr29.map NumV.ref) PRE_first_tail_x15_r0_body.kd29.big
    PRE_first_tail_x15_r0_body.kd29.region PRE_first_tail_x15_r0_body.kd29.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws29 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs29 : List SymE := PRE_first_tail_x15_r0_body.nr29.map fun r => (nth? PRE_first_tail_x15_r0_body.S263.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta29 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws29 PRE_first_tail_x15_r0_body.crs29
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB29 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab29 : PRE_first_tail_x15_r0_body.S264.tab = PRE_first_tail_x15_r0_body.S262.tab ++ PRE_first_tail_x15_r0_body.cws29.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace29 : PRE_first_tail_x15_r0_body.s264.trace = PRE_first_tail_x15_r0_body.s262.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext29 : PRE_first_tail_x15_r0_body.s264.next = 2697328
kernel_rfl PRE_first_tail_x15_r0_body.ccounters29 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s264.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s264.ffi).mlx.nnext) = (18768, 15859)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue29 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s263.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s264.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa29.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp29 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s264.ffi).mlx.tokens.all (bSN 1294) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean29 : Conv.cleanListB 18768 131072 (fun r => Nat.ble 75072 r) PRE_first_tail_x15_r0_body.s264
    (PRE_first_tail_x15_r0_body.wrB29 ++ (List.range 1).map (2697327 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs29 : bigsOutB 18768 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s264.ffi).mlx = true

end Host.Load.Run.Tpl
