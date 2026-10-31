import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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

/-! The compaction after the merge at call site 58 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s572` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa58` into the merged state
`PRE_first_tail_x15_r0_body.s571`. -/

def PRE_first_tail_x15_r0_body.pl58 : List Nat := []
def PRE_first_tail_x15_r0_body.nr58 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd58 : RData :=
  ⟨2720765, 2720767, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19354, 19354, 16440, 16440, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa58 : Map :=
  Conv.Map.compact 2720765 2720767 2558 PRE_first_tail_x15_r0_body.pl58 (PRE_first_tail_x15_r0_body.nr58.map NumV.ref) PRE_first_tail_x15_r0_body.kd58.big
    PRE_first_tail_x15_r0_body.kd58.region PRE_first_tail_x15_r0_body.kd58.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws58 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs58 : List SymE := PRE_first_tail_x15_r0_body.nr58.map fun r => (nth? PRE_first_tail_x15_r0_body.S571.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta58 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws58 PRE_first_tail_x15_r0_body.crs58
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB58 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab58 : PRE_first_tail_x15_r0_body.S572.tab = PRE_first_tail_x15_r0_body.S570.tab ++ PRE_first_tail_x15_r0_body.cws58.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace58 : PRE_first_tail_x15_r0_body.s572.trace = PRE_first_tail_x15_r0_body.s570.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext58 : PRE_first_tail_x15_r0_body.s572.next = 2720765
kernel_rfl PRE_first_tail_x15_r0_body.ccounters58 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.nnext) = (19354, 16440)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s571.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa58.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.tokens.all (bSN 2558) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean58 : Conv.cleanListB 19354 131072 (fun r => Nat.ble 77416 r) PRE_first_tail_x15_r0_body.s572
    (PRE_first_tail_x15_r0_body.wrB58 ++ (List.range 0).map (2720765 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs58 : bigsOutB 19354 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx = true

end Host.Load.Run.Tpl
