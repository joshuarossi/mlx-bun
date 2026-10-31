import host.sim.template.a4pre_first_tail_x15_r0_body.H18
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

/-! The compaction after the merge at call site 62 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s605` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa62` into the merged state
`PRE_first_tail_x15_r0_body.s604`. -/

def PRE_first_tail_x15_r0_body.pl62 : List Nat := [2723341]
def PRE_first_tail_x15_r0_body.nr62 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd62 : RData :=
  ⟨2723332, 2723342, Stage.setAll PTrie.nil [(2723331, 2723341)], Stage.setAll PTrie.nil [],
   19419, 19419, 16507, 16507, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa62 : Map :=
  Conv.Map.compact 2723331 2723342 2704 PRE_first_tail_x15_r0_body.pl62 (PRE_first_tail_x15_r0_body.nr62.map NumV.ref) PRE_first_tail_x15_r0_body.kd62.big
    PRE_first_tail_x15_r0_body.kd62.region PRE_first_tail_x15_r0_body.kd62.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws62 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs62 : List SymE := PRE_first_tail_x15_r0_body.nr62.map fun r => (nth? PRE_first_tail_x15_r0_body.S604.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta62 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws62 PRE_first_tail_x15_r0_body.crs62
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB62 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab62 : PRE_first_tail_x15_r0_body.S605.tab = PRE_first_tail_x15_r0_body.S603.tab ++ PRE_first_tail_x15_r0_body.cws62.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace62 : PRE_first_tail_x15_r0_body.s605.trace = PRE_first_tail_x15_r0_body.s603.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext62 : PRE_first_tail_x15_r0_body.s605.next = 2723332
kernel_rfl PRE_first_tail_x15_r0_body.ccounters62 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.nnext) = (19419, 16507)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue62 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s604.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa62.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp62 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.tokens.all (bSN 2704) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean62 : Conv.cleanListB 19419 131072 (fun r => Nat.ble 77676 r) PRE_first_tail_x15_r0_body.s605
    (PRE_first_tail_x15_r0_body.wrB62 ++ (List.range 1).map (2723331 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs62 : bigsOutB 19419 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx = true

end Host.Load.Run.Tpl
