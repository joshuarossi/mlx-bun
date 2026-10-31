import host.sim.template.a4pre_first_tail_x15_r0_body.H19
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

/-! The compaction after the merge at call site 70 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s626` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa70` into the merged state
`PRE_first_tail_x15_r0_body.s625`. -/

def PRE_first_tail_x15_r0_body.pl70 : List Nat := []
def PRE_first_tail_x15_r0_body.nr70 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd70 : RData :=
  ⟨2730177, 2730179, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19590, 19590, 16677, 16677, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa70 : Map :=
  Conv.Map.compact 2730177 2730179 3071 PRE_first_tail_x15_r0_body.pl70 (PRE_first_tail_x15_r0_body.nr70.map NumV.ref) PRE_first_tail_x15_r0_body.kd70.big
    PRE_first_tail_x15_r0_body.kd70.region PRE_first_tail_x15_r0_body.kd70.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws70 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs70 : List SymE := PRE_first_tail_x15_r0_body.nr70.map fun r => (nth? PRE_first_tail_x15_r0_body.S625.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta70 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws70 PRE_first_tail_x15_r0_body.crs70
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB70 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab70 : PRE_first_tail_x15_r0_body.S626.tab = PRE_first_tail_x15_r0_body.S624.tab ++ PRE_first_tail_x15_r0_body.cws70.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace70 : PRE_first_tail_x15_r0_body.s626.trace = PRE_first_tail_x15_r0_body.s624.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext70 : PRE_first_tail_x15_r0_body.s626.next = 2730177
kernel_rfl PRE_first_tail_x15_r0_body.ccounters70 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s626.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s626.ffi).mlx.nnext) = (19590, 16677)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s625.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s626.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa70.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s626.ffi).mlx.tokens.all (bSN 3071) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean70 : Conv.cleanListB 19590 131072 (fun r => Nat.ble 78360 r) PRE_first_tail_x15_r0_body.s626
    (PRE_first_tail_x15_r0_body.wrB70 ++ (List.range 0).map (2730177 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs70 : bigsOutB 19590 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s626.ffi).mlx = true

end Host.Load.Run.Tpl
