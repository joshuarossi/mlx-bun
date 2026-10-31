import host.sim.template.a4pre_first_tail_x15_r0_body.H29
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

/-! The compaction after the merge at call site 107 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s945` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa107` into the merged state
`PRE_first_tail_x15_r0_body.s944`. -/

def PRE_first_tail_x15_r0_body.pl107 : List Nat := [2758727]
def PRE_first_tail_x15_r0_body.nr107 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd107 : RData :=
  ⟨2758718, 2758728, Stage.setAll PTrie.nil [(2758717, 2758727)], Stage.setAll PTrie.nil [],
   20305, 20305, 17392, 17392, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa107 : Map :=
  Conv.Map.compact 2758717 2758728 4627 PRE_first_tail_x15_r0_body.pl107 (PRE_first_tail_x15_r0_body.nr107.map NumV.ref) PRE_first_tail_x15_r0_body.kd107.big
    PRE_first_tail_x15_r0_body.kd107.region PRE_first_tail_x15_r0_body.kd107.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws107 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs107 : List SymE := PRE_first_tail_x15_r0_body.nr107.map fun r => (nth? PRE_first_tail_x15_r0_body.S944.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta107 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws107 PRE_first_tail_x15_r0_body.crs107
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB107 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab107 : PRE_first_tail_x15_r0_body.S945.tab = PRE_first_tail_x15_r0_body.S943.tab ++ PRE_first_tail_x15_r0_body.cws107.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace107 : PRE_first_tail_x15_r0_body.s945.trace = PRE_first_tail_x15_r0_body.s943.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext107 : PRE_first_tail_x15_r0_body.s945.next = 2758718
kernel_rfl PRE_first_tail_x15_r0_body.ccounters107 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s945.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s945.ffi).mlx.nnext) = (20305, 17392)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s944.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s945.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa107.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s945.ffi).mlx.tokens.all (bSN 4627) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean107 : Conv.cleanListB 20305 131072 (fun r => Nat.ble 81220 r) PRE_first_tail_x15_r0_body.s945
    (PRE_first_tail_x15_r0_body.wrB107 ++ (List.range 1).map (2758717 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs107 : bigsOutB 20305 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s945.ffi).mlx = true

end Host.Load.Run.Tpl
