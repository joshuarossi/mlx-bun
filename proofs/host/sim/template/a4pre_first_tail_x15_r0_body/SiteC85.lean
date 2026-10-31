import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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

/-! The compaction after the merge at call site 85 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s758` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa85` into the merged state
`PRE_first_tail_x15_r0_body.s757`. -/

def PRE_first_tail_x15_r0_body.pl85 : List Nat := []
def PRE_first_tail_x15_r0_body.nr85 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd85 : RData :=
  ⟨2741867, 2741869, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19884, 19884, 16977, 16977, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa85 : Map :=
  Conv.Map.compact 2741867 2741869 3713 PRE_first_tail_x15_r0_body.pl85 (PRE_first_tail_x15_r0_body.nr85.map NumV.ref) PRE_first_tail_x15_r0_body.kd85.big
    PRE_first_tail_x15_r0_body.kd85.region PRE_first_tail_x15_r0_body.kd85.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws85 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs85 : List SymE := PRE_first_tail_x15_r0_body.nr85.map fun r => (nth? PRE_first_tail_x15_r0_body.S757.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta85 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws85 PRE_first_tail_x15_r0_body.crs85
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB85 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab85 : PRE_first_tail_x15_r0_body.S758.tab = PRE_first_tail_x15_r0_body.S756.tab ++ PRE_first_tail_x15_r0_body.cws85.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace85 : PRE_first_tail_x15_r0_body.s758.trace = PRE_first_tail_x15_r0_body.s756.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext85 : PRE_first_tail_x15_r0_body.s758.next = 2741867
kernel_rfl PRE_first_tail_x15_r0_body.ccounters85 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s758.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s758.ffi).mlx.nnext) = (19884, 16977)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue85 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s757.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s758.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa85.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp85 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s758.ffi).mlx.tokens.all (bSN 3713) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean85 : Conv.cleanListB 19884 131072 (fun r => Nat.ble 79536 r) PRE_first_tail_x15_r0_body.s758
    (PRE_first_tail_x15_r0_body.wrB85 ++ (List.range 0).map (2741867 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs85 : bigsOutB 19884 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s758.ffi).mlx = true

end Host.Load.Run.Tpl
