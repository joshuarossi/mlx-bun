import host.sim.template.a4pre_first_tail_x15_r0_body.H36
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

/-! The compaction after the merge at call site 131 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1155` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa131` into the merged state
`PRE_first_tail_x15_r0_body.s1154`. -/

def PRE_first_tail_x15_r0_body.pl131 : List Nat := [2777551]
def PRE_first_tail_x15_r0_body.nr131 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd131 : RData :=
  ⟨2777542, 2777552, Stage.setAll PTrie.nil [(2777541, 2777551)], Stage.setAll PTrie.nil [],
   20777, 20777, 17866, 17866, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa131 : Map :=
  Conv.Map.compact 2777541 2777552 5653 PRE_first_tail_x15_r0_body.pl131 (PRE_first_tail_x15_r0_body.nr131.map NumV.ref) PRE_first_tail_x15_r0_body.kd131.big
    PRE_first_tail_x15_r0_body.kd131.region PRE_first_tail_x15_r0_body.kd131.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws131 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs131 : List SymE := PRE_first_tail_x15_r0_body.nr131.map fun r => (nth? PRE_first_tail_x15_r0_body.S1154.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta131 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws131 PRE_first_tail_x15_r0_body.crs131
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB131 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab131 : PRE_first_tail_x15_r0_body.S1155.tab = PRE_first_tail_x15_r0_body.S1153.tab ++ PRE_first_tail_x15_r0_body.cws131.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace131 : PRE_first_tail_x15_r0_body.s1155.trace = PRE_first_tail_x15_r0_body.s1153.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext131 : PRE_first_tail_x15_r0_body.s1155.next = 2777542
kernel_rfl PRE_first_tail_x15_r0_body.ccounters131 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.nnext) = (20777, 17866)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1154.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa131.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.tokens.all (bSN 5653) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean131 : Conv.cleanListB 20777 131072 (fun r => Nat.ble 83108 r) PRE_first_tail_x15_r0_body.s1155
    (PRE_first_tail_x15_r0_body.wrB131 ++ (List.range 1).map (2777541 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs131 : bigsOutB 20777 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx = true

end Host.Load.Run.Tpl
